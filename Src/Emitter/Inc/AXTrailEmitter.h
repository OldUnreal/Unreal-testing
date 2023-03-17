/*=============================================================================
	AXTrailEmitter.h.
=============================================================================*/
	AXTrailEmitter() {}
	void ChangeMaxParticles( int Count ) {}
	UBOOL RemoteSpawnParticle(const FVector& Position) { return 0; } // Not functional on beam emitter.
	void InitTrailEmitter();
	void UpdateEmitter(FLOAT DeltaTime, UEmitterRendering* Render, UBOOL bSkipChildren);
	AActor* GrabTrail(const FVector& Pos, const FRotator& Rot);
	class FParticlesDataBase* GetParticleInterface();
	void ResetEmitter();
	void InitializeEmitter(AXParticleEmitter* Parent);
	void RespawnEmitter() {}
	FLOAT GetMaxLifeTime() const;
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
