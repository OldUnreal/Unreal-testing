//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_ActorMove ]
//
// This will case a actor to move towards a Spike Tape
//=============================================================================

class CS_ActorMove expands CutSeq;

var() int  GroundSpeed;
var() name SpikeTag;

function Trigger(actor Other, pawn EventInstigator)
{

  local CS_SpikeTape ST,TST;
  local CSPawn P;
  
  CSTrackAction("CS_ActorMove");
  
  // Find the spike tape to move them too  
  
  foreach AllActors(class 'CS_SpikeTape',TST,SpikeTag)
  {
	ST = TST;
  }    	    	
  
  ST.bInUse = true;
   
  foreach AllActors(class 'CSPawn',P,Event)
  {
  
	CSLog("Moving "$P$" to "$ST);  
  
        P.SetMovementPhysics();
	P.CSMoveTarget = ST;
	P.CSShotList = CS_ShotList(Other);
	P.GroundSpeed = GroundSpeed;
	P.Destination = ST.Location;
	P.GotoState('ACT_MovingTo');


  } 
   
    
}

defaultproperties
{
	Texture=CSTRIGGER
}
