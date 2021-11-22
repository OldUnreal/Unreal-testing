/*=============================================================================
	AXParticleEmitter.h.
=============================================================================*/
	AXParticleEmitter() {}
	virtual void InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter) {}
	virtual void UpdateEmitter( const float DeltaTime, UEmitterRendering* Sender ) {}
	void PostEditChange();
	virtual void ResetEmitter();
	virtual bool ShouldRenderEmitter( UEmitterRendering* Sender ){return true;}
	virtual bool ShouldUpdateEmitter( UEmitterRendering* Sender ){return true;}
	virtual void ResetVars();
	void PostNetReceive();
	UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	void PostScriptDestroyed();
	virtual void InitView() {}
	virtual void GetBeamFrame( FVector* Verts, INT Size, FCoords& Coords, AActor* Particle, INT FrameVerts ) {}
	void SpawnChildPart( const FVector Pos, TArray<class AXEmitter*>& PartIdx );
	void UpdateChildren(float Delta, UEmitterRendering* Render);
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
