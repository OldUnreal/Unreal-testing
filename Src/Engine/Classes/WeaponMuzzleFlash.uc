// Unreal third person weapon muzzle flash.
Class WeaponMuzzleFlash extends InventoryAttachment
	Native;

var bool bConstantMuzzle,bStrobeMuzzle,bFlashTimer;
var bool bCurrentlyVisible; // This flag works like bHidden for rendering.

simulated function FlashMuzzle()
{
	bCurrentlyVisible = true;
	bFlashTimer = true;
	Enable('Tick');
}
simulated function SetMuzzleLoop( bool bOn )
{
	bConstantMuzzle = bOn;
	bFlashTimer = true;
	bCurrentlyVisible = bOn;
	if( bOn )
		Enable('Tick');
	else Disable('Tick');
}
simulated function Tick( float Delta )
{
	if( bFlashTimer ) // Give 1 tick time to render the flash.
	{
		bFlashTimer = false;
		return;
	}
	if( !bConstantMuzzle )
	{
		bCurrentlyVisible = false;
		Disable('Tick');
		return;
	}
	if( bStrobeMuzzle )
		bCurrentlyVisible = !bCurrentlyVisible;
}

defaultproperties
{
	bHidden=true
	bUnlit=true
}