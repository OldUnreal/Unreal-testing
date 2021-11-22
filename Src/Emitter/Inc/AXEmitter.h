/*=============================================================================
	AXEmitter.h.
=============================================================================*/
	AXEmitter() {}
	void InitView();
	virtual void SpawnMoreParticles( int Count );
	virtual void ChangeMaxParticles( int Count );
	virtual void TriggerEmitter();
	virtual void KillEmitter();
	virtual void InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter);
	virtual void UpdateEmitter( const float DeltaTime, UEmitterRendering* Sender );
	BYTE SpawnParticle( UEmitterRendering* Render, BYTE SpawnFlags, FVector*& TransPose, const FVector& SpawnOffs=FVector(0,0,0) );
	virtual UBOOL RemoteSpawnParticle( FVector Position );
	virtual void UpdateParticles( float Delta, UEmitterRendering* Render );
	FVector GetSpawnPosition();
	FVector GetSpawnVelocity( FVector VelValue );
	virtual void ModifyParticle( AActor* A, PartsType* Data ) {}
	virtual FRotator GetParticleRot( AActor* A, PartsType* Data, const float &Dlt, FVector &Mvd, UEmitterRendering* Render );
	virtual void ResetEmitter();
	bool ShouldRenderEmitter( UEmitterRendering* Sender );
	bool ShouldUpdateEmitter( UEmitterRendering* Sender );
	AXEmitter* GenerateChildEmitter(UClass* EmitClass, UEmitterRendering* Render, AXParticleEmitter* EmitterOuter);
	bool IsVisible( UEmitterRendering* Sender );
	void Modify();
	void PostScriptDestroyed();
	void RenderSelectInfo( FSceneNode* Frame );
	void InitChildCombiners(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter);
	void CleanUpRefs( AXEmitter* X );
	void DrawCorona( struct FSceneNode* Frame, FLOAT Delta );
	void DrawPartCoronas( UCanvas* Camera, const FLOAT& Delta );
	void ResetVars();
	FBox GetVisibilityBox();
	virtual void InitPhysXParticle(AActor* A, PartsType* Data);
	void ExitRbPhysics();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
