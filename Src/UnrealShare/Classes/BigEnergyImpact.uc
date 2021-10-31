//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BigEnergyImpact added for a EnergyImpact decal when using ASMD-Combo or Eightball Ring
// usage: add in the selected class (RingExplosion2,3)
// in simulated function SpawnEffects()
// a = Spawn(class'BigEnergyImpact',,,,rot(16384,0,0));
//=============================================================================

class BigEnergyImpact expands Scorch;

#exec TEXTURE IMPORT NAME=bigshockmark FILE=Textures\Decals\misc_burn.pcx LODSET=2


defaultproperties
{
	MultiDecalLevel=3
	DrawScale=+1.5
	Texture=texture'Unrealshare.bigshockmark'
}
