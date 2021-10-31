//=============================================================================
// UPakSMDebugger.
//=============================================================================
class UPakSMDebugger expands UPakDebugger;

exec function Debug()
{
	bDebuggingOn = !bDebuggingOn;
	
	if( bDebuggingOn )
	{
		PlayerPawn( Owner ).MyHUD = spawn( class'UPakDebugHUD', Owner );
	}
	else
	{
		PlayerPawn( Owner ).MyHUD = spawn( PlayerPawn( Owner ).Default.HUDType, Owner );
	}
}

exec function T()
{
	Pawn( Owner ).Visibility = Pawn( Owner ).Default.Visibility;
}

function PickupFunction( Pawn Other )
{
	Pawn( Owner ).Visibility = 0;
}

defaultproperties
{
}
