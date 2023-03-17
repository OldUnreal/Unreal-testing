//=============================================================================
// Combat Assault Rifle.uc
// $Date: 5/05/99 11:05a $
// $Revision: 2 $
//=============================================================================
class CARifle expands Weapon;

// First Person View
#exec MESH IMPORT MESH=Car1st ANIVFILE=MODELS\CARIFLE\Car1st_a.3d DATAFILE=MODELS\CARIFLE\Car1st_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Car1st X=0 Y=0 Z=07

#exec MESH SEQUENCE MESH=Car1st SEQ=All        STARTFRAME=0 NUMFRAMES=53
#exec MESH SEQUENCE MESH=Car1st SEQ=ALTFIRE   STARTFRAME=0 NUMFRAMES=13
#exec MESH SEQUENCE MESH=Car1st SEQ=ALTRELOAD STARTFRAME=13 NUMFRAMES=5
#exec MESH SEQUENCE MESH=Car1st SEQ=DOWN       STARTFRAME=18 NUMFRAMES=10
#exec MESH SEQUENCE MESH=Car1st SEQ=FIRE       STARTFRAME=28 NUMFRAMES=5
#exec MESH SEQUENCE MESH=Car1st SEQ=SELECT     STARTFRAME=33 NUMFRAMES=15
#exec MESH SEQUENCE MESH=Car1st SEQ=STILL      STARTFRAME=48 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Car1st SEQ=SWAY       STARTFRAME=49 NUMFRAMES=4
//
#exec TEXTURE IMPORT NAME=Jnewcar1 FILE=MODELS\CARIFLE\car01.pcx Group=Skins Flags=2
#exec TEXTURE IMPORT NAME=Jnewcar2 FILE=MODELS\CARIFLE\car02.pcx Group=Skins
#exec TEXTURE IMPORT NAME=Jnewcar3 FILE=MODELS\CARIFLE\car03.pcx Group=Skins

#exec TEXTURE IMPORT NAME=JCar1st0 FILE=MODELS\CARIFLE\flash.PCX GROUP=Skins FLAGS=2

#exec MESHMAP NEW   MESHMAP=Car1st MESH=Car1st
#exec MESHMAP SCALE MESHMAP=Car1st X=0.01 Y=0.01 Z=0.02

#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=1 TEXTURE=Jnewcar1
#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=2 TEXTURE=JCar1st0

#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=3 TEXTURE=Jnewcar3
#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=4 TEXTURE=Jnewcar2
//#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=1 TEXTURE=JCARIFLE4

//#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=1 TEXTURE=JCar1st1

// Pickup View
#exec MESH IMPORT MESH=CARpickup ANIVFILE=MODELS\CARIFLE\CARpickup_a.3d DATAFILE=MODELS\CARIFLE\CARpickup_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CARpickup X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=CARpickup SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CARpickup SEQ=CARPICKUP STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JCAR3rd1 FILE=MODELS\CARIFLE\CAR-PICK-LOW.PCX GROUP=Skins FLAGS=2 

#exec MESHMAP NEW   MESHMAP=CARpickup MESH=CARpickup
#exec MESHMAP SCALE MESHMAP=CARpickup X=0.16 Y=0.16 Z=0.26

#exec MESHMAP SETTEXTURE MESHMAP=CARpickup NUM=1 TEXTURE=JCAR3rd1

// Third-person view
#exec MESH IMPORT MESH=Car3rd ANIVFILE=MODELS\CARIFLE\Car3rd_a.3d DATAFILE=MODELS\CARIFLE\Car3rd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Car3rd X=-105 Y=0 Z=-15

#exec MESH SEQUENCE MESH=Car3rd SEQ=All        STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=Car3rd SEQ=ALTFIRE STARTFRAME=0 NUMFRAMES=4
#exec MESH SEQUENCE MESH=Car3rd SEQ=FIRE    STARTFRAME=4 NUMFRAMES=4
#exec MESH SEQUENCE MESH=Car3rd SEQ=STILL   STARTFRAME=8 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Car3rd SEQ=ALTRELOAD STARTFRAME=8 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Car3rd SEQ=SELECT STARTFRAME=8 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Car3rd SEQ=SWAY STARTFRAME=8 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Car3rd SEQ=DOWN STARTFRAME=8 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JCar3rd0 FILE=MODELS\CARIFLE\flash.PCX GROUP=Skins FLAGS=2

#exec MESHMAP NEW   MESHMAP=Car3rd MESH=Car3rd
#exec MESHMAP SCALE MESHMAP=Car3rd X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=Car3rd NUM=0 TEXTURE=JCar3rd0
#exec MESHMAP SETTEXTURE MESHMAP=Car3rd NUM=1 TEXTURE=JCar3rd1

// Sounds
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\FIRING.WAV" NAME="Firing" GROUP="CARifle"
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\SHORTFIRE.WAV" NAME="ShortFire" GROUP="CARifle"
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CHAINEND3.WAV" NAME="ChainEnd3" GROUP="CARifle"
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CHAINLOOP3.WAV" NAME="ChainLoop3" GROUP="CARifle"
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CHAINSTART3.WAV" NAME="ChainStart3" GROUP="CARifle"

#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CHAINGUN3.WAV" NAME="ChainGun3" GROUP="CARifle"

#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CARifleSelect.WAV" NAME="CARifleSelect" GROUP="CARifle"
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CARifleLoad.WAV" NAME="CARifleLoad" GROUP="CARifle"
#exec AUDIO IMPORT FILE="SOUNDS\CARIFLE\CARifleShell.WAV" NAME="CARifleShell" GROUP="CARifle"

var float ShotAccuracy, Count;
var float Adjuster;				// Used for adjusting aim error, etc.
var int RoundsFired;			// Won't need this much longer
var int InitialRounds;			// Number of inital rounds fired before bFirstFire becomes false
var int TraceCount;
var vector StartingLocation;
var Rotator AdjustedAimStored;
var pawn Victim;
var int LightCounter;
var PathNodeIterator pni;
var bool bTracerOn;
var bool bAutoTarget;
var bool bFirstFire;			// First pulse has no immediate recoil- this flag determines that
var bool bAltFireReady;

// Delete me
var CARDebug CARDebugger;

replication
{
	reliable if( Role==ROLE_Authority )
		ShakePlayer, AdjustedAimStored;
}

exec function Tracer()
{
	bTracerOn = !bTracerOn;
}

exec function Debug()
{
	CARDebugger = spawn( class'CARDebug' );
	CARDebugger.DebugWeapon = self;
	CARDebugger.GotoState( 'Debugging' );
}

function PostBeginPlay()
{
	bFirstFire = True;
	AltProjectileClass = class'ExplosiveBullet';
	bAltFireReady = True;
	bTracerOn = True;
	Super.PostBeginPlay();
}

function SetUpProjectile()
{
	RoundsFired = 0;
	if( AmmoType.UseAmmo( 1 ) )
		TraceFire( 0.25 );
	else
		GotoState( 'FinishFire' );
}

simulated function ShakePlayer( float ShakeMod )
{
	local vector X, Z;

	if( PlayerPawn( Owner ) != None && InitialRounds >= 10 && bFirstFire )
		bFirstFire = false;
	else
	{
		PlayerPawn(Owner).ShakeTimer = 0.01;
		PlayerPawn(Owner).maxshake = 20 * ShakeMod;
		PlayerPawn(Owner).ShakeMag = 0;
		PlayerPawn(Owner).verttimer = 0.001;
	}

	if( Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer && LightCounter >= 5 )
	{
		spawn(class'WeaponLight',self,,Owner.Location+CalcDrawOffset()+X*25+Z*15,rot(0,0,0));
		LightCounter = 0;
	}
	LightCounter++;
}


function Finish()
{
	if( bChangeWeapon )
	{
		GotoState( 'DownWeapon' );
		return;
	}
	if( PlayerPawn( Owner ) == None )
	{
		if( AmmoType.AmmoAmount <= 0 )
		{
			Pawn( Owner ).StopFiring();
			Pawn( Owner ).SwitchToBestWeapon();
			if( bChangeWeapon )
			{
				GotoState( 'DownWeapon' );
			}
		}
		else if( Pawn( Owner ).bFire != 0 )
			Global.Fire( 0 );
		else if( (Pawn( Owner ).bAltFire != 0 ) && ( FRand() < AltRefireRate ) )
			Global.AltFire( 0 );
		else
		{
			Pawn( Owner ).StopFiring();
			GotoState( 'Idle' );
		}
		return;
	}

	if( (AmmoType.AmmoAmount <= 0) || (Pawn( Owner ).Weapon != self ) )
		GotoState( 'Idle' );
	else if( Pawn( Owner ).bFire != 0 )
		Global.Fire( 0 );
	else if( Pawn( Owner ).bAltFire != 0 )
		Global.AltFire( 0 );
	else GotoState( 'Idle' );
}

function Timer()
{
	if( Owner!=None )
	{
		PlayAnim( 'AltReload', 0.8 );
		PlaySound( sound'CARifleLoad', SLOT_Misc, 3.0 * Pawn( Owner ).SoundDampening, True );
	}
	bAltFireReady = True;
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local float OldAccuracy;
	local vector AimDir;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	if( bAutoTarget )
	{
		PlayerPawn( Owner ).ViewRotation = rotator( Normal( Victim.Location - PlayerPawn( Owner ).Location ) );
	}
	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	if( VSize( Pawn(Owner).Velocity ) > 200 && VSize( Pawn(Owner).Velocity ) <= 500)
	{
		OldAccuracy = Accuracy;
		Accuracy += 0.11;
	}
	else if( VSize( Pawn(Owner).Velocity ) > 500 && VSize( Pawn(Owner).Velocity ) <= 750 )
	{
		OldAccuracy = Accuracy;
		Accuracy += 0.2;
	}

	else if( VSize(Pawn(Owner).Velocity ) > 750 )
	{
		OldAccuracy = Accuracy;
		Accuracy += 0.5;
	}

	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * (X) + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = Pawn(Owner).AdjustAim( 1000000, StartTrace, 2.75 * AimError, False, False );
	AdjustedAimStored = AdjustedAim;
	EndTrace = StartTrace + ( Accuracy+Adjuster ) * ( FRand() - 0.5 )* Y * 1000 + Accuracy * ( FRand() - 0.5 ) * Z * 1000 ;
	EndTrace += ( 10000 * vector( AdjustedAim ) );
	Other = Pawn( Owner ).TraceShot( HitLocation, HitNormal, EndTrace, StartTrace );
	AimDir = vector( AdjustedAim );
	if ( VSize(HitLocation - StartTrace) > 250 && TraceCount == 15 )
	{
		Spawn(class'CARTracer',,, StartTrace + 125 * AimDir,rotator(EndTrace - StartTrace));
		TraceCount = 0;
	}
	TraceCount++;
	ProcessTraceHit( Other, HitLocation, HitNormal, vector( AdjustedAim ), Y, Z );
	Accuracy = OldAccuracy;
	// Increment Adjuster, which affects accuracy based on how long you've been firing.
	if( Adjuster <= 0.35 )
	{
		Adjuster += 0.025;
	}
	RoundsFired = 0;
}

function ProcessTraceHit( Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z )
{
	local int rndDam;
	local WallHitEffect WallHit;
	local SpriteSmokePuff Puff;

	if( PlayerPawn( Owner ) != None )
	{
		if( Pawn( Owner ) != None )
			ShakePlayer( 1 );
		InitialRounds++;
	}
	if (Other != None && (Other == Level || Other.bWorldGeometry))
	{
		if( FRand() < 0.5 )
			WallHit = Spawn( class'CARWallHitEffect2',,, HitLocation + HitNormal * 9, Rotator( HitNormal ) );
		else WallHit = Spawn( class'CARWallHitEffect',,, HitLocation + HitNormal * 9, Rotator( HitNormal ) );
		WallHit.DrawScale -= FRand();
	}
	else if( Other != None && Other != Self && Other != Owner )
	{
		if( !Other.IsA( 'Pawn' ) && !Other.IsA( 'Carcass' ) )
		{
			if( FRand() < 0.01 )
			{
				Puff = spawn( class'SpriteSmokePuff',,, HitLocation + HitNormal * 9 );
				Puff.DrawScale -= FRand();
			}
		}

		if( Level.Game.IsA( 'SinglePlayer' ) )
			rndDam = Rand( 5 ) + 2;
		else rndDam = Rand( 10 ) + 2;

		if( Other != None && Other.IsA( 'Carcass' ) )
			rndDam = 10 + Rand(10);
		if( Other != None && !Owner.IsA( 'SpaceMarine' ) )
			Other.TakeDamage( rndDam, Pawn(Owner), HitLocation, rndDam * 250.0 * X, 'shot' );
		else if( OTher != None && Owner.IsA( 'SpaceMarine' ) )
		{
			rndDam = 3;
			Other.TakeDamage( rndDam, Pawn( Owner ), HitLocation, rndDam * 500.0 * X, 'shot' );
		}
	}

}

function Fire( float Value )
{
	Enable( 'Tick' );
	if( Count < 1 && AmmoType.AmmoAmount > 0 )
	{
		CheckVisibility();
		// Need a looping .wav for this
		PlaySound( sound'ChainStart3', SLOT_Misc, 3.0 * Pawn( Owner ).SoundDampening, True );

		if( PlayerPawn(Owner) != None )
			PlayerPawn( Owner ).ShakeView( ShakeTime, ShakeMag, ShakeVert );
		SoundVolume = 255 * Pawn( Owner ).SoundDampening;
		bPointing = True;
		ShotAccuracy = 0.3;
		if ( AnimSequence != 'AltFire' )
		{
			PlayFiring();
		}
		GotoState( 'NormalFire' );
	}
	else
		GoToState( 'Idle' );
}

function AltFire( float Value )
{
	Enable( 'Tick' );

	if( Count < 1 && bAltFireReady && AmmoType.UseAmmo( 5 ) )
	{
		CheckVisibility();
		PlaySound( sound'CARifleShell', SLOT_Misc );
		if( PlayerPawn( Owner ) != None )
			PlayerPawn( Owner ).ShakeView( 0.35, 250, 5 );
		SoundVolume = 255 * Pawn( Owner ).SoundDampening;
		bPointing = True;
		ShotAccuracy = 0.0;
		PlayAltFiring();
		GotoState( 'AltFiring' );
	}
	else
	{
		Pawn( Owner ).bAltFire = 0;
		GoToState( 'Idle' );
	}
}

function PlayFiring()
{
	LoopAnim( 'Fire', 1.98 );
}

function PlayAltFiring()
{
	PlayAnim( 'AltFire', 1.5);
}

// ================================================================================================
// FinishFire State
// ================================================================================================

state FinishFire
{
	function AltFire( float F );

Begin:
	Pawn(Owner).bAltFire = 0;
	if( Pawn(Owner).bFire == 0 )
	{
		Adjuster = 0;
		InitialRounds = 0;
		FinishAnim();
		bFirstFire = True;
		if ( (AmmoType != None) && ( AmmoType.AmmoAmount <= 0 ) )
		{
			FinishAnim();
			Pawn( Owner ).SwitchToBestWeapon();  //Goto Weapon that has Ammo
		}
		Finish();
	}
	if( ( AmmoType != None ) && ( AmmoType.AmmoAmount <= 0 ) )
	{
		FinishAnim();
		Pawn( Owner ).SwitchToBestWeapon();  //Goto Weapon that has Ammo
		Finish();
	}
}

// ================================================================================================
// NormalFire State
// ================================================================================================

state NormalFire
{
	function Tick( float DeltaTime )
	{
		if( Owner == None )
			AmbientSound = None;
	}
	function AnimEnd()
	{
		if( AnimSequence != 'Fire' || !bAnimLoop )
		{
			if( Pawn( Owner ).bFire != 0 )
				LoopAnim('Fire', 1.95 , 0.05);
		}
		if( Pawn(Owner).bFire == 0 || AmmoType.AmmoAmount <= 0 )
			GotoState( 'FinishFire' );
	}
	function AltFire( float Value )
	{
		Enable( 'Tick' );

		if( Count < 1 && bAltFireReady )
		{
			CheckVisibility();
			PlaySound( sound'CARifleShell', SLOT_Misc );
			if( PlayerPawn( Owner ) != None )
			{
				PlayerPawn( Owner ).ShakeView( 0.35, 250, 5 );
			}
			SoundVolume = 255 * Pawn( Owner ).SoundDampening;
			bPointing = True;
			ShotAccuracy = 0.0;
			PlayAltFiring();
			GotoState( 'AltFiring' );
		}
		else
		{
			Pawn( Owner ).bAltFire = 0;
			GoToState( 'Idle' );
		}
	}
	function BeginState()
	{
		AmbientSound = FireSound;
	}
	function EndState()
	{
		local float Damping;

		if( Pawn(Owner) == None )
			Damping = 1;
		else Damping = Pawn( Owner) .SoundDampening;

		AmbientSound = None;
		PlaySound( sound'ChainEnd3', SLOT_Misc, 3.0 * Damping);
		Super.EndState();
	}

Begin:
	SetLocation( Owner.Location );
	Sleep( 0.04 );
	SetUpProjectile();
	if (Level.Netmode != NM_Standalone)
		PlayAnim( 'Fire', 1.98 );
	else LoopAnim( 'Fire', 1.98 );
	if( Pawn(Owner).bFire == 0 || AmmoType.AmmoAmount <= 0 )
		GotoState( 'FinishFire' );
	Goto( 'Begin' );
}

// ================================================================================================
// AltFiring State
// ================================================================================================

state AltFiring
{
	function ShortFire()
	{
		PlaySound( sound'CARifleShell', Slot_Misc, 4 );
		ProjectileFire( AltProjectileClass, AltProjectileSpeed, False );
		Pawn( Owner ).bAltFire = 0;
		RoundsFired = 3;
		bAltFireReady = False;
	}
	function Tick( float DeltaTime )
	{
		if( Owner == None )
			AmbientSound = None;
		if( PlayerPawn( Owner ) == None && ( FRand() > AltReFireRate ) )
			Pawn(Owner).bAltFire = 0;
		if( Pawn(Owner).bAltFire == 0 )
			Finish();
	}
	function AnimEnd()
	{
		if( Pawn( Owner ).bAltFire == 0 || AmmoType.AmmoAmount <= 0 )
			Finish();
	}
	function EndState()
	{
		SetTimer( 1.0, False );
		AmbientSound = None;
	}
Begin:
	SetLocation( Owner.Location );
	ShortFire();
	if( PlayerPawn( Owner ) != None )
	{
		ShakePlayer( 1.2 );
	}
	FinishAnim();
	PlayAnim( 'Still' );
	Finish();
}

// ================================================================================================
// Idle State
// ================================================================================================

state Idle
{

Begin:
	FinishAnim();
	if( ( AmmoType != None ) && ( AmmoType.AmmoAmount <= 0 ) )
	{
		FinishAnim();
		Pawn( Owner ).StopFiring();
		Pawn( Owner ).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	}

	if( Pawn( Owner ).bFire != 0 && AmmoType.AmmoAmount > 0 )
		Fire( 0.0 );

	if( Pawn( Owner ).bAltFire != 0 && AmmoType.AmmoAmount > 4 )
		AltFire( 0.0 );

	PlayAnim( 'Still' );
	bPointing = False;
	Disable( 'AnimEnd' );
	PlayIdleAnim();
}

// Toss this weapon out
function DropFrom(vector StartLocation)
{
	bAltFireReady = true;
	Super.DropFrom(  StartLocation );
}

// Implementation note: the function definition is preserved because
// its removal might break custom weapon classes derived from this class
function bool HandlePickupQuery( inventory Item )
{
	return Super.HandlePickupQuery(Item);
} 

defaultproperties
{
     AmmoName=Class'UPak.CARifleClip'
     PickupAmmoCount=300
     bInstantHit=True
     FireOffset=(X=10.000000)
     AltProjectileClass=Class'UPak.ExplosiveBullet'
     shakemag=200.000000
     shaketime=0.000500
     shakevert=16.000000
     AIRating=0.400000
     RefireRate=30.000000
     AltRefireRate=0.300000
     FireSound=Sound'UPak.CARifle.ChainGun3'
     AltFireSound=Sound'UPak.CARifle.CARifleShell'
     SelectSound=Sound'UPak.CARifle.CARifleSelect'
     AutoSwitchPriority=4
     InventoryGroup=3
     PickupMessage="You got the Combat Assault Rifle"
     ItemName="Combat Assault Rifle"
     PlayerViewOffset=(X=3.250000,Y=-0.900000,Z=-1.450000)
     PlayerViewMesh=LodMesh'UPak.Car1st'
     PickupViewMesh=LodMesh'UPak.CARpickup'
     ThirdPersonMesh=LodMesh'UPak.Car3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'UPak.CARpickup'
     bNoSmooth=False
     CollisionHeight=8.000000
}
