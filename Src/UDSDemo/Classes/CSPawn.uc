//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CSPawn ]
//
// The CSPawn class has been included as an example of how you will need to 
// subclass all of the creatures.  It's annoying, but in the end allows for much 
// greater control over them in a cut sequence.
//
//=============================================================================

class CSPawn expands ScriptedPawn;

var CS_SpikeTape	CSMoveTarget;  // Where is this pawn heading
var CS_ShotList		CSShotList;	   // What shotlist controls this pawn
var name		BeforeActing;	// What state was this pawn in before it was a CS

state ACT_MovingTo
{
     ignores SeePlayer, Bump, EnemyNotVisible, HearNoise, Trigger, WarnTarget;

	function SetFall()
	{
		NextState = 'ACT_Moving'; 
		NextLabel = 'Moving';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}


    function AnimEnd()
	{
	   if (GroundSpeed > 200)
	     PlayFollowRunning();
	   else
	     PlayFollowWalking();
	}

Begin:

	if (GroundSpeed > 200)
		TweenToRunning(0.2);
	else
	    TweenToWalking(0.2);

    SetMovementPhysics();
	WaitForLanding();
	
Moving:


	if (CSMoveTarget == None)
	{
		SetPhysics(PHYS_None);
		GotoState('ActWaiting');
	}

	if (GroundSpeed > 200)	
		PlayRunning();
	else
	    PlayWalking();
	    
	TurnToward(CSMoveTarget);
	MoveToward(CSMoveTarget, GroundSpeed); 

	Goto('Moving');
}

state ActWaiting
{

	function AnimEnd()
	{
		PlayActWaiting();
	}
	
begin:

	Log("[CS] "$Self$" is waiting");
	PlayActWaiting();

}

function BeginCS()
{

	BeforeActing = GetStateName();
	SetPhysics(PHYS_None);
	GotoState('ActWaiting');	

}

function EndCS()
{
	SetMovementPhysics();
	GotoState(BeforeActing);
}

// PlayActWaiting - This is the function an pawn involoved in a CS plays while waiting.  It usually
// plays the normal waiting function, but can be over written.
// 

function PlayActWaiting()
{
  PlayWaiting();
}


function PlayFollowWalking()
{
	PlayWalking();
}

function PlayFollowRunning()
{
	PlayRunning();
}

defaultproperties
{
}
