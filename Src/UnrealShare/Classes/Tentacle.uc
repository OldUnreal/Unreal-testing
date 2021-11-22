//=============================================================================
// Tentacle.
//=============================================================================
class Tentacle extends ScriptedPawn;

#exec MESH IMPORT MESH=Tentacle1 ANIVFILE=Models\tentcl_a.3d DATAFILE=Models\tentcl_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Tentacle1 X=00 Y=330 Z=00 YAW=64 ROLL=-64

#exec MESH SEQUENCE MESH=Tentacle1 SEQ=All    STARTFRAME=0   NUMFRAMES=156 RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Curl   STARTFRAME=0   NUMFRAMES=18  RATE=15 Group=Hiding
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Dead1  STARTFRAME=18  NUMFRAMES=25  RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Dead1Land STARTFRAME=43  NUMFRAMES=3 RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Dead2  STARTFRAME=46  NUMFRAMES=11  RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Hide   STARTFRAME=57  NUMFRAMES=1            Group=Hiding
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Move1  STARTFRAME=58  NUMFRAMES=10
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Move2  STARTFRAME=68  NUMFRAMES=10
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Shoot  STARTFRAME=78  NUMFRAMES=15  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Smack  STARTFRAME=93  NUMFRAMES=30  Group=Attack
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Uncurl STARTFRAME=123 NUMFRAMES=18  RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Fighter  STARTFRAME=141 NUMFRAMES=1  RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=Waver  STARTFRAME=141 NUMFRAMES=15  RATE=15
#exec MESH SEQUENCE MESH=Tentacle1 SEQ=TakeHit STARTFRAME=132 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JTentacle1 FILE=Models\Tentacle.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=Tentacle1 X=0.15 Y=0.15 Z=0.3
#exec MESHMAP SETTEXTURE MESHMAP=Tentacle1 NUM=1 TEXTURE=JTentacle1 TLOD=10

#exec MESH NOTIFY MESH=Tentacle1 SEQ=Dead1 TIME=0.96 FUNCTION=Drop
#exec MESH NOTIFY MESH=Tentacle1 SEQ=Smack TIME=0.6 FUNCTION=SmackTarget

#exec AUDIO IMPORT FILE="Sounds\Tentacle\injured1.wav" NAME="injured1tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\injured2.wav" NAME="injured2tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\yell1.wav" NAME="yell1tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\yell2.wav" NAME="yell2tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\waver1.wav" NAME="waver1tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\splat2.wav" NAME="splat2tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\death2a.wav" NAME="death2tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\strike2.wav" NAME="strike2tn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\mebax.wav" NAME="curltn" GROUP="Tentacle"

//-----------------------------------------------------------------------------
// Tentacle variables.

// Attack damage.
var() int WhipDamage; // Damage done by whipping.

var(Sounds) sound mebax;
var(Sounds)  sound whip;
var(Sounds) sound Smack;

//-----------------------------------------------------------------------------
// Tentacle functions.

simulated function bool IsHeadshot( vector HitLocation, vector TraceDir )
{
	if( !Class'SinglePlayer'.Default.bUseExactHSDetection )
		return (!bIsBoss && Super(Pawn).IsHeadShot(HitLocation,TraceDir));
	return false; // No head.
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bLeadTarget = bLeadTarget && (FRand() > 0.5);
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	if( BonusSkill<=1.f )
		bQuiet = false;
	GotoState('Waiting');
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Tentacle') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('ScriptedPawn') )
		return ATTITUDE_Hate;
	else
		return ATTITUDE_Ignore;
}

simulated function AddVelocity( vector NewVelocity )
{
	if (Health <=0 || bDeleteMe)
	{
		Disable('Hitwall');
		Disable('Bump');
	}
	if (Physics == PHYS_Rotating)
		Velocity = vect(0,0,0);
	else
		Velocity += NewVelocity;
}

function PreSetMovement()
{
	bCanJump = false;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, projStart, EnemyUp;
	local actor HitActor;
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

	projStart = Location + CollisionHeight * vect(0,0,-1.2);

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor == None) || (HitActor == Enemy)
			|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart, true);

	return ( (HitActor == None) || (HitActor == Enemy)
			 || ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) );
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Rotating);
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;

	bCanWalk = true; //even though can't move, still acquire enemies
	result = Super.SetEnemy(NewEnemy);
	bCanWalk = false;
	return result;
}

function Drop()
{
	//implemented in TentacleCarcass
}

singular function Falling()
{
	SetMovementPhysics();
}

function PlayWaiting()
{
	TweenAnim('Hide', 5.0);
}

function PlayPatrolStop()
{
	TweenAnim('Hide', 5.0);
}

function PlayWaitingAmbush()
{
	TweenAnim('Hide', 5.0);
}

function PlayUncurl()
{
	if( !bQuiet )
		PlaySound(Mebax, SLOT_Interact);
	if( BonusSkill>0.f )
		PlayAnim('Uncurl', 0.6 + (BonusSkill*0.3), 0.2 - (BonusSkill*0.03));
	else PlayAnim('Uncurl', 0.6, 0.2);
}

function PlayChallenge()
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
		PlayUncurl();
	else
		PlayAnim('Waver', 1.0, 0.1);
}

function TweenToFighter(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
		PlayUncurl();
	else
		TweenAnim('Waver', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
		PlayUncurl();
	else if ( (AnimSequence != 'Move2') || !bAnimLoop )
		TweenAnim('Move2', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
		PlayUncurl();
	else if ( (AnimSequence != 'Move1') || !bAnimLoop )
		TweenAnim('Move1', tweentime);
}

function TweenToWaiting(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) != 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Curl', 0.6, 0.2);
	}
}

function TweenToPatrolStop(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
		PlayUncurl();
	else TweenAnim('Waver', tweentime);
}

function PlayRunning()
{
	LoopAnim('Move2', 1.0,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Move1', 1.0,, 0.4);
}

function PlayThreatening()
{
	if ( FRand() < 0.8 )
		PlayAnim('Waver', 0.4);
	else
		PlayAnim('Smack', 0.4);
}

function PlayTurning()
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
		PlayUncurl();
	else
		LoopAnim('Waver');
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 3 * TransientSoundVolume);
	if ( Velocity.Z > 200 )
		PlayAnim('Dead2', 0.7, 0.1);
	else
	{
		PlayAnim('Dead1', 0.7, 0.1);
		SetPhysics(PHYS_None);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Waver', 0.2);
}

function PlayInAir()
{
	LoopAnim('Waver');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Waver');
}


function PlayVictoryDance()
{
	PlaySound(whip, SLOT_Interact);
	PlayAnim('Smack', 0.6, 0.1);
}

function PlayMeleeAttack()
{
	PlaySound(whip, SLOT_Interact);
	PlayAnim('Smack');
}

function SmackTarget()
{
	if ( Target == None )
		return;
	if ( MeleeDamageTarget(WhipDamage, (WhipDamage * 1000 * Normal(Target.Location - Location))) )
		PlaySound(Smack, SLOT_Interact);
}

function PlayRangedAttack()
{
	local vector projStart;

	MakeNoise(1.0);
	projStart = Location + CollisionHeight * vect(0,0,-1.2);
	spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, 900, bLeadTarget, bWarnTarget));
	PlayAnim('Shoot',1.f + (BonusSkill*0.65));
}

state Attacking
{
	ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		if (Physics == PHYS_Swimming)
		{
			Super.ChooseAttackMode();
			return;
		}
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self)
		{
			if ((OldEnemy != None) && (OldEnemy.Health > 0)
					&& (OldEnemy != self) && (!OldEnemy.bDeleteme))
			{
				Enemy = OldEnemy;
				OldEnemy = None;
			}
			else
			{
				GotoState('Waiting');
				return;
			}
		}

		if (!LineOfSightTo(Enemy))
			GotoState('StakeOut');
		else
			GotoState('RangedAttack');
	}
}

state StakeOut
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 && !bDeleteme)
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
	}

Begin:
	PlayChallenge();
	TurnTo(LastSeenPos);
HangOut:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self)
		GotoState('Attacking');
	if ( bHasRangedAttack && bClearShot && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 100) && CanStakeOut() )
		PlayRangedAttack();
	FinishAnim();
	PlayChallenge();
	Sleep(1 + FRand());
	if ( FRand() < 0.1 )
		GotoState('Waiting');
	else
		LoopAnim('Waver');
	Goto('HangOut');
}

state Acquisition
{

PlayOut:
	FinishAnim();

Begin:
	PlayTurning();
	FinishAnim();
	GotoState('Attacking');
}

defaultproperties
{
	mebax=Sound'UnrealShare.Tentacle.curltn'
	Whip=Sound'UnrealShare.Tentacle.strike2tn'
	Smack=Sound'UnrealShare.Tentacle.splat2tn'
	CarcassType=Class'UnrealShare.TentacleCarcass'
	Aggressiveness=1.000000
	RefireRate=0.700000
	bHasRangedAttack=True
	bMovingRangedAttack=True
	bLeadTarget=False
	RangedProjectile=Class'UnrealShare.TentacleProjectile'
	Acquire=Sound'UnrealShare.Tentacle.yell1tn'
	Fear=Sound'UnrealShare.Tentacle.injured2tn'
	Roam=Sound'UnrealShare.Tentacle.waver1tn'
	Threaten=Sound'UnrealShare.Tentacle.yell2tn'
	MeleeRange=70.000000
	WaterSpeed=100.000000
	AccelRate=100.000000
	JumpZ=10.000000
	SightRadius=1000.000000
	PeripheralVision=-2.000000
	HearingThreshold=10.000000
	Health=50
	UnderWaterTime=-1.000000
	Intelligence=BRAINS_REPTILE
	HitSound1=Sound'UnrealShare.Tentacle.injured1tn'
	HitSound2=Sound'UnrealShare.Tentacle.injured2tn'
	Land=Sound'UnrealShare.Tentacle.splat2tn'
	Die=Sound'UnrealShare.Tentacle.death2tn'
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Tentacle1'
	CollisionRadius=28.000000
	CollisionHeight=36.000000
	Mass=200.000000
	Buoyancy=400.000000
	RotationRate=(Pitch=0,Yaw=30000,Roll=0)
	WhipDamage=14
	BeaconOffset=-1.1
	bNoDynamicShadowCast=true
}