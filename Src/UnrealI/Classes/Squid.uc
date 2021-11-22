//=============================================================================
// Squid.
//=============================================================================
class Squid extends ScriptedPawn;

#exec MESH IMPORT MESH=Squid1 ANIVFILE=Models\squid_a.3d DATAFILE=Models\squid_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Squid1 X=0 Y=0 Z=-100 YAW=-64 ROLL=-64

#exec MESH SEQUENCE MESH=squid1 SEQ=All		STARTFRAME=0	NUMFRAMES=142
#exec MESH SEQUENCE MESH=squid1 SEQ=Dead1	STARTFRAME=0	NUMFRAMES=21	RATE=15
#exec MESH SEQUENCE MESH=squid1 SEQ=TakeHit STARTFRAME=0	NUMFRAMES=1
#exec MESH SEQUENCE MESH=squid1 SEQ=Fighter STARTFRAME=21   NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=squid1 SEQ=Grab	STARTFRAME=36   NUMFRAMES=13	RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=squid1 SEQ=Hold	STARTFRAME=49   NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=squid1 SEQ=Release STARTFRAME=64   NUMFRAMES=6
#exec MESH SEQUENCE MESH=squid1 SEQ=Slap	STARTFRAME=70   NUMFRAMES=13	RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=squid1 SEQ=Spin	STARTFRAME=83   NUMFRAMES=10	RATE=15
#exec MESH SEQUENCE MESH=squid1 SEQ=Swim	STARTFRAME=93   NUMFRAMES=20	RATE=15
#exec MESH SEQUENCE MESH=squid1 SEQ=Thrust  STARTFRAME=113  NUMFRAMES=18	RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=squid1 SEQ=Turn	STARTFRAME=131  NUMFRAMES=11	RATE=15

#exec TEXTURE IMPORT NAME=JSquid1 FILE=Models\squid.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=Squid1 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=squid1 NUM=1 TEXTURE=Jsquid1

#exec MESH NOTIFY MESH=Squid1 SEQ=Grab TIME=0.54 FUNCTION=GrabTarget
#exec MESH NOTIFY MESH=Squid1 SEQ=Slap TIME=0.36 FUNCTION=SlapTarget
#exec MESH NOTIFY MESH=Squid1 SEQ=Thrust TIME=0.23 FUNCTION=ThrustTarget

#exec AUDIO IMPORT FILE="Sounds\Squid\amb1sq.wav" NAME="amb1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\death1sq.wav" NAME="death1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\grab1sq.wav" NAME="grab1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\hit1sq.wav" NAME="hit1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\slap1sq.wav" NAME="slap1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\thrust1sq.wav" NAME="thrust1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\injur1sq.wav" NAME="injur1sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\injur2sq.wav" NAME="injur2sq" GROUP="Squid"
#exec AUDIO IMPORT FILE="Sounds\Squid\turn1sq.wav" NAME="turn1sq" GROUP="Squid"

//-----------------------------------------------------------------------------
// Squid variables.

// Attack damage.
var() byte
ThrustDamage,		// Basic damage done by bite.
SlapDamage;

var(Sounds) sound thrust;
var(Sounds) sound slapgrabhit;
var(Sounds) sound thrusthit;
var(Sounds) sound slap;
var(Sounds) sound turn;
var(Sounds) sound grab;
var(Sounds) sound spin;
var(Sounds) sound flop;

var float	AirTime;

//-----------------------------------------------------------------------------
// Squid functions.

simulated function bool IsHeadshot( vector HitLocation, vector TraceDir )
{
	if( !Class'SinglePlayer'.Default.bUseExactHSDetection || HeadRadius<=0 )
		return (!bIsBoss && Super(Pawn).IsHeadShot(HitLocation,TraceDir));
	if( (vector(Rotation) Dot TraceDir)>0 ) // Mouth is being covered by the body.
		return CheckWithHeadRegion(HitLocation,TraceDir);
	return false;
}

function ZoneChange(ZoneInfo newZone)
{
	if ( newZone.bWaterZone )
	{
		AirTime = 0;
		if (Physics != PHYS_Swimming)
			setPhysics(PHYS_Swimming);
	}
	else if (Physics == PHYS_Swimming)
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
		GotoState('Flopping');
	}
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
	MaxDesiredSpeed = 0.7 + 0.1 * skill;
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
		GotoState('Flopping');
	}
}

function PlayWaiting()
{
	LoopAnim('Fighter', 0.1 + 0.3 * FRand());
}

function PlayPatrolStop()
{
	LoopAnim('Fighter', 0.1 + 0.3 * FRand());
}

function PlayWaitingAmbush()
{
	LoopAnim('Fighter', 0.1 + 0.3 * FRand());
}

function PlayChallenge()
{
	PlayAnim('Fighter', 0.4, 0.2);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence != 'Swim') || !bAnimLoop )
		TweenAnim('Swim', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( (AnimSequence != 'Swim') || !bAnimLoop )
		TweenAnim('Swim', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Fighter', 0.2 + 0.8 * FRand(), 0.3);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function PlayRunning()
{
	if ( ((AnimSequence == 'Spin') && (FRand() < 0.8)) || (FRand() < 0.06) )
		LoopAnim('Spin');
	else
		LoopAnim('Swim', -0.8/WaterSpeed,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Swim', -0.8/WaterSpeed,, 0.4);
}

function PlayThreatening()
{
	if ( FRand() < 0.6 )
		PlayAnim('Swim', 0.4);
	else
	{
		PlaySound(Spin, SLOT_Interact);
		PlayAnim('Spin', 0.4);
	}
}

function PlayTurning()
{
	PlaySound(turn, SLOT_Interact);
	LoopAnim('Turn', 0.4);
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead1', 0.7, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	DesiredRotation = Rotation;
	DesiredRotation.Pitch = 0;
	TweenAnim('Spin', 0.2);
}

function PlayInAir()
{
	LoopAnim('Fighter', 0.7);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Spin', 0.2);
}

function PlayVictoryDance()
{
	PlayAnim('grab', 0.6, 0.1);
	PlaySound(Grab, SLOT_Interact);
}


function GrabTarget()
{
	if ( Target == None )
		return;
	if ( MeleeDamageTarget(SlapDamage, (SlapDamage * 1500.0 * Normal(Location - Target.Location))) )
		PlaySound(SlapGrabHit, SLOT_Interact);
}

function SlapTarget()
{
	if ( Target == None )
		return;
	if ( MeleeDamageTarget(SlapDamage, (SlapDamage * 1500.0 * Normal(Target.Location - Location))) )
		PlaySound(SlapGrabHit, SLOT_Interact);
}

function ThrustTarget()
{
	if ( Target == None )
		return;
	if ( MeleeDamageTarget(ThrustDamage, (ThrustDamage * 1500.0 * Normal(Target.Location - Location))) )
		PlaySound(ThrustHit, SLOT_Interact);
}

//FIXME - hold (turn off client's physics???
function PlayMeleeAttack()
{
	local float decision;
	decision = FRand();
	if (decision < 0.35)
	{
		PlaySound(Thrust, SLOT_Interact);
		PlayAnim('Thrust', 0.8);
	}
	else if (decision < 0.7)
	{
		PlaySound(Slap, SLOT_Interact);
		PlayAnim('Slap', 0.8);
	}
	else
	{
		PlaySound(Grab, SLOT_Interact);
		PlayAnim('Grab');
	}
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal, TargetPoint;
	local float TargetDist;
	local actor HitActor;
	local bool result;

	result = false;

	if (Target == self )
		Target = none;
	if (Target == none )   // allow non pawn targets
	{
		if ( enemy != none && enemy.health >0  && !enemy.bDeleteme && enemy!=self)
			Target = Enemy;
	}
	if (Target == none || (Target != none && (Target.bDeleteme || (Target.IsA('Pawn') && Pawn(Target).Health <=0))) )
		return false;
	TargetDist = VSize(Target.Location - Location);
	Acceleration = AccelRate * (Target.Location - Location)/TargetDist;
	If (TargetDist <= (MeleeRange * 1.4 + Target.CollisionRadius + CollisionRadius)) //still in melee range
	{
		TargetPoint = Location - TargetDist * vector(Rotation);
		TargetPoint.Z = FMin(TargetPoint.Z, Target.Location.Z + Target.CollisionHeight);
		TargetPoint.Z = FMax(TargetPoint.Z, Target.Location.Z - Target.CollisionHeight);
		HitActor = Trace(HitLocation, HitNormal, TargetPoint, Location, true);
		If (HitActor == Target)
		{
			Target.TakeDamage(hitdamage, Self,HitLocation, pushdir, 'hacked');
			result = true;
		}
	}
	return result;
}

State Flopping
{
	ignores seeplayer, hearnoise, enemynotvisible, hitwall;

	function Timer()
	{
		AirTime += 1;
		if ( AirTime > 25 + 15 * FRand() )
		{
			Health = -1;
			Died(None, 'suffocated', Location);
			return;
		}
		SetPhysics(PHYS_Falling);
		Velocity = 200 * VRand();
		Velocity.Z = 170 + 200 * FRand();
		DesiredRotation.Pitch = Rand(8192) - 4096;
		DesiredRotation.Yaw = Rand(65535);
		TweenAnim('turn', 0.1);
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		local Rotator newRotation;
		if (NewZone.bWaterZone)
		{
			AirTime = 0;
			newRotation = Rotation;
			newRotation.Roll = 0;
			SetRotation(newRotation);
			SetPhysics(PHYS_Swimming);
			GotoState('Attacking');
		}
		else if (Physics != PHYS_Falling)
			SetPhysics(PHYS_Falling);
	}

	function Landed(vector HitNormal)
	{
		local rotator newRotation;
		SetPhysics(PHYS_None);
		SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
		newRotation = Rotation;
		newRotation.Pitch = 0;
		newRotation.Roll = Rand(16384) - 8192;
		DesiredRotation.Pitch = 0;
		SetRotation(newRotation);
		PlaySound(land,SLOT_Interact,,,400);
		TweenAnim('dead1', 0.3);
	}

	function AnimEnd()
	{
		if (Physics == PHYS_None)
		{
			if (AnimSequence == 'dead1')
			{
				PlayAnim('dead1');
			}
			else
				TweenAnim('dead1', 0.2);
		}
		else
			PlayAnim('turn', 0.7);
	}

Begin:
	SetTimer(0.3 + FRand(), false);
	TweenAnim('Swim', 0.7);
}

state TacticalMove
{
	ignores SeePlayer, HearNoise;

	function Timer()
	{
		Spawn(class'BigBlackSmoke');
	}

	function BeginState()
	{
		SetTimer(0.2, true);
		Super.BeginState();
	}
}

//squid has own melee attack because he faces away from his target when attacking
state MeleeAttack
{
	ignores SeePlayer, HearNoise, Bump;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'MeleeAttack';
			NextLabel = 'Begin';
		}
	}

	function KeepAttacking()
	{
		bReadyToAttack = true;
		if ( (Enemy == None) || (Enemy.Health <= 0) || (enemy.bDeleteme) || (Enemy == self))
			GotoState('Attacking');
		else if (VSize(Enemy.Location - Location) > (0.9 * MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('TacticalMove', 'NoCharge');
	}

	function EnemyNotVisible()
	{
		//log("enemy not visible");
		GotoState('Attacking');
	}

	function AnimEnd()
	{
		GotoState('MeleeAttack', 'DoneAttacking');
	}

	function BeginState()
	{
		Disable('AnimEnd');
		bCanStrafe = true; //so he can turn in place
	}

	function EndState()
	{
		bCanStrafe = false;
	}

Begin:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Target = Enemy;

FaceTarget:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Acceleration = Vect(0,0,0);
	Target = Enemy;
	if (NeedToTurn(2 * Location - Enemy.Location))
	{
		PlayTurning();
		TurnTo(2 * Location - Enemy.Location);
		TweenToFighter(0.15);
	}
	else if ( (5 - Skill) * FRand() > 3 )
	{
		DesiredRotation = Rotator(Location - Enemy.Location);
		PlayChallenge();
	}

	FinishAnim();

	if (VSize(Location - Enemy.Location) > MeleeRange + CollisionRadius + Enemy.CollisionRadius)
		GotoState('Attacking');

ReadyToAttack:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Target = Enemy;
	DesiredRotation = Rotator(Location - Enemy.Location);
	PlayMeleeAttack();
	Enable('AnimEnd');
	Sleep(0.0);
Attacking:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	TurnTo(2 * Location - Enemy.Location);
	Goto('Attacking');
DoneAttacking:
	Disable('AnimEnd');
	Sleep(0.0);
	KeepAttacking();
	Goto('FaceTarget');
}

defaultproperties
{
	ThrustDamage=35
	SlapDamage=30
	Thrust=Sound'UnrealI.Squid.thrust1sq'
	slapgrabhit=Sound'UnrealI.Squid.hit1sq'
	thrusthit=Sound'UnrealI.Squid.hit1sq'
	Slap=Sound'UnrealI.Squid.slap1sq'
	Turn=Sound'UnrealI.Squid.turn1sq'
	Grab=Sound'UnrealI.Squid.grab1sq'
	Aggressiveness=0.800000
	MeleeRange=70.000000
	GroundSpeed=0.000000
	WaterSpeed=430.000000
	AirSpeed=0.000000
	SightRadius=2000.000000
	PeripheralVision=-0.500000
	Health=260
	Intelligence=BRAINS_REPTILE
	HitSound1=Sound'UnrealI.Squid.injur1sq'
	HitSound2=Sound'UnrealI.Squid.injur2sq'
	Die=Sound'UnrealI.Squid.death1sq'
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Squid1'
	AmbientSound=Sound'UnrealI.Squid.amb1sq'
	CollisionRadius=40.000000
	CollisionHeight=60.000000
	Mass=200.000000
	Buoyancy=200.000000
	RotationRate=(Pitch=26000,Roll=13000)
	menuname="Squid"
	Maxstepheight=0
	CarcassType=Class'UnrealI.SquidCarcass'
	HeadOffset=(X=-20)
	HeadRadius=10
}
