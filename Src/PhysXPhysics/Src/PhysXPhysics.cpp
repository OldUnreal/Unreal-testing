
#include "PhysXPhysics.h"

EName NAME_PhysX = NAME_None;

static volatile FLOAT SimDeltaTime = 1.f;

physx::PxPhysics* UPhysXPhysics::physXScene = NULL;
physx::PxDefaultCpuDispatcher* UPhysXPhysics::CPUDistpatcher = NULL;
UBOOL UPhysXPhysics::bEngineRunning = FALSE;
physx::PxMaterial* UPhysXPhysics::DefaultMaterial = NULL;

#if PHYSX_MULTITHREAD
FThreadLock UPhysXPhysics::SimulationMutex;
FThreadLock UPhysXPhysics::ActorListMutex;
#endif

#if STATS
FPhysXStats::FPhysXStats()
	: FStatGroup(TEXT("Physics")), RigidObjCount(this, TEXT("RigidBody Count")), RagdollObjCount(this, TEXT("Ragdoll Count")), JointObjCount(this, TEXT("Joint Count")), PhysMemUse(this, TEXT("Memory Usage"))
{}

FPhysXStats GPhysXStats;
#endif

#if !WIN32
inline void* GetNextAligned(void* Ptr)
{
	if (!(reinterpret_cast<uintptr_t>(Ptr) & 0xF))
		return Ptr;
	return reinterpret_cast<void*>((reinterpret_cast<uintptr_t>(Ptr) & ~0xF) + 0x10);
}
#endif

class UEAllocator : public physx::PxAllocatorCallback
{
public:
	void* allocate(size_t size, const char* typeName, const char* filename, int line)
	{
#if BUILD_64
		/*size += 0x10;
		STAT(GPhysXStats.PhysMemUse.Value += size);
		size_t* Result = (size_t*)malloc(size);
		*Result = size;
		return (Result + 4);*/
		return malloc(size);
#elif WIN32
		return _aligned_malloc(size, 16);
		/*size += 0x10;
		STAT(GPhysXStats.PhysMemUse.Value += size);
		size_t* Result = (size_t*)_aligned_malloc(size, 16);
		*Result = size;
		return (Result + 4);*/
#else
		size_t alignedsize = (size + 0x14);
		STAT(GPhysXStats.PhysMemUse.Value += (alignedsize & 0xFFFF));
		void* Result = appMalloc(alignedsize, PHYS_X_NAME);
		void* Aligned = GetNextAligned(((DWORD*)Result) + 1);
		*((DWORD*)Aligned - 1) = (DWORD(alignedsize & 0xFFFF) << 16) | ((BYTE*)Aligned - (BYTE*)Result);
		return Aligned;
#endif
	}
	void deallocate(void* ptr)
	{
#if BUILD_64
		/*size_t* V = ((size_t*)ptr) - 4;
		STAT(GPhysXStats.PhysMemUse.Value -= *V);
		free(V);*/
		free(ptr);
#elif WIN32
		_aligned_free(ptr);
		/*size_t* V = ((size_t*)ptr) - 4;
		STAT(GPhysXStats.PhysMemUse.Value -= *V);
		_aligned_free(V);*/
#else
		DWORD Info = *((DWORD*)ptr - 1);
		STAT(GPhysXStats.PhysMemUse.Value -= (Info >> 16));
		appFree((BYTE*)ptr - (Info & 0xFFFF));
#endif
	}
};
class UEErrorNotify : public physx::PxErrorCallback
{
public:
	void reportError(physx::PxErrorCode::Enum code, const char* message, const char* file, int line)
	{
		if (!(code & physx::PxErrorCode::eDEBUG_WARNING) && line != 230 && line != 876 && line != 878 && line != 242 && line != 934) // Don't warn about large triangles in meshes nor convex mesh points being the same!
			GWarn->Logf(PHYS_X_NAME TEXT(": %s (in %s, line %i"), appFromAnsi(message), appFromAnsi(file), line);
	}
};
class UESimulatedCallback : public physx::PxSimulationEventCallback
{
	void onConstraintBreak(physx::PxConstraintInfo* constraints, physx::PxU32 count)
	{
		// Note: Can't call event callbacks directly here as it's not running in main game thread.
		physx::PxJoint* J;
		for (physx::PxU32 i = 0; i < count; ++i)
		{
			J = (physx::PxJoint*)constraints[i].externalReference;
			if (J && J->userData)
				((FPhysXJoint*)J->userData)->NoteJointBroken();
		}
	}
	void onWake(physx::PxActor** actors, physx::PxU32 count)
	{
	}
	void onSleep(physx::PxActor** actors, physx::PxU32 count)
	{
	}
	void onContact(const physx::PxContactPairHeader& pairHeader, const physx::PxContactPair* pairs, physx::PxU32 nbPairs)
	{
		guard(UESimulatedCallback::onContact);

		if (!pairHeader.actors[0] || !pairHeader.actors[1])
			return;

		FPhysXUserDataBase* A = reinterpret_cast<FPhysXUserDataBase*>(pairHeader.actors[0]->userData);
		FPhysXUserDataBase* B = reinterpret_cast<FPhysXUserDataBase*>(pairHeader.actors[1]->userData);
		if (B && !A)
			Exchange(A, B);
		else if (!A && !B)
			return;

		static FVector BestLocation, BestNormal;
		static FLOAT BestForce;
		UBOOL bDidHit = FALSE;

		for (physx::PxU32 i = 0; i < nbPairs; ++i)
		{
			const physx::PxContactPair& P = pairs[i];
			if (!P.shapes[0] || !P.shapes[1] || P.contactCount == 0)
				continue;
			
			static physx::PxContactPairPoint Points[3];
			physx::PxU32 n = P.extractContacts(Points, 3);

			for (physx::PxU32 j = 0; j < n; ++j)
			{
				FLOAT Force = Abs(Points[j].separation) / SimDeltaTime;
				if (!bDidHit || Force > BestForce)
				{
					BestLocation = PXVectorToUE(Points[j].position);
					BestNormal = PXNormalToUE(Points[j].normal);
					BestForce = Force;
					bDidHit = TRUE;
				}
			}
		}

		if (bDidHit)
		{
			BestForce *= PXScaleToUE;
			if (A && !A->OnContact(B, BestLocation, BestNormal, BestForce) && B)
				B->OnContact(A, BestLocation, BestNormal, BestForce);
		}
		unguard;
	}
	void onTrigger(physx::PxTriggerPair* pairs, physx::PxU32 count)
	{
	}
	void onAdvance(const physx::PxRigidBody* const* bodyBuffer, const physx::PxTransform* poseBuffer, const physx::PxU32 count)
	{
	}
};

#if PHYSX_MULTITHREAD
static FWorkingThread GPhysXThread(TEXT("PhysX"));

struct FPhysXSceneWork : public FWorkQuery
{
	FPhysXScene* Scene;
	FLOAT DeltaTime;

	FPhysXSceneWork(FWorkingThread* InThread, FPhysXScene* S, FLOAT dt)
		: FWorkQuery(InThread, TEXT("PhysXScene")), Scene(S), DeltaTime(dt)
	{}
	void Main();
};
#endif

void UPhysXPhysics::StaticConstructor()
{
	guard(UPhysXPhysics::StaticConstructor);
	bEnableMultiThreading = TRUE;
	new(GetClass(), TEXT("bEnableMultiThreading"), 0)UBoolProperty(CPP_PROPERTY(bEnableMultiThreading), TEXT("Config"), (CPF_Config | CPF_Edit));
	unguard;
}

void UPhysXPhysics::InitEngine()
{
	guard(UPhysXPhysics::InitEngine);
	if (physXScene)
		appErrorf(TEXT("PhysX Physics engine already initialized!"));

	NAME_PhysX = (EName)FName(PHYS_X_NAME, FNAME_Intrinsic).GetIndex();
	GLog->Logf(NAME_PhysX, TEXT("Initializing PhysX physics engine (ver %i.%i.%i)!"), PX_PHYSICS_VERSION_MAJOR, PX_PHYSICS_VERSION_MINOR, PX_PHYSICS_VERSION_BUGFIX);

	physx::PxTolerancesScale TolScale;
	TolScale.length = 1;
	TolScale.speed = 800;
	static UEAllocator phyAlloc;
	static UEErrorNotify ErrNotify;
	physx::PxFoundation* Fund = PxCreateFoundation(PX_PHYSICS_VERSION, phyAlloc, ErrNotify);
	physXScene = PxCreatePhysics(PX_PHYSICS_VERSION, *Fund, TolScale);
	if(!PxInitExtensions(*physXScene, nullptr))
		appErrorf(TEXT("PhysX: PxInitExtensions failed!"));
	CPUDistpatcher = physx::PxDefaultCpuDispatcherCreate(1);
	if (!CPUDistpatcher)
		appErrorf(TEXT("PhysX: PxDefaultCpuDispatcherCreate failed!"));
	DefaultMaterial = physXScene->createMaterial(0.5f, 0.5f, 0.5f);

	bEngineRunning = TRUE;
	unguard;
}
void UPhysXPhysics::ExitEngine()
{
	guard(UPhysXPhysics::ExitEngine);
	bEngineRunning = FALSE;

	if (FPhysXScene::NumScenes)
		GWarn->Logf(TEXT("Shutting down PhysicsEngine while scenes are still running?"));
	
	if (physxCooker)
	{
		physxCooker->release();
		physxCooker = NULL;
	}
	if (DefaultMaterial)
	{
		DefaultMaterial->release();
		DefaultMaterial = nullptr;
	}
	if (CPUDistpatcher)
	{
		CPUDistpatcher->release();
		CPUDistpatcher = nullptr;
	}
	physXScene->release();
	physXScene = NULL;
	PxCloseExtensions();
	PxGetFoundation().release();
	GLog->Log(NAME_Exit, TEXT("Shutting down PhysX physics engine."));
	unguard;
}
UBOOL UPhysXPhysics::Exec(const TCHAR* Cmd, FOutputDevice& Out)
{
	guard(UPhysXPhysics::Exec);
	return 0;
	unguard;
}
PX_SceneBase* UPhysXPhysics::CreateScene(ULevel* Level)
{
	guard(UPhysXPhysics::CreateScene);
	FPhysXScene* NewScene = NewTagged(PHYS_X_NAME) FPhysXScene(Level, (bEnableMultiThreading != 0));
	if (!NewScene->pxScene)
	{
		delete NewScene;
		NewScene = NULL;
	}
	return NewScene;
	unguard;
}

physx::PxFilterFlags UEFilterShader(
	physx::PxFilterObjectAttributes attributes0, physx::PxFilterData filterData0,
	physx::PxFilterObjectAttributes attributes1, physx::PxFilterData filterData1,
	physx::PxPairFlags& pairFlags, const void* constantBlock, physx::PxU32 constantBlockSize)
{
	if (!filterData0.word0 && !filterData1.word0 && !(filterData0.word2 & filterData1.word1) && !(filterData1.word2 & filterData0.word1))
		return physx::PxFilterFlag::eSUPPRESS;

	//pairFlags = physx::PxPairFlag::eCONTACT_DEFAULT | physx::PxPairFlag::eNOTIFY_TOUCH_FOUND;
	pairFlags = physx::PxPairFlag::eCONTACT_DEFAULT | physx::PxPairFlag::eNOTIFY_THRESHOLD_FORCE_FOUND | physx::PxPairFlag::eNOTIFY_CONTACT_POINTS;
	return physx::PxFilterFlag::eDEFAULT;
}

DWORD FPhysXScene::NumScenes = 0;
FPhysXJoint* FPhysXScene::BrokenJoints = NULL;

FPhysXScene::FPhysXScene(ULevel* L, UBOOL bMultiThread)
	: PX_SceneBase(L), pxScene(nullptr), BSPEntity(nullptr), RemainDelta(0.f), SkippedDelta(0.f), PhysList(nullptr), NumTickables(0), ThreadProc(nullptr), bMultiThreading(bMultiThread)
{
	guard(FPhysXScene::FPhysXScene);
	FINISH_PHYSX_THREAD;
	debugf(NAME_PhysX, TEXT("New PhysX scene %p - %ls"), this, L->GetFullName());
	++NumScenes;
	physx::PxSceneDesc Desc(UPhysXPhysics::physXScene->getTolerancesScale());
	Desc.cpuDispatcher = UPhysXPhysics::CPUDistpatcher;
	Desc.filterShader = UEFilterShader;
	pxScene = UPhysXPhysics::physXScene->createScene(Desc);
	if (!pxScene)
		GWarn->Logf(NAME_PhysX, TEXT("ERROR: Failed to create Physics Scene for %ls"), L->GetFullName());
	else
	{
		guard(InitBSP);
		physx::PxTriangleMesh* MDL = CreateBSPModel(L->Model);
		if (MDL)
		{
			BSPEntity = UPhysXPhysics::physXScene->createRigidStatic(physx::PxTransform(physx::PxIdentity));
			if (BSPEntity)
			{
				physx::PxTriangleMeshGeometry BSPGeometry(MDL, physx::PxMeshScale());
				physx::PxShape* Shape = UPhysXPhysics::physXScene->createShape(BSPGeometry, &Materials(0), Materials.Num(), true, (physx::PxShapeFlag::eSCENE_QUERY_SHAPE | physx::PxShapeFlag::eSIMULATION_SHAPE));
				if (Shape)
				{
					BSPEntity->attachShape(*Shape);
					physx::PxFilterData LevelFilter(1, 1, 1, 0);
					Shape->setSimulationFilterData(LevelFilter);
					Shape->release();
				}
				pxScene->addActor(*BSPEntity);
			}
			MDL->release();
		}
		unguard;

		static UESimulatedCallback UECallback;
		pxScene->setSimulationEventCallback(&UECallback);
	}
	unguard;
}
void FPhysXScene::ShutDownScene()
{
	guard(FPhysXScene::ShutDownScene);
	debugf(NAME_PhysX, TEXT("End PhysX scene %p - %ls"), this, GetNameSafe());
#if PHYSX_MULTITHREAD
	if (ThreadProc)
		ThreadProc->Destroy();
	ThreadProc = NULL;
#endif
	unguard;
}
FPhysXScene::~FPhysXScene()
{
	guard(FPhysXScene::~FPhysXScene);

#if PHYSX_MULTITHREAD
	// VERIFY no thread still running!
	verify(ThreadProc == NULL);
#endif

	bPendingDelete = TRUE;

	FINISH_PHYSX_THREAD;
	if (BSPEntity)
	{
		BSPEntity->release();
		BSPEntity = nullptr;
	}
	if (pxScene)
	{
		pxScene->release();
		pxScene = nullptr;
	}
	for (INT i = 0; i < Materials.Num(); ++i)
		Materials(i)->release();
	--NumScenes;
	unguard;
}

void FPhysXScene::EnlistActor(FListedPhysXActor* A)
{
	FINISH_PHYSX_ACTORLIST;
	A->NextRb = PhysList;
	PhysList = A;
	++NumTickables;
}
void FPhysXScene::UnlistActor(FListedPhysXActor* A)
{
	FINISH_PHYSX_ACTORLIST;
	if (PhysList == A)
		PhysList = A->NextRb;
	else
	{
		for(FListedPhysXActor* L= PhysList; L; L=L->NextRb)
			if (L->NextRb == A)
			{
				L->NextRb = A->NextRb;
				break;
			}
	}
	A->NextRb = NULL;
	--NumTickables;
}

FListedPhysXActor::FListedPhysXActor(FPhysXScene* S)
	: NextRb(nullptr), pxScene(S)
{
	if (S)
		S->EnlistActor(this);
}
FListedPhysXActor::~FListedPhysXActor() noexcept(false)
{
	if (pxScene)
		pxScene->UnlistActor(this);
}
void FListedPhysXActor::pxSetScene(void* rb, PX_SceneBase* NewScene)
{
	if(pxScene)
		pxScene->UnlistActor(this);
	FPhysXActorBase::pxSetScene(rb, NewScene);
	pxScene = reinterpret_cast<FPhysXScene*>(NewScene);
	if (pxScene)
		pxScene->EnlistActor(this);
}
void FPhysXActorBase::pxSetScene(void* rb, PX_SceneBase* NewScene)
{
	physx::PxRigidActor* r = reinterpret_cast<physx::PxRigidActor*>(rb);
	if (r && NewScene)
	{
		FINISH_PHYSX_THREAD;
		if (r->getScene())
			r->getScene()->removeActor(*r);
		reinterpret_cast<FPhysXScene*>(NewScene)->pxScene->addActor(*r);
	}
}

constexpr FLOAT MAX_SIM_DELTA = 1.f / 40.f;
constexpr FLOAT MIN_SIM_DELTA = 1.f / 80.f;

inline void RunSubstep(FPhysXScene* S, FLOAT DeltaTime)
{
	guard_nofunc;
	{
		INT iTick = 0;
		INT iLastTickables = INDEX_NONE;
		guard(TickPhysicsObjects);
		FINISH_PHYSX_ACTORLIST;
		iLastTickables = S->NumTickables;
		for (FListedPhysXActor* L = S->PhysList; L; L = L->NextRb)
		{
			L->PhysicsTick(DeltaTime);
			++iTick;
		}
		unguardf((TEXT("(%i/%i)"), iTick, iLastTickables));
	}

	guard(RunSimulation);
	FLOAT Remain = DeltaTime + S->RemainDelta;
	INT Loops = 0;
	while (Remain > MAX_SIM_DELTA && Loops < 6)
	{
		SimDeltaTime = MAX_SIM_DELTA;
#if PHYSX_MULTITHREAD
		UPhysXPhysics::SimulationMutex.lock();
#endif
		S->pxScene->simulate(MAX_SIM_DELTA);
		S->pxScene->fetchResults(true);
#if PHYSX_MULTITHREAD
		UPhysXPhysics::SimulationMutex.unlock();
#endif
		Remain -= MAX_SIM_DELTA;
		++Loops;
	}
	if (Remain >= MIN_SIM_DELTA) // Don't allow simulate too low delta.
	{
		Remain = Min(Remain, MAX_SIM_DELTA);
		SimDeltaTime = Remain;
#if PHYSX_MULTITHREAD
		UPhysXPhysics::SimulationMutex.lock();
#endif
		S->pxScene->simulate(Remain);
		S->pxScene->fetchResults(true);
#if PHYSX_MULTITHREAD
		UPhysXPhysics::SimulationMutex.unlock();
#endif
		S->RemainDelta = 0.f;
	}
	else S->RemainDelta = Remain;
	unguard;
	unguardf_nofunc((TEXT("(%p %ls)"), S, S->GetNameSafe()));
}

#if PHYSX_MULTITHREAD
void FPhysXSceneWork::Main()
{
	guard(FPhysXSceneWork::Main);
	RunSubstep(Scene, DeltaTime);
	unguard;
}
#endif

void UPhysXPhysics::PreTick()
{
	guard(UPhysXPhysics::PreTick);
	unguard;
}

struct FBrokenPair
{
	TSafePointer<AActor> Owner;
	TSafePointer<UPXJ_BaseJoint> Joint;

	FBrokenPair(FPhysXJoint* J)
		: Owner(J->GetActorOwner()), Joint(J->GetJointOwner())
	{
	}
};
void UPhysXPhysics::Tick(FLOAT DeltaTime)
{
	guard(UPhysXPhysics::Tick);
	if (FPhysXScene::BrokenJoints)
	{
		guard(ProcessBrokenJoints);
		TArray<FBrokenPair> BrokenList;
		{
			// Lock down simulations while we gather the joint list.
			FINISH_PHYSX_THREAD;
			for (FPhysXJoint* BJ = FPhysXScene::BrokenJoints; BJ; BJ = BJ->NextBroken)
				new (BrokenList) FBrokenPair(BJ);
			FPhysXScene::BrokenJoints = NULL;
		}

		AActor* A;
		UPXJ_BaseJoint* J;
		for (INT i = 0; i < BrokenList.Num(); ++i)
		{
			A = BrokenList(i).Owner.Get();
			J = BrokenList(i).Joint.Get();
			if (J && A && !A->IsPendingKill())
				A->OnJointBroken(J);
		}
		unguard;
	}
	unguard;
}

//#include "UnRender.h"

void FPhysXScene::TickScene(FLOAT DeltaTime)
{
	guard(FPhysXScene::TickScene);
	PX_SceneBase::TickScene(DeltaTime);

#if PHYSX_MULTITHREAD
	if (bMultiThreading)
	{
		if (ThreadProc)
		{
			if (!ThreadProc->IsFinished())
			{
				SkippedDelta += DeltaTime;
				return;
			}
			ThreadProc->Destroy();
		}
		FLOAT SceneDelta = Min(DeltaTime + SkippedDelta, 0.5f);
		SkippedDelta = 0.f;
		ThreadProc = new FPhysXSceneWork(&GPhysXThread, this, SceneDelta);
	}
	else
#endif
	{
#if PHYSX_MULTITHREAD
		if (ThreadProc)
		{
			ThreadProc->Destroy();
			ThreadProc = nullptr;
		}
#endif
		RunSubstep(this, DeltaTime);
	}
#if 0
	{
		FINISH_PHYSX_THREAD;
		const physx::PxRenderBuffer& rbuf = pxScene->getRenderBuffer();
		INT nl = rbuf.getNbLines();
		const physx::PxDebugLine* dl = rbuf.getLines();
		FColor rr;
		for (INT i = 0; i < nl; ++i)
		{
			rr = *reinterpret_cast<FColor*>(dl->color0);
			new FDebugLineData(NX3vToVect(dl->pos0), NX3vToVect(dl->pos1), rr.Plane());
		}
	}
#endif
	unguard;
}

IMPLEMENT_PACKAGE(PhysXPhysics);
IMPLEMENT_CLASS(UPhysXPhysics);
