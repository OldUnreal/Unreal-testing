//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_ActorChange ]
//
// This will cause an Actor to do a given animation
//=============================================================================

class CS_ActorAct expands CutSeq;

var() name AnimSeq;

function Trigger(actor Other, pawn EventInstigator)
{

	local CSPawn P;
	
	CSTrackAction("CS_ActorAct");
   
	foreach AllActors(class'CSPawn',P,Event)
	{
		CSLog(""$P$" is performing "$AnimSeq);
		P.PlayAnim(AnimSeq);
	}

}

defaultproperties
{
	Texture=CSACTION
}
