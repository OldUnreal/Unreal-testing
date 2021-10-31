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
class BoltScorchB expands EnergyImpact;

#exec TEXTURE IMPORT NAME=energymarkb1 FILE=Textures\Decals\DPScorchBlue1.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkb2 FILE=Textures\Decals\DPScorchBlue2.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkb3 FILE=Textures\Decals\DPScorchBlue3.pcx LODSET=4
#exec TEXTURE IMPORT NAME=energymarkb4 FILE=Textures\Decals\DPScorchBlue4.pcx LODSET=4

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.25) Texture = texture'energymarkb1';
	else if (f<0.5) Texture = texture'energymarkb2';
	else if (f<0.75) Texture = texture'energymarkb3';
	else Texture = texture'energymarkb4';
}


defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.25
	Texture=texture'energymarkb1'
}
