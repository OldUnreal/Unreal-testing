//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// StingerCrack added for a Stingerprojectile decal when using Stinger
// usage: add in the selected class
// in simulated function HitWall
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'StingerCrack',,,Location, rotator(HitNormal));
//=============================================================================

class StingerCrack expands Scorch;

#exec TEXTURE IMPORT NAME=StiCrack1 FILE=Textures\Decals\Sti_crk1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=StiCrack2 FILE=Textures\Decals\Sti_crk2.pcx LODSET=2

simulated function BeginPlay()
{
	if ( FRand() < 0.5 )
		Texture = texture'Unrealshare.StiCrack1';
	else
		Texture = texture'Unrealshare.StiCrack2';
}

defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=-0.4
	Texture=texture'Unrealshare.StiCrack1'
}
