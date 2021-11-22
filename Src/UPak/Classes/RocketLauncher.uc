//=============================================================================
// RocketLauncher.uc
// $Date: 4/28/99 11:16a $
// $Revision: 2 $
//=============================================================================
class RocketLauncher expands Weapon;

#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketSelect1.wav" NAME="RocketSelect1" GROUP="RocketLauncher"
#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketShot1.wav" NAME="RocketShot1" GROUP="RocketLauncher"
#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketShot2.wav" NAME="RocketShot2" GROUP="RocketLauncher"

var( Weapon ) bool bRJDisabled; // Disable RocketJump ability
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
