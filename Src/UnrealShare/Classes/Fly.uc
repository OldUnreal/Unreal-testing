//=============================================================================
// Fly.
//=============================================================================
class Fly extends ScriptedPawn;

#exec TEXTURE IMPORT NAME=JFly1HD FILE=Models\fly.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JFly1 FILE=Models\fly_old.pcx GROUP=Skins FLAGS=2 HD=JFly1HD

#exec MESH IMPORT MESH=FlyM ANIVFILE=Models\fly_a.3d DATAFILE=Models\fly_d.3d LODSTYLE=2
#exec MESH ORIGIN MESH=FlyM X=0 Y=-30 Z=70 YAW=64 ROLL=-62

#exec MESH SEQUENCE MESH=FlyM SEQ=All      STARTFRAME=0     NUMFRAMES=97
#exec MESH SEQUENCE MESH=FlyM SEQ=Dead     STARTFRAME=0     NUMFRAMES=16
#exec MESH SEQUENCE MESH=FlyM SEQ=TakeHit  STARTFRAME=0     NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlyM SEQ=Flying   STARTFRAME=16    NUMFRAMES=10	RATE=15
#exec MESH SEQUENCE MESH=FlyM SEQ=Land     STARTFRAME=26    NUMFRAMES=11	RATE=15
#exec MESH SEQUENCE MESH=FlyM SEQ=Shoot1   STARTFRAME=37    NUMFRAMES=25 RATE=40  Group=Attack
#exec MESH SEQUENCE MESH=FlyM SEQ=Shoot2   STARTFRAME=62    NUMFRAMES=10   Group=Attack
#exec MESH SEQUENCE MESH=FlyM SEQ=Takeoff  STARTFRAME=72    NUMFRAMES=15
#exec MESH SEQUENCE MESH=FlyM SEQ=Walking  STARTFRAME=87   NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=FlyM SEQ=Waiting  STARTFRAME=88   NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlyM SEQ=Fighter  STARTFRAME=0     NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=flyM X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=flyM NUM=1 TEXTURE=Jfly1

#exec AUDIO IMPORT FILE="Sounds\Razorfly\buzz3rf.wav" NAME="buzz3rf" GROUP="Razorfly"
#exec AUDIO IMPORT FILE="Sounds\Razorfly\injur1rf.wav" NAME="injur1rf" GROUP="Razorfly"
#exec AUDIO IMPORT FILE="Sounds\Razorfly\injur2rf.wav" NAME="injur2rf" GROUP="Razorfly"
#exec AUDIO IMPORT FILE="Sounds\Razorfly\death1rf.wav" NAME="death1rf" GROUP="Razorfly"


//-----------------------------------------------------------------------------
// Fly variables.

//-----------------------------------------------------------------------------
// Fly functions.

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function ZoneChange(ZoneInfo newZone)
{
	if ( newZone.bWaterZone )
	{
		MoveTimer = -1.0;
		if ( (Enemy != None) && (Enemy.Location.Z < Location.Z) )
			GotoState('TacticalMove', 'BackOff');
		else
			Acceleration = Accelrate * vect(0,0,1);
	}
}

function SetMovementPhysics()
{
	if (Enemy != None)
		SetPhysics(PHYS_Flying);
	else if (Physics != PHYS_Falling)
		SetPhysics(PHYS_Walking);
}

singular function Falling()
{
	SetPhysics(PHYS_Flying);
	if (bIsPlayer)
	{
		PlayInAir();
		return;
	}

	if (health > 0 && !bDeleteme)
		SetFall();
}

function PlayWaiting()
{
	if ( Physics == PHYS_Walking )
		TweenAnim('Waiting', 10.0);
	else
		LoopAnim('Flying', 0.75);
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
	PlayAnim('Shoot1', 1.0, 0.1);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Flying', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence != 'Flying') || !bAnimLoop )
		TweenAnim('Flying', tweentime);
}

function TweenToWalking(float tweentime)
{
	if (Physics == PHYS_Walking)
		TweenAnim('Walking', tweentime);
	else if ( (AnimSequence != 'Flying') || !bAnimLoop )
		TweenAnim('Flying', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Land', 0.2 + 0.5 * FRand());
	SetPhysics(PHYS_Falling);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Flying', tweentime);
}

function PlayRunning()
{
	LoopAnim('Flying');
}

function PlayWalking()
{
	if (Physics == PHYS_Walking)
		LoopAnim('Walking', -1.0/GroundSpeed,, 0.4);
	else
		LoopAnim('Flying');
}

function PlayThreatening()
{
	if ( FRand() < 0.8 )
		LoopAnim('Flying');
	else
		LoopAnim('Shoot1', 0.4);
}

function PlayTurning()
{
	if (Physics == PHYS_Walking)
		LoopAnim('Walking');
	else
		LoopAnim('Flying');
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 2.5 * TransientSoundVolume);
	PlayAnim('Dead', 0.7, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Flying', 0.2);
}

function PlayInAir()
{
	LoopAnim('Flying');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Land');
}

function PlayVictoryDance()
{
	if ( FRand() < 0.4 )
		TweenToWaiting(0.25);
	else
		PlayAnim('Flying',1.0, 0.05);
}

function PlayMeleeAttack()
{
	if ( Target == None )
	{
		Playrunning();
		return;
	}
	if (Physics == PHYS_Walking)
		PlayAnim('Shoot2');
	else
		PlayAnim('Shoot1');

	if ( MeleeDamageTarget(15, (15 * 1000.0 * Normal(Target.Location - Location))) )
		PlaySound(Threaten, SLOT_Talk);
	GotoState('TacticalMove', 'BackOff');
}

function PlayRangedAttack()
{
	local vector projStart;
	local vector adjust;

	if ( Target != none && VSize(Target.Location - Location) <= (MeleeRange + Target.CollisionRadius + CollisionRadius ) )
	{
		PlayMeleeAttack();
		return;
	}
	PlayAnim('Shoot1');
	if (RangedProjectile!=none)
	{
		adjust = vect(0,0,0);
		adjust.Z = Target.CollisionHeight + 20;
		Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
		projStart = Location - 0.5 * CollisionHeight * vect(0,0,1);
		spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, 400, false, false));
	}
}

function PlayMovingAttack()
{
	PlayRangedAttack();
}

state TacticalMove
{
	ignores SeePlayer, HearNoise;

BackOff:
	if (Enemy == none)
		Acceleration = AccelRate * Normal(Focus);
	else
		Acceleration = AccelRate * Normal(Location - Enemy.Location);
	Acceleration.Z *= 0.5;
	Destination = Location;
	Sleep(0.5);
	SetTimer(TimeBetweenAttacks, false);

	Goto('TacticalTick');
}


state Roaming
{
	function PickDestination()
	{
		GotoState('Wandering');
	}

Begin:
	GotoState('Wandering');
}

state Attacking
{
	ignores SeePlayer, HearNoise, Bump, HitWall;

	function BeginState()
	{
		if ( TimerRate <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false);
		SetMovementPhysics();
	}
}

state Charging
{
	ignores SeePlayer, HearNoise;

	function BeginState()
	{
		SetMovementPhysics(); // came from bump melee ? reset
		super.Beginstate();
	}
}

defaultproperties
{
	CarcassType=Class'UnrealShare.FlyCarcass'
	Aggressiveness=0.700000
	RefireRate=0.700000
	WalkingSpeed=1.000000
	bCanStrafe=True
	MeleeRange=40.000000
	GroundSpeed=100.000000
	AirSpeed=240.000000
	AccelRate=600.000000
	JumpZ=10.000000
	Visibility=100
	SightRadius=1000.000000
	PeripheralVision=-0.500000
	Health=30
	HitSound1=Sound'UnrealShare.Razorfly.injur1rf'
	HitSound2=Sound'UnrealShare.Razorfly.injur2rf'
	Land=None
	Die=Sound'UnrealShare.Razorfly.death1rf'
	CombatStyle=0.400000
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.FlyM'
	AmbientSound=Sound'UnrealShare.Razorfly.buzz3rf'
	CollisionRadius=20.000000
	CollisionHeight=12.000000
	Buoyancy=110.000000
	RotationRate=(Pitch=6000,Yaw=65000,Roll=8192)
	HeadOffset=(X=14)
	HeadRadius=8
}
