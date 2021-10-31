//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BlastMark added for a BlastMark decal when using Rockets and Grenades
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.GrenadeBlastMark' into the default properties
// otherwise (Grenades) put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'BlastMark',,,Location, rotator(HitNormal));
//=============================================================================


class GrenadeBlastMark expands Scorch;

#exec TEXTURE IMPORT NAME=GLBlast FILE=Textures\Decals\explo1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast2 FILE=Textures\Decals\explo2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast3 FILE=Textures\Decals\explo3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast4 FILE=Textures\Decals\explo4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast5 FILE=Textures\Decals\explo5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast6 FILE=Textures\Decals\explo6.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast7 FILE=Textures\Decals\explo7.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast8 FILE=Textures\Decals\Blast4_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast9 FILE=Textures\Decals\Blast4_2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast10 FILE=Textures\Decals\Blast4_3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast11 FILE=Textures\Decals\Blast4_4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast12 FILE=Textures\Decals\Blast4_5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GLBlast13 FILE=Textures\Decals\Blast4_6.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.142) Texture = texture'Unrealshare.GLBlast';
	else if (f<0.285)	Texture = texture'UnrealShare.GLBlast2';
	else if (f<0.428)	Texture = texture'UnrealShare.GLBlast3';
	else if (f<0.571)	Texture = texture'UnrealShare.GLBlast4';
	else if (f<0.714)	Texture = texture'UnrealShare.GLBlast5';
	else if (f<0.857)	Texture = texture'UnrealShare.GLBlast6';
	else				Texture = texture'UnrealShare.GLBlast7';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=0.5
	Texture=texture'UnrealShare.GLBlast'
}
