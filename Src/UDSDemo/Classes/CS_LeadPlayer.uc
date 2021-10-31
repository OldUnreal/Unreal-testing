//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_LeadPlayer ]
// 
// This actor will cause the player to follow the camera.
//=============================================================================

class CS_LeadPlayer expands CutSeq;

function Trigger( actor Other, pawn EventInstigator )
{
 	local CS_Camera C;

	CSTrackAction( "CS_LEADPLAYER" );

	// Find the camera.

	C = CSPlayer( EventInstigator ).CSCamera;
	 	  
	CSLog( EventInstigator $ " is following " $ C );

	// Adjust it's settings.

	C.Target = EventInstigator;
	C.bLeading = true;
	C.SetPhysics( PHYS_Projectile );
	EventInstigator.SetPhysics( PHYS_Projectile );
	EventInstigator.SetCollisionSize( 0.0, 0.0 );
	EventInstigator.SetLocation( C.Location );
	EventInstigator.Velocity = C.Velocity;
	EventInstigator.DrawType = DT_None;
	EventInstigator.Style = STY_None;
	EventInstigator.Mesh = None;
	EventInstigator.bHidden = true;
	EventInstigator.Visibility = 0;
}

defaultproperties
{
	Texture=CS_PAWN
}
