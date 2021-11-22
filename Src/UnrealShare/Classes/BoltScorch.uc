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
class BoltScorch expands EnergyImpact;

#exec TEXTURE IMPORT NAME=energymark FILE=Textures\Decals\Disp1.pcx LODSET=4
#exec OBJ LOAD FILE=Textures\Decals\DispDecals.utx PACKAGE=UnrealShare.DispDecal

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.166) Texture = texture'Disp1_A00';
	else if (f<0.333) Texture = texture'Disp2_A00';
	else if (f<0.5) Texture = texture'Disp3_A00';
	else if (f<0.666) Texture = texture'Disp4_A00';
	else if (f<0.833) Texture = texture'Disp5_A00';
	else Texture = texture'Disp6_A00';
}


defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.1
	Texture=texture'Disp1_A00'
}
