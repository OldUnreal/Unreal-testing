//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// WallCrack added for a wallcrack decal when using RazorJack or FlakCanon
// usage: add in the selected class
// in simulated function HitWall
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'WallCrack',,,Location, rotator(HitNormal));
//=============================================================================

class WallCrack expands Scorch;

#exec TEXTURE IMPORT NAME=WallCrack1 FILE=Textures\Decals\Flak_crk1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=WallCrack2 FILE=Textures\Decals\Flak_crk2.pcx LODSET=2

simulated function BeginPlay()
{
	if ( FRand() < 0.5 )
		Texture = texture'Unrealshare.WallCrack1';
	else
		Texture = texture'Unrealshare.WallCrack2';
}

defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.4
	Texture=texture'Unrealshare.WallCrack1'
}
