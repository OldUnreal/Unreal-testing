//=============================================================================
// FadeInTrigger.
//=============================================================================
class FadeInTrigger expands Triggers;

var() float DelayTime;
var 		PlayerPawn Victim;
var float 	ScaleModifier;

function Trigger( actor Other, pawn EventInstigator )
{
	if( EventInstigator.IsA( 'PlayerPawn' ) )
	{
		Victim = PlayerPawn( EventInstigator );
		Victim.ClientAdjustGlow( -1.0, vect( 0, 0, 0 ) );
		Enable( 'Timer' );
		SetTimer( 0.1, true );		
	}
}

simulated function Timer()
{
	if( ScaleModifier <= 1.0 )
	{
		PlayerPawn( Owner ).ClientAdjustGlow( ScaleModifier, vect( 0, 0, 0 ) );
		ScaleModifier += 0.0075;
	}
	else
	{
		PlayerPawn( Owner ).ClientAdjustGlow( 1.0, vect( 0, 0, 0 ) );
		ScaleModifier = 0.0;
		Disable( 'Timer' );
	}
}

defaultproperties
{
}
