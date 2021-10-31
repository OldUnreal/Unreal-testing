//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_PlayerMoveTo ]
//
// Will direct a player to move towards a Spike tape.
//=============================================================================

class CS_PlayerMoveTo expands CutSeq;

var() bool 			bIgnorePitchNRoll;
var() vector		NewVelocity;
var	  CSPlayer 		MyPlayer;
var   CS_SpikeTape 	MySpike;

function Trigger(actor Other, pawn EventInstigator)
{

   local rotator NewRotation;
   local CS_SpikeTape ST,NewTarget;

   CSTrackAction("CS_PlayerMoveTo");

   // Have the player Turn Towards the Spike Tape
   
   CSLog("Adjusting Rotation for: "$EventInstigator);
   
   foreach AllActors(class 'CS_SpikeTape',ST,Event)
   {
    
   		NewRotation = rotator(ST.Location - CSPlayer(EventInstigator).Location);
   		
   		if (bIgnorePitchNRoll)
   		{
   		  NewRotation.Pitch = CSPlayer(EventInstigator).Rotation.Pitch;
   		  NewRotation.Roll = CSPlayer(EventInstigator).Rotation.Roll;
   		}
   		
		CSLog("Spike Found: "$St);
		ST.SetInUse();
		NewTarget = ST;		
  		
   }
   		
   CSPlayer(EventInstigator).SetRotation(NewRotation);
   CSPlayer(EventInstigator).CSMoveTarget = NewTarget;
   CSPlayer(EventInstigator).CSShotList = CS_ShotList(Other);
   CSPlayer(EventInstigator).ScriptedMove(NewVelocity);

   MySpike = NewTarget;
   MyPlayer = CSPlayer(EventInstigator);

   CSLog("We are now tracking movement for "$MyPlayer);

  
   GotoState('TrackPlayer');
}

// The TrackPlayer state is needed since the player pawns are handled very differently.  In retrospect, I 
// should have forced in a "Dummy" pawn for the player, but hey.. fuck it.

state TrackPlayer
{

	function SetPlayerRotation()
	{
	
		local rotator NewRotation;
		
	
		NewRotation = rotator(MySpike.Location - MyPlayer.Location);
		NewRotation.Pitch = 0;
   		NewRotation.Roll = 0;   		  
		MyPlayer.SetRotation(NewRotation);


	}	


begin:

	if (MyPlayer.CSMoveTarget != None)
	{
		SetPlayerRotation();
		sleep(0.1);
		goto('Begin');
	}
	else
	{
		CSLog("We have stopped tracking movement for "$MyPlayer);
		GotoState('');	
	}

}

defaultproperties
{
	Texture=CS_PAWN
}
