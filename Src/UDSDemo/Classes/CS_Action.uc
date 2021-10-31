//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_Action ]
//
// This actor is used to begin the start of a cut sequence.  It's job is to 
// set everything in place.
//
// Important note:  The FirstLock variable allows you to define FirstLock = "SELF".
// This will cause the camera to be locked on to whomever triggered the sequence.
//
//=============================================================================
class CS_Action expands CutSeq;

var   bool  Triggered;			  	// Event was triggered
var	  float TriggerTime;			// Time this event was triggered.

var() bool  Retriggerable;			// Is this camera retriggerable
var() bool	bOnlyTriggerable;		// Does a touch set it off
var() name  FirstShotList;			// Name of the first shotlist to call.
var() bool  LetterBoxed;			// Do we use the normal or letterboxed HUD
var() name  FirstCamera;			// The First camera to activate.
var() name  FirstLock;			    // If set, the engine will lock a camera on to the TAG
var() bool  FreezeActor;			// Should the actor be frozen in place

function Touch(Actor Other)
{
	// Cut Sequences can also only be triggered by the player.

    if (!Other.IsA('CSPlayer'))
    { 
      CSLog("Only Players May Trigger");
      return;
    }

	if (bOnlyTriggerable)
	  return;

    CSLog(""$Other$" has triggered a Cut Sequence");
	Self.Trigger(OTher, Pawn(Other));
}

function Trigger(actor Other, pawn EventInstigator)
{

 	local CS_Camera C;
	local CS_ShotList SL;
	local Actor A;	

	CSTrackAction("CS_ACTION");
	
    // All cut sequences are called only once.

	if (Triggered && (!Retriggerable))
	{
	  CSLog("Action is Trigger Once!");
	  return;
	}
	  
	if (Triggered && (Level.TimeSeconds - TriggerTime < 3))
	{
	  CSLog("Cant Re-Trigger yet..waiting");
	  return;
	}


	TriggerTime = Level.TimeSeconds;
	Triggered = true;
   
            
    // First, track down the camera.
    
    foreach AllActors(class'CS_Camera',c,FirstCamera)
    {
    
      	C.Trigger(Self,pawn(Other));        
      	
      	if (FirstLock=='Self')
      	{
      		CSLog("Locking Camera on to Instigator: "$EventInstigator.Name);
      		C.bLockedOn = true;
      		C.Target = EventInstigator;
      	}
      	else if (FirstLock != '')
      	{
      	
    		foreach AllActors(class 'Actor',a,FirstLock)
    		{
    			C.bLockedOn = true;
    			C.Target = A;
				CSLog("Locking Camera on to Actor: "$A.Name);
    		}  	
      	
      	}
    }
      		
    
	// Should all actors in this Cut Sequence be frozen    

    if (FreezeActor)
    {

		CSLog("Freezing Actors and Player");

		// Freeze the player
				
		CSPlayer(EventInstigator).Freeze(True);
    
    
	}

	// Switch the player in to CS mode


	CSPlayer(EventInstigator).POVThirdPerson(Letterboxed); 	
	CSPlayer(EventInstigator).CSAbortSpeed=1;
 	
	// Find the first CS_ShotList and trigger it
 						
	foreach AllActors( class 'CS_SHOTLIST', SL, FirstShotList )
	{
	    	CSLog("Executing Shotlist: "$SL);
    		SL.Trigger( Other, Other.Instigator );
	}

}

defaultproperties
{
	Texture=CSACTION
}
