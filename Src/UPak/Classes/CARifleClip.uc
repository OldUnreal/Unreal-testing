//=============================================================================
// CARifleClip.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class CARifleClip expands Ammo;

#exec MESH IMPORT MESH=CARammo ANIVFILE=MODELS\CARIFLE\CARammo_a.3d DATAFILE=MODELS\CARIFLE\CARammo_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=CARammo STRENGTH=0.0

#exec MESH ORIGIN MESH=CARammo X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=CARammo SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CARammo SEQ=CARAMMO STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JCARammo1 FILE=MODELS\CARIFLE\car03.PCX GROUP=Skins FLAGS=2 // Material #7

#exec MESHMAP NEW   MESHMAP=CARammo MESH=CARammo
#exec MESHMAP SCALE MESHMAP=CARammo X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=CARammo NUM=1 TEXTURE=JCARammo1
//
// Ammo icon
#exec TEXTURE IMPORT NAME=I_HD_Carammo FILE=Textures/HD_Icons/I_HD_Carammo.bmp GROUP=HD MIPS=OFF
#exec TEXTURE IMPORT NAME=CARAmmoI FILE=MODELS\CARifle\CARAmmoI.PCX GROUP=Skins MIPS=OFF HD=I_HD_Carammo

// Caseless ammo for Combat Assault Rifle

defaultproperties
{
	AmmoAmount=50
	MaxAmmo=400
	UsedInWeaponSlot(3)=1
	PickupMessage="You got a 50 bullet CAR clip."
	PickupViewMesh=LodMesh'CARammo'
	PickupViewScale=3.500000
	MaxDesireability=0.240000
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	Icon=Texture'CARAmmoI'
	Mesh=LodMesh'CARammo'
	DrawScale=2.500000
	CollisionRadius=15.000000
	CollisionHeight=20.000000
	bCollideActors=True
}
