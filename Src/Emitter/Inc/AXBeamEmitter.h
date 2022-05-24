/*=============================================================================
	AXBeamEmitter.h.
=============================================================================*/
	AXBeamEmitter() {}
	void InitializeEmitter(AXParticleEmitter* Parent);
	void ResetEmitter();
	void PostScriptDestroyed();
	void GetBeamFrame( FVector* Verts, INT Size, FCoords& Coords, xParticle* Particle, INT FrameVerts );
	void ResetVars();
	void UpdateParticles(FLOAT Delta, UEmitterRendering* Render);
	void ModifyParticle(xParticle* A);
	void CalcSegmentScales();
	void Serialize(FArchive& Ar);
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
