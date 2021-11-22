//=============================================================================
// IntermissionInfo5.
//=============================================================================
class IntermissionInfo5 expands IntermissionInfo;

function PostBeginPlay()
{
	SetTimer( 1, false );
}
function Timer()
{
	local Predator Pr;
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		Pr = Predator(P);
		if( Pr!=None )
		{
			Pr.AttitudeToPlayer = ATTITUDE_Friendly;
			Break;
		}
	}

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( Brute(P)==None )
			Continue;
		P.AttitudeToPlayer = ATTITUDE_Friendly;
		P.Enemy = Pr;
		P.Target = Pr;
		P.GotoState( 'Attacking' );
	}
}

defaultproperties
{
}
