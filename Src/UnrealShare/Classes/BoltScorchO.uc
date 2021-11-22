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
class BoltScorchO expands EnergyImpact;

#exec TEXTURE IMPORT NAME=energymarko1 FILE=Textures\Decals\DPScorchOrange1.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarko2 FILE=Textures\Decals\DPScorchOrange2.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarko3 FILE=Textures\Decals\DPScorchOrange3.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarko4 FILE=Textures\Decals\DPScorchOrange4.pcx LODSET=4

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.25) Texture = texture'energymarko1';
	else if (f<0.5) Texture = texture'energymarko2';
	else if (f<0.75) Texture = texture'energymarko3';
	else Texture = texture'energymarko4';
}


defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.25
	Texture=texture'energymarko1'
}
