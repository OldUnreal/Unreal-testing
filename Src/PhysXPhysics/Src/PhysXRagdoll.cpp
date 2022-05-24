
#include "PhysXPhysics.h"

//==========================================================================================
// Declarations

struct FPhysXArticulationBody : public PX_ArticulationList, public FListedPhysXActor
{
	DECLARE_BASE_PX(PX_ArticulationList, RBTYPE_Articulation);

	FVector Gravity;

	BITFIELD bAddedScene : 1, bHasGravity : 1;

	FPhysXArticulationBody(AActor* A, FPhysXScene* S, INT NumIterations);
	~FPhysXArticulationBody() noexcept(false);

	PX_ArticulationLink* CreateArticulationLink(const FArticulationProperties& Parms, const FVector& Pos, const FRotator& Rot);
	void FinishArticulation();

	UBOOL IsSleeping();
	void WakeUp();
	void PutToSleep();
	void SetGravity(const FVector& NewGrav);

	void PhysicsTick(FLOAT DeltaTime);

	// Collision grouping
	void SetCollisionFlags(DWORD Group, DWORD Flags);
};
struct FPhysXArticulationLink : public PX_ArticulationLink, public FPhysXActorBase
{
	DECLARE_BASE_PX(PX_ArticulationLink, RBTYPE_ArticulationLink);

	FPhysXArticulationLink(FPhysXArticulationBody* B, const FArticulationProperties& Parms, FPhysXScene* S, const FVector& Pos, const FRotator& Rot);
	~FPhysXArticulationLink() noexcept(false);

	void SetMass(FLOAT NewMass);
	void SetLimits(FLOAT MaxAngVel, FLOAT MaxLinVel);
	void SetDampening(FLOAT AngVelDamp, FLOAT LinVelDamp);

	FVector GetLinearVelocity();
	void SetLinearVelocity(const FVector& NewVel);
	FVector GetAngularVelocity();
	void SetAngularVelocity(const FVector& NewVel);
	void GetPosition(FVector* Pos, FRotator* Rot);
	void SetPosition(const FVector* NewPos, const FRotator* NewRot);
	FQuat GetRotation();
	void Impulse(const FVector& Force, const FVector* Pos = NULL, UBOOL bCheckMass = TRUE);

	void SetJointCoords(const FCoords& A, const FCoords& B);

	void MainDestroyed();

	// Collision grouping
	void SetCollisionFlags(DWORD Group, DWORD Flags);
};

//==========================================================================================
// Constructions

#define GET_BODY(ref) reinterpret_cast<PhysXArtBodyType*>(ref)
#define GET_LINK(ref) reinterpret_cast<PhysXArtLinkType*>(ref)

PX_ArticulationList* FPhysXScene::CreateArticulation(AActor* Owner, INT NumIterations)
{
	guard(FPhysXScene::CreateArticulation);
	return NewTagged(PHYS_X_NAME) FPhysXArticulationBody(Owner, this, NumIterations);
	unguard;
}
PX_ArticulationLink* FPhysXArticulationBody::CreateArticulationLink(const FArticulationProperties& Parms, const FVector& Pos, const FRotator& Rot)
{
	guard(FPhysXArticulationBody::CreateArticulationLink);
	FPhysXArticulationLink* NewLink = NewTagged(PHYS_X_NAME) FPhysXArticulationLink(this, Parms, pxScene, Pos, Rot);
	if (!NewLink->GetRbActor())
	{
		delete NewLink;
		NewLink = nullptr;
	}
	return NewLink;
	unguard;
}
void FPhysXArticulationBody::FinishArticulation()
{
	guard(FPhysXArticulationBody::FinishArticulation);
	if (!bAddedScene)
	{
		FINISH_PHYSX_THREAD;
		bAddedScene = TRUE;
		pxScene->pxScene->addArticulation(*GET_BODY(rbActor));
		//GET_BODY(rbActor)->setArticulationFlags(physx::PxArticulationFlag::eFIX_BASE);
	}
	unguard;
}

//==========================================================================================
// Articulation body

FPhysXArticulationBody::FPhysXArticulationBody(AActor* A, FPhysXScene* S, INT NumIterations)
	: PX_ArticulationList(A, S), FListedPhysXActor(S), bAddedScene(FALSE), bHasGravity(FALSE)
{
	guard(FPhysXArticulationBody::FPhysXArticulationBody);
	FINISH_PHYSX_THREAD;
	PhysXArtBodyType* Articulation = UPhysXPhysics::physXScene->createArticulationReducedCoordinate();
	rbActor = Articulation;

	// Stabilization can create artefacts on jointed objects so we just disable it
	//Articulation->setStabilizationThreshold(0.0f);
	//Articulation->setMaxProjectionIterations(NumIterations);
	//Articulation->setSeparationTolerance(0.001f);

	STAT(++GPhysXStats.RagdollObjCount.Count);
	unguard;
}
FPhysXArticulationBody::~FPhysXArticulationBody() noexcept(false)
{
	guard(FPhysXArticulationBody::~FPhysXArticulationBody);
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		if (bAddedScene)
			reinterpret_cast<FPhysXScene*>(Scene)->pxScene->removeArticulation(*GET_BODY(rbActor));
		GET_BODY(rbActor)->release();

		for (PX_ArticulationLink* L = GetList(); L; L = L->GetListNext())
			reinterpret_cast<FPhysXArticulationLink*>(L)->MainDestroyed();
	}
	STAT(--GPhysXStats.RagdollObjCount.Count);
	unguard;
}
void FPhysXArticulationBody::PhysicsTick(FLOAT DeltaTime)
{
	if (bHasGravity)
	{
		// Don't accumulate forces in sleeping objects, else they explode when waking up
		if (GET_BODY(rbActor)->isSleeping())
			return;

		for (PX_ArticulationLink* L = GetList(); L; L = L->GetListNext())
			GET_LINK(L->GetRbActor())->addForce(VectToNX3v(Gravity * DeltaTime), physx::PxForceMode::eVELOCITY_CHANGE, false);
	}
}
UBOOL FPhysXArticulationBody::IsSleeping()
{
	FINISH_PHYSX_THREAD;
	return rbActor ? UBOOL(GET_BODY(rbActor)->isSleeping()) : FALSE;
}
void FPhysXArticulationBody::WakeUp()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_BODY(rbActor)->wakeUp();
	}
}
void FPhysXArticulationBody::PutToSleep()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_BODY(rbActor)->putToSleep();
	}
}
void FPhysXArticulationBody::SetGravity(const FVector& NewGrav)
{
	FINISH_PHYSX_THREAD;
	Gravity = NewGrav;
	bHasGravity = !NewGrav.IsZero();
}
void FPhysXArticulationBody::SetCollisionFlags(DWORD Group, DWORD Flags)
{
	guard(FPhysXArticulationBody::SetCollisionFlags);
	if (rbActor)
	{
		for (PX_ArticulationLink* L = GetList(); L; L = L->GetListNext())
			L->SetCollisionFlags(Group, Flags);
	}
	unguard;
}

FPhysXArticulationLink::FPhysXArticulationLink(FPhysXArticulationBody* B, const FArticulationProperties& Parms, FPhysXScene* S, const FVector& Pos, const FRotator& Rot)
	: PX_ArticulationLink(B, Parms.ParentLink, Parms.Actor, S)
{
	PhysXArtLinkType* Link = NULL;
	if (B->GetRbActor())
	{
		FINISH_PHYSX_THREAD;
		Link = GET_BODY(B->GetRbActor())->createLink(Parms.ParentLink ? GET_LINK(Parms.ParentLink->GetRbActor()) : nullptr, NXCoordsToMatrix(Pos, Rot));
		rbActor = Link;
	}
	if (Link)
	{
		Parms.CollisionShape->ApplyShape(this, Parms.Scale3D);

		// Init mass
		FINISH_PHYSX_THREAD;
		//physx::PxVec3 COM = VectToNX3v(Parms.COMOffset);
		physx::PxRigidBodyExt::updateMassAndInertia(*Link, Parms.Mass);
		Link->userData = NULL;

		physx::PxArticulationJointReducedCoordinate* rcJoint = static_cast<physx::PxArticulationJointReducedCoordinate*>(Link->getInboundJoint());
		if (rcJoint)
		{
			rcJoint->setJointType(physx::PxArticulationJointType::eSPHERICAL);
			rcJoint->setMotion(physx::PxArticulationAxis::eSWING2, physx::PxArticulationMotion::eFREE);
			rcJoint->setMotion(physx::PxArticulationAxis::eSWING1, physx::PxArticulationMotion::eFREE);
			rcJoint->setMotion(physx::PxArticulationAxis::eTWIST, physx::PxArticulationMotion::eFREE);
			rcJoint->setFrictionCoefficient(1.f);
			rcJoint->setMaxJointVelocity(1000.f);
		}
	}
	else GWarn->Logf(TEXT("PhysX::createLink failed, links overflowed or parent link was invalid!"));
}
FPhysXArticulationLink::~FPhysXArticulationLink() noexcept(false)
{
	guard(FPhysXArticulationLink::~FPhysXArticulationLink);
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_LINK(rbActor)->release();
	}
	unguard;
}
void FPhysXArticulationLink::SetMass(FLOAT NewMass)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_LINK(rbActor)->setMass(NewMass);
	}
}
void FPhysXArticulationLink::SetLimits(FLOAT MaxAngVel, FLOAT MaxLinVel)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_LINK(rbActor)->setMaxAngularVelocity(MaxAngVel);
		GET_LINK(rbActor)->setMaxLinearVelocity(MaxLinVel);
	}
}
void FPhysXArticulationLink::SetDampening(FLOAT AngVelDamp, FLOAT LinVelDamp)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_LINK(rbActor)->setAngularDamping(AngVelDamp);
		GET_LINK(rbActor)->setLinearDamping(LinVelDamp);
	}
}

void FPhysXArticulationLink::SetJointCoords(const FCoords& A, const FCoords& B)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxArticulationJointBase* J = GET_LINK(rbActor)->getInboundJoint();
		if (J)
		{
			J->setChildPose(NXCoordsToMatrix(A));
			J->setParentPose(NXCoordsToMatrix(B));
		}
	}
}

void FPhysXArticulationLink::MainDestroyed()
{
	rbActor = nullptr;
}

// Set/Get values.
FVector FPhysXArticulationLink::GetLinearVelocity()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return NX3vToVect(GET_LINK(rbActor)->getLinearVelocity());
	}
	return FVector(0, 0, 0);
}
void FPhysXArticulationLink::SetLinearVelocity(const FVector& NewVel)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_LINK(rbActor)->setLinearVelocity(VectToNX3v(NewVel));
	}
}
FVector FPhysXArticulationLink::GetAngularVelocity()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return NX3vToVect(GET_LINK(rbActor)->getAngularVelocity());
	}
	return FVector(0, 0, 0);
}
void FPhysXArticulationLink::SetAngularVelocity(const FVector& NewVel)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		GET_LINK(rbActor)->setAngularVelocity(VectToNX3v(NewVel));
	}
}
void FPhysXArticulationLink::GetPosition(FVector* Pos, FRotator* Rot)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxTransform T = GET_LINK(rbActor)->getGlobalPose();
		FCoords C = NXMatrixToCoords(T);
		if (Pos)
			*Pos = C.Origin;
		if (Rot)
			*Rot = C.OrthoRotation();
	}
}
void FPhysXArticulationLink::SetPosition(const FVector* NewPos, const FRotator* NewRot)
{
	if (rbActor)
		FPhysXScene::SetOptionalPosition(GET_LINK(rbActor), NewPos, NewRot);
}
FQuat FPhysXArticulationLink::GetRotation()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxTransform T = GET_LINK(rbActor)->getGlobalPose();
		return FQuat(T.q.x, T.q.y, T.q.z, T.q.w);
	}
	return FQuat(1.f, 0.f, 0.f, 0.f);
}
void FPhysXArticulationLink::Impulse(const FVector& Force, const FVector* Pos, UBOOL bCheckMass)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		if (Pos)
		{
			physx::PxVec3 Vel, Ang;
			PhysXArtLinkType* dyn = GET_LINK(rbActor);
			FLOAT InvMass = bCheckMass ? (1.f / Actor->Mass) : 1.f;
			physx::PxRigidBodyExt::computeLinearAngularImpulse(*dyn, dyn->getGlobalPose(), VectToNX3v(*Pos), VectToNX3v(Force), InvMass, InvMass * 0.00025f, Vel, Ang);
			dyn->addForce(Vel, physx::PxForceMode::eVELOCITY_CHANGE);
			dyn->addTorque(Ang, physx::PxForceMode::eVELOCITY_CHANGE);
		}
		else GET_LINK(rbActor)->addForce(VectToNX3v(bCheckMass ? (Force / Actor->Mass) : Force), physx::PxForceMode::eVELOCITY_CHANGE);
	}
}
void FPhysXArticulationLink::SetCollisionFlags(DWORD Group, DWORD Flags)
{
	if (rbActor)
		FPhysXScene::SetActorCollisionFlags(GET_LINK(rbActor), Group, Flags);
}
