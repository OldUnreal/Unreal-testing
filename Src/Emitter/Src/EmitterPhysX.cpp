
#include "EmitterPrivate.h"

void AXEmitter::InitPhysXParticle(xParticle* A)
{
	guard(AXEmitter::InitPhysXParticle);
	UPX_RigidBodyData* RBD = Cast<UPX_RigidBodyData>(PhysicsData);
	if (!RBD || !RBD->CollisionShape || !XLevel->PhysicsScene || !RBD->CollisionShape->IsValidShape())
		return;

	RBD->Actor = A;
	PX_PhysicsObject* P;
	{
		if (A->bDoRot)
		{
			RBD->AngularVelocity = A->RotSp / 65536.f;
			P = XLevel->PhysicsScene->CreateRigidBody(FRigidBodyProperties(RBD), A->Location, A->Rotation);
			RBD->AngularVelocity = FVector(0, 0, 0);
		}
		else P = XLevel->PhysicsScene->CreateRigidBody(FRigidBodyProperties(RBD), A->Location, A->Rotation);
	}
	RBD->Actor = this;
	if (P)
	{
		A->RbPhysicsData = new FParticleRBPhysics(A, XLevel->PhysicsScene, P, RBD);
		P->SetLimits(RBD->MaxAngularVelocity, RBD->MaxLinearVelocity);
		P->SetDampening(RBD->AngularDamping, RBD->LinearDamping);
		P->SetGravity(A->Acceleration);
		P->SetCollisionFlags(UCONST_COLLISIONFLAG_Movers, 0);
	}
	unguard;
}
void AXEmitter::ExitRbPhysics()
{
	guard(AXEmitter::ExitRbPhysics);
	Super::ExitRbPhysics();
	if (PartPtr)
		PartPtr->HideAllParts();
	unguard;
}
void AXEmitter::DrawRbDebug()
{
	guard(AXEmitter::DrawRbDebug);
	Super::DrawRbDebug();
	if (PartPtr)
		PartPtr->DrawRbDebug();
	unguard;
}


#define DEBUG_VERIFY_OFFSETS 0

URopeMesh::URopeMesh() {}
URopeMesh::URopeMesh(AXRopeDeco* D)
	: RopeOwner(D)
{
	Update();
}
void URopeMesh::Update()
{
	guard(URopeMesh::Update);
	SplitOffset = RopeOwner->GetSplitOffset();
	const INT NumSegments = Max<INT>(RopeOwner->NumSegments, 1);
	const INT DblSeg = (NumSegments << 1);
	INT i;
	InitSize = RopeOwner->NumSegments;
	FrameVerts = DblSeg + 2;
	IsSplitMesh = (SplitOffset < 255);
	if (SplitOffset < 255)
		FrameVerts += 2;
	SMTris.SetSize(DblSeg);
	{
		FStaticMeshTri* T = &SMTris(0);
		FLOAT UMap = 0.f;
		const FLOAT UInc = RopeOwner->TexVertScaling;
		FLOAT UEnd = UInc;
		INT iVert = 0;
		const INT iSplitDbl = IsSplitMesh ? (SplitOffset << 1) : INDEX_NONE;
		for (i = 0; i < DblSeg; ++i, ++iVert)
		{
			if (i == iSplitDbl)
				iVert += 2;
			T[i].GroupIndex = 0;
			if (i & 1)
			{
				T[i].iVertex[0] = iVert;
				T[i].iVertex[1] = iVert + 2;
				T[i].iVertex[2] = iVert + 1;
				T[i].Tex[0].Set(UMap, 1.f);
				T[i].Tex[1].Set(UEnd, 1.f);
				T[i].Tex[2].Set(UEnd, 0.f);
				UMap = UEnd;
				UEnd += UInc;
			}
			else
			{
				T[i].iVertex[0] = iVert;
				T[i].iVertex[1] = iVert + 1;
				T[i].iVertex[2] = iVert + 2;
				T[i].Tex[0].Set(UMap, 0.f);
				T[i].Tex[1].Set(UMap, 1.f);
				T[i].Tex[2].Set(UEnd, 0.f);
			}
		}
	}
	Connects.SetSize(FrameVerts);
	VertLinks.SetSize(NumSegments + (IsSplitMesh ? 2 : 1));
	{
		FMeshVertConnect* C = &Connects(0);
		for (i = 0; i < FrameVerts; ++i)
		{
			C[i].NumVertTriangles = 1;
			C[i].TriangleListOffset = (i >> 1);
		}
		INT iVert = 0;
		const INT iSplitDbl = IsSplitMesh ? (SplitOffset << 1) : INDEX_NONE;
		INT* V = &VertLinks(0);
		for (i = 0; i < VertLinks.Num(); ++i, iVert += 2)
		{
			if (i == iSplitDbl)
				iVert += 2;
			V[i] = Min(iVert, SMTris.Num() - 1);
		}
	}
#if DEBUG_VERIFY_OFFSETS
	{
		FStaticMeshTri* T = &SMTris(0);
		for (i = 0; i < SMTris.Num(); ++i)
		{
			for (INT j = 0; j < 3; ++j)
				verifyf(T[i].iVertex[j] < FrameVerts, TEXT("Face(%i) Vertex(i) out of range %i/%i"), i, j, INT(T[i].iVertex[j]), FrameVerts);
		}

		verifyf(Connects.Num() >= FrameVerts, TEXT("Connects list too small %i/%i"), Connects.Num(), FrameVerts);
		FMeshVertConnect* C = &Connects(0);
		for (i = 0; i < Connects.Num(); ++i)
		{
			verifyf((C[i].TriangleListOffset + C[i].NumVertTriangles) <= VertLinks.Num(), TEXT("Connects(%i) out of range %i + %i/%i"), i, C[i].TriangleListOffset, C[i].NumVertTriangles, VertLinks.Num());
		}
		INT* V = &VertLinks(0);
		for (i = 0; i < VertLinks.Num(); ++i)
		{
			verifyf(V[i] >= 0 && V[i] < SMTris.Num(), TEXT("VertLinks(%i) out of range %i/%i"), i, V[i], SMTris.Num());
		}
	}
#endif

	if (!SMGroups.Num())
	{
		SMGroups.Add(1);
		FStaticMeshTexGroup& G = SMGroups(0);
		G.RealPolyFlags = PF_TwoSided;
		G.Texture = 0;
		G.SmoothGroup = 0;
	}
	if (!Textures.Num())
		Textures.AddZeroed(1);

	// Setup default bounds, gets updated every frame after.
	BoundingBox.IsValid = FALSE;
	BoundingBox += RopeOwner->Location;
	BoundingBox += RopeOwner->GetEndOffset();
	BoundingBox = BoundingBox.ExpandBy(RopeOwner->RopeThickness * 2.f);
	BoundingSphere = BoundingBox.GetSphereBounds();
	unguard;
}
void URopeMesh::GetFrame(FVector* Verts, INT Size, FCoords Coords, AActor* Owner, INT* LODRequest)
{
	guard(URopeMesh::GetFrame);
	if (InitSize != RopeOwner->NumSegments) // Error, unsafe to continue!
	{
		for (INT i = 0; i < FrameVerts; i++)
		{
			*Verts = FVector(i,(i & 1),0);
			*(BYTE**)&Verts += Size;
		}
		return;
	}

	if (RopeOwner->LastUpdateFrame != GFrameNumber)
	{
		RopeOwner->LastUpdateFrame = GFrameNumber;
		if (RopeOwner->RbPhysicsData && RopeOwner->RbPhysicsData->GetType() == FActorRBPhysicsBase::EPhysicsObjType::OBJ_Articulation)
			RopeOwner->SyncRBRope();
		else RopeOwner->SoftwareCalcRope();
	}

	const FVector* V = &RopeOwner->RenderPoints(0);
	FCoords DirCoords(GMath.UnitCoords);
	FVector OldAxis;
	const FLOAT Wide = RopeOwner->RopeThickness;
	INT NumSegments;

#if DEBUG_VERIFY_OFFSETS
	INT TestOffset = 0;
	INT iReadOffset = 0;
	const INT iReadMax = RopeOwner->RenderPoints.Num();
#endif

	for (INT Pass = 0; Pass < 2; ++Pass)
	{
		// Figure out first direction.
#if DEBUG_VERIFY_OFFSETS
		verifyf((iReadOffset + 1) < iReadMax, TEXT("InVert out of range %i/%i Pass %i"), iReadOffset + 1, iReadMax, Pass);
#endif
		FVector Dir(V[1] - V[0]);
		{
			DirCoords = (GMath.UnitCoords / Dir.Rotation());
			const FVector UpDir(DirCoords.XAxis);
			GetFaceCoords(V[0], Coords.Origin, UpDir, DirCoords);
			OldAxis = DirCoords.YAxis;
			DirCoords.ZAxis = DirCoords.YAxis;
		}

		if (!IsSplitMesh)
			NumSegments = Max<INT>(RopeOwner->NumSegments, 1);
		else if (Pass == 0)
			NumSegments = SplitOffset;
		else NumSegments = Max<INT>(RopeOwner->NumSegments, 1) - SplitOffset;

		for (INT i = 0; i <= NumSegments; i++)
		{
			if (i > 0 && i < NumSegments)
			{
#if DEBUG_VERIFY_OFFSETS
				verifyf((iReadOffset + i + 1) < iReadMax, TEXT("InVert out of range %i/%i Pass %i"), iReadOffset + i + 1, iReadMax, Pass);
#endif
				Dir = (V[i + 1] - V[i]);
				DirCoords = (GMath.UnitCoords / Dir.Rotation());
				const FVector UpDir(DirCoords.XAxis);
				GetFaceCoords(V[i], Coords.Origin, UpDir, DirCoords);
				DirCoords.ZAxis = (DirCoords.YAxis + OldAxis).SafeNormal();
				OldAxis = DirCoords.YAxis;
			}

#if DEBUG_VERIFY_OFFSETS
			TestOffset += 2;
			verifyf(TestOffset <= FrameVerts, TEXT("OutVert out of range %i/%i"), TestOffset, FrameVerts);
#endif
			*Verts = (V[i] - (DirCoords.ZAxis * Wide)).TransformPointBy(Coords);
			*(BYTE**)&Verts += Size;
			*Verts = (V[i] + (DirCoords.ZAxis * Wide)).TransformPointBy(Coords);
			*(BYTE**)&Verts += Size;
		}
		if (IsSplitMesh && Pass == 0)
		{
			V += (SplitOffset + 1);
#if DEBUG_VERIFY_OFFSETS
			iReadOffset += (SplitOffset + 1);
#endif
		}
		else break;
	}
	unguard;
}
FBox URopeMesh::GetRenderBoundingBox(const AActor* Owner, UBOOL Exact)
{
	guardSlow(URopeMesh::GetRenderBoundingBox);
	//FDebugLineData::DrawBox(BoundingBox.Min, BoundingBox.Max, FPlane(1, 0, 0, 1), 0);
	return BoundingBox;
	unguardSlow;
}
FSphere URopeMesh::GetRenderBoundingSphere(const AActor* Owner, UBOOL Exact)
{
	guardSlow(URopeMesh::GetRenderBoundingSphere);
	return BoundingSphere;
	unguardSlow;
}
FBox URopeMesh::GetCollisionBoundingBox(const AActor* Owner)
{
	guardSlow(URopeMesh::GetCollisionBoundingBox);
	return BoundingBox;
	unguardSlow;
}
UTexture* URopeMesh::GetTexture(INT Count, AActor* Owner)
{
	guardSlow(URopeMesh::GetTexture);
	return Owner->Texture;
	unguardSlow;
}
void URopeMesh::SetupCollision()
{
	CollisionState = 2;
}

IMPLEMENT_CLASS(URopeMesh);

void AXRopeDeco::PostBeginPlay()
{
	guard(AXRopeDeco::PostBeginPlay);
	Super::PostBeginPlay();

	if (GIsClient && !RopeMeshPtr)
	{
		RopeMeshPtr = new URopeMesh(this);
		Mesh = RopeMeshPtr;
	}
	unguard;
}
void AXRopeDeco::PostLoad()
{
	guard(AXRopeDeco::PostLoad);
	Super::PostLoad();
	if (GIsClient && !RopeMeshPtr)
		RopeMeshPtr = new URopeMesh(this);
	Mesh = RopeMeshPtr;
	unguard;
}
void AXRopeDeco::Spawned()
{
	guard(AXRopeDeco::Spawned);
	Super::Spawned();
	if (GIsClient && !RopeMeshPtr)
		RopeMeshPtr = new URopeMesh(this);
	Mesh = RopeMeshPtr;
	unguard;
}
void AXRopeDeco::PostScriptDestroyed()
{
	guard(AXRopeDeco::PostScriptDestroyed);
	Super::PostScriptDestroyed();
	if (RopeMeshPtr)
	{
		RopeMeshPtr->ConditionalDestroy();
		delete RopeMeshPtr;
		RopeMeshPtr = nullptr;
		Mesh = nullptr;
	}
	unguard;
}
void AXRopeDeco::NoteDuplicate(AActor* Src)
{
	guard(AXRopeDeco::NoteDuplicate);
	Super::NoteDuplicate(Src);
	RopeMeshPtr = GIsClient ? (new URopeMesh(this)) : nullptr;
	Mesh = RopeMeshPtr;
	unguard;
}
void AXRopeDeco::onPropertyChange(UProperty* Property, UProperty* OuterProperty)
{
	guard(AXRopeDeco::onPropertyChange);
	Super::onPropertyChange(Property, OuterProperty);
	if (GIsEditor && (!appStricmp(Property->GetName(), TEXT("NumSegments")) || !appStricmp(Property->GetName(), TEXT("TexVertScaling"))))
	{
		if (RopeMeshPtr)
			RopeMeshPtr->Update();
	}
	unguard;
}
FVector AXRopeDeco::GetEndOffset()
{
	guardSlow(AXRopeDeco::GetEndOffset);
	if (RopeEndActor && !RopeEndActor->bDeleteMe)
		return RopeEndOffset.TransformVectorBy(GMath.UnitCoords * RopeEndActor->Rotation) + RopeEndActor->Location;
	else return RopeEndOffset.TransformVectorBy(GMath.UnitCoords * Rotation) + Location;
	unguardSlow;
}

inline FLOAT SplineWave(FLOAT t)
{
	return -4.f * (t - 1.f) * t; // 1.f - Square(t * 2.f - 1.f);
}

void AXRopeDeco::SoftwareCalcRope()
{
	guard(AXRopeDeco::SoftwareCalcRope);
	const INT NumSegs = Max<INT>(NumSegments, 1);
	if (RenderPoints.Num() != (NumSegs + 2))
		RenderPoints.SetSize(NumSegs + 2);
	const FVector EndPoint(GetEndOffset());

	INT i, j;
	AActor* A;
	FLOAT TotalLength = 0.f;
	FVector PrevPos(Location);
	for (i = 0; i < MidPointActors.Num(); ++i)
	{
		A = MidPointActors(i);
		if (A && !A->bDeleteMe)
		{
			TotalLength += (A->Location - PrevPos).Size();
			PrevPos = A->Location;
		}
	}
	TotalLength += (EndPoint - PrevPos).Size();
	if (!PiecePoints.Num())
		RopeLength = TotalLength * (1.f + Abs(RopeLoseness));

	const FLOAT LenPerSegment = TotalLength / NumSegs;
	FVector CurDir(Rotation.Vector());
	PrevPos = Location;
	FVector* Result = &RenderPoints(0);
	*Result = Location;
	INT nSegments = 1;
	FVector Dir;
	const FVector* Target;
	FBox ResultBounds(0);
	ResultBounds += Location;
	for (i = 0; i <= MidPointActors.Num(); ++i)
	{
		if (i == MidPointActors.Num())
			Target = &EndPoint;
		else
		{
			A = MidPointActors(i);
			if (!A || A->bDeleteMe)
				continue;
			Target = &A->Location;
		}
		Dir = (*Target - PrevPos);
		FLOAT CurDist = Dir.Size();
		if (CurDist < SLERP_DELTA)
			continue;

		const INT SegmentsForThis = Max(appRound(CurDist / LenPerSegment), 1);
		FLOAT HangDir = RopeLoseness * (-CurDist);
		FLOAT StepDist = 1.f / FLOAT(SegmentsForThis);
		FLOAT CalcDist = StepDist;

		Dir /= CurDist;
		CurDir = (CurDir + Dir).SafeNormal();
		FVector StepPts(PrevPos + CurDir * LenPerSegment);
		ResultBounds += StepPts;
		Result[nSegments++] = StepPts + FVector(0.f, 0.f, HangDir * SplineWave(CalcDist));
		if (nSegments >= NumSegs)
			break;
		PrevPos = StepPts;

		if (SegmentsForThis > 1)
		{
			Dir = (*Target - PrevPos).SafeNormal();
			CurDir = Dir;
			for (j = 1; j < SegmentsForThis; ++j)
			{
				CalcDist += StepDist;
				StepPts = PrevPos + Dir * LenPerSegment;
				ResultBounds += StepPts;
				Result[nSegments++] = StepPts + FVector(0.f, 0.f, HangDir * SplineWave(CalcDist));
				if (nSegments >= NumSegs)
					break;
				PrevPos = StepPts;
			}
		}
	}
	Result[NumSegs] = EndPoint;

	if (RopeMeshPtr)
	{
		ResultBounds += EndPoint;
		ResultBounds = ResultBounds.ExpandBy(RopeThickness);
		RopeMeshPtr->BoundingBox = ResultBounds;
		RopeMeshPtr->BoundingSphere = ResultBounds.GetSphereBounds();
	}
	unguard;
}

void AXRopeDeco::RenderSelectInfo(FSceneNode* Frame)
{
	guard(AXRopeDeco::RenderSelectInfo);
	URenderDevice* RenDev = Frame->Viewport->RenDev;
	{
		FVector EndPoint(GetEndOffset());
		INT i;
		AActor* A;
		FVector PrevPos(Location);
		const FPlane LineColor(0.8f, 0.8f, 0.4f, 1.f);
		for (i = 0; i < MidPointActors.Num(); ++i)
		{
			A = MidPointActors(i);
			if (A && !A->bDeleteMe)
			{
				RenDev->Draw3DLine(Frame, LineColor, 0, PrevPos, A->Location);
				PrevPos = A->Location;
			}
		}
		RenDev->Draw3DLine(Frame, LineColor, 0, PrevPos, EndPoint);
	}
	if (bRopeWind)
	{
		FRotator Dir = WindDirection.Rotation();
		FCoords C = GMath.UnitCoords / Dir;
		const FPlane LineColor(0.2f, 0.2f, 1.f, 1.f);
		const FVector Tip = Location + C.XAxis * 14.f;
		RenDev->Draw3DLine(Frame, LineColor, 0, Location, Tip);
		RenDev->Draw3DLine(Frame, LineColor, 0, Tip, Tip - C.XAxis * 9.f + C.YAxis * 5.f);
		RenDev->Draw3DLine(Frame, LineColor, 0, Tip, Tip - C.XAxis * 9.f - C.YAxis * 5.f);
	}
	Super::RenderSelectInfo(Frame);
	unguard;
}

IMPLEMENT_CLASS(AXRopeDeco);

inline FVector CalcNewWind(AXRopeDeco* R)
{
	return (R->WindDirection + (VRand() * appFrand()) * R->WindRandDir).SafeNormal();
}

struct FRopeJoint : public PX_JointObject
{
	FCoords LocalCoordsA, LocalCoordsB;

	FRopeJoint(PX_PhysicsObject* A, PX_PhysicsObject* B, UPXJ_BaseJoint* J, struct FRopeRBPhysics* Rope, const FCoords& CA, const FCoords& CB)
		: PX_JointObject(A, B, J)
		, LocalCoordsA(CA)
		, LocalCoordsB(CB)
	{}

	void OtherSideDestroyed()
	{
		guard(FRopeJoint::OtherSideDestroyed);
		AXRopeDeco* Rope = reinterpret_cast<AXRopeDeco*>(ActorA->GetActor());
		if (Rope->RopeStartActor == OtherSideActor)
		{
			Rope->RopeStartActor = NULL;
			Rope->bHasLooseStart = TRUE;
		}
		if (Rope->RopeEndActor == OtherSideActor)
		{
			Rope->RopeEndActor = NULL;
			Rope->bHasLooseEnd = TRUE;
		}
		delete this;
		unguard;
	}
	void OtherSidePhysics(UBOOL bExit)
	{
		guard(FRopeJoint::OtherSidePhysics);
		ActorB = NULL;
		delete PhysXJoint;
		PhysXJoint = nullptr;
		if (!bExit)
		{
			if (OtherSideActor)
				ActorB = OtherSideActor->GetRbPhysics();
			Joint->InitJoint(*this, LocalCoordsA, LocalCoordsB);
		}
		unguard;
	}
	void OnActorDestroyed()
	{
		guard(FRopeJoint::OnActorDestroyed);
		delete this;
		unguard;
	}
};

struct FRopeSegment
{
	FRopeSegment* Next;
	FRopeSegment* RenderNext;
	PX_ArticulationLink* Object;
	UBOOL bIsSplitSegment;

	FRopeSegment(PX_ArticulationLink* Obj)
		: Next(nullptr), RenderNext(nullptr), Object(Obj), bIsSplitSegment(FALSE)
	{}
};

constexpr INT RopeIterations = 4; // How many physics iterations to give to the rope.

struct FRopeRBPhysics : public FActorRBPhysicsBase
{
	UBOOL bWasAsleep;
	PX_ArticulationList* Object; // Main object.
	PX_ArticulationList* BrokenObject; // Secondary object if rope is broken in half.
	PX_ArticulationLink* CenterLink; // Link we want to move actor location to.
	FRopeSegment* Segments;
	FRopeSegment* RenderSegments;
	UPX_RigidBodyData* Data;
	UBOOL bInnerMove;
	BYTE BrokenOffset;
	UPXC_SphereCollision* TempSphereShape;

	FVector WindDir, NextWindDir;
	FLOAT WindTimer;
	UBOOL bHadWind;

	FCoords CacheJointA, CacheJointB;
	UBOOL bCachedJoints;

	FRopeRBPhysics(AXRopeDeco* A, PX_SceneBase* Scene, UPX_RigidBodyData* D)
		: FActorRBPhysicsBase(A, Scene, FALSE)
		, bWasAsleep(FALSE)
		, Object(nullptr)
		, BrokenObject(nullptr)
		, CenterLink(nullptr)
		, Segments(nullptr)
		, RenderSegments(nullptr)
		, Data(D)
		, bInnerMove(FALSE)
		, BrokenOffset(255)
		, TempSphereShape(nullptr)
		, WindTimer(0.f)
		, bHadWind(FALSE)
		, bCachedJoints(FALSE)
	{
		WindDir = NextWindDir = CalcNewWind(A);
	}
	~FRopeRBPhysics() noexcept(false)
	{
		guard(FRopeRBPhysics::~FRopeRBPhysics);
		RemoveObject();
		if (TempSphereShape)
		{
			TempSphereShape->ConditionalDestroy();
			delete TempSphereShape;
		}
		unguard;
	}

	void RemoveObject()
	{
		guard(FRopeRBPhysics::RemoveObject);
		delete Object;
		Object = NULL;
		delete BrokenObject;
		BrokenObject = NULL;
		CenterLink = NULL;
		if (Segments)
		{
			FRopeSegment* N;
			for (FRopeSegment* R = Segments; R; R = N)
			{
				N = R->Next;
				delete R;
			}
			Segments = NULL;
			RenderSegments = NULL;
		}
		unguard;
	}
	PX_PhysicsObject* GetRbObject() const
	{
		return Object;
	}
	UPX_PhysicsDataBase* GetPxData() const
	{
		return Data;
	}

	void Tick(FLOAT DeltaTime)
	{
		guardSlow(FRopeRBPhysics::Tick);
		if (Object)
		{
			if (Object->ProcessCallbacks(this)) // Changed physics in a callback.
				return;

			AXRopeDeco* A = reinterpret_cast<AXRopeDeco*>(Owner);
			if (A->RopeMeshPtr)
			{
				FVector V;
				FBox NewBounds(0);
				for (FRopeSegment* R = Segments; R; R = R->Next)
				{
					R->Object->GetPosition(&V, NULL);
					NewBounds += V;
				}
				A->RopeMeshPtr->BoundingBox = NewBounds;
			}
			if (A->bRopeWind)
			{
				const FLOAT BaseTime = A->Level->TimeSeconds + A->WindAmptitude;
				if ((WindTimer -= DeltaTime) <= 0.f)
				{
					WindTimer = A->WindOscalliationRate;
					WindDir = NextWindDir;
					NextWindDir = CalcNewWind(A);
				}
				FLOAT WN = 0.5f + appCos(BaseTime * PI * 0.5f) * 0.5f;
				if (WN > 0.5)
				{
					bHadWind = TRUE;
					WN = (WN - 0.5f) * 2.f * A->WindStrength;
					Object->SetConstVelocity(WindDir * WN);
					//if (BrokenObject)
					//	BrokenObject->SetConstVelocity(WindDir * WN);
				}
				else if(bHadWind)
				{
					bHadWind = FALSE;
					Object->SetConstVelocity(FVector(0, 0, 0));
					//if (BrokenObject)
					//	BrokenObject->SetConstVelocity(FVector(0, 0, 0));
				}
			}
		}
		if (CenterLink)
		{
			FVector V;
			FCheckResult Hit;
			CenterLink->GetPosition(&V, NULL);
			Owner->XLevel->MoveActor(Owner, V - Owner->Location, Owner->Rotation, Hit);
		}
		unguardSlow;
	}
	void PhysicsImpact(PX_PhysicsObject* ThisBody, AActor* OtherBody, FLOAT Force, const FVector& HitLocation, const FVector& HitNormal)
	{
		Owner->PhysicsImpact(Force, HitLocation, HitNormal, OtherBody);
	}
	void ActorMoved()
	{
	}
	UBOOL RanInto(class AActor* Other)
	{
		return FALSE;
	}
	UBOOL HandleNetworkMove(FVector* NewPos, FRotator* NewRot)
	{
		return FALSE;
	}
	void NetworkVelocity(const FVector& NewVel)
	{
		if (Object)
			Object->SetLinearVelocity(NewVel);
	}
	void OnZoneChange(AZoneInfo* NewZone)
	{
		guard(FActorRBPhysics::OnZoneChange);
		FActorRBPhysicsBase::OnZoneChange(NewZone);
		if (Object)
		{
			if (NewZone->bWaterZone)
			{
				Object->SetLimits(Data->MaxAngularVelocity * Data->WaterMaxAngularVelocitySc, Data->MaxLinearVelocity * Data->WaterMaxLinearVelocitySc);
				Object->SetDampening(Data->WaterAngularDamping, Data->WaterLinearDamping);
			}
			else
			{
				Object->SetLimits(Data->MaxAngularVelocity, Data->MaxLinearVelocity);
				Object->SetDampening(Data->AngularDamping, Data->LinearDamping);
			}
		}
		unguard;
	}
	void ActorLevelChange(class ULevel* OldLevel, class ULevel* NewLevel)
	{
		PX_SceneBase* S = GetScene();
		S->SendToScene(Object, NewLevel->PhysicsScene);
		SetScene(NewLevel->PhysicsScene);
	}

	DWORD GetType() const
	{
		return OBJ_Articulation;
	}

	void WakeUp()
	{
		if (Object)
			Object->WakeUp();
		if (BrokenObject)
			BrokenObject->WakeUp();
	}
	void PutToSleep()
	{
		if (Object)
			Object->PutToSleep();
		if (BrokenObject)
			BrokenObject->PutToSleep();
	}
	UBOOL IsASleep()
	{
		if (BrokenObject && !BrokenObject->IsSleeping())
			return FALSE;
		return (!Object || Object->IsSleeping());
	}
	void SetAngularVelocity(const FVector& NewVel)
	{
		if (Object)
			Object->SetAngularVelocity(NewVel);
	}
	FVector GetAngularVelocity()
	{
		return (Object ? Object->GetAngularVelocity() : FVector(0, 0, 0));
	}
	void SetGravity(const FVector& NewGravity)
	{
		if (Object)
			Object->SetGravity(NewGravity);
		if (BrokenObject)
			BrokenObject->SetGravity(NewGravity);
	}
	void SetConstVelocity(const FVector& NewVel)
	{
		if (Object)
			Object->SetConstVelocity(NewVel);
		if (BrokenObject)
			BrokenObject->SetConstVelocity(NewVel);
	}
	void SetMass(FLOAT NewMass)
	{
		if (Object)
			Object->SetMass(NewMass);
		if (BrokenObject)
			BrokenObject->SetMass(NewMass);
	}

	void DrawDebug()
	{
		if (Object)
			Object->DrawDebug();
		if (BrokenObject)
			BrokenObject->DrawDebug();
	}

	void SetupBodies()
	{
		guard(FActorRBPhysics::SetupBodies);
		RemoveObject();
		AXRopeDeco* Rope = reinterpret_cast<AXRopeDeco*>(Owner);
		if (Rope->RopeJointStart)
			Rope->RopeJointStart->SetDisabled(TRUE);
		if (Rope->RopeJointEnd)
			Rope->RopeJointEnd->SetDisabled(TRUE);
		FVector* V = &Rope->RenderPoints(0);
		PX_ArticulationList* A = Rope->XLevel->PhysicsScene->CreateArticulation(Rope, RopeIterations);
		if (!A)
			return;

		const INT NumSeg = Max<INT>(Rope->NumSegments, 1);
		const FLOAT SegmentDist = (Rope->RopeLength / Max<INT>(Rope->NumSegments, 1)) * 0.5f;

#if 0 // Capsule collision. <- seams to get stuck inside walls a lot...
		UPXC_CapsuleCollision* ColShape = Cast<UPXC_CapsuleCollision>(Data->CollisionShape);
		if (!ColShape)
		{
			ColShape = new (Rope->GetOuter()) UPXC_CapsuleCollision();
			Data->CollisionShape = ColShape;
		}
		ColShape->Height = Max(SegmentDist - Rope->RopeThickness, 0.01f);
		ColShape->Radius = Max<FLOAT>(Rope->RopeThickness, 2.f);
#else // Box collision.
		UPXC_BoxCollision* ColShape = Cast<UPXC_BoxCollision>(Data->CollisionShape);
		if (!ColShape)
		{
			ColShape = new (Rope->GetOuter()) UPXC_BoxCollision();
			Data->CollisionShape = ColShape;
		}
		ColShape->Extent = FVector(SegmentDist * 2.f, Max<FLOAT>(Rope->RopeThickness, 1.f), Max<FLOAT>(Rope->RopeThickness, 1.f));
#endif

		Object = A;
		const FVector OneScale(1.f, 1.f, 1.f);
		FVector BaseVelocity = Rope->Velocity;
		FArticulationProperties RbParms(Rope, OneScale, Data->COMOffset, BaseVelocity, Data->AngularVelocity, Max<FLOAT>(Rope->Mass / NumSeg, 1.f), ColShape);
		RbParms.InertiaTensor = FVector(5.f, 5.f, 5.f);
		FVector rPos;
		FRotator rDir;
		FRopeSegment* nPrev = NULL;
		FRopeSegment* rPrev = NULL;
		FRopeSegment* nSeg;

		FCoords CoordsA = GMath.UnitCoords * FVector(SegmentDist, 0, 0);
		FCoords CoordsB = GMath.UnitCoords / FVector(SegmentDist, 0, 0);

		if (Rope->RopeStartActor)
		{
			if (Rope->RopeStartActor->bDeleteMe)
			{
				Rope->RopeStartActor = NULL;
				Rope->bHasLooseStart = TRUE;
			}
			else if (Rope->RopeStartActor->bIsMover && Rope->RopeStartActor->bHidden && Rope->RopeStartActor->Physics == PHYS_None)
				Rope->bHasLooseStart = TRUE;
		}
		if (Rope->RopeEndActor)
		{
			if (Rope->RopeEndActor->bDeleteMe)
			{
				Rope->RopeEndActor = NULL;
				Rope->bHasLooseEnd = TRUE;
			}
			else if (Rope->RopeEndActor->bIsMover && Rope->RopeEndActor->bHidden && Rope->RopeEndActor->Physics == PHYS_None)
				Rope->bHasLooseEnd = TRUE;
		}

		if (Rope->bHasLooseStart)
		{
			rPos = V[0];
			rDir = FRotator(0, 0, 0);
			RbParms.CollisionShape = GetEdgeSphere();
			PX_ArticulationLink* P = A->CreateArticulationLink(RbParms, rPos, rDir);
			RbParms.CollisionShape = ColShape;
			if (P)
			{
				RbParms.ParentLink = P;
				nSeg = new FRopeSegment(P);
				Segments = nSeg;
				nPrev = nSeg;
			}
		}

		FRopePiece* SP = (Rope->PiecePoints.Num() == NumSeg) ? &Rope->PiecePoints(0) : nullptr;
		for (INT Pass = 0; Pass < 2; ++Pass)
		{
			UBOOL bFirst = TRUE;
			INT FinalIndex = NumSeg;
			if (BrokenOffset < 255)
				FinalIndex = Pass ? (NumSeg + 1) : BrokenOffset;

			for (INT i = (Pass ? (BrokenOffset + 1) : 0); i < FinalIndex; ++i)
			{
				if (SP)
				{
					rPos = SP->Pos;
					rDir = SP->Dir;
					BaseVelocity = SP->Velocity;
					++SP;
				}
				else
				{
					FVector Dir(V[i + 1] - V[i]);
					rPos = V[i] + (Dir * 0.5f);
					rDir = Dir.Rotation();
				}
				PX_ArticulationLink* P = A->CreateArticulationLink(RbParms, rPos, rDir);
				if (P)
				{
					RbParms.ParentLink = P;
					nSeg = new FRopeSegment(P);
					if (nPrev)
					{
						if (bFirst)
						{
							bFirst = FALSE;
							if (!RenderSegments)
								RenderSegments = nSeg;
							FCoords TCoordsA = GMath.UnitCoords * FVector(SegmentDist * 0.5f, 0, 0);
							P->SetJointCoords(TCoordsA, GMath.UnitCoords);
						}
						else
						{
							P->SetJointCoords(CoordsA, CoordsB);
							if (!CenterLink)
								CenterLink = P;
						}
						nPrev->Next = nSeg;
						if (rPrev)
							rPrev->RenderNext = nSeg;
					}
					else
					{
						Segments = nSeg;
						RenderSegments = nSeg;
						bFirst = FALSE;
					}
					nPrev = nSeg;
					rPrev = nSeg;
				}
			}
			if (BrokenOffset < 255 && Pass == 0)
			{
				nPrev->bIsSplitSegment = TRUE;
				rPos = V[BrokenOffset];
				rDir = FRotator(0, 0, 0);
				RbParms.CollisionShape = GetEdgeSphere();
				PX_ArticulationLink* P = A->CreateArticulationLink(RbParms, rPos, rDir);
				if (P)
				{
					nSeg = new FRopeSegment(P);
					nPrev->Next = nSeg;
					FCoords TCoordsB = GMath.UnitCoords / FVector(SegmentDist * 0.5f, 0, 0);
					P->SetJointCoords(GMath.UnitCoords, TCoordsB);
					nPrev = nSeg;
				}
				A->FinishArticulation();

				// Start next piece after cut off one.
				A = Rope->XLevel->PhysicsScene->CreateArticulation(Rope, RopeIterations);
				verify(A != NULL);
				BrokenObject = A;
				rPos = V[BrokenOffset];
				RbParms.CollisionShape = GetEdgeSphere();
				RbParms.ParentLink = NULL;
				P = A->CreateArticulationLink(RbParms, rPos, rDir);
				RbParms.CollisionShape = ColShape;
				if (P)
				{
					nSeg = new FRopeSegment(P);
					nPrev->Next = nSeg;
					nPrev = nSeg;
					RbParms.ParentLink = P;
				}
			}
			else break;
		}

		if (Rope->bHasLooseEnd)
		{
			rPos = V[NumSeg];
			rDir = FRotator(0, 0, 0);
			RbParms.CollisionShape = GetEdgeSphere();
			PX_ArticulationLink* P = A->CreateArticulationLink(RbParms, rPos, rDir);
			if (P)
			{
				FRopeSegment* nSeg = new FRopeSegment(P);
				nPrev->Next = nSeg;
				FCoords TCoordsB = GMath.UnitCoords / FVector(SegmentDist, 0, 0);
				P->SetJointCoords(GMath.UnitCoords, TCoordsB);
			}
		}
		A->FinishArticulation();
		OnZoneChange(Rope->Region.Zone);

		//SetCollisionFlags((DWORD)CollisionGroups, (DWORD)CollisionFlag);
		SetCollisionFlags(UCONST_COLLISIONFLAG_Movers, 0);
		unguard;
	}
	void PostInitJoints()
	{
		guard(FRopeRBPhysics::PostInitJoints);
		// Init anchors...
		AXRopeDeco* RopeDeco = reinterpret_cast<AXRopeDeco*>(Owner);
		if (Segments && (!RopeDeco->bHasLooseStart || !RopeDeco->bHasLooseEnd))
		{
			const FLOAT SegmentDist = (RopeDeco->RopeLength / Max<INT>(RopeDeco->NumSegments, 1)) * 0.51f;
			FVector RopePos;
			FRotator RopeRot;
			FCoords WorldCoords, CoordsA, CoordsB;
			FRopeJoint* NewJoint;
			PX_PhysicsObject* D;

			if (!RopeDeco->bHasLooseStart && RopeDeco->RopeJointStart)
			{
				Segments->Object->GetPosition(&RopePos, &RopeRot);
				WorldCoords = GMath.UnitCoords * FVector(SegmentDist, 0, 0) / RopeRot / RopePos;
				CoordsA = WorldCoords * RopePos * RopeRot;

				if (RopeDeco->RopeStartActor && (D = RopeDeco->RopeStartActor->GetRbPhysics()) != NULL)
				{
					if (bCachedJoints)
						CoordsB = CacheJointA;
					else
					{
						CoordsB = WorldCoords * RopeDeco->RopeStartActor->Location * RopeDeco->RopeStartActor->Rotation;
						CacheJointA = CoordsB;
						bCachedJoints = TRUE;
					}
				}
				else
				{
					CoordsB = WorldCoords;
					D = nullptr;
				}
				RopeDeco->RopeJointStart->Owner = RopeDeco->PhysicsData;
				NewJoint = new FRopeJoint(Segments->Object, D, RopeDeco->RopeJointStart, this, CoordsA, CoordsB);
				if (!RopeDeco->RopeJointStart->InitJoint(*NewJoint, CoordsA, CoordsB))
					delete NewJoint;
			}

			if (!RopeDeco->bHasLooseEnd && RopeDeco->RopeJointEnd)
			{
				FRopeSegment* Last = Segments;
				while (Last->Next)
					Last = Last->Next;

				Last->Object->GetPosition(&RopePos, &RopeRot);
				WorldCoords = GMath.UnitCoords / FVector(SegmentDist, 0, 0) / RopeRot / RopePos;
				CoordsA = WorldCoords * RopePos * RopeRot;

				if (RopeDeco->RopeEndActor && (D = RopeDeco->RopeEndActor->GetRbPhysics()) != NULL)
				{
					if (bCachedJoints)
						CoordsB = CacheJointB;
					else
					{
						CoordsB = WorldCoords * RopeDeco->RopeEndActor->Location * RopeDeco->RopeEndActor->Rotation;
						CacheJointB = CoordsB;
						bCachedJoints = TRUE;
					}
				}
				else
				{
					CoordsB = WorldCoords;
					D = nullptr;
				}
				RopeDeco->RopeJointEnd->Owner = RopeDeco->PhysicsData;
				NewJoint = new FRopeJoint(Last->Object, D, RopeDeco->RopeJointEnd, this, CoordsA, CoordsB);
				if (!RopeDeco->RopeJointEnd->InitJoint(*NewJoint, CoordsA, CoordsB))
					delete NewJoint;
			}
		}
		unguard;
	}

	UBOOL BreakRope(BYTE Offset)
	{
		guard(FActorRBPhysics::BreakRope);
		AXRopeDeco* Rope = reinterpret_cast<AXRopeDeco*>(Owner);
		if (BrokenObject || Rope->RenderPoints.Num() < 4)
			return FALSE;
		if (RenderSegments)
			SaveState();
		BrokenOffset = Clamp<BYTE>(Offset, 1, Rope->RenderPoints.Num() - 3);
		FVector* V = &Rope->RenderPoints(0);
		for (INT i = (Rope->RenderPoints.Num() - 1); i > BrokenOffset; --i)
			V[i] = V[i - 1];

		if (RenderSegments)
		{
			SetupBodies();
			PostInitJoints();
		}
		if (Rope->RopeMeshPtr)
			Rope->RopeMeshPtr->Update();
		return TRUE;
		unguard;
	}
	UPXC_SphereCollision* GetEdgeSphere()
	{
		guardSlow(FActorRBPhysics::GetEdgeSphere);
		if (!TempSphereShape)
			TempSphereShape = new UPXC_SphereCollision();
		TempSphereShape->Radius = Max<FLOAT>(reinterpret_cast<AXRopeDeco*>(Owner)->RopeThickness, 1.f);
		return TempSphereShape;
		unguardSlow;
	}
	void Serialize(FArchive& Ar)
	{
		guardSlow(FActorRBPhysics::Serialize);
		Ar << TempSphereShape;
		unguardSlow;
	}
	void SaveState()
	{
		guard(FActorRBPhysics::SaveState);
		AXRopeDeco* Rope = reinterpret_cast<AXRopeDeco*>(Owner);
		INT TotalLen = 0;
		FRopeSegment* R;
		for (R = RenderSegments; R; R = R->RenderNext)
			++TotalLen;
		Rope->PiecePoints.SetSize(TotalLen);
		FRopePiece* P = &Rope->PiecePoints(0);
		for (R = RenderSegments; R; R = R->RenderNext)
		{
			R->Object->GetPosition(&P->Pos, &P->Dir);
			P->Velocity = R->Object->GetLinearVelocity();
			++P;
		}
		unguard;
	}
};

void AXRopeDeco::SyncRBRope()
{
	guard(AXRopeDeco::SyncRBRope);
	if (RbPhysicsData && RbPhysicsData->GetType() == FActorRBPhysicsBase::EPhysicsObjType::OBJ_Articulation)
	{
		FVector* V = &RenderPoints(0);
		FVector Pos, X;
		FRotator Rot;
		const FLOAT RopeSegSize = (RopeLength / Max<INT>(NumSegments, 1)) * 0.5f;
		for (FRopeSegment* R = reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->RenderSegments; R; R = R->RenderNext)
		{
			R->Object->GetPosition(&Pos, &Rot);
			X = Rot.Vector() * RopeSegSize;
			*V = Pos - X;
			++V;
			if (R->bIsSplitSegment)
			{
				*V = Pos + X;
				++V;
			}
		}
		*V = Pos + X;
	}
	unguard;
}

void AXRopeDeco::InitRbPhysics()
{
	guard(AXRopeDeco::InitRbPhysics);
	if (bDeleteMe) return;

	if (PhysicsData)
		PhysicsData->Actor = this; // Make sure this is always valid.

	if (Physics == PHYS_RigidBody)
	{
		if (RbPhysicsData)
			ExitRbPhysics();
		UPX_RigidBodyData* PX = Cast<UPX_RigidBodyData>(PhysicsData);
		if (PX && XLevel->PhysicsScene)
		{
			if (Role < ROLE_AutonomousProxy)
			{
				if (!PX->bClientSimulate)
					return;
			}
			else if (!PX->bServerSimulate)
				return;

			SoftwareCalcRope();
			FRopeRBPhysics* RPhys = new FRopeRBPhysics(this, XLevel->PhysicsScene, PX);
			RbPhysicsData = RPhys;
			if (RopeBrokenIndex < 255)
				RPhys->BreakRope(RopeBrokenIndex);
			RPhys->SetupBodies();
			if (PX->bStartSleeping)
				RPhys->PutToSleep();
		}
	}
	else if (RbPhysicsData)
		ExitRbPhysics();
	unguardobj;
}

FParticleRBPhysics::FParticleRBPhysics(AActor* A, PX_SceneBase* Scene, PX_PhysicsObject* Obj, UPX_RigidBodyData* D)
	: FActorRBPhysicsBase(A, Scene, TRUE), bWasAsleep(FALSE), Object(Obj), Data(D)
{
	check(Obj != NULL);
}

FParticleRBPhysics::~FParticleRBPhysics()
{
	if (Object)
		delete Object;
}

PX_PhysicsObject* FParticleRBPhysics::GetRbObject() const
{
	return Object;
}
UPX_PhysicsDataBase* FParticleRBPhysics::GetPxData() const
{
	return Data;
}

void FParticleRBPhysics::Tick(FLOAT DeltaTime)
{
	if (Object)
	{
		AActor* A = Owner;
		if (bWasAsleep != Object->IsSleeping())
			bWasAsleep = !bWasAsleep;
		else if (bWasAsleep)
			return;

		A->Velocity = Object->GetLinearVelocity();

		FVector V;
		FRotator Rot;
		Object->GetPosition(&V, &Rot);
		if (Data->bCheckWallPenetration)
		{
			FCheckResult Hit;
			if (!A->XLevel->SingleLineCheck(Hit, A, V, A->Location, (TRACE_Level | TRACE_Blocking))) // Tried to clip through world!
			{
				V = Hit.Location + Hit.Normal * 8.f;
				Object->SetPosition(&V, NULL);

				A->Velocity = A->Velocity.MirrorByVector(Hit.Normal) * 0.25f;
				Object->SetLinearVelocity(A->Velocity);
			}
		}
		A->Location = V;
		A->Rotation = Rot;
	}
}

void FParticleRBPhysics::ActorMoved()
{
	if (Object)
		Object->SetPosition(&Owner->Location, &Owner->Rotation);
}

void FParticleRBPhysics::ActorLevelChange(class ULevel* OldLevel, class ULevel* NewLevel)
{
	GetScene()->SendToScene(Object, NewLevel->PhysicsScene);
	SetScene(NewLevel->PhysicsScene);
}

DWORD FParticleRBPhysics::GetType() const
{
	return OBJ_RigidBody;
}

void FParticleRBPhysics::WakeUp()
{
	if (Object)
		Object->WakeUp();
}
void FParticleRBPhysics::PutToSleep()
{
	if (Object)
		Object->PutToSleep();
}
UBOOL FParticleRBPhysics::IsASleep()
{
	return (Object ? Object->IsSleeping() : TRUE);
}
void FParticleRBPhysics::SetAngularVelocity(const FVector& NewVel)
{
	if (Object)
		Object->SetAngularVelocity(NewVel);
}
FVector FParticleRBPhysics::GetAngularVelocity()
{
	return (Object ? Object->GetAngularVelocity() : FVector(0, 0, 0));
}
void FParticleRBPhysics::SetGravity(const FVector& NewGravity)
{
	if (Object)
		Object->SetGravity(NewGravity);
}
void FParticleRBPhysics::SetConstVelocity(const FVector& NewVel)
{
	if (Object)
		Object->SetConstVelocity(NewVel);
}
void FParticleRBPhysics::SetMass(FLOAT NewMass)
{
	if (Object)
		Object->SetMass(NewMass);
}
void FParticleRBPhysics::DrawDebug()
{
	if (Object)
		Object->DrawDebug();
}

void AXRopeDeco::execBreakRope(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execBreakRope);
	P_GET_BYTE(Offset);
	P_FINISH;

	if (RbPhysicsData && RbPhysicsData->GetType() == FActorRBPhysicsBase::EPhysicsObjType::OBJ_Articulation && reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->BreakRope(Offset))
	{
		RopeBrokenIndex = reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->BrokenOffset;
		bForceNetUpdate = TRUE;
		bNetDirty = TRUE;
		eventOnRopeBreak(RopeBrokenIndex);
		RESULT_GET(UBOOL) = TRUE;
	}
	else RESULT_GET(UBOOL) = FALSE;
	unguardexec;
}
void AXRopeDeco::execResetRope(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execResetRope);
	P_FINISH;

	ExitRbPhysics();
	PiecePoints.Empty();
	if (RopeBrokenIndex < 255)
	{
		RopeBrokenIndex = 255;
		bNetDirty = TRUE;
		bForceNetUpdate = TRUE;
	}
	InitRbPhysics();
	unguardexec;
}
void AXRopeDeco::execSetStartLocation(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execSetStartLocation);
	P_GET_VECTOR(Offset);
	P_GET_ACTOR_OPTX(NewStart, nullptr);
	P_FINISH;

	Stack.Log(NAME_ScriptWarning, TEXT("XRopeDeco.SetStartLocation is not yet implemented!"));
	unguardexec;
}
void AXRopeDeco::execSetEndLocation(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execSetEndLocation);
	P_GET_UBOOL(bLooseEnd);
	P_GET_VECTOR_OPTX(Offset, FVector(0, 0, 0));
	P_GET_ACTOR_OPTX(NewEnd, nullptr);
	P_FINISH;

	Stack.Log(NAME_ScriptWarning, TEXT("XRopeDeco.SetEndLocation is not yet implemented!"));
	unguardexec;
}

BYTE AXRopeDeco::GetSplitOffset() const
{
	guard(AXRopeDeco::GetSplitOffset);
	return (RbPhysicsData && RbPhysicsData->GetType() == FActorRBPhysicsBase::EPhysicsObjType::OBJ_Articulation) ? reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->BrokenOffset : 255;
	unguard;
}

void AXRopeDeco::Serialize(FArchive& Ar)
{
	guard(AXRopeDeco::Serialize);
	if (Ar.SerializeRefs())
	{
		Ar << RopeMeshPtr;
		if(RbPhysicsData && RbPhysicsData->GetType() == FActorRBPhysicsBase::EPhysicsObjType::OBJ_Articulation)
			reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->Serialize(Ar);
		Super::Serialize(Ar);
	}
	else if (Ar.IsSaving())
	{
		if (RbPhysicsData && RbPhysicsData->GetType() == FActorRBPhysicsBase::EPhysicsObjType::OBJ_Articulation)
			reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->SaveState();
		Mesh = nullptr;
		Super::Serialize(Ar);
		Mesh = RopeMeshPtr;
	}
	else Super::Serialize(Ar);
	unguard;
}
