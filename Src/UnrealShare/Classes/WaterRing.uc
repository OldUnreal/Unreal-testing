//=============================================================================
// WaterRing.
//=============================================================================
class WaterRing extends RingExplosion;

#exec OBJ LOAD FILE=Textures\fireeffect56.utx  PACKAGE=UnrealShare.Effect56

simulated function SpawnEffects()
{
}

defaultproperties
{
	Skin=UnrealShare.Effect56.fireeffect56
	Class=UnrealShare.WaterRing
	bNetOptional=True
	DecalClass=None
}
