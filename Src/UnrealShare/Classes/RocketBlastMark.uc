//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// RocketBlastMark added for a BlastMark decal when using Rockets and Grenades
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.RocketBlastMark' into the default properties
// otherwise  put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'RocketBlastMark',,,Location, rotator(HitNormal));
//=============================================================================

class RocketBlastMark expands Scorch;

#exec TEXTURE IMPORT NAME=RocketBlast FILE=Textures\Decals\Blast3_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RocketBlast2 FILE=Textures\Decals\Blast3_2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RocketBlast3 FILE=Textures\Decals\Blast3_3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RocketBlast4 FILE=Textures\Decals\Blast3_4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RocketBlast5 FILE=Textures\Decals\Blast3_5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RocketBlast6 FILE=Textures\Decals\Blast3_6.pcx LODSET=2
#exec TEXTURE IMPORT NAME=RocketBlast7 FILE=Textures\Decals\Blast3_7.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();
	if (f<0.142) Texture = texture'Unrealshare.Rocketblast';
	else if (f<0.285)	Texture = texture'UnrealShare.RocketBlast2';
	else if (f<0.428)	Texture = texture'UnrealShare.RocketBlast3';
	else if (f<0.571)	Texture = texture'UnrealShare.RocketBlast4';
	else if (f<0.714)	Texture = texture'UnrealShare.RocketBlast5';
	else if (f<0.857)	Texture = texture'UnrealShare.RocketBlast6';
	else				Texture = texture'UnrealShare.RocketBlast7';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=1
	Texture=texture'UnrealShare.RocketBlast'
}
