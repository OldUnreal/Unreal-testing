//=============================================================================
// TransitionCow.
//=============================================================================
class TransitionCow expands Cow;

var PathNode DestNode, TempNode;
var Brute BruteBully, TempBrute;
var bool bLanded;

auto state TransitionMode
{
	function BeginState()
	{
		foreach allactors( class'Brute', TempBrute )
		{
			BruteBully = TempBrute;
			Break;
		}
		
		SetTimer( 2.0, false );
	}
	
	function Timer()
	{
		GotoState( 'OnTheMove' );
	}
}

state OnTheMove
{
	begin:
		SetPhysics( PHYS_Walking );
		foreach allactors( class'Pathnode', TempNode )
		{
			if( TempNode.Tag == 'FirstSpot' )
			{
				DestNode = TempNode;
			}
			
		}
		TurnToward( DestNode );
		LoopAnim( 'Run' );
		BruteBully.GotoState( 'Pursuit' );
		MoveTo( DestNode.Location );
		FinishAnim();
	}
	
state Pursuit
{
	function BeginState()
	{
		DrawScale *= 2.5;
		Mass = 2000;
		FootStep = sound'Stomp4t';
		SetCollisionSize( CollisionHeight * 1.8, CollisionRadius * 1.8 );
		SetPhysics( PHYS_Falling );
		Velocity.Z += 75;
	}
	
Begin:
	Sleep( 2.5 );

	SetPhysics( PHYS_Walking );
	TurnToward( BruteBully );
	LoopAnim( 'Run' );
	foreach allactors( class'Pathnode', TempNode )
	{
		if( TempNode.Tag == 'SecondSpot' )
		{
			DestNode = TempNode;
		}
	}
	
	MoveTo( DestNode.Location );
	FinishAnim();
	Destroy();
}

defaultproperties
{
     bCollideActors=False
     bBlockPlayers=False
     bProjTarget=False
}
