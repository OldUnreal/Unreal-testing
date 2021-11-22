//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_ShotList ]
//
// The ShotList actor has been GREATLY expanded.  Please refer to the
// documentation for more information.
//
//=============================================================================
class CS_ShotList expands CutSeq;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutCamera[8]; 		// Camera to activate
var() name  OutCamLock[8];		// Who to lock the camera on to
var() name  OutTrigger[8]; 		// Trigger to active
var() name  OutCommand[8]; 		// SEQ Comm
var() sound	OutSounds[8];		// Sound effect to play
var() float OutDelays[8]; 	  	// Relative delays before generating events.  

var(Sounds) int DialogVolume;

								// -1 means wait for event to trigger

var int 		CurShot;   		  		// Internal counter.
var bool 		bActive;              	// Is this shotlist active
var bool 		bAbort;		    	  	// has this shotlist been aborted.
var bool 		bComplete;			 	// This Shotlist is waiting for an event

var CS_Camera 	tmpCam;					// Tmp camera storage
var Actor		tmpAct;					// Tmp Actor storage
var CutSeq		tmpseq;					// Tmp CutSeq storage


// This function is called by some of the CutSequence actors.  It's used to tell the Shot List 
// that a particular sequence has finished and that it can move on to the next.

function Completed()
{
  bComplete = true;
}

// 

function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

state IsDone
{
begin:
  CSLog("ShotList ["$Self$"] is done!");
  bActive=false;	
  enable('Trigger');
}

//
// Dispatch events.  This was taken straight from the Dispatcher actor.  I just 
// altered it to my needs.
//
state Dispatch
{

Begin:
	disable('Trigger');
	
	CSTrackAction("CS_ShotList");

	// Do each sequence (up to 8)

	bActive=true;
	CurShot=0;
NextShot:

	if (CurShot==8)
	  GotoState('IsDone');

	// If this ShotList has been aborted, exit out.

	if (bAbort==True)  
	{
	  CSLog("Shot List Aborted by User!");
	  bAbort=false;
	  bActive=false;
	  GotoState('IsDone');
	}
	
	// Switch to that Camera
	
	if (OutCamera[CurShot] != '')
	{

		CSLog("Searching for Camera :"$OutCamera[CurShot]);

		foreach AllActors(class 'CS_Camera',TmpCam, OutCamera[CurShot])
	    {
	     	CSLog("Switching to Camera "$TmpCam);
	     	TmpCam.Trigger(Self,Instigator);	
	    }

	}

	// Lock the Camera on if we need to

	
	if (OutCamLock[CurShot]!='')
	{
		TmpCam = CSPlayer(Instigator).CSCamera;
	
		if (OutCamLock[CurShot]=='unlock')
		{
			CSLog("Unlocking Camera");
			TmpCam.bLockedOn = false;
		}
		else if (OutCamLock[CurShot] == 'self')
		{
			CSLog("Locking Camera on to "$Instigator);
			TmpCam.bLockedOn = true;
			TmpCam.Target = instigator;
		}
		else
		{
		
			foreach AllActors(class 'Actor',TmpAct,OutCamLock[CurShot])
			{
				CSLog("Locking Camera on to "$TmpAct);
				TmpCam.bLockedOn = true;
				TmpCam.Target = TmpAct;
			}
		}
	
	}

	// Trigger any triggers
	
	if (OutTrigger[CurShot] != '' )
	{
		foreach AllActors( class 'Actor', Target, OutTrigger[CurShot] )
		{
			CSLog("Triggering "$Target);
			
			// If this is a CutSeq then put out a warning
			
			if (Target.IsA('CutSeq')) 
			{
				CSLog("{WARNING} CutSeq object found in Triggers field of Shot List: "$Self.Tag);

			}
			
			Target.Trigger( Self, Instigator );
		}
		  						
	}

		
	// Trigger any CS Commands
	
	if( OutCommand[CurShot] != '' )
	{
		foreach AllActors( class 'CutSeq', TmpSeq, OutCommand[CurShot] )
		{
			CSLog("Processing Command "$TmpSeq$"("$TmpSeq.Tag$")");
			TmpSeq.Trigger( Self, Instigator );
			
		}
		  						
	}

	if ( (OutSounds[CurShot] != None) && (bAbort != true) )
	{
		CSLog("Playing sound "$OutSounds[CurShot]$" at volume: "$DialogVolume);
		PlaySound(OutSounds[CurShot],SLOT_INTERFACE,DialogVolume);
	}
	
	// Pause or wait for an event.  Movement
		
	if (OutDelays[CurShot] <0)
	{
		bComplete = false;	
		GotoState('WaitForEvent');
	}  
	else
	{
   		CSLog("Waiting for "$OutDelays[CurShot]);
   		Sleep( OutDelays[CurShot] );		
   	}

	CurShot++;
 	Goto('NextShot');	   	

}


state WaitForEvent
{

begin:
  CSLog("Waiting for command to complete before restarting Shot List");
  
KeepWaiting:  
  if (bComplete)  
  {

	CSlog("Command Completed");

  	CurShot++;
    GotoState('Dispatch','NextShot');
  }
  
  sleep(0.1);
  goto('KeepWaiting');
  
}

event PreBeginPlay()
{

  bAbort = false;
  bActive = false;
  bComplete = false;

}

defaultproperties
{
	Texture=CSSHOTLIST
}
