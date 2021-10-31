//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_PlayerACT ]
//
// This actor will case a player to perform a given animation
//
//=============================================================================

class CS_PlayerACT expands CutSeq;

var() name Animation;

function Trigger(actor Other, pawn EventInstigator)
{

  CSTrackAction("CS_PlayerAct");
  CSPlayer(EventInstigator).PlayAnim(Animation);
 
  
}

defaultproperties
{
	Texture=CSACTION
}
