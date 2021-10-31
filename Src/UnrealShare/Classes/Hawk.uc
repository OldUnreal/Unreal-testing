//=============================================================================
// Hawk - Animated and scripted by .:..:
// new mesh and sounds by Turboman
//=============================================================================

Class Hawk extends ScriptedPawn;
#exec TEXTURE IMPORT NAME=Jhawk FILE=MODELS\hawk\jhawk.PCX GROUP=Skins LODSET=2 FLAGS=2 //mask
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hcall1.wav" NAME="Hcall1" GROUP="Hawk"
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hcall2.wav" NAME="Hcall2" GROUP="Hawk"
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hcall3.wav" NAME="Hcall3" GROUP="Hawk"
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hcall4.wav" NAME="Hcall4" GROUP="Hawk"
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hdeath1.wav" NAME="Hdeath1" GROUP="Hawk"
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hhit1.wav" NAME="Hhit1" GROUP="Hawk"
#exec AUDIO IMPORT FILE="Sounds\Hawk\Hflap1.wav" NAME="Hflap1" GROUP="Hawk"
#exec MESH IMPORT MESH=HawkM ANIVFILE=MODELS\hawk\HawkM_a.3d DATAFILE=MODELS\hawk\HawkM_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=HawkM X=0 Y=0 Z=64 YAW=64
#exec MESH LODPARAMS MESH=HawkM STRENGTH=0

#exec MESH SEQUENCE MESH=HawkM SEQ=All   		STARTFRAME=0 NUMFRAMES=120
#exec MESH SEQUENCE MESH=HawkM SEQ=walk 		STARTFRAME=0 NUMFRAMES=20 RATE=14
#exec MESH SEQUENCE MESH=HawkM SEQ=scratching 	STARTFRAME=21 NUMFRAMES=12 RATE=7
#exec MESH SEQUENCE MESH=HawkM SEQ=idle 		STARTFRAME=34 NUMFRAMES=3 RATE=1
#exec MESH SEQUENCE MESH=HawkM SEQ=looking 	STARTFRAME=36 NUMFRAMES=8 RATE=4
#exec MESH SEQUENCE MESH=HawkM SEQ=takeoff 	STARTFRAME=44 NUMFRAMES=8 RATE=10
#exec MESH SEQUENCE MESH=HawkM SEQ=fly 		STARTFRAME=52 NUMFRAMES=7 RATE=10
#exec MESH SEQUENCE MESH=HawkM SEQ=preattack 	STARTFRAME=101 NUMFRAMES=9 RATE=15
#exec MESH SEQUENCE MESH=HawkM SEQ=attack 	STARTFRAME=60 NUMFRAMES=9 RATE=15
#exec MESH SEQUENCE MESH=HawkM SEQ=attack2 		STARTFRAME=101 NUMFRAMES=8 RATE=15
#exec MESH SEQUENCE MESH=HawkM SEQ=deathfalling 	STARTFRAME=70 NUMFRAMES=6 RATE=15
#exec MESH SEQUENCE MESH=HawkM SEQ=deathlanded STARTFRAME=72 NUMFRAMES=6 RATE=15
#exec MESH SEQUENCE MESH=HawkM SEQ=land 		STARTFRAME=79 NUMFRAMES=10 RATE=10
#exec MESH SEQUENCE MESH=HawkM SEQ=run 		STARTFRAME=90 NUMFRAMES=8 RATE=14
#exec MESH SEQUENCE MESH=HawkM SEQ=call 	STARTFRAME=111 NUMFRAMES=9 RATE=15

#exec MESH SEQUENCE MESH=HawkM SEQ=walking 		STARTFRAME=0 NUMFRAMES=20 RATE=14
#exec MESH SEQUENCE MESH=HawkM SEQ=takehit 	STARTFRAME=70 NUMFRAMES=1
#exec MESH SEQUENCE MESH=HawkM SEQ=deathfall 	STARTFRAME=73 NUMFRAMES=1
#exec MESH SEQUENCE MESH=HawkM SEQ=fighter 	STARTFRAME=79 NUMFRAMES=1
#exec MESH SEQUENCE MESH=HawkM SEQ=glide	 	STARTFRAME=79 NUMFRAMES=1
#exec MESH SEQUENCE MESH=HawkM SEQ=deathland 	STARTFRAME=77 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=HawkM MESH=HawkM
#exec MESHMAP SCALE MESHMAP=HawkM X=0.2 Y=0.2 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=HawkM NUM=0 TEXTURE=Jhawk


//-----------------------------------------------------------------------------
// Manta variables.

// Attack damage.
var() byte WhipDamage;		// Basic damage done by whip.
var bool bAttackBump;
var bool bAvoidHit;
var(Sounds) sound whip;
var(Sounds) sound WingBeat;
var(Sounds) sound sting;

//-----------------------------------------------------------------------------
// Manta functions.

/* PreSetMovement()
default for walking creature.  Re-implement in subclass
for swimming/flying capability
*/

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( skill <= 1 )
		Health = 0.6 * Health;
	if ( skill == 0 )
		AttitudeToPlayer = ATTITUDE_Ignore;
}

function PreSetMovement()
{
	MaxDesiredSpeed = 0.6 + 0.13 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = true;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Flying);
}

function PlayWaiting()
{
	if ( AnimSequence!='Looking' && FRand()<0.25 )
		PlayAnim('Looking',0.8+FRand()*0.3,0.15);
	else if ( AnimSequence!='Scratching' && FRand()<0.15 )
		PlayAnim('Scratching',0.8+FRand()*0.4,0.15);
	else LoopAnim('Idle',0.7+FRand()*0.4,0.1);
}

function PlayPatrolStop()
{
	PlaySound(WingBeat, SLOT_Interact);
	LoopAnim('Fly', 1.1);
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	PlayAnim('Fly', 1.3, 0.1);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fly', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( AnimSequence=='Idle' || AnimSequence=='Scratching' || AnimSequence=='Looking' )
		TweenAnim('TakeOff',tweentime);
	else if ( (AnimSequence != 'Fly') || !bAnimLoop )
		TweenAnim('Fly', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( AnimSequence=='Idle' || AnimSequence=='Scratching' || AnimSequence=='Looking' )
		TweenAnim('TakeOff',tweentime);
	else if ( (AnimSequence != 'Fly') || !bAnimLoop )
		TweenAnim('Fly', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Idle', 0.6 + 0.8 * FRand(),0.25);
	if ( Physics==PHYS_Flying )
		SetPhysics(PHYS_Falling);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Fly', tweentime);
}

function PlayRunning()
{
	if ( AnimSequence=='TakeOff' )
	{
		SetPhysics(PHYS_Flying);
		PlayAnim('TakeOff',,0.f);
	}
	else
	{
		PlaySound(WingBeat, SLOT_Interact);
		LoopAnim('Fly', 1.2,, 0.4);
	}
}

function PlayWalking()
{
	if ( AnimSequence=='TakeOff' )
	{
		SetPhysics(PHYS_Flying);
		PlayAnim('TakeOff',,0.f);
	}
	else
	{
		PlaySound(WingBeat, SLOT_Interact);
		LoopAnim('Fly', 1.2,, 0.4);
	}
}

function PlayThreatening()
{
	PlaySound(WingBeat, SLOT_Interact);
	LoopAnim('Fly', 2.7);
}

function PlayTurning()
{
	PlaySound(WingBeat, SLOT_Interact);
	LoopAnim('Fly', 1.5,, 0.4);
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('DeathFall', 0.2, 0.7);
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Fly', 0.2);
}

function PlayInAir()
{
	if ( Enemy!=None && MoveTarget==Enemy )
		LoopAnim('PreAttack',,0.1);
	else LoopAnim('Fly');
}

function PlayLanded(float impactVel)
{
	TweenAnim('Idle',0.1);
}


function PlayVictoryDance()
{
	//PlayAnim('Whip', 0.6, 0.1);
	PlaySound(Threaten, SLOT_Talk);
}

function PlayRangedAttack()
{
	PlayMeleeAttack();
}
function PlayMeleeAttack()
{
	local vector adjust;

	if ( Target==None )
	{
		PlayRunning();
		return;
	}
	if ( Physics==PHYS_Walking )
		SetPhysics(PHYS_Flying);
	adjust = vect(0,0,0.8) * Target.CollisionHeight;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	MoveTarget = Target;
	MoveTimer = 1;
	Enable('Bump');
	bAttackBump = false;
	if ( AnimSequence!='PreAttack' )
		PlayAnim('PreAttack',,0.1);
	GoToState('MeleeAttack','ChargeInto');
}

state MeleeAttack
{
	ignores SeePlayer, HearNoise;

	singular function Bump(actor Other)
	{
		if ( Enemy!=none && Other==Enemy )
		{
			Disable('Bump');  ///enabled in PlayMeleeAttack
			MeleeDamageTarget(WhipDamage, (WhipDamage * 1000.0 * Normal(Enemy.Location - Location)));
			bAttackBump = true;
			Velocity*=-0.5;
			GotoState('TacticalMove', 'BackOff');
		}
	}
	function KeepAttacking()
	{
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self)
			GotoState('Attacking');
		else if (bAttackBump)
		{
			SetTimer(TimeBetweenAttacks, false);
			GotoState('TacticalMove', 'NoCharge');
		}
	}
ChargeInto:
	MoveToward(Enemy,3);
	if ( MeleeDamageTarget(WhipDamage, (WhipDamage * 1000.0 * Normal(Enemy.Location - Location))) )
	{
		Velocity*=-0.5;
		GotoState('TacticalMove', 'BackOff');
	}
	GoTo'DoneAttacking';
}

state Charging
{
	ignores SeePlayer, HearNoise;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else if ( (FRand() < 3 * Damage/Default.Health) && ((Damage > 0.5 * Health) || (VSize(Location - Enemy.Location) > 150)) )
			{
				bAvoidHit = true;
				NextState = 'TacticalMove';
				NextLabel = 'NoCharge';
			}
			else
			{
				NextState = 'Charging';
				NextLabel = 'TakeHit';
			}
			GotoState('TakeHit');
		}
	}
}

state TacticalMove
{
	function PickDestination(bool bNoCharge)
	{
		local vector pick, pickdir, enemydir,Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, MaxMove;

		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self)
		{
			GotoState('Attacking');
			return;
		}

		if ( bAvoidHit && (FRand() < 0.7) )
			MaxMove = 300;
		else
			MaxMove = 600;

		bAvoidHit = false;
		enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * FRand() - 1.0;

		if (enemyDist < CollisionRadius + Enemy.CollisionRadius + 2 * MeleeRange)
			Aggression = FMin(0.0, Aggression);
		else if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression = FMax(0.0, Aggression);

		enemydir = (Enemy.Location - Location)/enemyDist;
		minDist = FMin(160.0, 5*CollisionRadius);
		Y = (enemydir Cross vect(0,0,1));
		strafeSize = FMin(0.8, (2 * Abs(Aggression) * FRand() - 0.2));
		if (Aggression <= 0)
			strafeSize *= -1;
		enemydir = enemydir * strafeSize;
		if (FRand() < 0.8)
			enemydir.Z = 1.5;
		else
			enemydir.Z = FMax(0,enemydir.Z);

		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		pick = Location + (pickdir + enemydir) * (minDist + MaxMove * FRand());
		pick.Z = Location.Z + 60 + 0.65 * MaxMove * FRand();
		minDest = Location + minDist * Normal(pick - location);
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = CollisionHeight;

		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if ( HitActor == None )
		{
			Destination = pick;
			return;
		}
		pick = Location + (enemydir - pickdir) * (minDist + MaxMove * FRand());
		pick.Z = Location.Z + 60 + 0.5 * MaxMove * FRand();
		minDest = Location + minDist * Normal(pick - location);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if ( HitActor == None )
		{
			Destination = pick;
			return;
		}

		pick = Location - enemydir * (minDist + MaxMove * FRand());
		pick.Z = Location.Z + 0.5 * MaxMove * FRand();
		minDest = Location + Normal(pick - Location) * minDist;
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if ( HitActor == None )
		{
			Destination = pick;
			return;
		}

		if ( !bNoCharge && (enemyDist > 120) )
			GotoState('Charging');

		pick = MaxMove * FRand() * VRand();
		pick.Z = FMin(Location.Z, pick.Z);
		Destination = pick;
	}
	function Bump(Actor Other)
	{
		Disable('Bump');
		if (bAttackBump == true)
			bAttackBump = false;
		else if (Other == Enemy)
		{
			bReadyToAttack = true;
			Target = Enemy;
			GotoState('MeleeAttack');
		}
		else if (Enemy.Health <= 0)
			GotoState('Attacking');
	}
BackOff:
	if (Enemy == none)
		Acceleration = AccelRate * Normal(Focus);
	else
		Acceleration = AccelRate * Normal(Location - Enemy.Location);
	Acceleration.Z *= 0.5;
	Destination = Location;
	PlayThreatening();
	Sleep(1.25);
	SetTimer(TimeBetweenAttacks, false);
	Goto('TacticalTick');
}
function bool CanFireAtEnemy()
{
	if ( Enemy == none || enemy.health <= 0 || enemy.bdeleteme || Enemy == self )
		return false;
	return ActorReachable(Enemy);
}

defaultproperties
{
	DrawType=DT_Mesh
    Mesh=Lodmesh'HawkM'
	Acquire=Sound'Hcall3'
	Roam=Sound'Hcall1'
	Threaten=Sound'Hcall2'
	Hitsound1=Sound'Hhit1'
	Hitsound2=Sound'Hhit1'
	wingBeat=Sound'Hflap1'
	Die=Sound'Hdeath1'
	AnimSequence="Idle"
	RotationRate=(Yaw=45000,Pitch=16384)
	GroundSpeed=1
	AirSpeed=880
	AccelRate=850
	MenuName="Hawk"
	Health=95
	Mass=90
	Buoyancy=90
	UnderWaterTime=10
	bCanStrafe=false
	MeleeRange=50
	bHasRangedAttack=true
	CombatStyle=10
	WhipDamage=17
	CollisionHeight=17
	CarcassType=Class'HawkCarcass'
	HeadOffset=(X=26,Z=9)
	HeadRadius=12
}
