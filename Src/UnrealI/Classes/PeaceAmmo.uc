//=============================================================================
// PeaceAmmo.
//=============================================================================
class PeaceAmmo extends Ammo;

#exec Texture Import File=Textures\HD_Icons\I_HD_Peace.bmp Name=I_HD_Peace Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Peace FILE=Textures\Hud\I_Peace.pcx GROUP="Icons" HD=I_HD_Peace

defaultproperties
{
    AmmoAmount=1
    UsedInWeaponSlot(1)=5
    Mesh=None
	Icon=Texture'UnrealI.Icons.I_Peace'
    CollisionRadius=30.00
    CollisionHeight=30.00
    bCollideActors=False
}