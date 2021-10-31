//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_FollowOther ]
//
// This will case the camera to track any pawn.
//=============================================================================


class CS_FollowOther expands CutSeq;

function Trigger(actor Other, pawn EventInstigator)
{
    local Actor A;
    local CS_Camera C;
    
	CSTrackAction("CS_FollowOther");

	C = CSPlayer(EventInstigator).CSCamera;

	// Adjust its settings.	
	foreach AllActors(class'Actor', A, Event)
	{
	    C.Target = A;
		CSLog(""$C$" is following "$A);
	}
	C.bFollowing = true;
	C.SetPhysics(PHYS_Projectile);		
}

defaultproperties
{
	Texture=CSACTION
}
