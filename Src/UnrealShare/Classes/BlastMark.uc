//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BlastMark added for a BlastMark decal when using Rockets and Grenades
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.BlastMark' into the default properties
// otherwise (Grenades) put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'BlastMark',,,Location, rotator(HitNormal));
//=============================================================================


class BlastMark expands Scorch;

#exec TEXTURE IMPORT NAME=Blast FILE=Textures\Decals\Blast1_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=Blast2 FILE=Textures\Decals\Blast1_2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=Blast3 FILE=Textures\Decals\Blast1_3.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.33)			Texture = texture'UnrealShare.Blast';
	else if (f<0.66)	Texture = texture'UnrealShare.Blast2';
	else				Texture = texture'UnrealShare.Blast3';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=+1.0
	Texture=texture'UnrealShare.Blast'
}
