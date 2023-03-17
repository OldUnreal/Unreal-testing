//=============================================================================
// RocketLauncher.uc
// $Date: 4/28/99 11:16a $
// $Revision: 2 $
//=============================================================================
class RocketLauncher expands Weapon;

// First person view
#exec MESH IMPORT MESH=RL1st ANIVFILE=MODELS\ROCKETLAUNCHER\RL1st_a.3d DATAFILE=MODELS\ROCKETLAUNCHER\RL1st_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RL1st X=-110 Y=115 Z=-45
#exec MESH SEQUENCE MESH=RL1st SEQ=All      STARTFRAME=0 NUMFRAMES=83
#exec MESH SEQUENCE MESH=RL1st SEQ=DISPENSE STARTFRAME=0 NUMFRAMES=27
#exec MESH SEQUENCE MESH=RL1st SEQ=DOWN     STARTFRAME=27 NUMFRAMES=12
#exec MESH SEQUENCE MESH=RL1st SEQ=FIRE     STARTFRAME=39 NUMFRAMES=12
#exec MESH SEQUENCE MESH=RL1st SEQ=RELOAD   STARTFRAME=51 NUMFRAMES=14
#exec MESH SEQUENCE MESH=RL1st SEQ=SELECT   STARTFRAME=65 NUMFRAMES=12
#exec MESH SEQUENCE MESH=RL1st SEQ=STILL    STARTFRAME=77 NUMFRAMES=1
#exec MESH SEQUENCE MESH=RL1st SEQ=SWAY     STARTFRAME=78 NUMFRAMES=5

#exec TEXTURE IMPORT NAME=JRL1st1 FILE=MODELS\ROCKETLAUNCHER\PART1.PCX GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=JRL1st2 FILE=MODELS\ROCKETLAUNCHER\PART2.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=JRL1st3 FILE=MODELS\ROCKETLAUNCHER\PART3.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=JRL1st4 FILE=MODELS\ROCKETLAUNCHER\ASMDSMG.PCX GROUP=Skins

#exec MESHMAP NEW   MESHMAP=RL1st MESH=RL1st
#exec MESHMAP SCALE MESHMAP=RL1st X=0.005 Y=0.007 Z=0.01

#exec MESHMAP SETTEXTURE MESHMAP=RL1st NUM=1 TEXTURE=JRL1st1
#exec MESHMAP SETTEXTURE MESHMAP=RL1st NUM=2 TEXTURE=JRL1st2
#exec MESHMAP SETTEXTURE MESHMAP=RL1st NUM=3 TEXTURE=JRL1st3
#exec MESHMAP SETTEXTURE MESHMAP=RL1st NUM=4 TEXTURE=JRL1st1
#exec MESHMAP SETTEXTURE MESHMAP=RL1st NUM=5 TEXTURE=JRL1st2
#exec MESHMAP SETTEXTURE MESHMAP=RL1st NUM=6 TEXTURE=JRL1st4

// Pickup View
#exec MESH IMPORT MESH=RLpickup ANIVFILE=MODELS\ROCKETLAUNCHER\RLpickup_a.3d DATAFILE=MODELS\ROCKETLAUNCHER\RLpickup_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RLpickup X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=RLpickup SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=RLpickup SEQ=RLPICKUP STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JRLpickup1 FILE=MODELS\NEWRL\part1.pcx Group=Skins Flags=2
#exec TEXTURE IMPORT NAME=JRLpickup2 FILE=MODELS\NEWRL\part2.pcx Group=Skins
#exec TEXTURE IMPORT NAME=JRLpickup3 FILE=MODELS\NEWRL\part3.pcx Group=Skins
#exec TEXTURE IMPORT NAME=JRLpickup4 FILE=MODELS\ROCKETLAUNCHER\ASMDSMG.pcx Group=Skins

#exec MESHMAP NEW   MESHMAP=RLpickup MESH=RLpickup
#exec MESHMAP SCALE MESHMAP=RLpickup X=0.05 Y=0.05 Z=0.09

#exec MESHMAP SETTEXTURE MESHMAP=RLpickup NUM=1 TEXTURE=JRLpickup1
#exec MESHMAP SETTEXTURE MESHMAP=RLpickup NUM=2 TEXTURE=JRLpickup3
#exec MESHMAP SETTEXTURE MESHMAP=RLpickup NUM=3 TEXTURE=JRLpickup1
#exec MESHMAP SETTEXTURE MESHMAP=RLpickup NUM=4 TEXTURE=JRLpickup2

// 3rd Person View
#exec MESH IMPORT MESH=RL3rd ANIVFILE=MODELS\ROCKETLAUNCHER\RL3rd_a.3d DATAFILE=MODELS\ROCKETLAUNCHER\RL3rd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RL3rd X=-450 Y=30 Z=30

#exec MESH SEQUENCE MESH=RLpickup SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=RLpickup SEQ=RLPICKUP STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=RL3rd MESH=RL3rd
#exec MESHMAP SCALE MESHMAP=RL3rd X=0.0675 Y=0.0375 Z=0.0675

#exec TEXTURE IMPORT NAME=JRL3rd1 FILE=MODELS\NEWRL\part1.pcx Group=Skins Flags=2
#exec TEXTURE IMPORT NAME=JRL3rd2 FILE=MODELS\NEWRL\part2.pcx Group=Skins
#exec TEXTURE IMPORT NAME=JRL3rd3 FILE=MODELS\NEWRL\part3.pcx Group=Skins
#exec TEXTURE IMPORT NAME=JRL3rd4 FILE=MODELS\ROCKETLAUNCHER\ASMDSMG.pcx Group=Skins

#exec MESHMAP SETTEXTURE MESHMAP=RL3rd NUM=1 TEXTURE=JRL3rd1
#exec MESHMAP SETTEXTURE MESHMAP=RL3rd NUM=2 TEXTURE=JRL3rd2
#exec MESHMAP SETTEXTURE MESHMAP=RL3rd NUM=3 TEXTURE=JRL3rd3
#exec MESHMAP SETTEXTURE MESHMAP=RL3rd NUM=4 TEXTURE=JRL3rd1
#exec MESHMAP SETTEXTURE MESHMAP=RL3rd NUM=5 TEXTURE=JRL3rd2
#exec MESHMAP SETTEXTURE MESHMAP=RL3rd NUM=6 TEXTURE=JRL3rd4

#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketSelect1.wav" NAME="RocketSelect1" GROUP="RocketLauncher"
#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketShot1.wav" NAME="RocketShot1" GROUP="RocketLauncher"
#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketShot2.wav" NAME="RocketShot2" GROUP="RocketLauncher"

var(Weapon) bool bRJDisabled; // Disable RocketJump ability
var int ReloadTracker;
var PathNodeIterator pni;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	ProjectileSpeed = class'UPakRocket'.default.speed;
	AltProjectileSpeed = class'TowRocket'.default.speed;
}

function PostBeginPlay()
{
	if( Level.Game.bDeathMatch )
		PickupAmmoCount += 15;
	Super.PostBeginPlay();
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise( Pawn( Owner ).SoundDampening );
	GetAxes( Pawn( Owner ).ViewRotation, X, Y, Z );
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z; 
	AdjustedAim = Pawn( Owner ).AdjustAim( ProjSpeed, Start, AimError, True, bWarn );	
	return Spawn( ProjClass, Owner,, Start, AdjustedAim );	
}

function PlayFiring()
{
	Owner.PlaySound( FireSound, SLOT_None, Pawn( Owner ).SoundDampening * 4.0 );
	PlayAnim( 'Fire', 0.75 );
}

function PlayAltFiring()
{
	Owner.PlaySound( AltFireSound, SLOT_None, Pawn(Owner).SoundDampening * 4.0 );
	PlayAnim( 'Fire', 0.75 );
}

function Fire( float value )
{
	if ( AmmoType.UseAmmo( 1 ) )
	{
		GotoState( 'NormalFire' );
		
		if( PlayerPawn( Owner ) != None )
			PlayerPawn( Owner ).ShakeView( ShakeTime, ShakeMag, ShakeVert );
		bPointing=True;
		ProjectileFire( ProjectileClass, ProjectileSpeed, bWarnTarget );
		PlayFiring();
		if( Owner.bHidden )
			CheckVisibility();
	}
}
	
function Altfire( float value )
{
	if( AmmoType.UseAmmo( 1 ) )
	{
		GotoState( 'AltFiring' );
		
		if( PlayerPawn( Owner ) != None )
			PlayerPawn( Owner ).ShakeView( ShakeTime, ShakeMag, ShakeVert );
		bPointing=True;
		ProjectileFire( AltProjectileClass, AltProjectileSpeed, bWarnTarget );
		PlayFiring();
		if( Owner.bHidden )
			CheckVisibility();
	}
}

	
function PlayIdleAnim()
{
	if( AnimSequence == 'Fire1' && FRand() < 0.2 )
		Owner.PlaySound( Misc1Sound, SLOT_None, Pawn( Owner ).SoundDampening * 0.5 );
	else if ( AnimSequence!='Still' )
	{
		if( FRand() < 0.5 )
			Owner.PlaySound( Misc1Sound, SLOT_None, Pawn( Owner ).SoundDampening * 0.5 );
		else LoopAnim( 'Still', 0.04, 0.3 );
	}
	Enable( 'AnimEnd' );
}

// ================================================================================================
// Idle State
// ================================================================================================

state Idle
{
	function BeginState()
	{
		bPointing = false;
		SetTimer( 0.5 + 2 * FRand(), false );
		Super.BeginState();
		if( Pawn( Owner ).bFire != 0 )
			Fire( 0.0 );
		if( Pawn(Owner).bAltFire != 0 )
	  	  	AltFire(0.0);		
	}
		
	function EndState()
	{
		SetTimer( 0.0, false );
		Super.EndState();
	}
}


state NormalFire
{
	function BeginState()
	{
		ReloadTracker++;
		Super.BeginState();
	}
	
Begin:
	FinishAnim();
	LoopAnim( 'Still' );
	if( Owner.IsA( 'Bots' ) )
		Sleep( 1.25 );
	else Sleep( 0.5 );
	Finish();
}


state AltFiring
{
Begin:
	FinishAnim();
	LoopAnim( 'Still' );
	if( Owner.IsA( 'Bots' ) )
		Sleep( 1.25 );
	else Sleep( 0.5 );
	Finish();
}


// Implementation note: the function definition is preserved because
// its removal might break custom weapon classes derived from this class
function bool HandlePickupQuery( inventory Item )
{
	return Super.HandlePickupQuery(Item);
} 

defaultproperties
{
     AmmoName=Class'UPak.RLAmmo'
     PickupAmmoCount=5
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     FireOffset=(X=12.000000,Y=-6.000000,Z=-7.000000)
     ProjectileClass=Class'UPak.UPakRocket'
     AltProjectileClass=Class'UPak.TowRocket'
     AIRating=0.600000
     RefireRate=0.150000
     AltRefireRate=0.150000
     FireSound=Sound'UPak.RocketLauncher.RocketShot2'
     AltFireSound=Sound'UPak.RocketLauncher.RocketShot2'
     SelectSound=Sound'UPak.RocketLauncher.RocketSelect1'
     AutoSwitchPriority=6
     InventoryGroup=5
     PickupMessage="You got the RocketLauncher."
     ItemName="RocketLauncher"
     PlayerViewOffset=(X=3.800000,Y=-1.400000,Z=-1.800000)
     PlayerViewMesh=LodMesh'UPak.RL1st'
     PickupViewMesh=LodMesh'UPak.RLpickup'
     ThirdPersonMesh=LodMesh'UPak.RL3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'UPak.RLpickup'
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=8.000000
     bSimulatedPawnRep=true
}
