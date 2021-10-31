/*=============================================================================
	AXBeamEmitter.h.
=============================================================================*/
	AXBeamEmitter() {}
	void InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter);
	void ResetEmitter();
	void PostScriptDestroyed();
	void GetBeamFrame( FVector* Verts, INT Size, FCoords& Coords, AActor* Particle, INT FrameVerts );
	void ResetVars();
	void UpdateParticles( float Delta, UEmitterRendering* Render );
	void ModifyParticle( AActor* A, PartsType* Data );
	void CalcSegmentScales();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
