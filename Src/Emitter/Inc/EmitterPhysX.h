#pragma once

struct EMITTER_API FParticleRBPhysics : public FActorRBPhysicsBase
{
	UBOOL bWasAsleep;
	PX_PhysicsObject* Object;
	UPX_RigidBodyData* Data;

	FParticleRBPhysics(AActor* A, PX_SceneBase* Scene, PX_PhysicsObject* Obj, UPX_RigidBodyData* D);
	~FParticleRBPhysics();

	PX_PhysicsObject* GetRbObject() const;
	UPX_PhysicsDataBase* GetPxData() const;
	void Tick(FLOAT DeltaTime);
	void ActorMoved();
	void ActorLevelChange(class ULevel* OldLevel, class ULevel* NewLevel);
	DWORD GetType() const;
	void WakeUp();
	void PutToSleep();
	UBOOL IsASleep();
	void SetAngularVelocity(const FVector& NewVel);
	FVector GetAngularVelocity();
	void SetGravity(const FVector& NewGravity);
	void SetConstVelocity(const FVector& NewVel);
	void SetMass(FLOAT NewMass);
	void DrawDebug();
};

class EMITTER_API URopeMesh : public UStaticMesh
{
	DECLARE_CLASS(URopeMesh, UStaticMesh, CLASS_Transient, Emitter);

	AXRopeDeco* RopeOwner;
	BYTE InitSize;
	INT SplitOffset;
	UBOOL IsSplitMesh;

	URopeMesh();
public:
	URopeMesh(AXRopeDeco* D);
	void Update();
	void GetFrame(FVector* Verts, INT Size, FCoords Coords, AActor* Owner, INT* LODRequest = NULL);
	FBox GetRenderBoundingBox(const AActor* Owner, UBOOL Exact);
	FSphere GetRenderBoundingSphere(const AActor* Owner, UBOOL Exact);
	FBox GetCollisionBoundingBox(const AActor* Owner);
	UTexture* GetTexture(INT Count, AActor* Owner);
	void SetupCollision();
};

