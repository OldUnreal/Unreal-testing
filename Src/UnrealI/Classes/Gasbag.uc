//=============================================================================
// Gasbag.
//=============================================================================
class Gasbag extends ScriptedPawn;

#exec MESH IMPORT MESH=GasBagM ANIVFILE=Models\GAS_A.3d DATAFILE=Models\DATA28.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GasBagM X=00 Y=150 Z=-100 YAW=64

#exec MESH SEQUENCE MESH=GasBagM SEQ=All      STARTFRAME=0   NUMFRAMES=133
#exec MESH SEQUENCE MESH=GasBagM SEQ=TwoPunch STARTFRAME=0   NUMFRAMES=13	RATE=15 Group=Attack
#exec MESH SEQUENCE MESH=GasBagM SEQ=Belch    STARTFRAME=13  NUMFRAMES=15	RATE=15	Group=MovingAttack
#exec MESH SEQUENCE MESH=GasBagM SEQ=ThreatBelch STARTFRAME=13 NUMFRAMES=15  RATE=15
#exec MESH SEQUENCE MESH=GasBagM SEQ=Deflate  STARTFRAME=28  NUMFRAMES=16	RATE=15
#exec MESH SEQUENCE MESH=GasBagM SEQ=TakeHit  STARTFRAME=28  NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasBagM SEQ=Fiddle   STARTFRAME=44  NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=GasBagM SEQ=Float    STARTFRAME=59  NUMFRAMES=6		RATE=6
#exec MESH SEQUENCE MESH=GasBagM SEQ=Grab     STARTFRAME=65  NUMFRAMES=20	RATE=15
#exec MESH SEQUENCE MESH=GasBagM SEQ=Pound    STARTFRAME=85 NUMFRAMES=13	RATE=15 Group=Attack
#exec MESH SEQUENCE MESH=GasBagM SEQ=T1       STARTFRAME=98 NUMFRAMES=5
#exec MESH SEQUENCE MESH=GasBagM SEQ=T2       STARTFRAME=103 NUMFRAMES=9
#exec MESH SEQUENCE MESH=GasBagM SEQ=T3       STARTFRAME=112 NUMFRAMES=4
#exec MESH SEQUENCE MESH=GasBagM SEQ=T4       STARTFRAME=116 NUMFRAMES=4
#exec MESH SEQUENCE MESH=GasBagM SEQ=Dead2    STARTFRAME=120 NUMFRAMES=13	RATE=15
#exec MESH SEQUENCE MESH=GasBagM SEQ=Fighter  STARTFRAME=65  NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasBagM SEQ=Hit2     STARTFRAME=120 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=GasBag2 FILE=Models\gasbod.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=GasBag1 FILE=Models\gasarm.pcx GROUP="Skins"

#exec MESHMAP SCALE MESHMAP=GasBagM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=GasBagM NUM=5 TEXTURE=GasBag1
#exec MESHMAP SETTEXTURE MESHMAP=GasBagM NUM=6 TEXTURE=GasBag2

#exec MESH NOTIFY MESH=GasBagM SEQ=Belch TIME=0.5 FUNCTION=SpawnBelch
#exec MESH NOTIFY MESH=GasBagM SEQ=TwoPunch TIME=0.35 FUNCTION=PunchDamageTarget
#exec MESH NOTIFY MESH=GasBagM SEQ=TwoPunch TIME=0.7 FUNCTION=PunchDamageTarget
#exec MESH NOTIFY MESH=GasBagM SEQ=Pound TIME=0.33 FUNCTION=PoundDamageTarget
#exec MESH NOTIFY MESH=GasBagM SEQ=Deflate TIME=0.80 FUNCTION=LandThump

#exec AUDIO IMPORT FILE="Sounds\Gassius\2punch1a.wav" NAME="twopunch1g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\injur1a.wav" NAME="injur1g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\injur2a.wav" NAME="injur2g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\yell2a.wav" NAME="yell2g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\yell3a.wav" NAME="yell3g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\nearby1.wav" NAME="nearby1g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\death1a.wav" NAME="death1g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\hit1a.wav" NAME="hit1g" GROUP="Gasbag"
#exec AUDIO IMPORT FILE="Sounds\Gassius\amb2gb.wav" NAME="amb2g" GROUP="Gasbag"

//-----------------------------------------------------------------------------
// Gasbag variables.

// Attack damage.
var() byte
PunchDamage,	// Basic damage done by each punch.
PoundDamage;	// Basic damage done by pound.

var(Sounds)	sound Punch;
var(Sounds) sound Pound;
var(Sounds) sound PunchHit;
var GasBag ParentBag;
var int numChildren;

//-----------------------------------------------------------------------------
// Gasbag functions.

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if (BonusSkill > 0.f && !ReducedDamageType)
	{
		// Make gasbags more immune to each others fireballs.
		ReducedDamageType = 'burned';
		ReducedDamagePct = BonusSkill*0.3f;
	}
}

simulated function bool IsHeadshot( vector HitLocation, vector TraceDir )
{
	if( !Class'SinglePlayer'.Default.bUseExactHSDetection || HeadRadius<=0 )
		return (!bIsBoss && Super(Pawn).IsHeadShot(HitLocation,TraceDir));
	if( (vector(Rotation) Dot TraceDir)<0.2 ) // Head is being covered by the body.
		return CheckWithHeadRegion(HitLocation,TraceDir);
	return false;
}

function Destroyed()
{
	if ( ParentBag != None )
		ParentBag.numChildren--;
	Super.Destroyed();
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	bCanDuck = true;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;

	//log("duck");
	duckDir.Z = 0;
	if ( (Skill == 0) && Rand(2) )
		DuckDir *= -1;

	Extent = GetExtent();
	HitActor = Trace(HitLocation, HitNormal, Location + 100 * duckDir, Location, false, Extent);
	if( HitActor )
	{
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 100 * duckDir, Location, false, Extent);
	}
	if( HitActor )
		return;

	//log("good duck");
	Destination = Location + 150 * duckDir;
	Velocity = 400 * duckDir;
	AirSpeed *= 2.5;
	GotoState('TacticalMove', 'DoMove');
}

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying);
}

singular function Falling()
{
	SetPhysics(PHYS_Flying);
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;
	animspeed = 0.3 + 0.5 * FRand();

	decision = FRand();
	if (!bool(NextAnim)) //pick first waiting animation
		NextAnim = 'Float';

	LoopAnim(NextAnim, animspeed);
	////log("Next brute waiting anim is "$nextanim);
	if (NextAnim == 'Float')
	{
		if (decision < 0.15)
			NextAnim = 'Fiddle';
	}
	else if (NextAnim == 'Fiddle')
	{
		if (decision < 0.5)
			NextAnim = 'Float';
		else if (decision < 0.65)
			NextAnim = 'Grab';
	}
	else
		NextAnim = 'Float';
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence == 'Belch') && IsAnimating() )
		return;
	if ( (AnimSequence != 'Float') || !bAnimLoop )
		TweenAnim('Float', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( (AnimSequence != 'Float') || !bAnimLoop )
		TweenAnim('Float', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Float', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Float', tweentime);
}

function PlayRunning()
{
	if ( AnimSequence == 'Belch' )
		LoopAnim('Float', -1.0/AirSpeed, 0.5, 0.4);
	else
		LoopAnim('Float', -1.0/AirSpeed,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Float', -1.0/AirSpeed,, 0.4);
}


function PlayThreatening()
{
	local float decision;

	decision = FRand();

	if ( decision < 0.7 )
		PlayAnim('Float', 0.4, 0.4);
	else if ( decision < 0.8 )
		PlayAnim('ThreatBelch', 0.4, 0.25);
	else
	{
		PlayThreateningSound();
		TweenAnim('Fighter', 0.3);
	}
}

function PlayTurning()
{
	LoopAnim('Float');
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	if ( FRand() < 0.5 )
		PlayAnim('Deflate', 0.7, 0.1);
	else
		PlayAnim('Dead2', 0.7, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	if ( FRand() < 0.6 )
		TweenAnim('TakeHit', tweentime);
	else
		TweenAnim('Hit2', 1.5 * tweentime);
}

function TweenToFalling()
{
	TweenAnim('Float', 0.2);
}

function PlayInAir()
{
	LoopAnim('Float');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Float');
}


function PlayVictoryDance()
{
	PlayAnim('Pound', 0.6, 0.1);
	PlaySound(PunchHit, SLOT_Interact);
}

function PlayMeleeAttack()
{
	local vector adjust;

	if ( Target == None )
	{
		PlayRunning();
		return;
	}
	adjust.Z = Target.CollisionHeight;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	if (FRand() < 0.5)
	{
		PlaySound(Punch, SLOT_Interact);
		PlayAnim('TwoPunch');
	}
	else
	{
		PlaySound(Pound, SLOT_Interact);
		PlayAnim('Pound');
	}
}

function PlayRangedAttack()
{
	local vector adjust;

	if ( Target == None )
	{
		PlayThreatening();
		return;
	}
	adjust.Z = Target.CollisionHeight + 20;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	PlayAnim('Belch');
}

function SpawnBelch()
{
	spawn(RangedProjectile,,,,AdjustAim(ProjectileSpeed, Location, 400, bLeadTarget, bWarnTarget));
}

function PunchDamageTarget()
{
	if (Target==none)
		return;
	if (MeleeDamageTarget(PunchDamage, (PunchDamage * 1300 * Normal(Target.Location - Location))))
		PlaySound(PunchHit, SLOT_Interact);
}

function PoundDamageTarget()
{
	if (Target==none)
		return;
	if (MeleeDamageTarget(PoundDamage, (PoundDamage * 800 * Normal(Target.Location - Location))))
		PlaySound(PunchHit, SLOT_Interact);
}

function PlayMovingAttack()
{
	if ( AnimSequence == 'Float' )
		PlayAnim('Belch', 1.0, 0.2);
	else
		PlayAnim('Belch');
}

State TacticalMove
{
	ignores SeePlayer, HearNoise;

	function EndState()
	{
		AirSpeed = Default.AirSpeed;
		Super.EndState();
	}
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other.IsA('GasBag'))
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
} 

defaultproperties
{
	PunchDamage=12
	PoundDamage=25
	Punch=Sound'UnrealI.Gasbag.twopunch1g'
	Pound=Sound'UnrealI.Gasbag.twopunch1g'
	PunchHit=Sound'UnrealI.Gasbag.hit1g'
	CarcassType=Class'UnrealI.GassiusCarcass'
	Aggressiveness=0.700000
	RefireRate=0.500000
	bHasRangedAttack=True
	bMovingRangedAttack=True
	RangedProjectile=Class'UnrealI.GasBagBelch'
	ProjectileSpeed=600.000000
	Acquire=Sound'UnrealI.Gasbag.yell2g'
	Fear=Sound'UnrealI.Gasbag.injur2g'
	Roam=Sound'UnrealI.Gasbag.nearby1g'
	Threaten=Sound'UnrealI.Gasbag.yell3g'
	bCanStrafe=True
	MeleeRange=50.000000
	AirSpeed=200.000000
	JumpZ=10.000000
	SightRadius=2000.000000
	FovAngle=120.000000
	Health=200
	HitSound1=Sound'UnrealI.Gasbag.injur1g'
	HitSound2=Sound'UnrealI.Gasbag.injur2g'
	Die=Sound'UnrealI.Gasbag.death1g'
	CombatStyle=0.400000
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.GasBagM'
	AmbientSound=Sound'UnrealI.Gasbag.amb2g'
	CollisionRadius=56.000000
	CollisionHeight=36.000000
	Mass=120.000000
	RotationRate=(Pitch=8192,Yaw=65000,Roll=2048)
	HeadOffset=(X=2,Z=16)
	HeadRadius=14
}
