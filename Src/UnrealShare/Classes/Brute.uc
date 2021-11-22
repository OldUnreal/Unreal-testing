//=============================================================================
// Brute.
//=============================================================================
class Brute extends ScriptedPawn;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Brute1 ANIVFILE=Models\Brute_a.3d DATAFILE=Models\Brute_d.3d
#exec MESH ORIGIN MESH=Brute1 X=-20 Y=-160 Z=-215 YAW=64 ROLL=-64

#exec MESH SEQUENCE MESH=Brute1 SEQ=All          STARTFRAME=0   NUMFRAMES=309
#exec MESH SEQUENCE MESH=Brute1 SEQ=GutHit       STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Brute1 SEQ=Breath2      STARTFRAME=1   NUMFRAMES=8  RATE=6
#exec MESH SEQUENCE MESH=Brute1 SEQ=Charge       STARTFRAME=9   NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=CockGun      STARTFRAME=19  NUMFRAMES=18 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Dead1        STARTFRAME=37  NUMFRAMES=13 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Dead2        STARTFRAME=50  NUMFRAMES=15 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Dead3        STARTFRAME=65  NUMFRAMES=11 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Dead4        STARTFRAME=76  NUMFRAMES=23 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Fighter      STARTFRAME=99  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Brute1 SEQ=Gutshot      STARTFRAME=100 NUMFRAMES=34		 Group=Attack
#exec MESH SEQUENCE MESH=Brute1 SEQ=HeadHit      STARTFRAME=134 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Brute1 SEQ=Hit          STARTFRAME=135 NUMFRAMES=5  RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=LeftHit      STARTFRAME=140 NUMFRAMES=1
#exec mesh SEQUENCE MESH=Brute1 SEQ=StillLook    STARTFRAME=141 NUMFRAMES=23 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Precharg     STARTFRAME=164 NUMFRAMES=15 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=PistolWhip   STARTFRAME=179 NUMFRAMES=10 RATE=15 Group=Attack
#exec MESH SEQUENCE MESH=Brute1 SEQ=Punch        STARTFRAME=189 NUMFRAMES=13 RATE=15 Group=Attack
#exec MESH SEQUENCE MESH=Brute1 SEQ=StillFire    STARTFRAME=202 NUMFRAMES=20         Group=Attack
#exec MESH SEQUENCE MESH=Brute1 SEQ=RightHit     STARTFRAME=222 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Brute1 SEQ=Sleep        STARTFRAME=223 NUMFRAMES=6  RATE=6
#exec MESH SEQUENCE MESH=Brute1 SEQ=T8           STARTFRAME=229 NUMFRAMES=12 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=Walk         STARTFRAME=242 NUMFRAMES=23 RATE=15
#exec MESH SEQUENCE MESH=Brute1 SEQ=WalkFire     STARTFRAME=265 NUMFRAMES=44		 Group=MovingAttack

#exec TEXTURE IMPORT NAME=jBrute1 FILE=Models\Brute2C.pcx GROUP=Skins DETAIL=Pock
#exec TEXTURE IMPORT NAME=Brute3 FILE=Models\Brute3.pcx GROUP="Skins" DETAIL=Pock

#exec OBJ LOAD FILE=Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=Brute1 X=0.125 Y=0.125 Z=0.25
#exec MESHMAP SETTEXTURE MESHMAP=Brute1 NUM=0 TEXTURE=jBrute1
#exec MESHMAP SETTEXTURE MESHMAP=Brute1 NUM=1 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec MESH NOTIFY MESH=Brute1 SEQ=WalkFire TIME=0.18 FUNCTION=SpawnRightShot
#exec MESH NOTIFY MESH=Brute1 SEQ=WalkFire TIME=0.68 FUNCTION=SpawnLeftShot
#exec MESH NOTIFY MESH=Brute1 SEQ=StillFire TIME=0.5 FUNCTION=SpawnLeftShot
#exec MESH NOTIFY MESH=Brute1 SEQ=PistolWhip TIME=0.5 FUNCTION=WhipDamageTarget
#exec MESH NOTIFY MESH=Brute1 SEQ=Punch TIME=0.55 FUNCTION=WhipDamageTarget
#exec MESH NOTIFY MESH=Brute1 SEQ=GutShot TIME=0.3 FUNCTION=GutShotTarget
#exec MESH NOTIFY MESH=Brute1 SEQ=GutShot TIME=0.6 FUNCTION=GutShotTarget
#exec MESH NOTIFY MESH=Brute1 SEQ=Walk TIME=0.31 FUNCTION=Step
#exec MESH NOTIFY MESH=Brute1 SEQ=Walk TIME=0.8 FUNCTION=Step
#exec MESH NOTIFY MESH=Brute1 SEQ=Dead1 TIME=0.56 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Brute1 SEQ=Dead2 TIME=0.5 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Brute1 SEQ=Dead3 TIME=0.52 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Brute1 SEQ=Dead4 TIME=0.71 FUNCTION=LandThump
#exec MESH NOTIFY MESH=Brute1 SEQ=Charge TIME=0.25 FUNCTION=Step
#exec MESH NOTIFY MESH=Brute1 SEQ=Charge TIME=0.75 FUNCTION=Step

#exec AUDIO IMPORT FILE="Sounds\Brute\Walk1a.wav" NAME="walk1br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Pwhip1a.wav" NAME="pwhip1br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Injur1a.wav" NAME="injur1br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Injur2a.wav" NAME="injur2br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Yell1a.wav" NAME="yell1br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Yell2a.wav" NAME="yell2br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Nearby2a.wav" NAME="nearby2br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Death1a.wav" NAME="death1br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Death2br.wav" NAME="death2br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Walk1b.wav" NAME="walk2br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Pstlhit1.wav" NAME="pstlhit1br" GROUP="Brute"
#exec AUDIO IMPORT FILE="Sounds\Brute\Amb1br.wav" NAME="amb1br" GROUP="Brute"

//-----------------------------------------------------------------------------
// Brute variables.

// Attack damage.
var() byte WhipDamage;		// Basic damage done by pistol-whip.
var bool   bBerserk;
var bool   bLongBerserk;
var() bool bTurret;			// Doesn't move while attacking

// Sounds
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;
var(Sounds) sound PistolWhip;
var(Sounds) sound GutShot;
var(Sounds) sound PistolHit;
var(Sounds) sound Die2;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Skill > 1)
		bLeadTarget = true;
	if ( Skill == 0 )
		ProjectileSpeed *= 0.85;
	else if ( Skill > 2 )
		ProjectileSpeed *= 1.1;
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Brute') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Nali') )
		return ATTITUDE_Hate;
	else
		return ATTITUDE_Ignore;
}

function GoBerserk()
{
	bLongBerserk = false;
	if ( (bBerserk || ((Health < 0.75 * Default.Health) && (FRand() < 0.65)))
			&& (VSize(Location - Enemy.Location) < 500) )
		bBerserk = true;
	else
		bBerserk = false;
	if ( bBerserk )
	{
		AccelRate = 4 * AccelRate;
		GroundSpeed = 2.5 * Default.GroundSpeed;
	}
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;

	bReadyToAttack = true;
	animspeed = 0.3 + 0.5 * FRand(); //fixme - add to all creatures

	decision = FRand();
	if ( AnimSequence == 'Sleep' )
	{
		if ( decision < 0.07 )
		{
			SetAlertness(0.0);
			PlayAnim('Breath2',animspeed, 0.4);
			return;
		}
		else
		{
			SetAlertness(-0.3);
			PlayAnim('Sleep', 0.3 + 0.3 * FRand());
			return;
		}
	}
	else if ( AnimSequence == 'Breath2' )
	{
		if ( decision < 0.2 )
		{
			SetAlertness(-0.3);
			PlayAnim('Sleep',animspeed,0.4);
			return;
		}
		else if ( decision < 0.37 )
			PlayAnim('StillLook', animspeed);
		else if ( decision < 0.55 )
			PlayAnim('CockGun', animspeed);
		else
			PlayAnim('Breath2', 0.3 + 0.3 * FRand(), 0.4);
	}
	else if ( decision < 0.1 )
		PlayAnim('StillLook', animspeed, 0.4);
	else
		PlayAnim('Breath2', 0.3 + 0.3 * FRand(), 0.4);

	if ( AnimSequence == 'StillLook' )
	{
		SetAlertness(0.7);
		if ( !bQuiet && (FRand() < 0.7) )
			PlayRoamingSound();
	}
	else
		SetAlertness(0.0);
}

function PlayThreatening()
{
	local float decision;

	decision = FRand();

	if ( decision < 0.7 )
		PlayAnim('Breath2', 0.4, 0.3);
	else if ( decision < 0.8 )
		LoopAnim('PreCharg', 0.4, 0.25);
	else
	{
		PlayThreateningSound();
		TweenAnim('Fighter', 0.3);
	}
}

function PlayPatrolStop()
{
	local float decision;
	local float animspeed;
	animspeed = 0.5 + 0.4 * FRand(); //fixme - add to all creatures

	decision = FRand();
	if ( AnimSequence == 'Breath2' )
	{
		if ( decision < 0.4 )
			PlayAnim('StillLook', animspeed);
		else if (decision < 0.6 )
			PlayAnim('CockGun', animspeed);
		else
			PlayAnim('Breath2', animspeed);
	}
	else if ( decision < 0.2 )
		PlayAnim('StillLook', animspeed);
	else
		PlayAnim('Breath2', animspeed);

	if ( AnimSequence == 'StillLook' )
	{
		SetAlertness(0.7);
		if ( !bQuiet && (FRand() < 0.7) )
			PlayRoamingSound();
	}
	else
		SetAlertness(0.0);
}

function PlayWaitingAmbush()
{
	bQuiet = true;
	PlayPatrolStop();
}

function PlayChallenge()
{
	PlayAnim('PreCharg', 0.7, 0.2);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( bBerserk )
		TweenAnim('Charge', tweentime);
	if ( IsAnimating() && (AnimSequence == 'WalkFire') )
		return;
	if (AnimSequence != 'Walk' || !bAnimLoop)
		TweenAnim('Walk', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Breath2', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Breath2', tweentime);
}

function PlayRunning()
{
	if (Focus == Destination)
	{
		LoopAnim('Walk', -1.1/GroundSpeed,,0.4);
		return;
	}

	LoopAnim('Walk', StrafeAdjust(),,0.3);
}

function PlayWalking()
{
	LoopAnim('Walk', -1.1/GroundSpeed,,0.4);
}

function PlayTurning()
{
	TweenAnim('Walk', 0.3);
}

function PlayBigDeath(name DamageType)
{
	PlaySound(Die2, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead2',0.7,0.1);
}

function PlayHeadDeath(name DamageType)
{
	PlayAnim('Dead4',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayLeftDeath(name DamageType)
{
	PlayAnim('Dead2',0.7,0.1);
	PlaySound(Die,SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayRightDeath(name DamageType)
{
	PlayAnim('Dead3',0.7,0.1);
	PlaySound(Die,SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayGutDeath(name DamageType)
{
	PlayAnim('Dead1',0.7,0.1);
	PlaySound(Die,SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayMovingAttack()
{
	PlayAnim('WalkFire', 1.1);
}

function PlayVictoryDance()
{
	PlayAnim('PreCharg', 0.7, 0.3);
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor1, HitActor2;
	local float EnemyDist;

	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self)
		return false;

	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Location + 0.5 * CollisionRadius * X + 0.8 * CollisionRadius * Y + 0.4 * CollisionRadius * Z;
	HitActor1 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);
	if ( (HitActor1 != Enemy) && (Pawn(HitActor1) != None)
			&& (AttitudeTo(Pawn(HitActor1)) > ATTITUDE_Ignore) )
		return false;

	projStart = Location + 0.5 * CollisionRadius * X - 0.8 * CollisionRadius * Y + 0.4 * CollisionRadius * Z;
	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor2 == None) || (HitActor2 == Enemy)
			|| ((Pawn(HitActor2) != None) && (AttitudeTo(Pawn(HitActor2)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return ( (HitActor2 == None) || (HitActor2 == Enemy)
			 || ((Pawn(HitActor2) != None) && (AttitudeTo(Pawn(HitActor2)) <= ATTITUDE_Ignore)) );
}


function SpawnLeftShot()
{
	FireProjectile( vect(1.2,0.7,0.4), 750);
}

function SpawnRightShot()
{
	FireProjectile( vect(1.2,-0.7,0.4), 750);
}

function WhipDamageTarget()
{
	if (Target==none)
		return;
	if ( MeleeDamageTarget(WhipDamage, (WhipDamage * 1000.0 * Normal(Target.Location - Location))) )
		PlaySound(PistolHit, SLOT_Interact);
}

function Step()
{
	if (FRand() < 0.6)
		PlaySound(FootStep, SLOT_Interact,,,2000);
	else
		PlaySound(FootStep2, SLOT_Interact,,,2000);
}

function GutShotTarget()
{
	FireProjectile( vect(1.2,-0.55,0.0), 800);
}

function PlayMeleeAttack()
{
	local float decision;

	decision = FRand();
	If ( decision < 0.6 )
	{
		PlaySound(PistolWhip, SLOT_Interact);
		PlayAnim('PistolWhip');
	}
	else
	{
		PlaySound(PistolWhip, SLOT_Interact);
		PlayAnim('Punch');
	}
}

function PlayRangedAttack()
{
	//FIXME - if going to ranged attack need to
	//	TweenAnim('StillFire', 0.2);
	//What I need is a tween into time for the PlayAnim()
	if ( Target == None )
	{
		PlayThreatening();
		return;
	}

	if ( (AnimSequence == 'T8') || (VSize(Target.Location - Location) > 230) )
	{
		SpawnRightShot();
		PlayAnim('StillFire');
	}
	else
		PlayAnim('GutShot');
}


state Attacking
{
	ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local pawn changeEn;

		if ( !bTurret )
		{
			Super.ChooseAttackMode();
			return;
		}
		if ((Enemy == none) || (Enemy.Health <= 0) || (Enemy.bDeleteme)|| (Enemy == self))
		{
			if (Orders == 'Attacking')
				Orders = '';
			WhatToDoNext('','');
			return;
		}

		if (AttitudeToEnemy == ATTITUDE_Threaten)
		{
			GotoState('Threatening');
			return;
		}
		else if (!LineOfSightTo(Enemy))
		{
			if ( (OldEnemy != None)
					&& (AttitudeTo(OldEnemy) == ATTITUDE_Hate) && LineOfSightTo(OldEnemy) )
			{
				changeEn = enemy;
				enemy = oldenemy;
				oldenemy = changeEn;
			}
			else
			{
				GotoState('StakeOut');
				return;
			}
		}

		if (bReadyToAttack)
		{
			////log("Attack!");
			Target = Enemy;
			If (VSize(Enemy.Location - Location) <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('MeleeAttack');
			else
				GotoState('RangedAttack');
			return;
		}

		GotoState('RangedAttack', 'Challenge');
	}
}

state Charging
{
	ignores SeePlayer, HearNoise;

	function AnimEnd()
	{
		If ( bBerserk )
		LoopAnim('Charge', -1.1/GroundSpeed,,0.5);
		else
			PlayCombatMove();
	}

	function Timer()
	{
		if ( bBerserk && bLongBerserk && (FRand() < 0.3) )
		{
			AccelRate = Default.AccelRate;
			GroundSpeed = Default.GroundSpeed;
			bBerserk = false;
		}
		bLongBerserk = bBerserk;

		Super.Timer();
	}

	function BeginState()
	{
		GoBerserk();
		Super.BeginState();
	}

	function EndState()
	{
		if ( bBerserk )
		{
			GroundSpeed = Default.GroundSpeed;
			AccelRate = Default.AccelRate;
		}
		Super.EndState();
	}
}


state RangedAttack
{
	ignores SeePlayer, HearNoise, Bump;

	function TweenToFighter(float TweenTime)
	{
		if ( AnimSequence == 'T8' )
			return;
		if ( (GetAnimGroup(AnimSequence) == 'Hit') || (Skill > 3 * FRand()) || (VSize(Location - Target.Location) < 320)  )
			TweenAnim('Fighter', tweentime);
		else
			PlayAnim('T8', 1.0, 0.15);
	}
}

defaultproperties
{
	WhipDamage=20
	footstep=Sound'UnrealShare.Brute.walk1br'
	Footstep2=Sound'UnrealShare.Brute.walk2br'
	PistolWhip=Sound'UnrealShare.Brute.pwhip1br'
	PistolHit=Sound'UnrealShare.Brute.pstlhit1br'
	Die2=Sound'UnrealShare.Brute.death2br'
	CarcassType=Class'UnrealShare.BruteCarcass'
	Aggressiveness=1.000000
	RefireRate=0.300000
	WalkingSpeed=0.600000
	bHasRangedAttack=True
	bMovingRangedAttack=True
	bLeadTarget=False
	RangedProjectile=Class'UnrealShare.BruteProjectile'
	ProjectileSpeed=700.000000
	Acquire=Sound'UnrealShare.Brute.yell1br'
	Fear=Sound'UnrealShare.Brute.injur2br'
	Roam=Sound'UnrealShare.Brute.nearby2br'
	Threaten=Sound'UnrealShare.Brute.yell2br'
	bCanStrafe=True
	MeleeRange=70.000000
	GroundSpeed=140.000000
	WaterSpeed=100.000000
	JumpZ=-1.000000
	Visibility=150
	SightRadius=1500.000000
	Health=340
	ReducedDamageType=exploded
	ReducedDamagePct=0.300000
	UnderWaterTime=60.000000
	HitSound1=Sound'UnrealShare.Brute.injur1br'
	HitSound2=Sound'UnrealShare.Brute.injur2br'
	Land=None
	Die=Sound'UnrealShare.Brute.death1br'
	WaterStep=None
	CombatStyle=0.800000
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Brute1'
	AmbientSound=Sound'UnrealShare.Brute.amb1br'
	TransientSoundVolume=3.000000
	CollisionRadius=52.000000
	CollisionHeight=52.000000
	Mass=400.000000
	Buoyancy=390.000000
	RotationRate=(Pitch=3072,Yaw=45000,Roll=0)
	HeadOffset=(X=9,Z=50)
	HeadRadius=14
}
