//=============================================================================
// IntermissionInfo3.
//=============================================================================
class IntermissionInfo3 expands IntermissionInfo;

function PostBeginPlay()
{
	SetTimer( 0.5, false );
}
function Timer()
{
	local Pawn P;
	local Titan T;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		T = Titan(P);
		if( T!=None )
			Break;
	}
	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( Queen(P)==None )
			Continue;
		P.Enemy = T;
		P.Target = T;
		P.GotoState( 'Attacking' );
	}
}

defaultproperties
{
}
