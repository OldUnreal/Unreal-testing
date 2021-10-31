//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// EnergyImpact added for a EnergyImpact decal when using ASMD
// if the class uses the explode function (such as Rockets, DispersionAmmo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.EnergyImpact' in defaultproperties
// otherwise put in a function like HitWall:
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'EnergyImpact',,,Location, rotator(HitNormal));
//=============================================================================

class EnergyImpact expands Scorch;

#exec TEXTURE IMPORT NAME=shockmark FILE=Textures\Decals\scorch1.pcx LODSET=2


defaultproperties
{
	MultiDecalLevel=2
	DrawScale=+1.0
	Texture=texture'Unrealshare.shockmark'
}
