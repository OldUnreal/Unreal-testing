//=============================================================================
// Shells.
//=============================================================================
class Shells extends Ammo;

#exec AUDIO IMPORT FILE="Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd" GROUP="Pickups"

#exec MESH IMPORT MESH=ShellsM ANIVFILE=MODELS\aniv34_a.3d DATAFILE=MODELS\aniv34_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShellsM X=-118 Y=292 Z=-21 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=ShellsM STRENGTH=0.3
#exec MESH SEQUENCE MESH=ShellsM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShellsM SEQ=STILL STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jshells1HD FILE=Models\shells.bmp Group="HD"
#exec TEXTURE IMPORT NAME=Jshells1 FILE=Models\shells_old.pcx GROUP="Skins" FLAGS=2 HD=Jshells1HD
#exec MESHMAP NEW   MESHMAP=ShellsM MESH=ShellsM
#exec MESHMAP SCALE MESHMAP=ShellsM X=0.013125 Y=0.013125 Z=0.02625
#exec MESHMAP SETTEXTURE MESHMAP=ShellsM NUM=1 TEXTURE=JShells1

#exec Texture Import File=Textures\HD_Icons\I_HD_ShotShell.bmp Name=I_HD_ShotShell Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_ShotShell FILE=Models\I_ShotShell.pcx GROUP="Icons" MIPS=Off HD=I_HD_ShotShell

defaultproperties
{
	AmmoAmount=12
	MaxAmmo=48
	UsedInWeaponSlot(2)=1
	ParentAmmo=Class'UnrealShare.Shells'
	PickupMessage="You picked up 12 shells"
	PickupViewMesh=LodMesh'UnrealShare.ShellsM'
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	Icon=Texture'UnrealShare.Icons.I_ShotShell'
	Mesh=LodMesh'UnrealShare.ShellsM'
	CollisionRadius=12.000000
	CollisionHeight=5.000000
	bCollideActors=True
	SoundRadius=26
	SoundVolume=37
	SoundPitch=73
}
