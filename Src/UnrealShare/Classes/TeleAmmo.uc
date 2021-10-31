//=============================================================================
// TeleAmmo.
//=============================================================================
class TeleAmmo extends Ammo;

#exec Texture Import File=Textures\HD_Icons\I_HD_Tele.bmp Name=I_HD_Tele Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Tele FILE=Textures\Hud\I_Tele.pcx GROUP="Icons" HD=I_HD_Tele

defaultproperties
{
    AmmoAmount=1
    UsedInWeaponSlot(1)=10
	Mesh=None
    Icon=Texture'UnrealShare.Icons.I_Tele'
    CollisionRadius=30.00
    CollisionHeight=30.00
    bCollideActors=False
}