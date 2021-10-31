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
class BoltScorchY expands EnergyImpact;

#exec TEXTURE IMPORT NAME=energymarky1 FILE=Textures\Decals\DPScorchYellow1.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarky2 FILE=Textures\Decals\DPScorchYellow2.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarky3 FILE=Textures\Decals\DPScorchYellow3.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarky4 FILE=Textures\Decals\DPScorchYellow4.pcx LODSET=4

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.25) Texture = texture'energymarky1';
	else if (f<0.5) Texture = texture'energymarky2';
	else if (f<0.75) Texture = texture'energymarky3';
	else Texture = texture'energymarky4';
}


defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.25
	Texture=texture'energymarky1'
}
