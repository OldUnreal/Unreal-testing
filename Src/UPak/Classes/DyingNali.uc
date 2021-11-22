//=============================================================================
// DyingNali.
//=============================================================================
class DyingNali expands NaliStatue;

// This is a pseudo instantly dying Nali for Matt's level.
function PostBeginPlay()
{
	SetTimer( 3.0, false );
}

function Timer()
{
	GotoState( 'Dying' );
}


auto state Dying
{
	function BeginState()
	{
	}
	

	function Tick( float DeltaTime )
	{
		local vector Location2;
		
		Location2 = ( Location + vect( 0, 0, -15 ) ) + vect( 0, 0, 15) >> Rotation;
		spawn( class'VoiceBox',,, Location2 );
		Destroy();
	}
}

defaultproperties
{
     bPushable=False
     bStasis=False
     Physics=PHYS_Rotating
     bFixedRotationDir=True
}
