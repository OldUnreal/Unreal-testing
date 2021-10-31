//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_Wrap ]
//
// This actor should be the last Command called by your shotlist sequences.  
// It's job is to reset the system it's to pre-cut sequence state.
//=============================================================================

class CS_Wrap expands CutSeq;

var() bool bSetFinalRotation;

function Trigger(actor Other, pawn EventInstigator)
{

 	local CSPlayer P;
 	local CS_SpikeTape St;
 	
 	CSTrackAction("CS_Wrap");

	P = CSPlayer(EventInstigator);

	if ( P.CSAbortSpeed > 1 )
	{
		CSLog("Abort detected.. reseting Game Speed");
		Level.Game.SetGameSpeed(1);
		P.CSAbortSpeed = 1;
	}

 	
    CSLOG("Reseting Player "$p);   	     	    
	P.POVFirstPerson();	// Reset their view
	P.Freeze(false);

    if (bSetFinalRotation)
    {
      EventInstigator.CLientSetRotation(Self.Rotation);
      CSLog("Setting Player "$EventInstigator$"'s Rotation");
     
    }  

	// If the player's movements have been locked up, clear it all.

	if (P.bIsActing)
	{
	   P.ResetScriptedMove();	
	   P.Freeze(false);
	   P.SetPhysics(PHYS_Walking);
	   P.bMovable = true;
	}
	
	foreach AllActors( class 'CS_SpikeTape',ST)
	{
		ST.bInUse = false;
	}

		
}

defaultproperties
{
	Texture=CSWRAP
}
