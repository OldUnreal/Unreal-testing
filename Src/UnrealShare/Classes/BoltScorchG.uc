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
class BoltScorchG expands EnergyImpact;

#exec TEXTURE IMPORT NAME=energymarkg1 FILE=Textures\Decals\DPScorchGreen1.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkg2 FILE=Textures\Decals\DPScorchGreen2.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkg3 FILE=Textures\Decals\DPScorchGreen3.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkg4 FILE=Textures\Decals\DPScorchGreen4.pcx LODSET=4

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.25) Texture = texture'energymarkg1';
	else if (f<0.5) Texture = texture'energymarkg2';
	else if (f<0.75) Texture = texture'energymarkg3';
	else Texture = texture'energymarkg4';
}


defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.25
	Texture=texture'energymarkg1'
}
