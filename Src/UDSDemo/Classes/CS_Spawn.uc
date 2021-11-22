//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_Spawn ]
//
// Creates an Actor
// 
//=============================================================================

class CS_Spawn expands CutSeq;

var() class<actor> NewActor; 	// the template class

function Trigger(actor Other, pawn EventInstigator)
{

	local Actor A;
	
	CSTrackAction("CS_Spawn");

	// Create it.
	
	A = spawn(NewActor,, '', Self.Location,Self.Rotation);	
	
	if (A==none)
	    CSLog(""$Self$" attempted a Spawn of "$NewActor$" that failed!");
	else
		CSLog(""$NewActor$" has been spawned!");
	
}	

defaultproperties
{
	Texture=CSACTION
}
