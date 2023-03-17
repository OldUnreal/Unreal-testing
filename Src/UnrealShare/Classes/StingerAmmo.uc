//=============================================================================
// StingerAmmo.
//=============================================================================
class StingerAmmo extends Ammo;

#exec OBJ LOAD FILE=Detail.utx

#exec AUDIO IMPORT FILE="Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd"       GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Stingerammo.bmp Name=I_HD_Stingerammo Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_StingerAmmo FILE=Textures\Hud\i_sting.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Stingerammo

#exec MESH IMPORT MESH=TarydiumPickup ANIVFILE=MODELS\aniv54_a.3d DATAFILE=MODELS\data54_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TarydiumPickup X=-63 Y=-82 Z=-65 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=TarydiumPickup STRENGTH=0.3
#exec TEXTURE IMPORT NAME=JTaryPick1HD FILE=Models\shells.bmp Group="HD" DETAIL=Marble
#exec TEXTURE IMPORT NAME=JTaryPick1 FILE=Models\shells_old.pcx GROUP="Skins" FLAGS=2 HD=JTaryPick1HD
#exec MESH SEQUENCE MESH=TarydiumPickup SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TarydiumPickup SEQ=STILL STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=TarydiumPickup MESH=TarydiumPickup
#exec MESHMAP SCALE MESHMAP=TarydiumPickup X=0.0194 Y=0.0194 Z=0.0388

#exec MESHMAP SETTEXTURE MESHMAP=TarydiumPickup NUM=4 TEXTURE=JTaryPick1

defaultproperties
{
	AmmoAmount=40
	MaxAmmo=200
	UsedInWeaponSlot(3)=1
	PickupMessage="You picked up 40 Tarydium Shards"
	PickupViewMesh=Mesh'UnrealShare.TarydiumPickup'
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	Icon=Texture'UnrealShare.Icons.I_StingerAmmo'
	Mesh=Mesh'UnrealShare.TarydiumPickup'
	bMeshCurvy=False
	CollisionRadius=22.000000
	CollisionHeight=6.000000
	bCollideActors=True
}
