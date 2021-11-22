//=============================================================================
// CS_ClientFader.
//=============================================================================
class CS_ClientFader expands Info;

// Generic client screen fade in.

var() float ScaleMagnitude;
var float ScaleModifier;

simulated function Timer()
{
	if (Owner != None)
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

}

function PostBeginPlay()
{
	SetTimer( 0.1, true );
}

defaultproperties
{
	Texture=CSCAMERA
}
