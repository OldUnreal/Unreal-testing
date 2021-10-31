//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BoltScorch added for a BoltScorch decal when using DispersionPistol
// usage:
// if the class uses the explode function (such as Rockets) : add in the selected class
// ExplosionDecal=class'Unrealshare.Boltscorch' into the default properties (DispersionAmmo)
// otherwise put in a function like HitWall:
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'BoltScorch',,,Location, rotator(HitNormal));
//=============================================================================
class BoltScorchR expands EnergyImpact;

#exec TEXTURE IMPORT NAME=energymarkr1 FILE=Textures\Decals\DPScorchRed1.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkr2 FILE=Textures\Decals\DPScorchRed2.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkr3 FILE=Textures\Decals\DPScorchRed3.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkr4 FILE=Textures\Decals\DPScorchRed4.pcx LODSET=4

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.25) Texture = texture'energymarkr1';
	else if (f<0.5) Texture = texture'energymarkr2';
	else if (f<0.75) Texture = texture'energymarkr3';
	else Texture = texture'energymarkr4';
}


defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.25
	Texture=texture'energymarkr1'
}
