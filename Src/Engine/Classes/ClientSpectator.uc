Class ClientSpectator extends Spectator
	NoUserCreate
	Transient;

function PreBeginPlay()
{
	// Set instigator to self.
	Instigator = Self;
}
function PostBeginPlay()
{
	HUDType = Class<HUD>(DynamicLoadObject("UnrealShare.UnrealHUD",Class'Class'));
}
function PostNetBeginPlay()
{
}

exec function Say( string S )
{
}
exec function TeamSay( string S )
{
}

event UnPossess()
{
	if( myHUD )
		myHUD.Destroy();
	bIsPlayer = false;
	Destroy();
}

defaultproperties
{
	bCollideWhenPlacing=false
	RemoteRole=ROLE_None
}