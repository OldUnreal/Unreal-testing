//=============================================================================
// FlakBox.
//=============================================================================
class FlakBox extends Ammo;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd"       GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Flakammo.bmp Name=I_HD_Flakammo Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_FlakAmmo FILE=Textures\Hud\i_flak.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Flakammo

#exec MESH IMPORT MESH=flakboxMesh ANIVFILE=Models\flakb_a.3d DATAFILE=ModelsFX\flakb_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=flakboxMesh STRENGTH=0.3
#exec MESH ORIGIN MESH=flakboxMesh X=0 Y=0 Z=0 YAW=0 ROLL=128
#exec MESH SEQUENCE MESH=flakboxMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPickup1 FILE=Models\pickup.pcx GROUP="Skins" DETAIL=Metal
#exec MESHMAP SCALE MESHMAP=flakboxMesh X=0.045 Y=0.045 Z=0.09
#exec MESHMAP SETTEXTURE MESHMAP=flakboxMesh NUM=1 TEXTURE=JPickup1

defaultproperties
{
	AmmoAmount=10
	MaxAmmo=50
	UsedInWeaponSlot(6)=1
	PickupMessage="You picked up 10 Flak Shells"
	PickupViewMesh=Mesh'UnrealI.flakboxMesh'
	MaxDesireability=0.320000
	PickupSound=Sound'UnrealI.Pickups.AmmoSnd'
	Icon=Texture'UnrealI.Icons.I_FlakAmmo'
	Mesh=Mesh'UnrealI.flakboxMesh'
	bMeshCurvy=False
	CollisionRadius=16.000000
	CollisionHeight=11.000000
	bCollideActors=True
}
