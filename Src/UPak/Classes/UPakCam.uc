//=============================================================================
// UPakCam.
//=============================================================================
class UPakCam expands Keypoint;

var() Pawn CameraTarget;
var() bool bRotateToTarget;
var() float CameraTime;
var UPakCamTrigger Director;
var() bool bFadeIn;
var() bool bViewFromTarget;
var() bool bNoHUD;
var() bool bNoCrosshair;
var() bool bAutoTarget;
var() bool bTargetPlayerPawn;

function PostBeginPlay()
{
	Disable( 'Tick' );
}

function Timer()
{
	Director.SwitchCamera();
}

function TurnOn()
{
	if( bRotateToTarget )
		Enable( 'Tick' );

	if( bViewFromTarget )
		PlayerPawn( Director.Victim ).ViewTarget = CameraTarget;
	
	if( CameraTime > 0 )
	{
		Enable( 'Timer' );
		SetTimer( CameraTime, false );
	}
}

function Tick( float DeltaTime )
{
	if( !bTargetPlayerPawn )
	{
		if( CameraTarget != none && CameraTarget.IsA( 'Pawn' ) && CameraTarget.Health > 0 )
			SetRotation(  rotator( Normal( CameraTarget.Location - Location )));
		else GetNewCameraTarget();
	}
	else
	{
		if( Director.Victim == none )
			Director.Victim = GetClosestPlayer();
		if( Director.Victim == none )
			Return;
		SetRotation( rotator( Normal( Director.Victim.Location - Location )));
	}
}


function PlayerPawn GetClosestPlayer()
{
	local PlayerPawn P;
	
	foreach RadiusActors( class'PlayerPawn', P, 1000 )
	{
		return P;
	}
}

function bool CanSeeTarget()
{
	local Actor HitActor;
	local vector HItLocation, HitNormal;
	
	HitActor = Trace( HitLocation, HitNormal, Location, CameraTarget.Location, true );
	
	if( HitActor == CameraTarget )
		return true;
	else return false;
}

function TurnOff()
{
	Disable( 'Tick' );
	Disable( 'Timer' );
}

function GetNewCameraTarget()
{
	local Pawn P;
	local vector HitLocation, HitNormal;
	local Actor HitActor;
	
	foreach radiusactors( class'Pawn', P, 1500 )
	{
		HitActor = Trace( HitLocation, HitNormal, Location, P.Location, true );
		if( HitActor == P )
			CameraTarget = P;
	}
}
	
function RotateToTarget()
{
	if( !bTargetPlayerPawn )
		SetRotation(  rotator( Normal( CameraTarget.Location - Location )));
	else
	{
		if( Director.Victim != none )
			SetRotation( rotator( Normal( Director.Victim.Location - Location )));
		else SetRotation( rotator( Normal( GetClosestPlayer().Location - Location ) ) );
	}
}

defaultproperties
{
     bStatic=False
}
