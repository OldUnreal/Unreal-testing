//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_Camera ]
// 
// This is the actual Camera actor.
//
//=============================================================================

class CS_Camera expands Keypoint;

var nowarn Actor Target;
var bool bLockedOn; 	// Is this Camera locked on to a target
var bool bFollowing;	// Are we following someone
VAR BOOL BLEADING;

function Trigger(actor Other, pawn EventInstigator)
{
 	local CSPlayer P;
	local Actor A;

 	Log("[C/S Engine]: Activing Camera: "$Self);
 	
	// Find all players.

 	foreach AllActors(class'CSPlayer',p)
 	{
 	  	LOG("[C/S Engine]: Found Player: "$P);

		// Change their POV to that of the camera.
 	  	p.POVGotoLocation(Self);
		break;
   	} 		
	SetCollision(true);
	SetLocation(Location); // Trigger!
	foreach RadiusActors(Class'Actor',A,26)
		if( A.bCollideActors )
			A.Touch(P);
}

function UnTrigger(actor Other, pawn EventInstigator)
{	
}

function TurnTowardsTarget(vector targ)
{

    SetRotation(Rotator(targ - location));
        
}


function AdjustWithPlayer(vector Vel)
{

  Velocity = Vel;
}


event Tick(float DeltaTime)
{
    if (bLockedOn) 
  		TurnTowardsTarget(target.Location);
  		
    if (bFollowing)
      AdjustWithPlayer(target.Velocity);
     	   
  Super.Tick(DeltaTime);
  
}

defaultproperties
{
     bStatic=False
     bStasis=True
     bDirectional=True
     bFixedRotationDir=True
	 Texture=CSCAMERA
}
