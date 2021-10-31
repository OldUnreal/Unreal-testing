//=============================================================================
// SuperHealth.
//=============================================================================
class SuperHealth extends Health;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=SuperHealthMesh ANIVFILE=Models\sheal_a.3d DATAFILE=Models\sheal_d.3d LODSTYLE=8
#exec MESH LODPARAMS MESH=SuperHealthMesh STRENGTH=0.6
#exec  MESH ORIGIN MESH=SuperHealthMesh X=0 Y=0 Z=0 ROLL=128
#exec  MESH SEQUENCE MESH=SuperHealthMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec  TEXTURE IMPORT NAME=Jshealth1 FILE=Models\shealth.pcx GROUP="Skins" DETAIL=Metal
#exec OBJ LOAD FILE=Textures\WaterEffect1.utx  PACKAGE=UnrealShare.WEffect1
#exec  MESHMAP SCALE MESHMAP=SuperHealthMesh X=0.04 Y=0.04 Z=0.08
#exec  MESHMAP SETTEXTURE MESHMAP=SuperHealthMesh NUM=1 TEXTURE=Jshealth1
#exec  MESHMAP SETTEXTURE MESHMAP=SuperHealthMesh NUM=0 TEXTURE=UnrealShare.WEffect1.WaterEffect1

function PlayPickupMessage(Pawn Other)
{
	Other.ClientMessage(PickupMessage, 'Pickup');
}

defaultproperties
{
	HealingAmount=100
	bSuperHeal=true
	MaxDesireability=+00001.000000
	PickupMessage="You picked up the Super Health Pack"
	RespawnTime=+00100.000000
	PickupViewMesh=UnrealShare.SuperHealthMesh
	Texture=None
	Mesh=UnrealShare.SuperHealthMesh
	CollisionRadius=+00016.000000
	CollisionHeight=+00019.500000
}
