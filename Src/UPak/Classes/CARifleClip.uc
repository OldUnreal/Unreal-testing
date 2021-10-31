//=============================================================================
// CARifleClip.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class CARifleClip expands Ammo;

// Caseless ammo for Combat Assault Rifle
#exec obj load file="UPakAmmoModels.u" Package="UPak"

defaultproperties
{
     AmmoAmount=50
     MaxAmmo=400
     UsedInWeaponSlot(3)=1
     PickupMessage="You got a 50 bullet CAR clip."
     PickupViewMesh=LodMesh'UPak.CARammo'
     PickupViewScale=3.500000
     MaxDesireability=0.240000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'UPak.Skins.CARAmmoI'
     Mesh=LodMesh'UPak.CARammo'
     DrawScale=2.500000
     CollisionRadius=15.000000
     CollisionHeight=20.000000
     bCollideActors=True
}
