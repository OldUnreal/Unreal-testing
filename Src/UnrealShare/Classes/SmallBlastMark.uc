//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BlastMark added for a BlastMark decal when using Rockets and Grenades
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.SmallBlastMark' into the default properties
// otherwise (Grenades) put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'SmallBlastMark',,,Location, rotator(HitNormal));
//=============================================================================


class SmallBlastMark expands Scorch;

#exec TEXTURE IMPORT NAME=srocketblast FILE=Textures\Decals\SmallBlast_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast2 FILE=Textures\Decals\SmallBlast_2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast3 FILE=Textures\Decals\SmallBlast_3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast4 FILE=Textures\Decals\SmallBlast_4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast5 FILE=Textures\Decals\SmallBlast_5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast6 FILE=Textures\Decals\SmallBlast_6.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast7 FILE=Textures\Decals\SmallBlast_7.pcx LODSET=2
#exec TEXTURE IMPORT NAME=srocketblast8 FILE=Textures\Decals\SmallBlast_8.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if		(f<0.125)	Texture = texture'Unrealshare.srocketblast';
	else if (f<0.25)	Texture = texture'Unrealshare.srocketblast2';
	else if (f<0.375)	Texture = texture'Unrealshare.srocketblast3';
	else if (f<0.5)		Texture = texture'Unrealshare.srocketblast4';
	else if (f<0.625)	Texture = texture'Unrealshare.srocketblast5';
	else if (f<0.75)	Texture = texture'Unrealshare.srocketblast6';
	else if (f<0.875)	Texture = texture'Unrealshare.srocketblast7';
	else				Texture = texture'Unrealshare.srocketblast8';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=+0.25
	Texture=texture'Unrealshare.srocketblast'
}
