//=============================================================================
// UPakCamTrigger.
//=============================================================================
class UPakCamTrigger expands Triggers;

var() int CameraFOV;
var() UPakCam CameraArray[ 32 ];
var() float CameraSwitchTime;
var int CurrentCamera;
var bool bInactive;
var Pawn Victim;
var() bool bLetterBox;
var() bool bFreezePlayer, bFreezeRotation;
var bool bCanDisable;
var bool bFadeOut, bTurnedOn;
var bool bUnTouchDisabled;
var float OldFOV;

function PostBeginPlay()
{
	local int i;
	
	for( i = 0; i <= 31; i++ )
	{
		if( CameraArray[ i ] != none )
			CameraArray[ i ].Director = self;
		else break;
	}
}

function Touch( actor Other )
{
	if( !bInActive )
	{
		if( Other.IsA( 'PlayerPawn' ) )
		{
			Victim = Pawn( Other );
			OldFov = PlayerPawn( Other ).DesiredFOV;
			PlayerPawn( Other ).LoopAnim( 'Breath1', 0.3 );
			if( bFreezePlayer )
				Pawn( Other ).SetPhysics( PHYS_None );
			PlayerPawn( Other ).SetDesiredFOV( CameraFOV );
			if( !CameraArray[ CurrentCamera ].bNoHUD )
				UPakHUD( PlayerPawn( Victim ).myHUD ).bNoHUD = true;
			if( !CameraArray[ CurrentCamera ].bNoCrosshair )
				UPakHUD( PlayerPawn( Victim ).myHUD ).bNoCrosshair = true;
			PlayerPawn( Other ).ViewTarget = CameraArray[ 0 ];
			if( bLetterBox )
				UPakHUD( PlayerPawn( Other ).myHUD ).bLetterBox = true;
			CameraArray[ 0 ].TurnOn();
		}
	}
}

function UnTouch( actor Other )
{
	if( Victim == Pawn( Other ) && !bUnTouchDisabled )
	{
		TurnOffCameras();
		PlayerPawn( Victim ).SetDesiredFOV( OldFOV );
		PlayerPawn( Victim ).SetPhysics( PHYS_Walking );
		UPakHUD( PlayerPawn( Victim ).myHUD ).bNoCrosshair = false;
		PlayerPawn( Victim ).ViewTarget = none;
		UPakHUD( PlayerPawn( Victim ).myHUD ).bLetterBox = false;
		UPakHUD( PlayerPawn( Victim ).myHUD ).bNoHUD = false;
		CurrentCamera = 0;

	}
}


function Timer()
{
	SwitchCamera();
}

function SwitchCamera()
{
	if( CameraArray[ CurrentCamera + 1 ] != none && CameraArray[ CurrentCamera + 1 ].bFadeIn && !bFadeOut )
	{
		PlayerPawn( Victim ).ClientAdjustGlow( -1, vect( 0, 0, 0 ) );
		SetTimer( 1.5, false );
		bFadeOut = true;
		return;
	}
	CurrentCamera += 1;

	if( CameraArray[ CurrentCamera ] == none )
	{
		CurrentCamera = 0;
	}
	if( CameraCanSeeTarget() )
	{	
	 	PlayerPawn( Victim ).ViewTarget = CameraArray[ CurrentCamera ];
	}
	else
	{
		CurrentCamera++;
		if( CameraArray[ CurrentCamera ] == none )
			CurrentCamera = 0;
	}

	if( !CameraArray[ CurrentCamera ].bNoHUD )
	{
		UPakHUD( PlayerPawn( Victim ).myHUD ).bNoHUD = true;
	}			
	
	CameraArray[ CurrentCamera ].TurnOn();
	if( bFadeOut )
	{
		PlayerPawn( Victim ).ClientAdjustGlow( 1, vect( 0, 0, 0 ) );
		bFadeOut = false;
	}
}
	
function bool CameraCanSeeTarget()
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	
	CameraArray[ CurrentCamera ].RotateToTarget();
	
	HitActor = trace( HitLocation, HitNormal, CameraArray[ CurrentCamera ].CameraTarget.Location, CameraArray[ CurrentCamera ].Location, true );
	if( HitActor == CameraArray[ CurrentCamera ].CameraTarget )
		return true;
	else return false;
}

	
function Trigger( actor Other, pawn EventInstigator )
{
	if( !bTurnedOn )
	{
		bUnTouchDisabled = true;	
		Touch( EventInstigator );
		bTurnedOn = true;
	}
	else
	{
		TurnOffCameras();
		PlayerPawn( Victim ).SetDesiredFOV( OldFOV );
		PlayerPawn( Victim ).ViewTarget = none;
		PlayerPawn( Victim ).SetPhysics( PHYS_Walking );
		UPakHUD( PlayerPawn( Victim ).myHUD ).bNoCrosshair = false;
		UPakHUD( PlayerPawn( Victim ).myHUD ).bLetterBox = false;
		UPakHUD( PlayerPawn( Victim ).myHUD ).bNoHUD = false;
		CurrentCamera = 0;
	}	
}

function TurnOffCameras()
{
	local int i;
	
	for( i = 0; i <= 31; i++ )
	{
		if( CameraArray[ i ] != none )
			CameraArray[ i ].TurnOff();
		else break;
	}
}

defaultproperties
{
}
