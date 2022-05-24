/*=============================================================================
	AXEmitter.h.
=============================================================================*/
	AXEmitter() {}
	void InitView();
	void OnCreateObjectNew(UObject* ParentObject);
	virtual void SpawnMoreParticles( int Count );
	virtual void ChangeMaxParticles( int Count );
	virtual void TriggerEmitter();
	void OnImportDefaults(UClass* OwnerClass);
	void InitializeEmitter(AXParticleEmitter* Parent);
	void RelinkChildEmitters();
	virtual void UpdateEmitter(FLOAT DeltaTime, UEmitterRendering* Render, UBOOL bSkipChildren);
	UBOOL SpawnParticle( UEmitterRendering* Render, BYTE SpawnFlags, FVector*& TransPose, const FVector& SpawnOffs=FVector(0,0,0) );
	virtual UBOOL RemoteSpawnParticle( const FVector& Position );
	virtual void UpdateParticles(FLOAT Delta, UEmitterRendering* Render);
	FVector GetSpawnPosition();
	FVector GetSpawnVelocity( FVector VelValue );
	virtual void ModifyParticle(xParticle* A) {}
	virtual FRotator GetParticleRot(xParticle* A, const FLOAT Dlt, FVector& Mvd, UEmitterRendering* Render);
	virtual void ResetEmitter();
	void DestroyCombiners();
	class FParticlesDataBase* GetParticleInterface();
	UBOOL ShouldRenderEmitter(FSceneNode* Frame);
	UBOOL ShouldUpdateEmitter(FSceneNode* Frame);
	void GenerateChildEmitter(UClass* EmitClass, TArray<AXEmitter*>& AppendArray);
	UBOOL IsVisible(FSceneNode* Frame);
	void Modify();
	void PostScriptDestroyed();
	void RenderSelectInfo( FSceneNode* Frame );
	void CleanUpRefs( AXEmitter* X );
	void DrawCorona( struct FSceneNode* Frame, FLOAT Delta );
	void DrawPartCoronas(FSceneNode* Frame, FLOAT Delta, AXParticleEmitter* Parent);
	FBox GetVisibilityBox();
	virtual void InitPhysXParticle(class xParticle* A);
	void ExitRbPhysics();
	FLOAT GetMaxLifeTime() const;
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
