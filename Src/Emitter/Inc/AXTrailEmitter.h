/*=============================================================================
	AXTrailEmitter.h.
=============================================================================*/
	AXTrailEmitter() {}
	void ChangeMaxParticles( int Count ) {}
	void TriggerEmitter();
	UBOOL RemoteSpawnParticle( FVector Position ) { return 0; } // Not functional on beam emitter.
	UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	void BeginNewTrailSeg();
	void KillEmitter();
	void InitTrailEmitter();
	void ResetEmitter();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
