//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_Wrap ]
//
// This Actor stops a camera from moving/rotation.
//
//=============================================================================

class CS_StopCamera expands CutSeq;

function Trigger(actor Other, pawn EventInstigator)
{

 	local CS_Camera C;
 	
 	CSTrackAction("CS_StopCamera");
 	
	// Find the Camera

	C = CSPlayer(EventInstigator).CSCamera;

    CSLOG("Stopping Camera "$C);
 	    
	// Stop IT!
 	    
 	C.SetPhysics(PHYS_None);
    
	C.DesiredRotation.Pitch = 0;
	C.DesiredRotation.Yaw = 0;
	C.DesiredRotation.Roll = 0;
		
	C.RotationRate.Pitch = 0;
	C.RotationRate.Yaw = 0;
	C.RotationRate.Roll = 0;
		
	C.Velocity.X =  0;
	C.Velocity.Y =  0;
	C.Velocity.Z =  0;
		
}

defaultproperties
{
	Texture=CSCAMERA
}
