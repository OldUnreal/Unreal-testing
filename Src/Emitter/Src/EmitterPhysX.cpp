
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
					Object->SetPosition(V, Rot);

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
			Object->SetPosition(Owner->Location, Owner->Rotation);
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

void AXEmitter::InitPhysXParticle(AActor* A, PartsType* Data)
{
	guard(AXEmitter::InitPhysXParticle);
	UPX_RigidBodyData* RBD = Cast<UPX_RigidBodyData>(PhysicsData);
	if (!RBD || !RBD->CollisionShape || !XLevel->PhysicsScene)
		return;

	PX_ShapesBase* Body = RBD->CollisionShape->GetShape();
	if (!Body)
		return;

	RBD->Actor = A;
	PX_PhysicsObject* P = XLevel->PhysicsScene->CreateRigidBody(RBD, Body);
	RBD->Actor = this;
	if (P)
	{
		A->RbPhysicsData = new FParticleRBPhysics(A, XLevel->PhysicsScene, P, RBD);
		P->SetLimits(RBD->MaxAngularVelocity, RBD->MaxLinearVelocity);
		P->SetDampening(RBD->AngularDamping, RBD->LinearDamping);
		P->SetGravity(A->Acceleration);
	}
	unguard;
}
void AXEmitter::ExitRbPhysics()
{
	Super::ExitRbPhysics();
	UEmitterRendering* Render = Cast<UEmitterRendering>(RenderInterface);
	if (Render)
		Render->HideAllParticles();
}
