//=============================================================================
// PawnRelocater.
//=============================================================================
class PawnRelocator expands NavigationPoint;

var() Name MatchTag;

function PostBeginPlay()
{
}
function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;
	
	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( P.Tag == MatchTag )
			P.SetLocation( GetDestination() );
	}	
}
function vector GetDestination()
{
	local Pathnode P;
	
	foreach allactors( class'Pathnode',P,MatchTag )
		return P.Location;
}

defaultproperties
{
}
