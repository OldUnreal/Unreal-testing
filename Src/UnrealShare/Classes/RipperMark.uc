//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// RipperMark added for a BlastMark decal when using Rockets and Grenades
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.RipperMark' into the default properties
// otherwise  put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'RipperMark',,,Location, rotator(HitNormal));
//=============================================================================

class RipperMark expands Scorch;

#exec TEXTURE IMPORT NAME=RipperBlast FILE=Textures\Decals\Blast2_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RipperBlast2 FILE=Textures\Decals\Blast2_2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RipperBlast3 FILE=Textures\Decals\Blast2_3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RipperBlast4 FILE=Textures\Decals\Blast2_4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RipperBlast5 FILE=Textures\Decals\Blast2_5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RipperBlast6 FILE=Textures\Decals\Blast2_6.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.166) Texture = texture'Unrealshare.ripperblast';
	else if (f<0.333)	Texture = texture'UnrealShare.RipperBlast2';
	else if (f<0.499)	Texture = texture'UnrealShare.RipperBlast3';
	else if (f<0.666)	Texture = texture'UnrealShare.RipperBlast4';
	else if (f<0.833)	Texture = texture'UnrealShare.RipperBlast5';
	else				Texture = texture'UnrealShare.RipperBlast6';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=0.5
	Texture=texture'UnrealShare.RipperBlast'
}
