//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_FollowPlayer ]
// 
// This actor will cause the camera to follow the player.
//=============================================================================

class CS_FollowPlayer expands CutSeq;

function Trigger(actor Other, pawn EventInstigator)
{

 	local CS_Camera C;
	 	
	CSTrackAction("CS_FOLLOWPLAYER");
 	
	// Find the camera.

	C = CSPlayer(EventInstigator).CSCamera;
	 	  
	CSLog(""$C$" is following "$EventInstigator);
	
	// Adjust it's settings.

	C.Target = EventInstigator;
	C.bFollowing = true;
	C.SetPhysics(PHYS_Projectile);
		
}

defaultproperties
{
	Texture=CSACTION
}
