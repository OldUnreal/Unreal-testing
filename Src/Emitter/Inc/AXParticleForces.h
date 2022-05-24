/*=============================================================================
	AXParticleForces.h.
=============================================================================*/
AXParticleForces() {}
virtual void HandleForce(xParticle* A, FLOAT Delta) {} // Do nothing on base class.
bool UpdateForceOn( AActor* PartActor, const float& LifeTimeScale );
void Modify();
void PostScriptDestroyed();
void RenderSelectInfo( FSceneNode* Frame );
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/