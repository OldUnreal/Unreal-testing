//=============================================================================
// RLAmmo.
//=============================================================================
class RLAmmo expands Ammo;

#exec MESH IMPORT MESH=RLammo ANIVFILE=MODELS\ROCKETLAUNCHER\RLammo_a.3d DATAFILE=MODELS\ROCKETLAUNCHER\RLammo_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RLammo X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=RLammo SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=RLammo SEQ=RLAMMO STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JRLAmmo1 FILE=MODELS\ROCKETLAUNCHER\PART2.PCX GROUP=Skins FLAGS=2

#exec MESHMAP NEW   MESHMAP=RLammo MESH=RLammo
#exec MESHMAP SCALE MESHMAP=RLammo X=0.0375 Y=0.0375 Z=0.075

#exec MESHMAP SETTEXTURE MESHMAP=RLammo NUM=1 TEXTURE=JRLammo1
//
// Ammo icon
#exec TEXTURE IMPORT NAME=I_HD_RLammo FILE=Textures/HD_Icons/I_HD_RLammo.bmp GROUP=HD MIPS=OFF
#exec TEXTURE IMPORT NAME=RLAmmoI FILE=MODELS\ROCKETLAUNCHER\RLAmmoI.PCX GROUP=Skins MIPS=OFF HD=I_HD_RLammo

defaultproperties
{
	AmmoAmount=10
	MaxAmmo=100
	UsedInWeaponSlot(5)=1
	PickupMessage="You got 10 rockets."
	PickupViewMesh=LodMesh'RLAmmo'
	PickupSound=Sound'AmmoSnd'
	Icon=Texture'RLAmmoI'
	Mesh=LodMesh'RLAmmo'
	CollisionRadius=15.000000
	CollisionHeight=25.000000
	bCollideActors=True
}
