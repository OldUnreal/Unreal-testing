//=============================================================================
// FallingCratePoint.
//=============================================================================
class FallingCratePoint expands Info;

var MarineBox box;
var nowarn PlayerPawn Target;

function PostBeginPlay()
{
	local PlayerPawn P;
	local vector HitNormal, HitLocation;
	local actor HitActor;
	
	foreach allactors( class'PlayerPawn', P )
	{
		Target = P;
	}
	HitActor = trace( HitNormal, HitLocation, Target.Location, Target.Location + vect( 0, 0, 25000 ), true );
	SetLocation( HitLocation );
	Box = Spawn( class'MarineBox' );
	GotoState( 'Controlling' );
}

function Timer()
{
	Velocity.Z += 500;
}


state Controlling
{
	function BeginState()
	{
		Box.SetPhysics( PHYS_Falling );
		Enable( 'Tick' );
	}
	
	function Tick( float DeltaTime )
	{
		Box.RotationRate.Yaw = Rand( 75000 );
		Box.RotationRate.Pitch = Rand( 75000 );
		Box.RotationRate.Roll = Rand( 75000 );
	}
}

defaultproperties
{
}
