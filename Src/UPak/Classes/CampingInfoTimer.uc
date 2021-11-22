//=============================================================================
// CampingInfoTimer.
//=============================================================================
class CampingInfoTimer expands Info;

var Bots Camper;
var bool bStopInitialCheck;
var GrenadeLauncher GL;

state CampingTracking
{
	function BeginState()
	{
		local float OldPitch;
		
		if ( Camper != None && GL.DetGrenade != None )
		{
			SetTimer( 0.25, True );
			OldPitch = Camper.Rotation.Pitch;
			Camper.SetRotation( rotator(  GL.DetGrenade.Location - Camper.Location ) );
		}
		else
		{
			Destroy();		
		}		
	}
	
	function Timer()
	{
		// Check for line of site in here? May ruin some of the surprise.
		
		if ( (Camper != None && GL != None) && (!GL.bDetgrenadeActive) || (Camper != None && GL.DetGrenade == None)  )
		{
			Camper.CampTime = 0;
			Camper.bWantsToCamp = False;
			Camper.bCamping = False;
			Camper.Focus = Camper.Destination;
			Camper.GotoState( 'Roaming' );
			Destroy();
		}
		else if ( Camper != None && VSize( Camper.Location - GL.DetGrenade.Location ) > 350 && !bStopInitialCheck )
		{
			Camper.bWantsToCamp = True;
			Camper.bCamping = True;
			Camper.CampTime = 4.5;
			Camper.Focus = GL.DetGrenade.Location;
			Camper.GotoState( 'Roaming', 'Camp' );
			Camper.Focus = GL.DetGrenade.Location;

			Camper.SetRotation( rotator( GL.DetGrenade.Location - Camper.Location ) );
			bStopInitialCheck = True;
		}
	}

	function Tick( float DeltaTime )
	{
		if ( Camper != None && GL != None )
		{
			if ( ( GL != none ) && ( !GL.bDetGrenadeActive ) && ( !bStopInitialCheck ) )
			{
				if ( Camper != None )
				{
					// Below lines need their own function (duplicate a set of lines above)
					Camper.CampTime = 0;
					Camper.bWantsToCamp = False;
					Camper.bCamping = False;
					Camper.Focus = Camper.Destination;
					Camper.GotoState( 'Roaming' );
				}
				Destroy();
			}			

			else if ( bStopInitialCheck && Camper != None && GL.bDetGrenadeActive )
			{
				Camper.SetRotation( rotator( GL.DetGrenade.Location - Camper.Location ) );
			}
				
		}
			else Destroy();
	}

	
	Begin:
			
	if ( bStopInitialCheck )
	{
		Camper.TurnTo( GL.DetGrenade.Location );
		Goto( 'Begin' );
	}
}

defaultproperties
{
}
