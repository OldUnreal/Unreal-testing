/*=============================================================================
	AXRainRestrictionVolume.h.
=============================================================================*/
	AXRainRestrictionVolume() {}
	bool PointIsInside( FVector Point );
	void RenderSelectInfo( FSceneNode* Frame );
	void Modify();
	void PostScriptDestroyed();
	void NotifyActorMoved();
	void PostEditMove();
	void UpdateBounds();
	void PostLoad();
	UBOOL Tick(FLOAT DeltaTime, enum ELevelTick TickType);
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/