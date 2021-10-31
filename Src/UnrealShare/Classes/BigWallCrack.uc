//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BigWallCrack added for a BigRock decal
// usage: add in the selected class
// in simulated function HitWall
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'BigWallCrack',,,Location, rotator(HitNormal));
//=============================================================================

class BigWallCrack expands Scorch;

#exec TEXTURE IMPORT NAME=BigWallCrack FILE=Textures\Decals\big_crk.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack2 FILE=Textures\Decals\big_crk2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack3 FILE=Textures\Decals\big_crk3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack4 FILE=Textures\Decals\big_crk4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack5 FILE=Textures\Decals\big_crk5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack6 FILE=Textures\Decals\big_crk6.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack7 FILE=Textures\Decals\big_crk7.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack8 FILE=Textures\Decals\big_crk8.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BigWallCrack9 FILE=Textures\Decals\big_crk9.pcx LODSET=2

var() texture CrackTextures[9];

simulated function PostBeginPlay()
{
	if (Class'Scorch'.Default.DecalLifeSpan<0)
		SetTimer(1.0, false); //Default
	else
		LifeSpan=fmax(0,Class'Scorch'.Default.DecalLifeSpan); //Stay around as long as the user wants in seconds. 0 = Forever.
	Texture = CrackTextures[Rand(ArrayCount(CrackTextures))];
	Super.PostBeginPlay();
}

defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.4
	Texture=texture'BigWallCrack'
	CrackTextures(0)=texture'BigWallCrack'
	CrackTextures(1)=texture'BigWallCrack2'
	CrackTextures(2)=texture'BigWallCrack3'
	CrackTextures(3)=texture'BigWallCrack4'
	CrackTextures(4)=texture'BigWallCrack5'
	CrackTextures(5)=texture'BigWallCrack6'
	CrackTextures(6)=texture'BigWallCrack7'
	CrackTextures(7)=texture'BigWallCrack8'
	CrackTextures(8)=texture'BigWallCrack9'
}
