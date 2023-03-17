//=============================================================================
// GLAmmo.
//=============================================================================
class GLAmmo expands Ammo;

#exec MESH IMPORT MESH=GLammo ANIVFILE=MODELS\GLAUNCHER\GLammo_a.3d DATAFILE=MODELS\GLAUNCHER\GLammo_d.3d X=0 Y=0 Z=0

#exec MESH ORIGIN MESH=GLammo X=0 Y=0 Z=50 ROLL=0.59

#exec MESH SEQUENCE MESH=GLammo SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=GLammo SEQ=GLAMMO STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JGLAmmo0 FILE=MODELS\GLAUNCHER\LOWPOLY.PCX GROUP=Skins FLAGS=2 // AMMO

#exec MESHMAP NEW   MESHMAP=GLammo MESH=GLammo
#exec MESHMAP SCALE MESHMAP=GLammo X=0.05 Y=0.05 Z=0.1

#exec MESHMAP SETTEXTURE MESHMAP=GLammo NUM=1 TEXTURE=JGLammo0

#exec TEXTURE IMPORT NAME=I_HD_GLammo FILE=Textures/HD_Icons/I_HD_GLammo.bmp GROUP=HD MIPS=OFF
#exec TEXTURE IMPORT NAME=GLAmmoI FILE=MODELS\GLAUNCHER\GLAmmoI.PCX GROUP=Skins MIPS=OFF HD=I_HD_GLammo

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(4)=1
     PickupMessage="You picked up 10 grenades."
     PickupViewMesh=LodMesh'UPak.GLAmmo'
     PickupViewScale=0.750000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'UPak.Skins.GLAmmoI'
     Mesh=LodMesh'UPak.GLAmmo'
     AmbientGlow=0
     CollisionRadius=15.000000
     CollisionHeight=20.000000
     bCollideActors=True
}
