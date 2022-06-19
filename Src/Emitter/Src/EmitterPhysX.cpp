
#include "EmitterPrivate.h"

struct FParticleRBPhysics : public FActorRBPhysicsBase
{
	UBOOL bWasAsleep;
	PX_PhysicsObject* Object;
	UPX_RigidBodyData* Data;

	FParticleRBPhysics(AActor* A, PX_SceneBase* Scene, PX_PhysicsObject* Obj, UPX_RigidBodyData* D)
		: FActorRBPhysicsBase(A, Scene, TRUE), bWasAsleep(FALSE), Object(Obj), Data(D)
	{
		check(Obj != NULL);
	}
	~FParticleRBPhysics()
	{
		if (Object)
			delete Object;
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
	void ActorMoved()
	{
		if (Object)
			Object->SetPosition(&Owner->Location, &Owner->Rotation);
	}

	void ActorLevelChange(class ULevel* OldLevel, class ULevel* NewLevel)
	{
		GetScene()->SendToScene(Object, NewLevel->PhysicsScene);
		SetScene(NewLevel->PhysicsScene);
	}

	DWORD GetType() const
	{
		return OBJ_RigidBody;
	}

	void WakeUp()
	{
		if (Object)
			Object->WakeUp();
	}
	void PutToSleep()
	{
		if (Object)
			Object->PutToSleep();
	}
	UBOOL IsASleep()
	{
		return (Object ? Object->IsSleeping() : TRUE);
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
	}
	void SetConstVelocity(const FVector& NewVel)
	{
		if (Object)
			Object->SetConstVelocity(NewVel);
	}
	void SetMass(FLOAT NewMass)
	{
		if (Object)
			Object->SetMass(NewMass);
	}
};

void AXEmitter::InitPhysXParticle(xParticle* A)
{
	guard(AXEmitter::InitPhysXParticle);
	UPX_RigidBodyData* RBD = Cast<UPX_RigidBodyData>(PhysicsData);
	if (!RBD || !RBD->CollisionShape || !XLevel->PhysicsScene || !RBD->CollisionShape->IsValidShape())
		return;

	RBD->Actor = A;
	PX_PhysicsObject* P = XLevel->PhysicsScene->CreateRigidBody(FRigidBodyProperties(RBD), A->Location, A->Rotation);
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

// Rope Deco:
IMPLEMENT_CLASS(AXRopeDeco);

class EMITTER_API URopeMesh : public UStaticMesh
{
	DECLARE_CLASS(URopeMesh, UStaticMesh, CLASS_Transient, Emitter);

	AXRopeDeco* RopeOwner;
	BYTE InitSize;

	URopeMesh() {}
public:
	URopeMesh(AXRopeDeco* D)
		: RopeOwner(D)
	{
		Update();
	}
	void Update()
	{
		guard(URopeMesh::Update);
		const INT NumSegments = Max<INT>(RopeOwner->NumSegments, 1);
		const INT DblSeg = (NumSegments << 1);
		INT i;
		InitSize = RopeOwner->NumSegments;
		FrameVerts = DblSeg + 2;
		SMTris.SetSize(DblSeg);
		{
			FStaticMeshTri* T = &SMTris(0);
			FLOAT UMap = 0.f;
			const FLOAT UInc = RopeOwner->TexVertScaling;
			FLOAT UEnd = UInc;
			for (i = 0; i < DblSeg; ++i)
			{
				T[i].GroupIndex = 0;
				if (i & 1)
				{
					T[i].iVertex[0] = i;
					T[i].iVertex[1] = i + 2;
					T[i].iVertex[2] = i + 1;
					T[i].Tex[0].Set(UMap, 1.f);
					T[i].Tex[1].Set(UEnd, 1.f);
					T[i].Tex[2].Set(UEnd, 0.f);
					UMap = UEnd;
					UEnd += UInc;
				}
				else
				{
					T[i].iVertex[0] = i;
					T[i].iVertex[1] = i + 1;
					T[i].iVertex[2] = i + 2;
					T[i].Tex[0].Set(UMap, 0.f);
					T[i].Tex[1].Set(UMap, 1.f);
					T[i].Tex[2].Set(UEnd, 0.f);
				}
			}
		}
		Connects.SetSize(FrameVerts);
		VertLinks.SetSize(NumSegments + 1);
		{
			FMeshVertConnect* C = &Connects(0);
			INT* V = &VertLinks(0);
			for (i = 0; i < FrameVerts; ++i)
			{
				C[i].NumVertTriangles = 1;
				C[i].TriangleListOffset = (i >> 1);
			}
			for (i = 0; i < NumSegments; ++i)
				V[i] = (i << 1);
			V[NumSegments] = DblSeg - 1;
		}
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
	void GetFrame(FVector* Verts, INT Size, FCoords Coords, AActor* Owner, INT* LODRequest = NULL)
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
			if (RopeOwner->RbPhysicsData)
				RopeOwner->SyncRBRope();
			else RopeOwner->SoftwareCalcRope();
		}

		FVector* V = &RopeOwner->RenderPoints(0);
		FCoords DirCoords(GMath.UnitCoords);
		FVector OldAxis;

		// Figure out first direction.
		FVector Dir(V[1] - V[0]);
		{
			DirCoords = (GMath.UnitCoords / Dir.Rotation());
			const FVector UpDir(DirCoords.XAxis);
			GetFaceCoords(V[0], Coords.Origin, UpDir, DirCoords);
			OldAxis = DirCoords.YAxis;
			DirCoords.ZAxis = DirCoords.YAxis;
		}

		const INT NumSegments = Max<INT>(RopeOwner->NumSegments, 1);
		const INT NumLoops = NumSegments + 1;
		const FLOAT Wide = RopeOwner->RopeThickness;
		for (INT i = 0; i < NumLoops; i++)
		{
			if (i > 0 && i < NumSegments)
			{
				Dir = (V[i + 1] - V[i]);
				DirCoords = (GMath.UnitCoords / Dir.Rotation());
				const FVector UpDir(DirCoords.XAxis);
				GetFaceCoords(V[i], Coords.Origin, UpDir, DirCoords);
				DirCoords.ZAxis = (DirCoords.YAxis + OldAxis).SafeNormal();
				OldAxis = DirCoords.YAxis;
			}

			*Verts = (V[i] - (DirCoords.ZAxis * Wide)).TransformPointBy(Coords);
			*(BYTE**)&Verts += Size;
			*Verts = (V[i] + (DirCoords.ZAxis * Wide)).TransformPointBy(Coords);
			*(BYTE**)&Verts += Size;
		}
		unguard;
	}
	FBox GetRenderBoundingBox(const AActor* Owner, UBOOL Exact)
	{
		guardSlow(URopeMesh::GetRenderBoundingBox);
		//FDebugLineData::DrawBox(BoundingBox.Min, BoundingBox.Max, FPlane(1, 0, 0, 1), 0);
		return BoundingBox;
		unguardSlow;
	}
	FSphere GetRenderBoundingSphere(const AActor* Owner, UBOOL Exact)
	{
		guardSlow(URopeMesh::GetRenderBoundingSphere);
		return BoundingSphere;
		unguardSlow;
	}
	FBox GetCollisionBoundingBox(const AActor* Owner)
	{
		guardSlow(URopeMesh::GetCollisionBoundingBox);
		return BoundingBox;
		unguardSlow;
	}
	UTexture* GetTexture(INT Count, AActor* Owner)
	{
		guardSlow(URopeMesh::GetTexture);
		return Owner->Texture;
		unguardSlow;
	}
	void SetupCollision()
	{
		CollisionState = 2;
	}
};
IMPLEMENT_CLASS(URopeMesh);

void AXRopeDeco::execResetRope(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execResetRope);
	P_FINISH;
	unguardexec;
}
void AXRopeDeco::execSetStartLocation(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execSetStartLocation);
	P_FINISH;
	unguardexec;
}
void AXRopeDeco::execSetEndLocation(FFrame& Stack, RESULT_DECL)
{
	guard(AXRopeDeco::execSetEndLocation);
	P_FINISH;
	unguardexec;
}
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
void AXRopeDeco::Serialize(FArchive& Ar)
{
	guard(AXRopeDeco::Serialize);
	if (Ar.SerializeRefs())
	{
		Ar << RopeMeshPtr;
		Super::Serialize(Ar);
	}
	else if (Ar.IsSaving())
	{
		Mesh = nullptr;
		Super::Serialize(Ar);
		Mesh = RopeMeshPtr;
	}
	else Super::Serialize(Ar);
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

void AXRopeDeco::SoftwareCalcRope()
{
	guard(AXRopeDeco::SoftwareCalcRope);
	const INT NumSegs = Max<INT>(NumSegments, 1);
	if (RenderPoints.Num() != (NumSegs + 1))
		RenderPoints.SetSize(NumSegs + 1);
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
	RopeLength = TotalLength;

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
		Dir /= CurDist;
		CurDir = (CurDir + Dir).SafeNormal();
		FVector StepPts(PrevPos + CurDir * LenPerSegment);
		ResultBounds += StepPts;
		Result[nSegments++] = StepPts;
		if (nSegments >= NumSegs)
			break;
		PrevPos = StepPts;

		if (SegmentsForThis > 1)
		{
			Dir = (*Target - PrevPos).SafeNormal();
			CurDir = Dir;
			for (j = 1; j < SegmentsForThis; ++j)
			{
				StepPts = PrevPos + Dir * LenPerSegment;
				ResultBounds += StepPts;
				Result[nSegments++] = StepPts;
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
	FVector EndPoint(GetEndOffset());
	INT i;
	AActor* A;
	FVector PrevPos(Location);
	URenderDevice* RenDev = Frame->Viewport->RenDev;
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
	Super::RenderSelectInfo(Frame);
	unguard;
}

struct FRopeSegment
{
	FRopeSegment* Next;
	PX_ArticulationLink* Object;
	FVector OldPos;

	FRopeSegment(PX_ArticulationLink* Obj, const FVector& V)
		: Next(nullptr), Object(Obj), OldPos(V)
	{}
};
struct FRopeRBPhysics : public FActorRBPhysicsBase
{
	UBOOL bWasAsleep;
	PX_ArticulationList* Object;
	FRopeSegment* Segments;
	UPX_RigidBodyData* Data;
	FVector OldPos;
	FRotator InitRot;
	UBOOL bInnerMove;
	UBOOL bJointBroken;

	FRopeRBPhysics(AActor* A, PX_SceneBase* Scene, PX_ArticulationList* Obj, UPX_RigidBodyData* D)
		: FActorRBPhysicsBase(A, Scene, FALSE), bWasAsleep(FALSE), Object(Obj), Segments(nullptr), Data(D), bInnerMove(FALSE), bJointBroken(FALSE)
	{
		check(Obj != NULL);
		OldPos = A->Location;
		InitRot = A->Rotation;
	}
	~FRopeRBPhysics() noexcept(false)
	{
		guard(FRopeRBPhysics::~FRopeRBPhysics);
		if (Object)
			delete Object;
		if (Segments)
		{
			FRopeSegment* N;
			for (FRopeSegment* R = Segments; R; R = N)
			{
				N = R->Next;
				delete R;
			}
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
		if (Object)
		{
			AActor* A = Owner;
			if (Object->ProcessCallbacks(this)) // Changed physics in a callback.
				return;

			FVector V;
			FCheckResult Hit;
			FBox NewBounds(0);
			for (FRopeSegment* R = Segments; R; R = R->Next)
			{
				R->Object->GetPosition(&V, NULL);
				if (R == Segments && !A->XLevel->SingleLineCheck(Hit, A, V, R->OldPos, (TRACE_Level | TRACE_Blocking))) // Tried to clip through world!
				{
					FVector NewVel = R->Object->GetLinearVelocity();
					V = Hit.Location + Hit.Normal * 8.f;
					R->Object->SetPosition(&V, NULL);

					NewVel = NewVel.MirrorByVector(Hit.Normal) * 0.25f;
					R->Object->SetLinearVelocity(NewVel);
				}
				R->OldPos = V;
				NewBounds += V;
			}
			reinterpret_cast<AXRopeDeco*>(A)->RopeMeshPtr->BoundingBox = NewBounds;
		}
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
		return OBJ_RigidBody;
	}

	void WakeUp()
	{
		if (Object)
			Object->WakeUp();
	}
	void PutToSleep()
	{
		if (Object)
			Object->PutToSleep();
	}
	UBOOL IsASleep()
	{
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
	}
	void SetConstVelocity(const FVector& NewVel)
	{
		if (Object)
			Object->SetConstVelocity(NewVel);
	}
	void SetMass(FLOAT NewMass)
	{
		if (Object)
			Object->SetMass(NewMass);
	}

	void PostInitJoints();
};

struct FRopeJoint : public PX_JointObject
{
	FRopeRBPhysics* OwnerRope;

	FRopeJoint(PX_PhysicsObject* A, PX_PhysicsObject* B, UPXJ_BaseJoint* J, FRopeRBPhysics* Rope)
		: PX_JointObject(A, B, J), OwnerRope(Rope)
	{}
	void OnJointBreak()
	{
		OwnerRope->bJointBroken = TRUE;
	}
};

void FRopeRBPhysics::PostInitJoints()
{
	guard(FRopeRBPhysics::PostInitJoints);
	// Init anchors...
	AXRopeDeco* RopeDeco = reinterpret_cast<AXRopeDeco*>(GetActor());
	if (RopeDeco->RopeJoint && Segments && (!RopeDeco->bHasLooseStart || !RopeDeco->bHasLooseEnd))
	{
		const FLOAT SegmentDist = (RopeDeco->RopeLength / Max<INT>(RopeDeco->NumSegments, 1)) * 0.51f;
		RopeDeco->RopeJoint->Owner = RopeDeco->PhysicsData;
		FVector RopePos;
		FRotator RopeRot;
		FCoords WorldCoords, CoordsA, CoordsB;
		FRopeJoint* NewJoint;
		PX_PhysicsObject* D;

		if (!RopeDeco->bHasLooseStart)
		{
			Segments->Object->GetPosition(&RopePos, &RopeRot);
			WorldCoords = GMath.UnitCoords * FVector(SegmentDist*1.1, 0, 0) / RopeRot / RopePos;
			CoordsA = WorldCoords * RopePos * RopeRot;

			if (RopeDeco->RopeStartActor && RopeDeco->RopeStartActor->RbPhysicsData && (D = RopeDeco->RopeStartActor->RbPhysicsData->GetRbObject()) != NULL)
				CoordsB = WorldCoords * RopeDeco->RopeStartActor->Location * RopeDeco->RopeStartActor->Rotation;
			else
			{
				CoordsB = WorldCoords;
				D = nullptr;
			}
			NewJoint = new FRopeJoint(Segments->Object, D, RopeDeco->RopeJoint, this);
			if (!RopeDeco->RopeJoint->InitJoint(*NewJoint, CoordsA, CoordsB))
				delete NewJoint;
		}

		if (!RopeDeco->bHasLooseEnd)
		{
			FRopeSegment* Last = Segments;
			while (Last->Next)
				Last = Last->Next;

			Last->Object->GetPosition(&RopePos, &RopeRot);
			WorldCoords = GMath.UnitCoords / FVector(SegmentDist*1.1, 0, 0) / RopeRot / RopePos;
			CoordsA = WorldCoords * RopePos * RopeRot;

			if (RopeDeco->RopeEndActor && RopeDeco->RopeEndActor->RbPhysicsData && (D = RopeDeco->RopeEndActor->RbPhysicsData->GetRbObject()) != NULL)
				CoordsB = WorldCoords * RopeDeco->RopeEndActor->Location * RopeDeco->RopeEndActor->Rotation;
			else
			{
				CoordsB = WorldCoords;
				D = nullptr;
			}
			NewJoint = new FRopeJoint(Last->Object, D, RopeDeco->RopeJoint, this);
			if (!RopeDeco->RopeJoint->InitJoint(*NewJoint, CoordsA, CoordsB))
				delete NewJoint;
		}
	}
	unguard;
}

void AXRopeDeco::OnJointBroken(UPXJ_BaseJoint* Joint)
{
	guard(AXRopeDeco::OnJointBroken);
	/*INT i = 0;
	RopeBreakIndex = 0;
	for (FRopeRBPhysics* R = reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData); R; R = R->NextRope, ++i)
	{
		if (R->bJointBroken)
		{
			R->bJointBroken = FALSE;
			RopeBreakIndex = i;
		}
	}
	eventPhysicsJointBreak(Joint);*/
	unguard;
}

void AXRopeDeco::SyncRBRope()
{
	guard(AXRopeDeco::SyncRBRope);
	if (RbPhysicsData)
	{
		FVector* V = &RenderPoints(0);
		FVector Pos;
		FRotator Rot;
		const FLOAT RopeSegSize = (RopeLength / Max<INT>(NumSegments, 1)) * 0.5f;
		for (FRopeSegment* R = reinterpret_cast<FRopeRBPhysics*>(RbPhysicsData)->Segments; R; R = R->Next)
		{
			R->Object->GetPosition(&Pos, &Rot);
			*V = Pos - Rot.Vector() * RopeSegSize;
			++V;
		}
		*V = Pos + (Rot.Vector() * RopeSegSize);
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
			
			UPXC_BoxCollision* CapCol = Cast<UPXC_BoxCollision>(PX->CollisionShape);
			if (!CapCol)
			{
				CapCol = new (GetOuter()) UPXC_BoxCollision();
				PX->CollisionShape = CapCol;
			}
			//CapCol->Radius = Max<FLOAT>(RopeThickness, 1.f);
			const INT NumSeg = Max<INT>(NumSegments, 1);
			const FLOAT SegmentDist = (RopeLength / Max<INT>(NumSegments, 1)) * 0.5f;
			//CapCol->Height = Max(SegmentDist, 0.01f);
			CapCol->Extent = FVector(SegmentDist, Max<FLOAT>(RopeThickness, 1.f), Max<FLOAT>(RopeThickness, 1.f));

			SoftwareCalcRope();
			FVector* V = &RenderPoints(0);
			FRopeRBPhysics* RPhys = NULL;
			PX_ArticulationList* A = XLevel->PhysicsScene->CreateArticulation(this, 16);
			if (A)
			{
				RPhys = new FRopeRBPhysics(this, XLevel->PhysicsScene, A, PX);
				const FVector OneScale(1.f, 1.f, 1.f);
				FArticulationProperties RbParms(this, OneScale, PX->COMOffset, Velocity, PX->AngularVelocity, Max<FLOAT>(Mass / NumSeg, 1.f), CapCol);
				FVector rPos;
				FRotator rDir;
				FRopeSegment* nPrev = NULL;

				FCoords CoordsA = GMath.UnitCoords * FVector(SegmentDist*1.1, 0, 0);
				FCoords CoordsB = GMath.UnitCoords / FVector(SegmentDist*1.1, 0, 0);
				
				for (INT i = 0; i < NumSeg; ++i)
				{
					FVector Dir(V[i + 1] - V[i]);
					rPos = V[i] + (Dir * 0.5f);
					rDir = Dir.Rotation();
					Dir.Normalize();
					//new FDebugLineData(rPos, rPos + Dir * 8.f, FPlane(1, 1, 0, 1), 1);
					//new FDebugLineData(rPos, rPos - Dir * 8.f, FPlane(1, 0, 1, 1), 1);
					Velocity = VRand() * 75.f;
					PX->AngularVelocity = VRand();
					PX_ArticulationLink* P = A->CreateArticulationLink(RbParms, rPos, rDir);
					if (P)
					{
						RbParms.ParentLink = P;
						FRopeSegment* nSeg = new FRopeSegment(P, rPos);
						if (nPrev)
						{
							nPrev->Next = nSeg;
							P->SetJointCoords(CoordsA, CoordsB);
						}
						else RPhys->Segments = nSeg;
						nPrev = nSeg;
					}
				}
				A->FinishArticulation();
				RPhys->OnZoneChange(Region.Zone);
			}

			RbPhysicsData = RPhys;
			if (PX->bStartSleeping)
				RPhys->PutToSleep();

			//RPhys->SetCollisionFlags((DWORD)CollisionGroups, (DWORD)CollisionFlag);
			RPhys->SetCollisionFlags(UCONST_COLLISIONFLAG_Movers, 0);
		}
	}
	else if (RbPhysicsData)
		ExitRbPhysics();
	unguardobj;
}
