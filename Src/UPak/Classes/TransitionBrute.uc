//=============================================================================
// TransitionBrute.
//=============================================================================
class TransitionBrute expands Brute;

var Cow CowTarget;
var Pathnode TempNode, DestNode;
var Book TargetPlayer, TempTargetPlayer;

auto state TransitionMode
{
	function BeginState()
	{
		FindCow();
	}
	
	function FindCow()
	{
		local Pawn P;
		local Book TP;
				
		For( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			CowTarget = Cow(P);
			if( CowTarget!=None )
				Break;
		}
		
		foreach allactors( class'Book', TP )
		{
			TargetPlayer = TP;
		}
	}

Begin:
	SetPhysics( PHYS_Walking );
	PlayAnim( 'CockGun', 0.2 );
	FinishAnim();
	LoopAnim( 'Breath2', 0.2 );
	Sleep( Rand( 5 ) + FRand() );
	PlayAnim( 'PistolWhip', 0.2 );
	FinishAnim();
	Acceleration = vect( 0, 0, 0 );
	PlayTurning();
	TurnToward( CowTarget );
	FinishAnim();
	Goto( 'Begin' );
}

	
state Pursuit
{

Begin:
	Sleep( 0.25 );
	foreach allactors( class'Pathnode', TempNode )
	{
		if( TempNode.Tag == 'LookSpot' )
		{
			DestNode = TempNode;
		}
	}
	
	TurnToward( CowTarget );
	LoopAnim( 'Charge' );
	MoveTo( DestNode.Location );
	FinishAnim();
	Acceleration *= 0;
	PlayTurning();
	TurnToward( TargetPlayer );
	PlayAnim( 'CockGun', 0.6 );
	FinishAnim();
		
	foreach allactors( class'Pathnode', TempNode )
	{
		if( TempNode.Tag == 'FirstSpot' )
		{
			DestNode = TempNode;
		}
	}

	PlayTurning();
	TurnToward( CowTarget );
	FinishAnim();
	LoopAnim( 'Charge' );
	MoveTo( DestNode.Location );
	FinishAnim();
	Acceleration *= 0;
	LoopAnim( 'Breath2' );
	foreach allactors( class'Pathnode', TempNode )
	{
		if( TempNode.Tag == 'SecondSpot' )
		{
			DestNode = TempNode;
		}
	}
	TurnToward( DestNode );
	CowTarget.GotoState( 'Pursuit' );
	LoopAnim( 'Charge' );
	MoveTo( DestNode.Location );
	FinishAnim();
	
}

defaultproperties
{
     Texture=None
     ScaleGlow=0.750000
     bUnlit=True
     bMeshCurvy=True
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     LightType=LT_Flicker
     LightEffect=LE_WateryShimmer
     LightBrightness=255
     LightHue=169
     LightSaturation=87
     LightRadius=32
}
