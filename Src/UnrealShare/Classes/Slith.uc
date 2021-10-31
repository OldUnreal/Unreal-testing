//=============================================================================
// Slith.
//=============================================================================
class Slith extends ScriptedPawn;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Slith1 ANIVFILE=Models\slith_a.3d DATAFILE=Models\slith_d.3d ZEROTEX=1 LODSTYLE=2
#exec MESH ORIGIN MESH=Slith1 X=0 Y=60 Z=50 YAW=64 ROLL=-64

#exec MESH SEQUENCE MESH=slith1 SEQ=All       STARTFRAME=0   NUMFRAMES=230
#exec MESH SEQUENCE MESH=slith1 SEQ=BREATH    STARTFRAME=0   NUMFRAMES=6	RATE=6
#exec MESH SEQUENCE MESH=slith1 SEQ=CHARGEUP  STARTFRAME=6   NUMFRAMES=13	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=WFighter  STARTFRAME=19  NUMFRAMES=1
#exec MESH SEQUENCE MESH=slith1 SEQ=CLAW1     STARTFRAME=19  NUMFRAMES=11			Group=Attack
#exec MESH SEQUENCE MESH=slith1 SEQ=CLAW2     STARTFRAME=30  NUMFRAMES=11			Group=Attack
#exec MESH SEQUENCE MESH=slith1 SEQ=DEAD1     STARTFRAME=41  NUMFRAMES=13	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=DEAD2     STARTFRAME=54  NUMFRAMES=21	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=LTakeHit  STARTFRAME=41  NUMFRAMES=1
#exec MESH SEQUENCE MESH=slith1 SEQ=WTakeHit  STARTFRAME=54  NUMFRAMES=1
#exec MESH SEQUENCE MESH=slith1 SEQ=DIVE      STARTFRAME=75  NUMFRAMES=16	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=Falling   STARTFRAME=83  NUMFRAMES=1
#exec MESH SEQUENCE MESH=slith1 SEQ=LFighter  STARTFRAME=91  NUMFRAMES=1
#exec MESH SEQUENCE MESH=slith1 SEQ=PUNCH     STARTFRAME=91  NUMFRAMES=15	RATE=15 Group=Attack
#exec MESH SEQUENCE MESH=slith1 SEQ=SCRATCH   STARTFRAME=106 NUMFRAMES=20	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=SHOOT1    STARTFRAME=126 NUMFRAMES=13	RATE=15 Group=MovingAttack
#exec MESH SEQUENCE MESH=slith1 SEQ=SHOOT2    STARTFRAME=139 NUMFRAMES=13	RATE=15 Group=MovingAttack
#exec MESH SEQUENCE MESH=slith1 SEQ=SLASH     STARTFRAME=152 NUMFRAMES=15	RATE=15 Group=Attack
#exec MESH SEQUENCE MESH=slith1 SEQ=SLICK     STARTFRAME=167 NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=SLITHER   STARTFRAME=182 NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=SURFACE   STARTFRAME=197 NUMFRAMES=18	RATE=15
#exec MESH SEQUENCE MESH=slith1 SEQ=SWIM      STARTFRAME=215 NUMFRAMES=15	RATE=15

#exec TEXTURE IMPORT NAME=JSlith1 FILE=Models\slith.pcx GROUP=Skins DETAIL=Pock
#exec MESHMAP SCALE MESHMAP=slith1 X=0.12 Y=0.12 Z=0.24
#exec MESHMAP SETTEXTURE MESHMAP=slith1 NUM=0 TEXTURE=Jslith1

#exec MESH NOTIFY MESH=slith1 SEQ=Claw1 TIME=0.81 FUNCTION=ClawDamageTarget
#exec MESH NOTIFY MESH=slith1 SEQ=Claw2 TIME=0.81 FUNCTION=ClawDamageTarget
#exec MESH NOTIFY MESH=slith1 SEQ=Punch TIME=0.5 FUNCTION=ClawDamageTarget
#exec MESH NOTIFY MESH=slith1 SEQ=Slash TIME=0.5 FUNCTION=ClawDamageTarget
#exec MESH NOTIFY MESH=slith1 SEQ=Shoot1 TIME=0.3 FUNCTION=ShootTarget
#exec MESH NOTIFY MESH=slith1 SEQ=Shoot2 TIME=0.3 FUNCTION=ShootTarget
#exec MESH NOTIFY MESH=slith1 SEQ=Dead1 TIME=0.61 FUNCTION=LandThump

#exec AUDIO IMPORT FILE="Sounds\Slith\amb1sl.wav" NAME="amb1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\injur1sl.wav" NAME="injur1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\injur2sl.wav" NAME="injur2sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\yell1sl.wav" NAME="yell1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\yell2sl.wav" NAME="yell2sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\yell3sl.wav" NAME="yell3sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\yell4sl.wav" NAME="yell4sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\roam1sl.wav" NAME="roam1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\dieL1sl.wav" NAME="deathLsl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\dieW1sl.wav" NAME="deathWsl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\surf1sl.wav" NAME="surf1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\dive2a.wav" NAME="dive2sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\swim1sl.wav" NAME="swim1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\scratch1sl.wav" NAME="scratch1sl" GROUP="Slith"
#exec AUDIO IMPORT FILE="Sounds\Slith\slithr1sl.wav" NAME="slithr1sl" GROUP="Slith"

//-----------------------------------------------------------------------------
// Slith variables.

// Attack damage.
var() byte ClawDamage;	// Basic damage done by Claw/punch.
var bool bFirstAttack;

var(Sounds) sound die2;
var(Sounds) sound slick;
var(Sounds) sound slash;
var(Sounds) sound slice;
var(Sounds) sound slither;
var(Sounds) sound swim;
var(Sounds) sound dive;
var(Sounds) sound surface;
var(Sounds) sound scratch;
var(Sounds) sound charge;

var(HeadRegion) vector SwimmingHeadOffset;

//-----------------------------------------------------------------------------
// Slith functions.

simulated function bool IsHeadshot( vector HitLocation, vector TraceDir )
{
	if( !Class'SinglePlayer'.Default.bUseExactHSDetection || HeadRadius<=0 )
		return (!bIsBoss && Super(Pawn).IsHeadShot(HitLocation,TraceDir));
	if( AnimSequence=='Swim' || AnimSequence=='CLAW1' || AnimSequence=='CLAW2' )
		HeadOffset = SwimmingHeadOffset;
	else HeadOffset = Default.HeadOffset;
	return CheckWithHeadRegion(HitLocation,TraceDir);
}

/* PreSetMovement()
default for walking creature.  Re-implement in subclass
for swimming/flying capability
*/

function PreSetMovement()
{
	MaxDesiredSpeed = 0.79 + 0.07 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Slith') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Nali') )
		return ATTITUDE_Hate;
	else
		return ATTITUDE_Ignore;
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone && (Physics != PHYS_Swimming) )
		SetPhysics(PHYS_Swimming);
	else if (Physics != PHYS_Walking)
		SetPhysics(PHYS_Walking);
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = 460; //set here so physics uses this for remainder of tick
	PlayOutOfWater();
	bUpAndOut = true;
}

function SetFall()
{
	if (Enemy != None)
	{
		NextState = 'Attacking'; //default
		NextLabel = 'Begin';
		NextAnim = 'LFighter';
		GotoState('FallingState');
	}
}

function PlayAcquisitionSound()
{
	if ( FRand() < 0.5 )
		PlaySound(Acquire, SLOT_Talk);
	else
		PlaySound(sound'yell3sl', SLOT_Talk);
}

function PlayWaiting()
{
	local float decision;

	if (Region.Zone.bWaterZone)
	{
		LoopAnim('Swim', 0.2  + 0.3 * FRand());
		return;
	}

	decision = FRand();

	if (decision < 0.8)
		LoopAnim('Breath', 0.2 + 0.6 * FRand());
	else if (decision < 0.9)
	{
		PlaySound(Slick, SLOT_Interact);
		LoopAnim('Slick', 0.4 + 0.6 * FRand());
	}
	else
	{
		PlaySound(Scratch, SLOT_Interact);
		LoopAnim('Scratch', 0.4 + 0.6 * FRand());
	}
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	TweenToFighter(0.1);
}

function TweenToFighter(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('WFighter', tweentime);
	else
		TweenAnim('LFighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if ( (AnimSequence == 'Shoot2') && IsAnimating() )
			return;
		if ( (AnimSequence != 'Swim') || !bAnimLoop )
			TweenAnim('Swim', tweentime);
	}
	else
	{
		if ( (AnimSequence == 'Shoot1') && IsAnimating() )
			return;
		if ( (AnimSequence != 'Slither') || !bAnimLoop )
			TweenAnim('Slither', tweentime);
	}
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if ( (AnimSequence != 'Swim') || !bAnimLoop )
			TweenAnim('Swim', tweentime);
	}
	else
	{
		if ( (AnimSequence != 'Slither') || !bAnimLoop )
			TweenAnim('Slither', tweentime);
	}
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('Swim', tweentime);
	else
		TweenAnim('Breath', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenToWaiting(tweentime);
}

function PlayRunning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Swim, SLOT_Interact);
		LoopAnim('Swim', -1.0/WaterSpeed,, 0.4);
	}
	else
	{
		PlaySound(Slither, SLOT_Interact);
		LoopAnim('Slither', -1.1/GroundSpeed,, 0.4);
	}
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Swim, SLOT_Interact);
		LoopAnim('Swim', -1.0/WaterSpeed,, 0.4);
	}
	else
	{
		PlaySound(Slither, SLOT_Interact);
		LoopAnim('Slither', -1.3/GroundSpeed,, 0.4);
	}
}

function PlayThreatening()
{
	local float decision;
	decision = FRand();

	if (decision < 0.8)
	{
		PlayWaiting();
		return;
	}
	NextAnim = '';

	if (Region.Zone.bWaterZone)
		TweenAnim('WFighter', 0.25);
	else
		TweenAnim('LFighter', 0.25);
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
		TweenAnim('Swim', 0.35);
	else
		TweenAnim('Slither', 0.35);
}

function PlayDying(name DamageType, vector HitLocation)
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Die2, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead2', 0.7, 0.1);
	}
	else
	{
		PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead1', 0.7, 0.1);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('WTakeHit', tweentime);
	else
		TweenAnim('LTakeHit', tweentime);
}

function PlayOutOfWater()
{
	PlayAnim('Surface',,0.1);
}

function PlayDive()
{
	PlayAnim('Dive',,0.1);
}

function TweenToFalling()
{
	TweenAnim('Falling', 0.4);
}

function PlayInAir()
{
	TweenAnim('Falling', 0.4);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Slither', 0.25);
}


function PlayVictoryDance()
{
	PlayAnim('ChargeUp', 0.3, 0.1);
	PlaySound(Charge, SLOT_Interact);
}

function ClawDamageTarget()
{
	if ( Target == None )
		return;
	MeleeDamageTarget(ClawDamage, (ClawDamage * 1000.0 * Normal(Target.Location - Location)));
}

function PlayMeleeAttack()
{
	local float decision;

	if (Target == none)
	{
		PlayChallenge();
		return;
	}
	decision = FRand();
	Acceleration = AccelRate * Normal(Target.Location - Location);
	//log("Start Melee Attack");
	if ( Region.Zone.bWaterZone )
	{
		if (AnimSequence == 'Claw1')
			decision += 0.17;
		else if (AnimSequence == 'Claw2')
			decision -= 0.17;

		if (decision < 0.5)
			PlayAnim('Claw1');
		else
			PlayAnim('Claw2');
	}
	else
	{
		if (AnimSequence == 'Punch')
			decision += 0.17;
		else if (AnimSequence == 'Slash')
			decision -= 0.17;
		if (decision < 0.5)
		{
			PlayAnim('Punch');
		}
		else
		{
			PlayAnim('Slash');
		}
	}
}


function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, projStart;
	local actor HitActor;
	local float EnemyDist;

	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		return false;
	EnemyDir = Enemy.Location - Location + Enemy.CollisionHeight * vect(0,0,0.8);
	EnemyDist = VSize(EnemyDir);
	if (EnemyDist > 750) //FIXME - what is right number?
		return false;

	EnemyDir = EnemyDir/EnemyDist;
	projStart = Location + 0.8 * CollisionRadius * EnemyDir + 0.8 * CollisionHeight * vect(0,0,1);
	HitActor = Trace(HitLocation, HitNormal,
					 projStart + (MeleeRange + Enemy.CollisionRadius) * EnemyDir,
					 projStart, false, vect(6,6,4) );

	return (HitActor == None);
}

function ShootTarget()
{
	FireProjectile( vect(1, 0, 0.8), 900);
}

function PlayRangedAttack()
{
	if (Region.Zone.bWaterZone)
		PlayAnim('Shoot2');
	else
		PlayAnim('Shoot1');
}

function PlayMovingAttack()
{
	PlayRangedAttack();
}

state MeleeAttack
{
	ignores SeePlayer, HearNoise, Bump;

	function PlayMeleeAttack()
	{
		if ( Region.Zone.bWaterZone && !bFirstAttack && (FRand() > 0.4 + 0.17 * skill) )
		{
			PlayAnim('Swim');
			Acceleration = AccelRate * Normal(Location - Enemy.Location + 0.9 * VRand());
		}
		else
			Global.PlayMeleeAttack();
		bFirstAttack = false;
	}

	function BeginState()
	{
		Super.BeginState();
		bCanStrafe = True;
		bFirstAttack = True;
	}

	function EndState()
	{
		Super.EndState();
		bCanStrafe = false;
	}
}

defaultproperties
{
	ClawDamage=25
	Die2=Sound'UnrealShare.Slith.deathWsl'
	SLASH=Sound'UnrealShare.Slith.yell4sl'
	SLITHER=Sound'UnrealShare.Slith.slithr1sl'
	Swim=Sound'UnrealShare.Slith.swim1sl'
	DIVE=Sound'UnrealShare.Slith.dive2sl'
	Surface=Sound'UnrealShare.Slith.surf1sl'
	SCRATCH=Sound'UnrealShare.Slith.scratch1sl'
	CarcassType=Class'UnrealShare.SlithCarcass'
	TimeBetweenAttacks=1.200000
	Aggressiveness=0.700000
	RefireRate=0.400000
	WalkingSpeed=0.300000
	bHasRangedAttack=True
	bMovingRangedAttack=True
	RangedProjectile=Class'UnrealShare.SlithProjectile'
	ProjectileSpeed=750.000000
	Acquire=Sound'UnrealShare.Slith.yell1sl'
	Fear=Sound'UnrealShare.Slith.yell3sl'
	Roam=Sound'UnrealShare.Slith.roam1sl'
	Threaten=Sound'UnrealShare.Slith.yell2sl'
	MeleeRange=50.000000
	GroundSpeed=250.000000
	WaterSpeed=280.000000
	AccelRate=850.000000
	JumpZ=120.000000
	Visibility=150
	SightRadius=2000.000000
	Health=210
	ReducedDamageType=Corroded
	ReducedDamagePct=1.000000
	UnderWaterTime=-1.000000
	HitSound1=Sound'UnrealShare.Slith.injur1sl'
	HitSound2=Sound'UnrealShare.Slith.injur2sl'
	Die=Sound'UnrealShare.Slith.deathLsl'
	CombatStyle=0.850000
	DrawType=DT_Mesh
	Style=STY_Masked
	Mesh=LodMesh'UnrealShare.Slith1'
	AmbientSound=Sound'UnrealShare.Slith.amb1sl'
	CollisionRadius=48.000000
	CollisionHeight=44.000000
	Mass=200.000000
	Buoyancy=200.000000
	RotationRate=(Pitch=3072,Yaw=40000,Roll=6000)
	AnimSequence=LFighter
	HeadOffset=(X=17,Z=35)
	HeadRadius=14
	SwimmingHeadOffset=(X=40,Z=-13)
}
