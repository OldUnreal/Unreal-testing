//=============================================================================
// ASMDAmmo.
//=============================================================================
class ASMDAmmo extends Ammo;

#exec AUDIO IMPORT FILE="Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\General\steam4.wav" NAME="Steam" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_ASMD.bmp Name=I_HD_ASMD Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_ASMD FILE=Textures\Hud\i_asmd.pcx GROUP="Icons" MIPS=OFF HD=I_HD_ASMD

#exec MESH IMPORT MESH=AsmdAmmoM ANIVFILE=Models\asmdam_a.3d DATAFILE=Models\asmdam_d.3d LODSTYLE=2
#exec MESH LODPARAMS MESH=AsmdAmmoM STRENGTH=0.25

#exec MESH ORIGIN MESH=AsmdAmmoM X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=AsmdAmmoM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JAsmdAmmo1 FILE=Models\asmdammo.pcx GROUP="Skins"
#exec OBJ LOAD FILE=Textures\fireeffectASMD.utx  PACKAGE=UnrealShare.EffectASMD
#exec MESHMAP SCALE MESHMAP=AsmdAmmoM X=0.045 Y=0.045 Z=0.09
#exec MESHMAP SETTEXTURE MESHMAP=AsmdAmmoM NUM=1 TEXTURE=JAsmdammo1 TLOD=5
#exec MESHMAP SETTEXTURE MESHMAP=AsmdAmmoM NUM=0 TEXTURE=UnrealShare.EffectASMD.FireEffectASMD TLOD=5
#exec MESHMAP SETTEXTURE MESHMAP=AsmdAmmoM NUM=2 TEXTURE=UnrealShare.EffectASMD.ASMDSMoke TLOD=5

defaultproperties
{
	AmmoAmount=10
	MaxAmmo=50
	UsedInWeaponSlot(4)=1
	PickupMessage="You picked up an ASMD core."
	PickupViewMesh=Mesh'UnrealShare.AsmdAmmoM'
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	Icon=Texture'UnrealShare.Icons.I_ASMD'
	Mesh=Mesh'UnrealShare.AsmdAmmoM'
	bMeshCurvy=False
	SoundRadius=26
	SoundVolume=37
	SoundPitch=73
	CollisionRadius=10.000000
	CollisionHeight=20.000000
	bCollideActors=True
}
