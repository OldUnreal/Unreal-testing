//=============================================================================
// KillTrigger.
//=============================================================================
class KillTrigger expands Triggers;

var() name KillTag;

function Triggered( actor Other, pawn EventInstigator )
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( P.Tag==KillTag )
			P.Destroy();
	}
}

defaultproperties
{
}
