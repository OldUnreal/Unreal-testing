//=============================================================================
// RLAmmo.
//=============================================================================
class RLAmmo expands Ammo;

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=100
     UsedInWeaponSlot(5)=1
     PickupMessage="You got 10 rockets."
     PickupViewMesh=LodMesh'UPak.RLAmmo'
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'UPak.Skins.RLAmmoI'
     Mesh=LodMesh'UPak.RLAmmo'
     CollisionRadius=15.000000
     CollisionHeight=25.000000
     bCollideActors=True
}
