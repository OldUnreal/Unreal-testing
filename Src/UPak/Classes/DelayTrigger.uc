//=============================================================================
// DelayTrigger.
//=============================================================================
class DelayTrigger expands Triggers;

var() float DelayTime;

function BeginState()
{
	SetTimer( DelayTime, false );
}

function Timer()
{
	local Trigger T;
	
	foreach allactors( class'Trigger', T )
	{
		if( T.Event == 'LOG' )
			T.Trigger( GetPlayerPawn(), GetPlayerPawn() );
	}
}

function PlayerPawn GetPlayerPawn()
{
	local PlayerPawn P;
	
	foreach allactors( class'PlayerPawn', P )
		return P;
}

defaultproperties
{
}
