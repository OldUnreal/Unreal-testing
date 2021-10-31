// Unreal third person weapon.
// This actor is both spawned and destroyed by engine whenever needed.
Class WeaponAttachment extends InventoryAttachment
	Native;

var() bool bCopyDisplay; // This attachment should constantly copy display properties from weapon itself (animation, textures etc...).
var Weapon WeaponOwner;
var WeaponMuzzleFlash MyMuzzleFlash;
var native const uint LastUpdateTime;

// Called by engine once actor has been spawned to notify which weapon is owning this actor.
simulated event SetWeaponOwner( Weapon Other )
{
	local byte i;

	WeaponOwner = Other;
	Mesh = WeaponOwner.ThirdPersonMesh;
	DrawScale = WeaponOwner.ThirdPersonScale;
	Texture = WeaponOwner.Texture;
	bMeshEnviroMap = WeaponOwner.bMeshEnviroMap;
	Style = WeaponOwner.Style;
	bParticles = WeaponOwner.bParticles;
	for( i=0; i<ArrayCount(MultiSkins); i++ )
		MultiSkins[i] = WeaponOwner.MultiSkins[i];
	if( WeaponOwner.MuzzleFlashMesh!=None && WeaponOwner.MuzzleFlashTexture!=None )
	{
		MyMuzzleFlash = Spawn(Class'WeaponMuzzleFlash',Self);
		MyMuzzleFlash.Style = WeaponOwner.MuzzleFlashStyle;
		MyMuzzleFlash.Mesh = WeaponOwner.MuzzleFlashMesh;
		MyMuzzleFlash.Texture = WeaponOwner.MuzzleFlashTexture;
		MyMuzzleFlash.DrawScale = WeaponOwner.MuzzleFlashScale;
		MyMuzzleFlash.bStrobeMuzzle = WeaponOwner.bToggleSteadyFlash;
		MyMuzzleFlash.bParticles = WeaponOwner.bMuzzleFlashParticles;
	}
}
// Called by engine when Weapon 'FlashCount' has changed
simulated event PlayMuzzleFlash()
{
	if( MyMuzzleFlash!=None && (Level.TimeSeconds-LastRenderedTime)<0.25f )
		MyMuzzleFlash.FlashMuzzle();
}
// Called by engine when Weapon 'bSteadyFlash3rd' has been toggled
simulated event LoopMuzzleFlash( bool bEnable )
{
	if( MyMuzzleFlash!=None )
		MyMuzzleFlash.SetMuzzleLoop(bEnable);
}
simulated function Destroyed()
{
	if( MyMuzzleFlash!=None )
	{
		MyMuzzleFlash.Destroy();
		MyMuzzleFlash = None;
	}
}

defaultproperties
{
	bCopyDisplay=true
}