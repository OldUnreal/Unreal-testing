//=============================================================================
// GLAmmo.
//=============================================================================
class GLAmmo expands Ammo;

#exec obj load file="UPakAmmoModels.u" Package="UPak"

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
