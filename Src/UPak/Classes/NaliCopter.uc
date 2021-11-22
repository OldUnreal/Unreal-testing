//=============================================================================
// NaliCopter.
//=============================================================================
class NaliCopter expands Nali;

var PlayerPawn RandomPlayer;

function GetPlayer()
{
	local PlayerPawn P;
	
	foreach allactors( class'PlayerPawn', P )
	{
		if( P != none )
			RandomPlayer = P;
	}
}

auto state PreCopter
{
	function BeginState()
	{
	}


Begin:
	LoopAnim( 'Breath' );
	Sleep( 2.0 );
	GetPlayer();
	if( RandomPlayer != none )
		TurnToward( RandomPlayer );
	GotoState( 'NaliCopter' );
}


state NaliCopter
{
	function BeginState()
	{
		bFixedRotationDir = true;
		RotationRate.Yaw = 90000;
	}

	function Tick( float DeltaTime )
	{
	}
	
Begin:
}

defaultproperties
{
}
