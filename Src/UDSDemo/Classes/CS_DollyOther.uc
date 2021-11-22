//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_DollyOther ]
// 
// Like CS_DollyPlayer this will cause the camera to dolly around any actor.
//=============================================================================

class CS_DollyOther expands CutSeq;


var() Vector	DollyVelocity;

function Trigger(actor Other, pawn EventInstigator)
{

	local Pawn P;
 	local CS_Camera C;

	CSTrackAction("CS_DOLLYOTHER");	 	
 	
	// Find the camera.

	C = CSPlayer(EventInstigator).CSCamera; 	

	// Adjust it's settings.

	foreach AllActors(class'Pawn',p,Event)
	{
		CSLog("Locking "$C$" on to "$EventInstigator);
		C.Target = EventInstigator;
	}
			
	C.bLockedOn = true;
    C.Velocity = DollyVelocity;
    C.SetPhysics(PHYS_Projectile);
 		
}

defaultproperties
{
	Texture=CSADJUST
}
