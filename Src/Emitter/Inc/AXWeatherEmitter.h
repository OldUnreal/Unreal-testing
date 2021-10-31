/*=============================================================================
	AXWeatherEmitter.h.
=============================================================================*/
	AXWeatherEmitter() {}
	void InitView();
	void InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter);
	void UpdateEmitter( const float DeltaTime, UEmitterRendering* Sender );
	BYTE SpawnParticle( UEmitterRendering* Render, const FVector &CDelta );
	void ResetEmitter();
	bool ShouldUpdateEmitter( UEmitterRendering* Sender );
	void RenderSelectInfo( FSceneNode* Frame );
	FBox GetVisibilityBox();
	void Modify();
	void PostEditMove();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
