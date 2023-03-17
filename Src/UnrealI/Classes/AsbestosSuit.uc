//=============================================================================
// AsbestosSuit.
//=============================================================================
class AsbestosSuit extends Suits;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\SUIT1.wav" NAME="SuitSnd" GROUP="Pickups"

#exec TEXTURE IMPORT NAME=AAsbSuit1HD FILE=Models\bAsbSuit.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=AAsbSuit1 FILE=Models\bAsbSuit_old.pcx GROUP="Skins" HD=AAsbSuit1HD

#exec MESH IMPORT MESH=AsbSuit ANIVFILE=..\UnrealShare\Models\bSuit_a.3d DATAFILE=..\UnrealShare\Models\bSuit_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=AsbSuit X=0 Y=100 Z=40 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=AsbSuit SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=AsbSuit X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=AsbSuit NUM=1 TEXTURE=AAsbSuit1

defaultproperties
{
	PickupMessage="You picked up the Asbestos Suit"
	ProtectionType1=Burned
	ProtectionType2=Frozen
	Charge=50
	ArmorAbsorption=50
	bIsAnArmor=True
	AbsorptionPriority=6
	PickupSound=UnrealI.SuitSnd
	DrawType=DT_Mesh
	Mesh=UnrealI.Suit
	CollisionRadius=+00030.000000
	CollisionHeight=+00030.000000
}
