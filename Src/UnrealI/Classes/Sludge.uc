//=============================================================================
// Sludge.
//=============================================================================
class Sludge extends Ammo;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd"       GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Sludgeammo.bmp Name=I_HD_Sludgeammo Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_SludgeAmmo FILE=Textures\Hud\i_sludge.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Sludgeammo
#exec TEXTURE IMPORT NAME=Jsludge1 FILE=Models\pickup.pcx GROUP="Skins"

#exec MESH IMPORT MESH=sludgemesh ANIVFILE=MODELS\sludge_a.3d DATAFILE=MODELS\sludge_d.3d LODSTYLE=8
#exec MESH ORIGIN MESH=sludgemesh X=0.5 Y=0 Z=0 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=sludgemesh STRENGTH=0.3

#exec MESH SEQUENCE MESH=sludgemesh SEQ=All   STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=sludgemesh SEQ=SWIRL STARTFRAME=0 NUMFRAMES=11

#exec MESHMAP NEW   MESHMAP=sludgemesh MESH=sludgemesh
#exec MESHMAP SCALE MESHMAP=sludgemesh X=0.126 Y=0.126 Z=0.258

#exec MESHMAP SETTEXTURE MESHMAP=sludgemesh NUM=1 TEXTURE=Jsludge1

auto state Init
{
Begin:
	BecomePickup();
	LoopAnim('Swirl',0.3);
	GoToState('Pickup');
}

defaultproperties
{
	AmmoAmount=25
	MaxAmmo=100
	UsedInWeaponSlot(8)=1
	PickupMessage="You picked up 25 Kilos of Tarydium Sludge"
	PickupViewMesh=Mesh'UnrealI.sludgemesh'
	MaxDesireability=0.220000
	PickupSound=Sound'UnrealI.Pickups.AmmoSnd'
	Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
	Mesh=Mesh'UnrealI.sludgemesh'
	bMeshCurvy=False
	CollisionRadius=22.000000
	CollisionHeight=15.000000
	bCollideActors=True
}
