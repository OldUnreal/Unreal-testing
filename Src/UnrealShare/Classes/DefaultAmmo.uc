//=============================================================================
// DefaultAmmo.
//=============================================================================
class DefaultAmmo extends ASMDAmmo;

#exec Texture Import File=Textures\HD_Icons\I_HD_Dispersion.bmp Name=I_HD_Dispersion Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Dispersion FILE=Textures\Hud\i_disp.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Dispersion

var() float RechargeDelay;

Auto State Idle2
{

	function Timer()
	{
		if ( AmmoAmount < MaxAmmo)
			AmmoAmount++;
		if ( AmmoAmount < 10 )
			SetTimer(RechargeDelay, false);
		else
			SetTimer(RechargeDelay * 0.1 * AmmoAmount, false);
	}

Begin:
	SetTimer(RechargeDelay, false);

}

defaultproperties
{
	RechargeDelay=1.100000
	UsedInWeaponSlot(1)=1
	UsedInWeaponSlot(4)=0
	Icon=Texture'UnrealShare.Icons.I_Dispersion'
	Mesh=None
	bMeshCurvy=False
	CollisionRadius=30.000000
	CollisionHeight=30.000000
	bCollideActors=False
}
