//=============================================================================
// Armor powerup.
//=============================================================================
class Armor extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\ARMOUR2.wav" NAME="ArmorSnd" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Armor.bmp Name=I_HD_Armor Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Armor FILE=Textures\Hud\i_armor.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Armor

#exec TEXTURE IMPORT NAME=Jarmor1HD FILE=Models\armor.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=Jarmor1 FILE=Models\armor_old.pcx GROUP="Skins" FLAGS=2 HD=Jarmor1HD

#exec MESH IMPORT MESH=ArmorM ANIVFILE=Models\aniv36.3d DATAFILE=Models\data36.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ArmorM X=0 Y=0 Z=0 YAW=0
#exec MESH LODPARAMS MESH=ArmorM STRENGTH=0.3
#exec MESH SEQUENCE MESH=ArmorM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=ArmorM X=0.035 Y=0.035 Z=0.07
#exec MESHMAP SETTEXTURE MESHMAP=ArmorM NUM=7 TEXTURE=Jarmor1 TLOD=10

defaultproperties
{
	bDisplayableInv=True
	PickupMessage="You got the Assault Vest"
	RespawnTime=30.000000
	PickupViewMesh=Mesh'UnrealShare.ArmorM'
	Charge=100
	ArmorAbsorption=90
	bIsAnArmor=True
	AbsorptionPriority=7
	MaxDesireability=1.800000
	PickupSound=Sound'UnrealShare.Pickups.ArmorSnd'
	Icon=Texture'UnrealShare.Icons.I_Armor'
	Mesh=Mesh'UnrealShare.ArmorM'
	AmbientGlow=64
	CollisionHeight=11.000000
}
