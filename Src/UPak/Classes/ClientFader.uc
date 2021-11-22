//=============================================================================
// ClientFader.
//=============================================================================
class ClientFader expands Info;

// Generic client screen fade in.

var() float ScaleMagnitude;
var float ScaleModifier;

function Timer()
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

function PostBeginPlay()
{
	SetTimer( 0.1, true );
}

defaultproperties
{
     RemoteRole=ROLE_None
}
