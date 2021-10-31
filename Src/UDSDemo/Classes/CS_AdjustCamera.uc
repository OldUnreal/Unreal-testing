//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_AdjustCamera ]
// 
// This allows you to adjust how the camera is moving in the world.  
//=============================================================================

class CS_AdjustCamera expands CutSeq;


var() rotator Adj_DesiredRotation;
var() rotator Adj_RotationRate;
var() vector Adj_Velocity;

function Trigger(actor Other, pawn EventInstigator)
{

 	local CS_Camera C;
	 
	CSTrackAction("CS_AdjustCamera");	
 	
 	C = CSPlayer(EventInstigator).CSCamera;
	CSLog("Adjusting Camera "$C);

	// Adjust it's settings.

	C.DesiredRotation = Adj_DesiredRotation;
	C.RotationRate = Adj_RotationRate;
	C.Velocity = Adj_Velocity;

	// What a hack.  The only mode that I could get the
	// camera to both rotate and move in was as a projectile.
	// I thought PHYS_Flying would work, but no go.  But hey..
	// does it really matter?
 	  
  	C.SetPhysics(PHYS_Projectile);
		
}

defaultproperties
{
	Texture=CSCAMERA
}
