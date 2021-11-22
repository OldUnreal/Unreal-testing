//=============================================================================
// UPakDebugger.
//=============================================================================
class UPakDebugger expands Pickup;

var bool bLocked;
var bool bDebuggingOn;

exec function Debug()
{
	bDebuggingOn = !bDebuggingOn;
	
	if( bDebuggingOn )
		PlayerPawn( Owner ).MyHUD = spawn( class'UPakDebugHUD', Owner );
	else PlayerPawn( Owner ).MyHUD = spawn( PlayerPawn( Owner ).Default.HUDType, Owner );
}



exec function D()
{
	Debug();
}

exec function L()
{
	Lock();
}

exec function Lock()
{
	bLocked = !bLocked;
	
	if( bLocked )
		 UPakDebugHUD( PlayerPawn( Owner ).MyHUD ).bLockedTarget  = True;
	else UPakDebugHUD( PlayerPawn( Owner ).MyHUD ).bLockedTarget = False;
}

		
state Activated
{
	function BeginState()
	{
		Owner.PlaySound( ActivateSound );
		Debug();
	}
}

state DeActivated
{
	function BeginState()
	{
		Owner.PlaySound( DeactivateSound );
		Debug();
	}
}

auto state PickUp
{
	function BeginState()
	{
		LoopAnim( 'Call', 0.5 );
		Super.BeginState();
	}
}

defaultproperties
{
     bCanActivate=True
     bActivatable=True
     bDisplayableInv=True
     bRotatingPickup=True
     ItemName="UPak Debugger"
     PlayerViewMesh=LodMesh'UnrealShare.Rabbit'
     PickupViewMesh=LodMesh'UnrealShare.Rabbit'
     PickupViewScale=1.200000
     ThirdPersonMesh=LodMesh'UnrealShare.Rabbit'
     ActivateSound=Sound'UnrealI.Pickups.dampndea'
     DeActivateSound=Sound'UnrealI.Pickups.DampSnd'
     Icon=Texture'UnrealShare.Icons.I_VoiceBox'
     AnimSequence=Call
     Mesh=LodMesh'UnrealShare.Rabbit'
}
