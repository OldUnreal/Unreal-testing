/*=============================================================================
	AXParticleForces.h.
=============================================================================*/
AXParticleForces() {}
virtual void HandleForce( PartsType* Data, AActor* A, const float& Delta ) {} // Do nothing on base class.
bool UpdateForceOn( AActor* PartActor, const float& LifeTimeScale );
void Modify();
void PostScriptDestroyed();
void RenderSelectInfo( FSceneNode* Frame );
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/