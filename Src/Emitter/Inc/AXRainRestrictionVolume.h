/*=============================================================================
	AXRainRestrictionVolume.h.
=============================================================================*/
	AXRainRestrictionVolume() {}
	bool PointIsInside( FVector Point );
	void RenderSelectInfo( FSceneNode* Frame );
	void Modify();
	void PostScriptDestroyed();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/