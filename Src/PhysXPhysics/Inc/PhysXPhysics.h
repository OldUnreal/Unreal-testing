
#include "PxPhysicsAPI.h"
#include "Engine.h"

#ifndef PHYSXPHYSICS_API
	#define PHYSXPHYSICS_API DLL_IMPORT
#endif

#define PHYS_X_NAME TEXT("PhysX")

#if DISABLE_MULTITHREADING
#define PHYSX_MULTITHREAD 0
#else
#define PHYSX_MULTITHREAD 1
#endif

#if PHYSX_MULTITHREAD
#define FINISH_PHYSX_THREAD FScopeThread<FThreadLock> PhysXScope(UPhysXPhysics::SimulationMutex)
#define FINISH_PHYSX_ACTORLIST FScopeThread<FThreadLock> PhysXScope(UPhysXPhysics::ActorListMutex)
#else
#define FINISH_PHYSX_THREAD 
#define FINISH_PHYSX_ACTORLIST 
#endif

typedef physx::PxArticulationReducedCoordinate PhysXArtBodyType;
typedef physx::PxArticulationLink PhysXArtLinkType;

struct FPhysXScene;

#define PXScaleToUE 20.f
#define UEScaleToPX 0.05f
#define PXMassToUE 50.f
#define UEMassToPX 0.02f

inline physx::PxVec3 UEVectorToPX(const FVector& V)
{
	return physx::PxVec3(V.X * UEScaleToPX, V.Y * UEScaleToPX, V.Z * UEScaleToPX);
}
inline FVector PXVectorToUE(const physx::PxVec3& t)
{
	return FVector(t.x * PXScaleToUE, t.y * PXScaleToUE, t.z * PXScaleToUE);
}

inline physx::PxVec3 UENormalToPX(const FVector& V)
{
	return physx::PxVec3(V.X, V.Y, V.Z);
}
inline FVector PXNormalToUE(const physx::PxVec3& t)
{
	return FVector(t.x, t.y, t.z);
}

inline physx::PxTransform UECoordsToPX(const FVector& Point, const FRotator& Rot)
{
	FCoords C = GMath.UnitCoords / Rot;
#if VECTOR_ALIGNMENT==16
	return physx::PxTransform(UEVectorToPX(Point), physx::PxQuat(physx::PxMat33(UENormalToPX(C.XAxis), UENormalToPX(C.YAxis), UENormalToPX(C.ZAxis))));
#else
	return physx::PxTransform(UEVectorToPX(Point), physx::PxQuat(physx::PxMat33(&C.XAxis.X)));
#endif
}
inline physx::PxTransform UECoordsToPX(const FCoords& C)
{
#if VECTOR_ALIGNMENT==16
	return physx::PxTransform(UEVectorToPX(C.Origin), physx::PxQuat(physx::PxMat33(UENormalToPX(C.XAxis), UENormalToPX(C.YAxis), UENormalToPX(C.ZAxis))));
#else
	return physx::PxTransform(UEVectorToPX(C.Origin), physx::PxQuat(physx::PxMat33(const_cast<FLOAT*>(&C.XAxis.X))));
#endif
}
inline FCoords PXCoordsToUE(const physx::PxTransform& m)
{
	physx::PxMat33 mx(m.q);
	return FCoords(PXVectorToUE(m.p), PXNormalToUE(mx.column0), PXNormalToUE(mx.column1), PXNormalToUE(mx.column2));
}
inline FQuat PXCoordsToUEQuat(const physx::PxTransform& m)
{
	return FQuat(m.q.x, m.q.y, m.q.z, m.q.w);
}
inline physx::PxQuat UERotatorToPX(const FRotator& Rot)
{
	FCoords C = GMath.UnitCoords / Rot;
#if VECTOR_ALIGNMENT==16
	return physx::PxQuat(physx::PxMat33(UENormalToPX(C.XAxis), UENormalToPX(C.YAxis), UENormalToPX(C.ZAxis)));
#else
	return physx::PxQuat(physx::PxMat33(&C.XAxis.X));
#endif
}

extern EName NAME_PhysX;

class UEMemoryStreamer : public physx::PxOutputStream, public physx::PxInputStream
{
private:
	TArray<BYTE> Buffer;
	INT ReadOffset;

public:
	UEMemoryStreamer()
		: ReadOffset(0)
	{}

	inline void Reset()
	{
		Buffer.Empty();
		ReadOffset = 0;
	}

	// Loading API
	uint32_t read(void* dest, uint32_t count);

	// Saving API
	uint32_t write(const void* src, uint32_t count);
};

class PHYSXPHYSICS_API UPhysXPhysics : public UPhysicsEngine
{
public:
	static physx::PxPhysics* physXScene;
	static UBOOL bEngineRunning;
	static physx::PxCooking* physxCooker;
	static UPhysXPhysics* GPhysEngine;
	static physx::PxDefaultCpuDispatcher* CPUDistpatcher;
	static physx::PxMaterial* DefaultMaterial;
#if PHYSX_MULTITHREAD
	static FThreadLock SimulationMutex;
	static FThreadLock ActorListMutex;
#endif
	BITFIELD bEnableMultiThreading;

	DECLARE_CLASS(UPhysXPhysics, UPhysicsEngine, CLASS_Transient | CLASS_Config, PhysXPhysics)

	void StaticConstructor();

	virtual void InitEngine();
	virtual void ExitEngine();

	static physx::PxCooking* GetCooker();

	void Tick(FLOAT DeltaTime) override;
	void PreTick() override;

	UBOOL Exec(const TCHAR* Cmd, FOutputDevice& Out = *GLog) override;
	PX_SceneBase* CreateScene(ULevel* Level) override;

	// Physics mesh creation.
	PX_MeshShape* CreateConvexMesh(FVector* Ptr, INT NumPts, UBOOL bMayMirror) override;
	PX_MeshShape* CreateMultiConvexMesh(struct FConvexModel* ConvexMesh, UBOOL bMayMirror) override;
	PX_MeshShape* CreateTrisMesh(FVector* Ptr, INT NumPts, DWORD* Tris, INT NumTris, UBOOL bMayMirror) override;

	// Shape creation.
	PX_ShapeObject* CreateBoxShape(const FShapeProperties& Props, const FVector& Extent) override;
	PX_ShapeObject* CreateSphereShape(const FShapeProperties& Props, FLOAT Radii) override;
	PX_ShapeObject* CreateCapsuleShape(const FShapeProperties& Props, FLOAT Height, FLOAT Radii) override;
	PX_ShapeObject* CreateMeshShape(const FShapeProperties& Props, PX_MeshShape* Mesh, const FVector& Scale = FVector(1, 1, 1)) override;

	// Joints.
	UBOOL CreateJointFixed(const FJointBaseProps& Props) override;
	UBOOL CreateJointHinge(const FJointHingeProps& Props) override;
	UBOOL CreateJointSocket(const FJointSocketProps& Props) override;
	UBOOL CreateConstriant(const FJointConstProps& Props) override;
};

struct FPhysXScene : public PX_SceneBase
{
	friend class FPhysicsThread;

	physx::PxScene* pxScene;
	static DWORD NumScenes;
	physx::PxRigidStatic* BSPEntity;
	FLOAT RemainDelta, SkippedDelta;
	struct FListedPhysXActor* PhysList;
	INT NumTickables;
	static struct FPhysXJoint* BrokenJoints;
	UBOOL bMultiThreading;

	struct FPhysXSceneWork* ThreadProc;

	FPhysXScene(ULevel* L, UBOOL bMultiThread);
	~FPhysXScene();

	void TickScene(FLOAT DeltaTime);

	PX_PhysicsObject* CreatePlatform(AActor* Owner, const FVector& Pos, const FRotator& Rot);
	PX_PhysicsObject* CreateRigidBody(const FRigidBodyProperties& Parms, const FVector& Pos, const FRotator& Rot);
	PX_PhysicsObject* CreateStaticBody(AActor* Owner, const FVector& Pos, const FRotator& Rot);

	// First create the articulation, then finish it once all bodies/joints are added.
	PX_ArticulationList* CreateArticulation(AActor* Owner, INT NumIterations);

	physx::PxTriangleMesh* CreateBSPModel(UModel* Model);

	physx::PxMaterialTableIndex GetBSPMaterialFriction(FLOAT Friction);

	void EnlistActor(FListedPhysXActor* A);
	void UnlistActor(FListedPhysXActor* A);

	void ShutDownScene();

	inline const TCHAR* GetNameSafe() const
	{
		const TCHAR* Result;
		try
		{
			Result = Level->GetPathName();
		}
		catch (...)
		{
			Result = TEXT("<Invalid Scene Pointer>");
		}
		return Result;
	}

	static inline void SetActorCollisionFlags(physx::PxRigidActor* a, DWORD Group, DWORD Flags)
	{
		guard(FPhysXScene::SetActorCollisionFlags);
		FINISH_PHYSX_THREAD;

		INT ns = a->getNbShapes();
		if (ns)
		{
			physx::PxShape** shapes = reinterpret_cast<physx::PxShape**>(appMalloc(sizeof(void*) * ns, PHYS_X_NAME));
			a->getShapes(shapes, ns);
			physx::PxFilterData filter;
			for (INT i = 0; i < ns; ++i)
			{
				filter = shapes[i]->getSimulationFilterData();
				filter.word0 = 0;
				filter.word1 = Group;
				filter.word2 = Flags;
				shapes[i]->setSimulationFilterData(filter);
			}
			appFree(shapes);
		}
		unguard;
	}
	static inline void SetOptionalPosition(physx::PxRigidActor* rb, const FVector* NewPos = nullptr, const FRotator* NewRot = nullptr)
	{
		guardSlow(FPhysXScene::SetOptionalPosition);
		FINISH_PHYSX_THREAD;
		if (NewPos && NewRot)
			rb->setGlobalPose(UECoordsToPX(*NewPos, *NewRot), false);
		else if (NewPos)
		{
			physx::PxTransform T = rb->getGlobalPose();
			T.p = UEVectorToPX(*NewPos);
			rb->setGlobalPose(T, false);
		}
		else if (NewRot)
		{
			physx::PxTransform T = rb->getGlobalPose();
			T.q = UERotatorToPX(*NewRot);
			rb->setGlobalPose(T, false);
		}
		unguardSlow;
	}

private:
	TMap<DWORD, physx::PxMaterialTableIndex> ZoneMaterials;
	TArray<physx::PxMaterial*> Materials;
};

struct FPhysXMesh : public PX_MeshShape
{
	physx::PxBase* Mesh;
	TArray<physx::PxConvexMesh*> ConvexList;
	FPhysXMesh* MirroredMesh;

	FPhysXMesh(physx::PxConvexMesh* CMesh);
	FPhysXMesh(physx::PxTriangleMesh* TMesh);
	FPhysXMesh(TArray<physx::PxConvexMesh*>& ConvexArray);

	inline physx::PxConvexMesh* GetConvex() const
	{
		return (physx::PxConvexMesh*)Mesh;
	}
	inline physx::PxTriangleMesh* GetTriangle() const
	{
		return (physx::PxTriangleMesh*)Mesh;
	}

	~FPhysXMesh();
};

struct FPhysXUserDataBase
{
	UBOOL bShapeQuery; // A shape has contact data in query.

	FPhysXUserDataBase()
		: bShapeQuery(FALSE)
	{}
	virtual AActor* GetActorOwner() const _VF_BASE_RET(NULL);
	virtual UBOOL OnContact(FPhysXUserDataBase* Other, const FVector& Position, const FVector& Normal, FLOAT Force) _VF_BASE_RET(FALSE);
};

struct FPhysXActorBase
{
	FPhysXActorBase()
	{}
	virtual ~FPhysXActorBase() noexcept(false)
	{}
	virtual AActor* GetActorOwner() const _VF_BASE_RET(NULL);

	virtual void pxSetScene(void* rb, PX_SceneBase* NewScene);

	virtual void PhysicsTick(FLOAT DeltaTime) {}

	virtual void PhysicsDraw() {}

	static void DrawRbShapes(const PX_PhysicsObject& Object, const FPlane& ShapeColor);
};

// Object with gravity/force influences.
struct FListedPhysXActor : public FPhysXActorBase
{
	FListedPhysXActor* NextRb;
	FPhysXScene* pxScene;

	FListedPhysXActor(FPhysXScene* S);
	~FListedPhysXActor() noexcept(false);

	void pxSetScene(void* rb, PX_SceneBase* NewScene);
};

#define DECLARE_BASE_PX(baseclass,type) \
	DWORD GetType() const \
	{ \
		return type; \
	} \
	AActor* GetActorOwner() const \
	{ \
		return GetActor(); \
	} \
	void ChangeScene(PX_SceneBase* NewScene) \
	{ \
		baseclass::ChangeScene(NewScene); \
		pxSetScene(rbActor, NewScene); \
	}

inline physx::PxRigidDynamic* GetDynamicActor(PX_PhysicsObject* P)
{
	constexpr UBOOL IsDynamicType[PX_PhysicsObject::ERBObjectType::RBTYPE_MAX] = {
		FALSE, // RBTYPE_Undefined
		TRUE, // RBTYPE_Platform
		TRUE, // RBTYPE_RigidBody
		FALSE, // RBTYPE_StaticBody
		FALSE, // RBTYPE_Articulation
		FALSE // RBTYPE_ArticulationLink
	};
	return (P && IsDynamicType[P->GetType()]) ? reinterpret_cast<physx::PxRigidDynamic*>(P->GetRbActor()) : nullptr;
}
inline physx::PxRigidActor* GetRigidActor(PX_PhysicsObject* P)
{
	constexpr UBOOL IsRigidType[PX_PhysicsObject::ERBObjectType::RBTYPE_MAX] = {
		FALSE, // RBTYPE_Undefined
		TRUE, // RBTYPE_Platform
		TRUE, // RBTYPE_RigidBody
		TRUE, // RBTYPE_StaticBody
		FALSE, // RBTYPE_Articulation
		TRUE // RBTYPE_ArticulationLink
	};
	return (P && IsRigidType[P->GetType()]) ? reinterpret_cast<physx::PxRigidActor*>(P->GetRbActor()) : nullptr;
}

struct FPhysXJoint : public PX_JointBase
{
	physx::PxJoint* JointObj;
	FPhysXJoint* NextBroken;
	UBOOL bPendingBroken;

	FPhysXJoint(PX_JointObject* Obj, physx::PxJoint* JO);
	~FPhysXJoint();

	void UpdateCoords(const FCoords& A, const FCoords& B);
	void NoteJointBroken();
};

enum EShapeFlags : DWORD
{
	ESHAPEFLAGS_None			= 0,
	ESHAPEFLAGS_ContactCallback	= (1 << 0),
	ESHAPEFLAGS_ContactModify	= (1 << 1),
};

struct FPhysXShape : public PX_ShapeObject
{
	physx::PxShape* Shape;
	physx::PxMaterial* LocalMateria;

	FPhysXUserDataBase* UserData;
	UBOOL bPendingContact, bUseContactVelocity;
	physx::PxVec3 PendingLocation, PendingNormal, CurContactVelocity;
	UINT LastContactFrame;

	FPhysXShape(const FShapeProperties& Parms, physx::PxShape* Sh, physx::PxMaterial* LM);
	~FPhysXShape() noexcept(false);

	FCoords GetLocalPose() override;
	void SetContactNotify(UBOOL bEnable) override;
	void SetFriction(FLOAT NewStatic, FLOAT NewDynmaic, FLOAT NewRestitution) override;
	void SetLocalPose(const FCoords& NewCoords) override;
	void SetContactVelocity(const FVector& NewCVelocity);
	
	inline void SyncContact()
	{
		guardSlow(FPhysXShape::SyncContact);
		bPendingContact = FALSE;
		bIsContact = TRUE;
		ContactLocation = PXVectorToUE(PendingLocation);
		ContactNormal = PXNormalToUE(PendingNormal);
		LastContactFrame = GFrameNumber + 2;
		unguardSlow;
	}
	inline UBOOL TickContact()
	{
		guardSlow(FPhysXShape::TickContact);
		if (bIsContact && LastContactFrame < GFrameNumber)
		{
			bIsContact = FALSE;
			return TRUE;
		}
		return FALSE;
		unguardSlow;
	}

	UBOOL OnContact(const physx::PxVec3& Location, const physx::PxVec3& Normal);
};

#define DECLARE_PXSHAPE(ShClass) ShClass(const FShapeProperties& Parms, physx::PxShape* Sh, physx::PxMaterial* LM) : FPhysXShape(Parms, Sh, LM) {} void DrawDebug(const FPlane& ShapeColor)

#if STATS
struct FPhysXStats : public FStatGroup
{
	FStatStaticCount RigidObjCount;
	FStatStaticCount RagdollObjCount;
	FStatStaticCount JointObjCount;
	FStatValueLightMem PhysMemUse;

	FPhysXStats();
};

extern FPhysXStats GPhysXStats;
#endif
