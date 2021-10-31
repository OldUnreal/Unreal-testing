//=============================================================================
// RifleRound.
//=============================================================================
class RifleRound extends RifleAmmo;

#exec MESH IMPORT MESH=RifleRoundM ANIVFILE=Models\rifles_a.3d DATAFILE=Models\rifles_d.3d LODSTYLE=10
#exec MESH ORIGIN MESH=RifleRoundM X=0 Y=-200 Z=0 YAW=0
#exec MESH LODPARAMS MESH=RifleRoundM STRENGTH=0.2
#exec MESH SEQUENCE MESH=RifleRoundM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=RifleR1 FILE=Models\rifles.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=RifleRoundM X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=RifleRoundM NUM=1 TEXTURE=RifleR1

defaultproperties
{
	AmmoAmount=1
	ParentAmmo=UnrealI.RifleAmmo
	PickupMessage="You got a Rifle Round."
	PickupViewMesh=UnrealI.RifleRoundM
	Mesh=UnrealI.RifleRoundM
	CollisionRadius=+00005.000000
	CollisionHeight=+00015.000000
}
