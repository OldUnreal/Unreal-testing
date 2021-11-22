//=============================================================================
// ToxinSuit.
//=============================================================================
class ToxinSuit extends Suits;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\ARMOUR2.wav"  NAME="ArmorSnd"      GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Suit2.bmp Name=I_HD_ToxinSuit Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_ToxinSuit FILE=Textures\Hud\I_ToxinSuit.pcx GROUP="Icons" MIPS=OFF HD=I_HD_ToxinSuit

#exec MESH IMPORT MESH=ToxSuit ANIVFILE=..\UnrealShare\Models\Suit_a.3d DATAFILE=..\UnrealShare\Models\Suit_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ToxSuit X=0 Y=100 Z=40 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=ToxSuit SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=AToxSuit1 FILE=Models\bToxSuit.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ToxSuit X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=ToxSuit NUM=1 TEXTURE=AToxSuit1

defaultproperties
{
	PickupMessage="You picked up the Toxin Suit"
	PickupViewMesh=UnrealI.ToxSuit
	ProtectionType1=Corroded
	Charge=50
	ArmorAbsorption=50
	bIsAnArmor=True
	AbsorptionPriority=6
	PickupSound=UnrealI.SuitSnd
	DrawType=DT_Mesh
	Mesh=UnrealI.ToxSuit
	CollisionRadius=+00030.000000
	CollisionHeight=+00030.000000
	Icon=Texture'I_ToxinSuit'
}
