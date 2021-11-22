//=============================================================================
// IntermissionInfo4.
//=============================================================================
class IntermissionInfo4 expands IntermissionInfo;

var Brute BruteTarget;
var Book BookCam;

function PostBeginPlay()
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		BruteTarget = Brute(P);
		if( BruteTarget!=None )
		{
			BruteTarget.AttitudeToPlayer = ATTITUDE_Friendly;
			Break;
		}
	}
	SetTimer( 0.5, false );
}
	
function Timer()
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( Krall(P)==None )
			Continue;
		P.AttitudeToPlayer = ATTITUDE_Friendly;
		P.Enemy = BruteTarget;
		P.Target = BruteTarget;
		P.GotoState( 'Attacking' );
	}
}

function Tick( float DeltaTime )
{
	if( BruteTarget==None || BruteTarget.Health<=0 )
		GotoState( 'Rotating' );
}

state Rotating
{
	function BeginState()
	{
		local Book TempBook;
		
		foreach allactors( class'Book', TempBook )
		{
			BookCam = TempBook;
			Break;
		}
		SetTimer( 1.0, false );
	}
	
	function Timer()
	{
		BookCam.SetPhysics( PHYS_Rotating );
		BookCam.RotationRate.Yaw = 750;
	}
}

defaultproperties
{
}
