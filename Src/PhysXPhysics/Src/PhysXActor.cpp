
#include "PhysXPhysics.h"

//==========================================================================================
// Declarations

#define MAX_CONTACTS 4

struct FContactPair
{
	AActor* Other;
	FVector Location, Normal, Velocity;

	inline void Set(AActor* O, const FVector& L, const FVector& N, const FVector& F)
	{
		Other = O;
		Location = L;
		Normal = N;
		Velocity = F;
	}
};

struct FRigidBodyUserData : public FPhysXUserDataBase
{
	struct FPhysXActorRigidBody* Owner;
	INT NumContants;
	FContactPair PendingContants[MAX_CONTACTS];

	FRigidBodyUserData(FPhysXActorRigidBody* O);
	UBOOL OnContact(FPhysXUserDataBase* Other, const FVector& Position, const FVector& Normal, FLOAT Force);
	AActor* GetActorOwner() const;
};
struct FPhysXActorRigidBody : public PX_PhysicsObject, public FListedPhysXActor
{
	DECLARE_BASE_PX(PX_PhysicsObject, RBTYPE_RigidBody);

	FRigidBodyUserData UserData;
	FVector Gravity, ZoneVelocity;
	FLOAT ZoneSpeed, MinImpactThreshold;

	BITFIELD bHasZoneVelocity : 1, bWasSleeping : 1, bHasGravity : 1;

	FPhysXActorRigidBody(const FRigidBodyProperties& Parms, FPhysXScene* S, const FVector& Pos, const FRotator& Rot);
	~FPhysXActorRigidBody() noexcept(false);

	inline physx::PxVec3 GetDesiredZoneSpeed(FLOAT MaxDelta, physx::PxRigidDynamic* rb) const
	{
		FLOAT CurSpeed = (PXVectorToUE(rb->getLinearVelocity()) | ZoneVelocity);
		if (CurSpeed < ZoneSpeed)
			return UEVectorToPX(ZoneVelocity * Min(MaxDelta, ZoneSpeed - CurSpeed));
		return physx::PxVec3(physx::PxZero);
	}

	void PhysicsTick(FLOAT DeltaTime);

	// Set/Get values.
	FVector GetLinearVelocity();
	void SetLinearVelocity(const FVector& NewVel);
	FVector GetAngularVelocity();
	void SetAngularVelocity(const FVector& NewVel);
	FQuat GetRotation();
	void GetPosition(FVector* Pos, FRotator* Rot);
	void SetPosition(const FVector* NewPos, const FRotator* NewRot);
	UBOOL IsSleeping();
	void WakeUp();
	void PutToSleep();
	void Impulse(const FVector& Force, const FVector* Pos = NULL, UBOOL bCheckMass = TRUE);
	void SetGravity(const FVector& NewGrav);
	void SetConstVelocity(const FVector& NewVel);
	void SetMass(FLOAT NewMass);
	void SetLimits(FLOAT MaxAngVel, FLOAT MaxLinVel);
	void SetDampening(FLOAT AngVelDamp, FLOAT LinVelDamp);

	// Query for callback events (return TRUE if actor got destroyed and should halt process now).
	UBOOL ProcessCallbacks(FActorRBPhysicsBase* Obj);

	// Collision grouping
	void DisableCollision(DWORD ThisID, DWORD ColFlags);
	void SetCollisionFlags(DWORD Group, DWORD Flags);
};

struct FStaticBodyUserData : public FPhysXUserDataBase
{
	struct FPhysXStaticBody* Owner;

	FStaticBodyUserData(FPhysXStaticBody* O);
	UBOOL OnContact(FPhysXUserDataBase* Other, const FVector& Position, const FVector& Normal, FLOAT Force)
	{
		return FALSE;
	}
	AActor* GetActorOwner() const;
};
struct FPhysXStaticBody : public PX_PhysicsObject, public FPhysXActorBase
{
	DECLARE_BASE_PX(PX_PhysicsObject, RBTYPE_StaticBody);

	FStaticBodyUserData UserData;

	FPhysXStaticBody(AActor* A, FPhysXScene* S, const FVector& Pos, const FRotator& Rot);
	~FPhysXStaticBody() noexcept(false);

	// Set/Get values.
	void GetPosition(FVector* Pos, FRotator* Rot);
	void SetPosition(const FVector* NewPos, const FRotator* NewRot);
	FQuat GetRotation();

	// Collision grouping
	void SetCollisionFlags(DWORD Group, DWORD Flags);
};

struct FPlatformUserData : public FPhysXUserDataBase
{
	struct FPhysXPlatformBody* Owner;

	FPlatformUserData(FPhysXPlatformBody* O);
	UBOOL OnContact(FPhysXUserDataBase* Other, const FVector& Position, const FVector& Normal, FLOAT Force)
	{
		return FALSE;
	}
	AActor* GetActorOwner() const;
};
struct FPhysXPlatformBody : public PX_PhysicsObject, public FPhysXActorBase
{
	DECLARE_BASE_PX(PX_PhysicsObject, RBTYPE_Platform);

	FPlatformUserData UserData;

	FPhysXPlatformBody(AActor* A, FPhysXScene* S, const FVector& Pos, const FRotator& Rot);
	~FPhysXPlatformBody();

	// Set/Get values.
	void GetPosition(FVector* Pos, FRotator* Rot);
	void SetPosition(const FVector* NewPos, const FRotator* NewRot);
	FQuat GetRotation();

	// Collision grouping
	void SetCollisionFlags(DWORD Group, DWORD Flags);
};

//==========================================================================================
// Creation functions.

PX_PhysicsObject* FPhysXScene::CreatePlatform(AActor* Owner, const FVector& Pos, const FRotator& Rot)
{
	guard(FPhysXScene::CreatePlatform);
	return NewTagged(PHYS_X_NAME) FPhysXPlatformBody(Owner, this, Pos, Rot);
	unguard;
}
PX_PhysicsObject* FPhysXScene::CreateRigidBody(const FRigidBodyProperties& Parms, const FVector& Pos, const FRotator& Rot)
{
	guard(FPhysXScene::CreateRigidBody);
	return NewTagged(PHYS_X_NAME) FPhysXActorRigidBody(Parms, this, Pos, Rot);
	unguard;
}
PX_PhysicsObject* FPhysXScene::CreateStaticBody(AActor* Owner, const FVector& Pos, const FRotator& Rot)
{
	guard(FPhysXScene::CreateStaticBody);
	return NewTagged(PHYS_X_NAME) FPhysXStaticBody(Owner, this, Pos, Rot);
	unguard;
}

//==========================================================================================
// Rigid body

/*FPhysXActorRigidBody::FPhysXActorRigidBody(UPX_RigidBodyData* Data, FPhysXScene* S)
	: FListedPhysXActor(Data->Actor, S), rbActor(NULL), DataOwner(Data), NumContants(0), bWasSleeping(FALSE)
{}*/

FPhysXActorRigidBody::FPhysXActorRigidBody(const FRigidBodyProperties& Parms, FPhysXScene* S, const FVector& Pos, const FRotator& Rot)
	: PX_PhysicsObject(Parms.Actor,S), FListedPhysXActor(S), UserData(this), MinImpactThreshold(Parms.MinImpactThreshold), bWasSleeping(FALSE)
{
	physx::PxRigidDynamic* dyn = nullptr;
	{
		FINISH_PHYSX_THREAD;
		// Init physics
		dyn = UPhysXPhysics::physXScene->createRigidDynamic(UECoordsToPX(Pos, Rot));
		if (!dyn)
			return;

		STAT(++GPhysXStats.RigidObjCount.Count);

		dyn->setLinearVelocity(UEVectorToPX(Parms.LinearVelocity));
		dyn->setAngularVelocity(UENormalToPX(Parms.AngularVelocity));
		dyn->setContactReportThreshold(Parms.MinImpactThreshold * UEScaleToPX);
		dyn->setSolverIterationCounts(8, 4);
		dyn->setSleepThreshold(2.f);
		dyn->setMass(Parms.Mass * UEMassToPX);
		dyn->setActorFlags(physx::PxActorFlag::eDISABLE_GRAVITY);
		dyn->userData = &UserData;
		rbActor = dyn;
	}

	Parms.CollisionShape->ApplyShape(this, Parms.Scale3D);

	FINISH_PHYSX_THREAD;
	// Init mass
	physx::PxVec3 COM = UEVectorToPX(Parms.COMOffset);
	physx::PxRigidBodyExt::updateMassAndInertia(*dyn, Parms.Mass * UEMassToPX, &COM);

	S->pxScene->addActor(*dyn);
}

FPhysXActorRigidBody::~FPhysXActorRigidBody() noexcept(false)
{
	guard(FPhysXActorRigidBody::~FPhysXActorRigidBody);
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		STAT(--GPhysXStats.RigidObjCount.Count);
		reinterpret_cast<FPhysXScene*>(Scene)->pxScene->removeActor(*reinterpret_cast<physx::PxRigidDynamic*>(rbActor));
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->release();
		rbActor = nullptr;
	}
	unguard;
}

void FPhysXActorRigidBody::PhysicsTick(FLOAT DeltaTime)
{
	if (!rbActor)
		return;

	// Make standing pawns add some weight ontop of this.
	physx::PxRigidDynamic* dyn = reinterpret_cast<physx::PxRigidDynamic*>(rbActor);
	AActor::GBasedListMutex.lock();
	if (Actor->RealBasedActors)
	{
		physx::PxTransform T = dyn->getCMassLocalPose() * dyn->getGlobalPose();
		FVector ComCenter = PXVectorToUE(T.p);
		AActor* B;
		for (INT i = (Actor->RealBasedActors->Num() - 1); i >= 0; --i)
		{
			B = (*Actor->RealBasedActors)(i);
			if (B && B->bIsPawn)
			{
				// Check if pawn radius encapsules center of mass.
				if ((ComCenter - B->Location).SizeSquared2D() < Square(B->CollisionRadius + 50.f))
				{
					physx::PxVec3 Vel = UEVectorToPX((B->Velocity + B->Region.Zone->ZoneGravity) * Min(B->Mass / Actor->Mass, 5.f) * DeltaTime);
					dyn->addForce(Vel, physx::PxForceMode::eVELOCITY_CHANGE);
					dyn->wakeUp();
				}
				else
				{
					physx::PxVec3 Vel, Ang;
					FLOAT InvMass = (1.f / Actor->Mass);
					physx::PxRigidBodyExt::computeLinearAngularImpulse(*dyn, dyn->getGlobalPose(), UEVectorToPX(B->Location), UEVectorToPX(((B->Velocity * 2.f) + B->Region.Zone->ZoneGravity) * Min(B->Mass, 1000.f) * DeltaTime), InvMass, InvMass * 0.00025f, Vel, Ang);
					dyn->addForce(Vel, physx::PxForceMode::eVELOCITY_CHANGE);
					dyn->addTorque(Ang, physx::PxForceMode::eVELOCITY_CHANGE);
					dyn->wakeUp();
					//physx::PxRigidBodyExt::addForceAtPos(*phyb->rbActor, VectToNX3v(((B->Velocity * 0.5f) + B->Region.Zone->ZoneGravity) * B->Mass * DeltaTime), VectToNX3v(B->Location), physx::PxForceMode::eFORCE, true);
				}
			}
		}
	}
	AActor::GBasedListMutex.unlock();

	// Don't accumulate forces in sleeping objects, else they explode when waking up
	if (dyn->isSleeping())
		return;

	if (bHasGravity)
		dyn->addForce(UEVectorToPX(Gravity * DeltaTime), physx::PxForceMode::eVELOCITY_CHANGE, false);

	if (bHasZoneVelocity)
		dyn->addForce(GetDesiredZoneSpeed(ZoneSpeed * 5.f * DeltaTime, dyn), physx::PxForceMode::eVELOCITY_CHANGE, false);
}

// Set/Get values.
FVector FPhysXActorRigidBody::GetLinearVelocity()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return PXVectorToUE(reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getLinearVelocity());
	}
	return FVector(0, 0, 0);
}
void FPhysXActorRigidBody::SetLinearVelocity(const FVector& NewVel)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setLinearVelocity(UEVectorToPX(NewVel));
	}
}
FVector FPhysXActorRigidBody::GetAngularVelocity()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return PXNormalToUE(reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getAngularVelocity());
	}
	return FVector(0, 0, 0);
}
void FPhysXActorRigidBody::SetAngularVelocity(const FVector& NewVel)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setAngularVelocity(UENormalToPX(NewVel));
	}
}
void FPhysXActorRigidBody::GetPosition(FVector* Pos, FRotator* Rot)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxTransform T = reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getGlobalPose();
		FCoords C = PXCoordsToUE(T);
		if (Pos)
			*Pos = C.Origin;
		if (Rot)
			*Rot = C.OrthoRotation();
	}
}
void FPhysXActorRigidBody::SetPosition(const FVector* NewPos, const FRotator* NewRot)
{
	if (rbActor)
		FPhysXScene::SetOptionalPosition(reinterpret_cast<physx::PxRigidDynamic*>(rbActor), NewPos, NewRot);
}
FQuat FPhysXActorRigidBody::GetRotation()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return PXCoordsToUEQuat(reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getGlobalPose());
	}
	return FQuat(1.f, 0.f, 0.f, 0.f);
}
UBOOL FPhysXActorRigidBody::IsSleeping()
{
	FINISH_PHYSX_THREAD;
	return rbActor ? UBOOL(reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->isSleeping()) : FALSE;
}
void FPhysXActorRigidBody::WakeUp()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->wakeUp();
	}
}
void FPhysXActorRigidBody::PutToSleep()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->putToSleep();
	}
}
void FPhysXActorRigidBody::Impulse(const FVector& Force, const FVector* Pos, UBOOL bCheckMass)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		if (Pos)
		{
			physx::PxVec3 Vel, Ang;
			physx::PxRigidDynamic* dyn = reinterpret_cast<physx::PxRigidDynamic*>(rbActor);
			FLOAT InvMass = bCheckMass ? (1.f / Actor->Mass) : 1.f;
			physx::PxRigidBodyExt::computeLinearAngularImpulse(*dyn, dyn->getGlobalPose(), UEVectorToPX(*Pos), UEVectorToPX(Force), InvMass, InvMass * 0.00025f, Vel, Ang);
			dyn->addForce(Vel, physx::PxForceMode::eVELOCITY_CHANGE);
			dyn->addTorque(Ang, physx::PxForceMode::eVELOCITY_CHANGE);
		}
		else reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->addForce(UEVectorToPX(bCheckMass ? (Force / Actor->Mass) : Force), physx::PxForceMode::eVELOCITY_CHANGE);
	}
}
void FPhysXActorRigidBody::SetGravity(const FVector& NewGrav)
{
	FINISH_PHYSX_THREAD;
	Gravity = NewGrav;
	bHasGravity = !NewGrav.IsZero();
}
void FPhysXActorRigidBody::SetConstVelocity(const FVector& NewVel)
{
	FINISH_PHYSX_THREAD;
	ZoneSpeed = NewVel.SizeSquared();
	bHasZoneVelocity = (ZoneSpeed > 1.f);
	if (bHasZoneVelocity)
	{
		ZoneSpeed = appSqrt(ZoneSpeed);
		ZoneVelocity = NewVel / ZoneSpeed;
	}
}
void FPhysXActorRigidBody::SetMass(FLOAT NewMass)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setMass(NewMass * UEMassToPX);
	}
}
void FPhysXActorRigidBody::SetLimits(FLOAT MaxAngVel, FLOAT MaxLinVel)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setMaxAngularVelocity(MaxAngVel);
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setMaxLinearVelocity(MaxLinVel * UEScaleToPX);
	}
}
void FPhysXActorRigidBody::SetDampening(FLOAT AngVelDamp, FLOAT LinVelDamp)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setAngularDamping(AngVelDamp);
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->setLinearDamping(LinVelDamp);
	}
}

struct FTempContact
{
	AActor* Other;
	FLOAT ContactForce;
	FVector ContactPos, ContactNormal;

	inline void Set(AActor* A, FLOAT F, const FVector& Pos, const FVector& Normal)
	{
		Other = A;
		ContactForce = F;
		ContactPos = Pos;
		ContactNormal = Normal;
	}
};

// Query for callback events (return TRUE if actor got destroyed and should halt process now).
UBOOL FPhysXActorRigidBody::ProcessCallbacks(FActorRBPhysicsBase* Obj)
{
	static FTempContact TempContacts[MAX_CONTACTS];
	BYTE RealContacts = 0;
	{
		FINISH_PHYSX_THREAD;

		// Send UnrealScript callbacks.
		if (UserData.NumContants && rbActor)
		{
			AActor* Other;
			FVector v = PXVectorToUE(reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getLinearVelocity());
			for (INT i = 0; i < UserData.NumContants; ++i)
			{
				Other = UserData.PendingContants[i].Other;
				if (!Other || Other->bDeleteMe)
					continue;
				FLOAT RealForce = (v - UserData.PendingContants[i].Velocity).Size();
				if (RealForce > MinImpactThreshold)
					TempContacts[RealContacts++].Set(Other, RealForce, UserData.PendingContants[i].Location, UserData.PendingContants[i].Normal);
			}
			UserData.NumContants = 0;
		}
	}
	// Must move it out of PhysicsSimulation mutex or it will crash with double lock call when sub-routine ends up destroying actor.
	if (RealContacts)
	{
		AActor* Other;
		volatile AActor* A = Actor;
		volatile FActorRBPhysicsBase* Org = A->RbPhysicsData;

		for (BYTE i = 0; i < RealContacts; ++i)
		{
			Other = UserData.PendingContants[i].Other;
			if (!Other->bDeleteMe)
			{
				Obj->PhysicsImpact(this, Other, TempContacts[i].ContactForce, TempContacts[i].ContactPos, TempContacts[i].ContactNormal);
				if (A->bDeleteMe || A->RbPhysicsData != Org) // Make sure actor wasn't destroyed or changed physics.
					return TRUE;
			}
		}
	}
	return FALSE;
}

// Collision grouping
void FPhysXActorRigidBody::DisableCollision(DWORD ThisID, DWORD ColFlags)
{
	/*if (rbActor)
	{
		FINISH_PHYSX_THREAD;
	}*/
}

void FPhysXActorRigidBody::SetCollisionFlags(DWORD Group, DWORD Flags)
{
	if (rbActor)
		FPhysXScene::SetActorCollisionFlags(reinterpret_cast<physx::PxRigidDynamic*>(rbActor), Group, Flags);
}

UBOOL FRigidBodyUserData::OnContact(FPhysXUserDataBase* Other, const FVector& Position, const FVector& Normal, FLOAT Force)
{
	if (Force > Owner->MinImpactThreshold && NumContants < MAX_CONTACTS)
	{
		AActor* A = Other ? Other->GetActorOwner() : Owner->GetActor()->Level;
		if (A)
			PendingContants[NumContants++].Set(A, Position, Normal, PXVectorToUE(reinterpret_cast<physx::PxRigidDynamic*>(Owner->GetRbActor())->getLinearVelocity()));
	}
	return FALSE;
}
AActor* FRigidBodyUserData::GetActorOwner() const
{
	return Owner->GetActor();
}

FRigidBodyUserData::FRigidBodyUserData(FPhysXActorRigidBody* O)
	: Owner(O), NumContants(0)
{
}

//==========================================================================================
// Static body

FPhysXStaticBody::FPhysXStaticBody(AActor* A, FPhysXScene* S, const FVector& Pos, const FRotator& Rot)
	: PX_PhysicsObject(A, S), UserData(this)
{
	guard(FPhysXStaticBody::FPhysXStaticBody);
	// Init physics
	FINISH_PHYSX_THREAD;
	physx::PxRigidStatic* st = UPhysXPhysics::physXScene->createRigidStatic(UECoordsToPX(Pos, Rot));
	if (!st)
		return;

	st->userData = &UserData;
	reinterpret_cast<FPhysXScene*>(S)->pxScene->addActor(*st);
	rbActor = st;
	unguard;
}
FPhysXStaticBody::~FPhysXStaticBody() noexcept(false)
{
	guard(FPhysXStaticBody::~FPhysXStaticBody);
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		reinterpret_cast<FPhysXScene*>(Scene)->pxScene->removeActor(*reinterpret_cast<physx::PxRigidStatic*>(rbActor));
		reinterpret_cast<physx::PxRigidStatic*>(rbActor)->release();
	}
	unguard;
}

// Set/Get values.
void FPhysXStaticBody::GetPosition(FVector* Pos, FRotator* Rot)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxTransform T = reinterpret_cast<physx::PxRigidStatic*>(rbActor)->getGlobalPose();
		FCoords C = PXCoordsToUE(T);
		if (Pos)
			*Pos = C.Origin;
		if (Rot)
			*Rot = C.OrthoRotation();
	}
}
void FPhysXStaticBody::SetPosition(const FVector* NewPos, const FRotator* NewRot)
{
	if (rbActor)
		FPhysXScene::SetOptionalPosition(reinterpret_cast<physx::PxRigidStatic*>(rbActor), NewPos, NewRot);
}
FQuat FPhysXStaticBody::GetRotation()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return PXCoordsToUEQuat(reinterpret_cast<physx::PxRigidStatic*>(rbActor)->getGlobalPose());
	}
	return FQuat(1.f, 0.f, 0.f, 0.f);
}

void FPhysXStaticBody::SetCollisionFlags(DWORD Group, DWORD Flags)
{
	if (rbActor)
		FPhysXScene::SetActorCollisionFlags(reinterpret_cast<physx::PxRigidStatic*>(rbActor), Group, Flags);
}

FStaticBodyUserData::FStaticBodyUserData(FPhysXStaticBody* O)
	: Owner(O)
{}
AActor* FStaticBodyUserData::GetActorOwner() const
{
	return Owner->GetActor();
}

//==========================================================================================
// Platform body

FPhysXPlatformBody::FPhysXPlatformBody(AActor* A, FPhysXScene* S, const FVector& Pos, const FRotator& Rot)
	: PX_PhysicsObject(A, S), UserData(this)
{
	// Init physics
	FINISH_PHYSX_THREAD;
	physx::PxRigidDynamic* dyn = UPhysXPhysics::physXScene->createRigidDynamic(UECoordsToPX(Pos, Rot));
	if (!dyn)
		return;

	//rbActor->userData = new FRigidBodyUserData(this);
	dyn->setContactReportThreshold(0);
	dyn->setSolverIterationCounts(8, 6);
	dyn->setSleepThreshold(1.f);
	dyn->setMass(9999.f);
	dyn->setActorFlags(physx::PxActorFlag::eDISABLE_GRAVITY);
	dyn->setRigidBodyFlags(physx::PxRigidBodyFlag::eKINEMATIC);
	dyn->userData = &UserData;
	S->pxScene->addActor(*dyn);
	rbActor = dyn;
}
FPhysXPlatformBody::~FPhysXPlatformBody()
{
	guard(FPhysXPlatformBody::~FPhysXPlatformBody);
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		((FPhysXScene*)Scene)->pxScene->removeActor(*reinterpret_cast<physx::PxRigidDynamic*>(rbActor));
		reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->release();
	}
	unguard;
}
void FPhysXPlatformBody::GetPosition(FVector* Pos, FRotator* Rot)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxTransform T = reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getGlobalPose();
		FCoords C = PXCoordsToUE(T);
		if (Pos)
			*Pos = C.Origin;
		if (Rot)
			*Rot = C.OrthoRotation();
	}
}
void FPhysXPlatformBody::SetPosition(const FVector* NewPos, const FRotator* NewRot)
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		physx::PxRigidDynamic* k = reinterpret_cast<physx::PxRigidDynamic*>(rbActor);
		if (NewPos && NewRot)
			k->setKinematicTarget(UECoordsToPX(*NewPos, *NewRot));
		else if (NewPos)
		{
			physx::PxTransform T = k->getGlobalPose();
			T.p = UEVectorToPX(*NewPos);
			k->setKinematicTarget(T);
		}
		else if (NewRot)
		{
			physx::PxTransform T = k->getGlobalPose();
			T.q = UERotatorToPX(*NewRot);
			k->setKinematicTarget(T);
		}
	}
}
FQuat FPhysXPlatformBody::GetRotation()
{
	if (rbActor)
	{
		FINISH_PHYSX_THREAD;
		return PXCoordsToUEQuat(reinterpret_cast<physx::PxRigidDynamic*>(rbActor)->getGlobalPose());
	}
	return FQuat(1.f, 0.f, 0.f, 0.f);
}

void FPhysXPlatformBody::SetCollisionFlags(DWORD Group, DWORD Flags)
{
	if (rbActor)
		FPhysXScene::SetActorCollisionFlags(reinterpret_cast<physx::PxRigidDynamic*>(rbActor), Group, Flags);
}

FPlatformUserData::FPlatformUserData(FPhysXPlatformBody* O)
	: Owner(O)
{}
AActor* FPlatformUserData::GetActorOwner() const
{
	return Owner->GetActor();
}
