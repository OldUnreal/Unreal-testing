//=============================================================================
// IntermissionInfo2.
//=============================================================================
class IntermissionInfo2 expands IntermissionInfo;

var Titan TitanTarget;
var Book BookCam;

function PostBeginPlay()
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		TitanTarget = Titan(P);
		if( TitanTarget!=None )
			Break;
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
		P.Enemy = TitanTarget;
		P.Target = TitanTarget;
		P.GotoState( 'Attacking' );
	}
}

function Tick( float DeltaTime )
{
	if( TitanTarget==None || TitanTarget.Health <= 0 || TitanTarget.bDeleteMe )
		GotoState( 'Rotating' );
}

state Rotating
{
	function BeginState()
	{
		local Book TempBook;
		
		foreach allactors( class'Book', TempBook )
			BookCam = TempBook;
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
