/*=============================================================================
	AXWeatherEmitter.h.
=============================================================================*/
	AXWeatherEmitter() {}
	void InitView();
	void InitializeEmitter(AXParticleEmitter* Parent);
	void UpdateEmitter(FLOAT DeltaTime, UEmitterRendering* Render, UBOOL bSkipChildren);
	UBOOL SpawnParticle( UEmitterRendering* Render, const FVector &CDelta );
	void ResetEmitter();
	UBOOL ShouldUpdateEmitter(FSceneNode* Frame);
	void RenderSelectInfo( FSceneNode* Frame );
	FBox GetVisibilityBox();
	void Modify();
	void PostEditMove();
	void PostScriptDestroyed();
	void PostLoad();
	void Destroy();
	class FParticlesDataBase* GetParticleInterface();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
