//=============================================================================
// Bandages.
//=============================================================================
class Bandages extends Health;

#exec MESH IMPORT MESH=bandage ANIVFILE=Models\band_a.3d DATAFILE=Models\band_d.3d LODSTYLE=10
#exec MESH LODPARAMS MESH=bandage STRENGTH=0.3
#exec  MESH ORIGIN MESH=bandage X=0 Y=0 Z=0 ROLL=0
#exec  MESH SEQUENCE MESH=bandage SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec  TEXTURE IMPORT NAME=Jband1 FILE=Models\bandages.pcx GROUP="Skins"
#exec  MESHMAP SCALE MESHMAP=bandage X=0.03 Y=0.03 Z=0.06
#exec  MESHMAP SETTEXTURE MESHMAP=bandage NUM=1 TEXTURE=Jband1

defaultproperties
{
	HealingAmount=5
	PickupMessage="You got some bandages +"
	PickupViewMesh=UnrealShare.Bandage
	Mesh=UnrealShare.Bandage
	CollisionRadius=+00014.000000
	CollisionHeight=+00004.000000
	Class=UnrealShare.Bandages
}
