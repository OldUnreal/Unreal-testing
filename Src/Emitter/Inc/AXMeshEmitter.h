/*=============================================================================
	AXMeshEmitter.h
=============================================================================*/
	AXMeshEmitter() {}
	void ModifyParticle( AActor* A, PartsType *Data );
	FRotator GetParticleRot( AActor* A, PartsType *Data, const float &Dlt, FVector &Mvd, UEmitterRendering* Render );
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
