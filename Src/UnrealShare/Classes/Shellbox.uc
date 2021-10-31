//=============================================================================
// Shellbox.
//=============================================================================
class Shellbox extends Ammo;

#exec OBJ LOAD FILE=Detail.utx

#exec AUDIO IMPORT FILE="Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd"       GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Shellammo.bmp Name=I_HD_Shellammo Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_ShellAmmo FILE=Textures\Hud\i_shell.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Shellammo

#exec MESH IMPORT MESH=ShellBoxMesh ANIVFILE=Models\shelbx_a.3d DATAFILE=Models\shelbx_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShellBoxMesh X=-50 Y=-40 Z=0 YAW=0
#exec MESH LODPARAMS MESH=ShellBoxMesh STRENGTH=0.3
#exec MESH SEQUENCE MESH=ShellBoxMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPickup21 FILE=Models\pickup2.pcx GROUP="Skins" DETAIL=Metal
#exec MESHMAP SCALE MESHMAP=ShellBoxMesh X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=ShellBoxMesh NUM=1 TEXTURE=JPickup21

defaultproperties
{
	AmmoAmount=50
	MaxAmmo=200
	UsedInWeaponSlot(0)=1
	UsedInWeaponSlot(2)=1
	PickupMessage="You picked up 50 bullets"
	PickupViewMesh=Mesh'UnrealShare.ShellBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	Icon=Texture'UnrealShare.Icons.I_ShellAmmo'
	Mesh=Mesh'UnrealShare.ShellBoxMesh'
	bMeshCurvy=False
	CollisionRadius=22.000000
	CollisionHeight=11.000000
	bCollideActors=True
}
