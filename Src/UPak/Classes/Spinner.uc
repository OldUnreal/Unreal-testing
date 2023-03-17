//=============================================================================
// Spinner.
//=============================================================================
class Spinner expands ScriptedPawn;

#exec MESH IMPORT MESH=Spinner ANIVFILE=MODELS\Spinner\Spider_a.3d DATAFILE=MODELS\Spinner\Spider_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Spinner X=0 Y=0 Z=112 YAW=-64

#exec MESH SEQUENCE MESH=Spinner SEQ=All      STARTFRAME=0 NUMFRAMES=183
#exec MESH SEQUENCE MESH=Spinner SEQ=death    STARTFRAME=0 NUMFRAMES=20
#exec MESH SEQUENCE MESH=Spinner SEQ=bite     STARTFRAME=20 NUMFRAMES=17 Group=Attack
#exec MESH SEQUENCE MESH=Spinner SEQ=backstep STARTFRAME=37 NUMFRAMES=9
#exec MESH SEQUENCE MESH=Spinner SEQ=idle     STARTFRAME=46 NUMFRAMES=19
#exec MESH SEQUENCE MESH=Spinner SEQ=jump     STARTFRAME=65 NUMFRAMES=16
#exec MESH SEQUENCE MESH=Spinner SEQ=look     STARTFRAME=81 NUMFRAMES=26
#exec MESH SEQUENCE MESH=Spinner SEQ=run      STARTFRAME=107 NUMFRAMES=10
#exec MESH SEQUENCE MESH=Spinner SEQ=threat   STARTFRAME=117 NUMFRAMES=17
#exec MESH SEQUENCE MESH=Spinner SEQ=walk     STARTFRAME=134 NUMFRAMES=16
#exec MESH SEQUENCE MESH=Spinner SEQ=wound    STARTFRAME=150 NUMFRAMES=11
#exec MESH SEQUENCE MESH=Spinner SEQ=zap      STARTFRAME=160 NUMFRAMES=23 Group=Attack
#exec MESH SEQUENCE MESH=Spinner SEQ=jumpbite STARTFRAME=182 NUMFRAMES=1 Group=MovingAttack
#exec MESH SEQUENCE MESH=Spinner SEQ=runbite  STARTFRAME=182 NUMFRAMES=1 Group=MovingAttack

#exec TEXTURE IMPORT NAME=JSpinner1 FILE=MODELS\Spinner\Spider1.PCX GROUP=Skins FLAGS=2 // spidxLEG3
#exec TEXTURE IMPORT NAME=JSpinner2 FILE=MODELS\Spinner\Spider2.PCX GROUP=Skins // spidx2map6

#exec MESH NOTIFY MESH=Spinner SEQ=bite          TIME=0.50 FUNCTION=BiteDamageTarget
#exec MESH NOTIFY MESH=Spinner SEQ=jumpbite      TIME=0.50 FUNCTION=BiteDamageTarget
#exec MESH NOTIFY MESH=Spinner SEQ=runbite       TIME=0.50 FUNCTION=BiteDamageTarget
#exec MESH NOTIFY MESH=Spinner SEQ=runbite       TIME=0.00 FUNCTION=RunStep
#exec MESH NOTIFY MESH=Spinner SEQ=runbite       TIME=0.60 FUNCTION=RunStep
#exec MESH NOTIFY MESH=Spinner SEQ=run           TIME=0.00 FUNCTION=RunStep
#exec MESH NOTIFY MESH=Spinner SEQ=run           TIME=0.50 FUNCTION=RunStep
#exec MESH NOTIFY MESH=Spinner SEQ=walk          TIME=0.43 FUNCTION=WalkStep
#exec MESH NOTIFY MESH=Spinner SEQ=walk          TIME=0.93 FUNCTION=WalkStep
//#exec MESH NOTIFY MESH=Spinner SEQ=zap           TIME=0.33 FUNCTION=SpawnShot
//#exec MESH NOTIFY MESH=Spinner SEQ=zap           TIME=0.67 FUNCTION=SpawnShot
#exec MESH NOTIFY MESH=Spinner SEQ=zap           TIME=0.50 FUNCTION=SpawnShot

#exec MESHMAP NEW   MESHMAP=Spinner MESH=Spinner
#exec MESHMAP SCALE MESHMAP=Spinner X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=Spinner NUM=1 TEXTURE=JSpinner1
#exec MESHMAP SETTEXTURE MESHMAP=Spinner NUM=2 TEXTURE=JSpinner2

#exec AUDIO IMPORT FILE="Sounds\Spinner\Idle1.wav"   NAME="amb1"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Idle2.wav"   NAME="amb2"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Bite.wav"    NAME="bite"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Death1.wav"  NAME="die1"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Death2.wav"  NAME="die2"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Hurt1.wav"   NAME="hurt1"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Hurt2.wav"   NAME="hurt2"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Hurt3.wav"   NAME="hurt3"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Threat1.wav" NAME="threat1" GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Threat2.wav" NAME="threat2" GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Threat3.wav" NAME="threat3" GROUP="Spinner"

var() byte BiteDamage;	// Basic damage done by bite.

var(Sounds) sound Bite;
var(Sounds) sound Die2;
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Class'PathNodeIterator'.Static.CheckUPak();
}

//
// Animation functions
//

function PlayRunning()
{
	PlayAnim( 'run' );
	// TODO: Strafing?
}

function PlayWalking()
{
	PlayAnim( 'walk' );
}

function PlayWaiting()
{
	local float AnimSpeed;
	AnimSpeed = 0.3 + 0.6 * FRand(); //vary speed
	if( FRand() < 0.05 )
	{
		SetAlertness( 0.5 );
		PlayAnim( 'look', AnimSpeed, 0.2 );
	}
	else
	{
		SetAlertness( 0.0 );
		PlayAnim( 'idle', AnimSpeed, 0.2 );
	}
}

function PlayTurning()
{
	//PlayAnim( 'walk', 1.0, 0.1 );
	//TweenAnim( 'walk', 0.2 );
	LoopAnim( 'walk', 1.0, 0.2 );
}

function PlayThreatening()
{
	local float decision, AnimSpeed;

	decision = FRand();
	AnimSpeed = 0.4 + 0.6 * FRand();
	
	if( decision < 0.7 )
	{
		PlayAnim( 'threat', AnimSpeed, 0.3 );
	}
	else if( decision < 0.9 )
	{
		PlayAnim( 'idle', AnimSpeed * 2, 0.3 );
	}
	else
	{
		PlayAnim( 'look', AnimSpeed, 0.3 );
	}	
}

function PlayChallenge()
{
	PlayThreatening();
}

function PlayMeleeAttack()
{
	PlayAnim( 'bite' );
}

function PlayMovingAttack()
{
	PlayAnim( 'runbite' );
}

function PlayRangedAttack()
{
	PlayAnim( 'zap' );
}

function PlayGutHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayHeadHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayLeftHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayRightHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayBigDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die2, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayHeadDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayLeftDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayRightDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayGutDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function TweenToRunning( float tweentime )
{
	TweenAnim( 'run', tweentime );
}

function TweenToWalking( float tweentime )
{
	TweenAnim( 'walk', tweentime );
}

function TweenToWaiting( float tweentime )
{
	TweenAnim( 'idle', tweentime );
}

function PlayTakeHitSound( int Damage, name damageType, int Mult )
{
	if( Level.TimeSeconds - LastPainSound < 0.25 )
		return;
	LastPainSound = Level.TimeSeconds;

	if( FRand() < 0.5 )
	{
		PlaySound( HitSound1, SLOT_Pain, 2.0 * Mult );
	}
	else
	{
		PlaySound( HitSound2, SLOT_Pain, 2.0 * Mult );
	}
}


//
// Notify functions
//

function RunStep()
{
	if( FRand() < 0.6 )
		PlaySound( FootStep, SLOT_Interact, 0.8,, 900 );
	else
		PlaySound( FootStep2, SLOT_Interact, 0.8,, 900 );
}

function WalkStep()
{
	if( FRand() < 0.6 )
		PlaySound( FootStep, SLOT_Interact, 0.2,, 500 );
	else
		PlaySound( FootStep2, SLOT_Interact, 0.2,, 500 );
}

function BiteDamageTarget()
{
	if( MeleeDamageTarget( BiteDamage, BiteDamage * 1000 * Normal( Target.Location - Location ) ) )
		PlaySound( Bite, SLOT_Interact );
}

function SpawnShot()
{
	local rotator FireRotation;
	local vector X,Y,Z, projStart;

	GetAxes( Rotation, X, Y, Z );
	MakeNoise( 1.0 );
	projStart = Location + 1.1 * CollisionRadius * X + 0.4 * CollisionHeight * Z;
	FireRotation = AdjustToss( ProjectileSpeed, projStart, 200, bLeadTarget, bWarnTarget );
	spawn( RangedProjectile, self,'', projStart, FireRotation );
}


//
// Miscellaneous functions
//

function SetMovementPhysics()
{
	SetPhysics( PHYS_Falling );
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, EnemyUp;
	local actor HitActor;
	local float EnemyDist;
		
	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize( EnemyDir );
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);

	//log( Self $ " CanFireAtEnemy() EnemyDir " $ rotator(EnemyDir) $ " EnemyDist " $ EnemyDist $ " EnemyUp " $ EnemyUp.Z );

	if( EnemyDist > 640 )
	{
		//log( Self $ " CanFireAtEnemy() EnemyDist > 640, return false" );
		return false;
	}
	if( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir / EnemyDist;
		EnemyUp = 300 * EnemyUp / EnemyDist;
	}
	
	HitActor = Trace( HitLocation, HitNormal, Location + EnemyDir + EnemyUp, Location, true );

	if( HitActor == None || HitActor == Enemy || Pawn(HitActor) != None && AttitudeTo( Pawn(HitActor) ) <= ATTITUDE_Ignore )
		return true;

	HitActor = Trace( HitLocation, HitNormal, Location + EnemyDir, Location, true );

	return HitActor == None || HitActor == Enemy || Pawn(HitActor) != None && AttitudeTo( Pawn(HitActor) ) <= ATTITUDE_Ignore;
}


//
// Aiming functions
//

function rotator AdjustToss( float ProjSpeed, vector ProjStart, int AimError, bool LeadTarget, bool WarnTarget )
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local float TargetDist, TossSpeed, TossTime;

	if( projSpeed == 0 )
		return AdjustAim( projSpeed, projStart, aimerror, leadTarget, warnTarget );
	if( Target == None )
		Target = Enemy;
	if( Target == None )
		return Rotation;
	if( !Target.IsA('Pawn') )
		return rotator( Target.Location - Location );
					
	FireSpot = Target.Location;
	TargetDist = VSize( Target.Location - ProjStart );
	//AimError = AimError * ( 11 - 10 * 
	//	( ( Target.Location - Location ) / TargetDist 
	//		Dot Normal( ( Target.Location + 0.7 * Target.Velocity ) - ( ProjStart + 0.7 * Velocity ) ) ) ); 

	//AimError = AimError * (2.6 - 0.65 * (skill + FRand()));
	//if ( (Skill < 2) && (Level.TimeSeconds - LastPainTime < 0.15) )
	//	aimerror *= 1.3;

	if ( leadTarget )
	{
		FireSpot += FMin( 1, 0.7 + 0.6 * FRand() ) * ( Target.Velocity * TargetDist / ProjSpeed );
		HitActor = Trace( HitLocation, HitNormal, FireSpot, ProjStart, false );
		if( HitActor != None )
		{
			FireSpot = 0.5 * ( FireSpot + Target.Location );
		}
	}

	//try middle
	FireSpot.Z = Target.Location.Z;
	HitActor = Trace( HitLocation, HitNormal, FireSpot, ProjStart, false );

	if ( HitActor != None && Target == Enemy )
	{
		FireSpot = LastSeenPos;
		if( Location.Z >= LastSeenPos.Z )
		{
			FireSpot.Z -= 0.5 * Enemy.CollisionHeight;
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
	if( FRand() < 0.90 )
	{
		TossSpeed = ProjSpeed + 0.4 * VSize( Velocity );
		if( Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z || TargetDist > TossSpeed )
		{
			TossTime = TargetDist / TossSpeed;
			FireSpot.Z -= ( ( 0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200 ) * TossTime + 0.4 * CollisionHeight );
		}
	}
	
	FireRotation = Rotator( FireSpot - ProjStart );
	     
	FireRotation.Yaw = FireRotation.Yaw + ( Rand(2 * AimError) - AimError );
	if( WarnTarget && Pawn(Target) != None )
		Pawn(Target).WarnTarget( self, ProjSpeed, Vector(FireRotation) );

	FireRotation.Yaw = FireRotation.Yaw & 65535;
	if( Abs( FireRotation.Yaw - ( Rotation.Yaw & 65535 ) ) > 8192 &&
		Abs( FireRotation.Yaw - ( Rotation.Yaw & 65535 ) ) < 57343 )
	{
		if( FireRotation.Yaw > Rotation.Yaw + 32768 ||
			FireRotation.Yaw < Rotation.Yaw && FireRotation.Yaw > Rotation.Yaw - 32768 )
		{
			FireRotation.Yaw = Rotation.Yaw - 8192;
		}
		else
		{
			FireRotation.Yaw = Rotation.Yaw + 8192;
		}
	}
	ViewRotation = FireRotation;
	return FireRotation;
}


//
// States
//

auto state StartUp
{
	function SetFall()
	{
	}
	function SetMovementPhysics()
	{
		SetPhysics( PHYS_None ); // don't fall at start
	}
//Begin:
//	log( Self $ " StartUp Rotation " $ Rotation $ " DesiredRotation " $ DesiredRotation );
}

state Waiting
{
TurnFromWall:
	if( NearWall(70) )
	{
		PlayTurning();
		TurnTo( Focus );
	}
Begin:
	TweenToWaiting( 0.4 );
	bReadyToAttack = false;
	if( Physics != PHYS_Falling )
	{
		SetPhysics( PHYS_None );
	}
KeepWaiting:
	NextAnim = '';
}

defaultproperties
{
     BiteDamage=20
     Die2=Sound'UPak.Spinner.Die2'
     footstep=Sound'UPak.Predator.step1'
     Footstep2=Sound'UPak.Predator.step2'
     CarcassType=Class'UPak.SpinnerCarcass'
     TimeBetweenAttacks=3.500000
     bHasRangedAttack=True
     bGreenBlood=True
     RangedProjectile=Class'UPak.SpinnerProjectile'
     Acquire=Sound'UPak.Spinner.threat1'
     Threaten=Sound'UPak.Spinner.threat2'
     bCanStrafe=True
     MeleeRange=60.000000
     GroundSpeed=250.000000
     AccelRate=500.000000
     JumpZ=128.000000
     HitSound1=Sound'UPak.Spinner.hurt1'
     HitSound2=Sound'UPak.Spinner.hurt2'
     Die=Sound'UPak.Spinner.Die1'
     CombatStyle=0.750000
     DrawType=DT_Mesh
     Mesh=LodMesh'UPak.Spinner'
     CollisionRadius=32.000000
     Buoyancy=100.000000
     RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
     bIsCrawler=true
}
