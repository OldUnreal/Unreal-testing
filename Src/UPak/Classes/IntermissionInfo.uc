//=============================================================================
// IntermissionInfo.
//=============================================================================
class IntermissionInfo expands Info;

#exec AUDIO IMPORT FILE="Sounds\Intermission\interm1.wav" NAME="interm" GROUP="Intermission"

var Cow CowTarget;
var bool bHasBeenSet;

function PostBeginPlay()
{
	SetTimer( 2.0, false );
}

function Timer()
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		CowTarget = Cow(P);
		if( CowTarget!=None )
			Break;
	}
		
	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( Predator(P)==None )
			Continue;
		P.Enemy = CowTarget;
		P.Target = CowTarget;
		P.GotoState( 'Attacking' );
	}
}

function Tick( float DeltaTime )
{
	local Pawn P;
	
	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( PlayerPawn(P)==None )
			Continue;
		P.Visibility = 0;
		P.bHidden = true;
		P.SetLocation( P.Location + vect( 0, 0, 100 ) );
		P.SetPhysics( PHYS_None );
	}
	if( bHasBeenSet )
		Return;
	if( CowTarget==none || CowTarget.bDeleteMe || CowTarget.Health<=0 )
	{
		bHasBeenSet = True;
		For( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			if( Predator(P)==None )
				Continue;
			P.AttitudeToPlayer = ATTITUDE_Friendly;
			P.GotoState( 'Waiting' );
			P.Enemy = none;
			P.Target = none;
		}
	}
}
	

defaultproperties
{
}
