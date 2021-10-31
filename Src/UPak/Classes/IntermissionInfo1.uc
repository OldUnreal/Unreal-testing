//=============================================================================
// IntermissionInfo1.
//=============================================================================
class IntermissionInfo1 expands IntermissionInfo;

var Mercenary BotTarget;

function PostBeginPlay()
{
	SetTimer( 2.0, false );
}
	
function Timer()
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		BotTarget = Mercenary(P);
		if( BotTarget!=None )
			Break;
	}
	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( Predator(P)!=None )
		{
			P.Enemy = BotTarget;
			P.Target = BotTarget;
			P.GotoState( 'Attacking' );
			BotTarget.Enemy = P;
			BotTarget.GotoState( 'Attacking' );
		}
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
	if( BotTarget==none || BotTarget.Health<=0 || BotTarget.bDeleteMe )
	{
		BotTarget = None;
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
