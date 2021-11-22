//================================================================
// class: ParticlePath
// file: ParticlePath.uc
// author: Raven
// www: http://turniej.unreal.pl/rp
// description:
// changes particle destination
//================================================================
/*
    Usage:

       NextPoint should be filled like this:

       ParticlePath'MyLevel.ParticlePath0'

       true name of ParticlePath to use in NextPoint can be found in Object->Name (when you chose next point of path)
*/
class UIParticlePath extends UIParticleSystem;

var() UIParticlePath NextPoint;

simulated function Touch(Actor Other)
{
	if (UIBasicParticle(Other) != none) UIBasicParticle(Other).Destn=NextPoint;
}


defaultproperties
{
	bDirectional=true
	bCollideActors=true
	Texture=Texture'UnrealShare.Icons.ParticlePath'
	DrawScale=1.0
	bHidden=true
}
