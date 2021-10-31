//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_SlowMotion ]
//
// This actor can be used to adjust the game speed to X percent of normal.  
// You can create some very nice John Woo type sequences with this.
// 
//=============================================================================

class CS_SlowMotion expands CutSeq;

var() float Percent;

function Trigger(actor Other, pawn EventInstigator)
{
	CSTrackAction("CS_SlowMotion");
	
	if (CSPlayer(EventInstigator).CSAbortSpeed == 1)
	{
		Level.Game.SetGameSpeed(Percent);
		CSLog("Adjusting Game Speed to: "$Percent);
	}
}
	

	

defaultproperties
{
	Texture=CSACTION
}
