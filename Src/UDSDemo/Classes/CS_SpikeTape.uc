//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_SpikeTape ]
//
// The spike tape actor is VERY important.  It's used when moving actors around
// in a cut sequence.  When touched during a C/S it sends a message back to
// the Active Shotlist saying it can continue if needed.
//
// This new updated Spike tape allows for very exacting movments.
//=============================================================================

class CS_SpikeTape expands Keypoint;

var() name 				FinishAnimation;
var() bool 				bStopWhenTouched;
var() bool				bExactTouch;
var   bool 				bInUse;

function SetInUse()
{
   bInUse = true;
}

function Touch(Actor Other)
{
  // If we are not in a cut sequence, dont do anything

  if (!bInUse) 
    return;
 

  // Check to see if we are exactly touching the spike tape.  HOWEVER, only X and Y are tested.
  // if you want your guy flying through the damn air, rewrite the code
 
  if (bExactTouch)
  {
	  Log("[SpikeTape]: Pawn @:"$Other.Location$" / Tape @:"$Location);

  	  if ((!(Location.X == Other.Location.X)) && (!(Location.Y == Other.Location.Y)))
  	    return;
  }
 
  
  Log("[C/S Engine]: "$Other$" touched the active Spike Tape "$Self);
  
  if ( (!Other.IsA('CSPlayer')) && (!Other.IsA('CSPawn')) )
    return;

  if (FinishAnimation!='')
  {
  	Pawn(Other).PlayAnim(FinishAnimation); 
  }

  // Should we stop the player ??? hmm??? hmmm???

  bInUse = false;
   
  if (bStopWhenTouched)
  {

	 if (Other.IsA('CSPlayer'))
	 {  
			Log("[C/S Engine]: Stopping "$Other);
	 
			CSPlayer(Other).AdjVelocity.X = 0;
			CSPlayer(Other).AdjVelocity.Y = 0;
			CSPlayer(Other).AdjVelocity.Z = 0;
			CSPlayer(Other).CLientSetRotation(Self.Rotation);
			CSPlayer(Other).CSMoveTarget = None;

			Log("[C/S Engine]: Telling Shotlist to Resume");
			
			CSPlayer(OTher).CSShotList.Completed();  // Tell the shot list the player has stopped.

	 }
	 else
	 {
			Log("[C/S Engine]: "$Other$" is being switched back to ActWaiting");
	   		CSPawn(Other).GotoState('ActWaiting');
			Pawn(Other).SetRotation(Self.Rotation);
			CSPawn(Other).CSMoveTarget = None;
			CSPawn(Other).SetPhysics(PHYS_None);

			Log("[C/S Engine]: Telling Shotlist to Resume");
	
			CSPAwn(OTher).CSShotList.Completed();  // Tell the shot list the pawn has stopped.
	 }
 
	   
  }
  
 
}

defaultproperties
{
	CollisionRadius=20.000000
	CollisionHeight=20.000000
	bCollideActors=True
}
