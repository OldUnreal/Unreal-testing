//=============================================================================
// Copter.
//=============================================================================
class Copter expands Decoration;

var PlayerPawn RandomPlayer;
var float RotationModifier;

function GetPlayer()
{
	local PlayerPawn P;
	
	foreach allactors( class'PlayerPawn', P )
	{
		if( P != none )
			RandomPlayer = P;
	}
}

auto state PreCopter
{
	function BeginState()
	{
	}

Begin:
	LoopAnim( 'Breath' );
	Sleep( 2.0 );
	GetPlayer();
	
	GotoState( 'NaliCopter' );
}


state NaliCopter
{
	function BeginState()
	{
		LoopAnim( 'Levitate' );
		SetPhysics( PHYS_Rotating );
		bFixedRotationDir = true;
	}

	function Tick( float DeltaTime )
	{
		if( RotationModifier <= 1000 )
		{
			RotationRate.Yaw += RotationModifier;
			RotationModifier += 15;	
		}
		else GotoState( 'Flying' );
	}

Begin:
}

state Flying
{
	function BeginState()
	{
		SetTimer( 0.2, true );
		SetPhysics( PHYS_Projectile );
		Velocity.Z += 1150;
		RotationRate.Yaw = 150000;
	}
	function Tick( float DeltaTime )
	{
		if( FRand() < 0.5 && Velocity.Z <= 150 )
			Velocity.Z += 50;
		else if( FRand() < 0.5 )
			Velocity.Z -= 50;
		else Velocity.Z += 50;
	}
}

defaultproperties
{
     bStatic=False
     bStasis=False
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Nali1'
     CollisionRadius=24.000000
     CollisionHeight=48.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
