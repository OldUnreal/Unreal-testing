//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_DollyPlayer ]
// 
// This will case the camera to dolly around the player who trigger the CS.
//=============================================================================

class CS_DollyPlayer expands CutSeq;

var() Vector DollyVelocity;

function Trigger(actor Other, pawn EventInstigator)
{

 	local CS_Camera C;
	 	
	CSTrackAction("CS_DOLLYPLAYER");
 	
	// Find the camera.

	C = CSPlayer(EventInstigator).CSCamera;

	// Adjust it's settings.

	CSLog("Dollying "$C$" around "$EventInstigator);

	C.Target = EventInstigator;
	C.bLockedOn = true;
    C.Velocity = DollyVelocity;
    C.SetPhysics(PHYS_Projectile);
		
 		
}

defaultproperties
{
	Texture=CSADJUST
}
