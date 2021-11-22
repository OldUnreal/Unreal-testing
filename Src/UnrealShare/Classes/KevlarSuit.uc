//=============================================================================
// KevlarSuit.
//=============================================================================
class KevlarSuit extends Suits;

#exec OBJ LOAD FILE=Detail.utx

#exec Texture Import File=Textures\HD_Icons\I_HD_Kevlar.bmp Name=I_HD_Kevlar Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_kevlar FILE=Textures\Hud\i_kevlar.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Kevlar

#exec MESH IMPORT MESH=KevSuit ANIVFILE=Models\kevlar_a.3d DATAFILE=Models\kevlar_d.3d X=0 Y=0 Z=0 MLOD=1
#exec MESH LODPARAMS MESH=KevSuit STRENGTH=0.5 MINVERTS=18 MORPH=0.1 ZDISP=1200.0
#exec MESH ORIGIN MESH=KevSuit X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=KevSuit SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=AkevSuit1 FILE=Models\Kevlar.pcx GROUP="Skins" DETAIL=metal
#exec MESHMAP SCALE MESHMAP=KevSuit X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=KevSuit NUM=1 TEXTURE=AkevSuit1 TLOD=10

#exec AUDIO IMPORT FILE="Sounds\Pickups\suit1.wav" NAME="suitsnd" GROUP="Pickups"

defaultproperties
{
	PickupMessage="You picked up the Kevlar Suit"
	PickupViewMesh=LodMesh'UnrealShare.KevSuit'
	Charge=100
	ArmorAbsorption=80
	bIsAnArmor=True
	AbsorptionPriority=6
	PickupSound=Sound'UnrealShare.Pickups.suitsnd'
	Icon=Texture'UnrealShare.Icons.I_kevlar'
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.KevSuit'
	CollisionRadius=20.000000
	CollisionHeight=30.000000
}
