//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_PlayerLookAt ]
//
// Turns a player towards a spike tape.
//
//=============================================================================

class CS_PlayerLookAt expands CutSeq;

var() name NewLocation;
var() bool bIgnorePitchNRoll;

function Trigger(actor Other, pawn EventInstigator)
{

   local rotator NewRotation;
   local CS_SpikeTape ST;

   CSTrackAction("CS_PlayerLookAt");

   // Have the player Turn Towards the Spike Tape
    
   foreach AllActors(class 'CS_SpikeTape',ST,Event)
   {
    
   		NewRotation = rotator(ST.Location - CSPlayer(EventInstigator).Location);
   		
   		if (bIgnorePitchNRoll)
   		{
   		  NewRotation.Pitch = CSPlayer(EventInstigator).Rotation.Pitch;
   		  NewRotation.Roll = CSPlayer(EventInstigator).Rotation.Roll;
   		}
   		
   		CSLog("Turning "$EventInstigator$"Towards "$St);
   }
   		
   CSPlayer(EventInstigator).SetRotation(NewRotation);

}

defaultproperties
{
	Texture=CSCAMERA
}
