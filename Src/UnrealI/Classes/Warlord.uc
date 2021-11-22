//=============================================================================
// Warlord.
//=============================================================================
class Warlord extends ScriptedPawn;

#exec MESH IMPORT MESH=WarlordM ANIVFILE=Models\warlor_a.3d DATAFILE=ModelsFX\warlor_d.3d Curvy=1 LODSTYLE=2
#exec MESH ORIGIN MESH=WarlordM X=0 Y=-300 Z=0 YAW=64 Roll=-64

#exec MESH SEQUENCE MESH=warlordM SEQ=All		STARTFRAME=0	NUMFRAMES=492
#exec MESH SEQUENCE MESH=warlordM SEQ=Breath	STARTFRAME=0	NUMFRAMES=8		RATE=6
#exec MESH SEQUENCE MESH=warlordM SEQ=Dead1		STARTFRAME=8    NUMFRAMES=26	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=TakeHit	STARTFRAME=8    NUMFRAMES=1
#exec MESH SEQUENCE MESH=warlordM SEQ=Fire		STARTFRAME=34   NUMFRAMES=15	RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=warlordM SEQ=Fighter	STARTFRAME=34	NUMFRAMES=1
#exec MESH SEQUENCE MESH=warlordM SEQ=Fly		STARTFRAME=49   NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=FlyFire	STARTFRAME=64   NUMFRAMES=15	RATE=15  Group=MovingAttack
#exec MESH SEQUENCE MESH=warlordM SEQ=Land		STARTFRAME=79   NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Run		STARTFRAME=94   NUMFRAMES=10	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Strike	STARTFRAME=104  NUMFRAMES=15	RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=warlordM SEQ=TakeOff	STARTFRAME=119  NUMFRAMES=10	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Twirl		STARTFRAME=129  NUMFRAMES=40
#exec MESH SEQUENCE MESH=warlordM SEQ=Walk		STARTFRAME=169  NUMFRAMES=15	RATE=18
#exec MESH SEQUENCE MESH=warlordM SEQ=WalkFire	STARTFRAME=184  NUMFRAMES=15	RATE=18  Group=MovingAttack
#exec MESH SEQUENCE MESH=warlordM SEQ=Appear	STARTFRAME=199  NUMFRAMES=11
#exec MESH SEQUENCE MESH=warlordM SEQ=FDodgeUp	STARTFRAME=210  NUMFRAMES=18	RATE=15	 Group=Dodge
#exec MESH SEQUENCE MESH=warlordM SEQ=FDodgeL	STARTFRAME=228  NUMFRAMES=15	RATE=15  Group=Dodge
#exec MESH SEQUENCE MESH=warlordM SEQ=FDodgeR	STARTFRAME=243  NUMFRAMES=15	RATE=15  Group=Dodge
#exec MESH SEQUENCE MESH=warlordM SEQ=GKick1	STARTFRAME=258  NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=GKick2	STARTFRAME=273  NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=GPunch1	STARTFRAME=288  NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=GPunch2	STARTFRAME=303  NUMFRAMES=15	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Grab		STARTFRAME=318  NUMFRAMES=18	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Laugh		STARTFRAME=336  NUMFRAMES=33	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Munch		STARTFRAME=369  NUMFRAMES=20	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Point		STARTFRAME=389  NUMFRAMES=28	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Teleport	STARTFRAME=417  NUMFRAMES=21	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Dead2A	STARTFRAME=438  NUMFRAMES=10	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Fall		STARTFRAME=448  NUMFRAMES=10	RATE=15
#exec MESH SEQUENCE MESH=warlordM SEQ=Dead2B	STARTFRAME=458  NUMFRAMES=34	RATE=15

#exec TEXTURE IMPORT NAME=JWarlord1 FILE=Models\warlord.pcx GROUP=Skins FLAGS=2 DETAIL=rockde2
#exec MESHMAP SCALE MESHMAP=WarlordM X=0.17 Y=0.17 Z=0.34
#exec MESHMAP SETTEXTURE MESHMAP=warlordM NUM=1 TEXTURE=Jwarlord1

#exec MESH NOTIFY MESH=WarlordM SEQ=Dead1 TIME=0.78 FUNCTION=LandThump
#exec MESH NOTIFY MESH=WarlordM SEQ=Fly TIME=0.1 FUNCTION=Flap
#exec MESH NOTIFY MESH=WarlordM SEQ=FlyFire TIME=0.1 FUNCTION=Flap
#exec MESH NOTIFY MESH=WarlordM SEQ=TakeOff TIME=0.1 FUNCTION=Flap
#exec MESH NOTIFY MESH=WarlordM SEQ=Run TIME=0.25 FUNCTION=Step
#exec MESH NOTIFY MESH=WarlordM SEQ=Run TIME=0.75 FUNCTION=Step
#exec MESH NOTIFY MESH=WarlordM SEQ=Walk TIME=0.33 FUNCTION=Step
#exec MESH NOTIFY MESH=WarlordM SEQ=Walk TIME=0.83 FUNCTION=Step
#exec MESH NOTIFY MESH=WarlordM SEQ=WalkFire TIME=0.33 FUNCTION=Step
#exec MESH NOTIFY MESH=WarlordM SEQ=WalkFire TIME=0.83 FUNCTION=Step

#exec AUDIO IMPORT FILE="Sounds\Warlord\injur1W.wav" NAME="injur1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\injur2W.wav" NAME="injur2WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\aquire1W.wav" NAME="acquire1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\DCry1W.wav" NAME="DeathCry1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\fly1W.wav" NAME="fly1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\roam1W.wav" NAME="roam1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\threat1W.wav" NAME="threat1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Warlord\breath1.wav" NAME="breath1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="Sounds\Titan\step1a.wav" NAME="step1t" GROUP="Titan"
#exec AUDIO IMPORT FILE="Sounds\Warlord\laugh3b.wav" NAME="laugh1WL" GROUP="WarLord"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Generic\teleprt28.wav" NAME="Teleport2" GROUP="Generic"

//FIXME - use TakeOff animation (maybe for falling start)

var() byte	StrikeDamage;
var() bool	bTeleportWhenHurt;
var float	LastDuckTime;
var float	NextCrushTimer;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bLeadTarget = bLeadTarget && (Rand(2) || BonusSkill>0.f);
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
	bCanDuck = true;
}

function ZoneChange(ZoneInfo newZone)
{
	if ( newZone.bWaterZone )
	{
		setPhysics(PHYS_Swimming);
		if (!bCanSwim)
			MoveTimer = -1.0;
		if ( Enemy == None)
			Acceleration = Accelrate * vect(0,0,1);
	}
	else
		Super.ZoneChange(newZone);
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Warlord') )
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	if ( bTeleportWhenHurt )
	{
		Health = 1000;
		PlayAnim('Teleport');
		GotoState('Teleporting');
	}
	else
		Super.Died(Killer, damageType, HitLocation);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local bool duckLeft, bSuccess;
	local actor HitActor;

	//log("duck");
	if ( Level.TimeSeconds - LastDuckTime < 0.6 - 0.1 * skill )
		return;
	if ( Region.Zone.bWaterZone )
		return;
	duckLeft = !bReversed;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;

	if ( (Physics != PHYS_Flying) && (FRand() < 0.4) ) // try to duck up
	{
		HitActor = Trace(HitLocation, HitNormal, Location + vect(0,0,300), Location, false, Extent);
		if ( HitActor == None )
		{
			if ( FRand() < 0.7 )
				PlayAnim('Fly', 1.6, 0.1);
			else
				PlayAnim('FDodgeUp');
			SetPhysics(PHYS_Flying);
			Destination = Location  + vect(0,0,300);
			Velocity = AirSpeed * vect(0,0,1);
			LastDuckTime = Level.TimeSeconds;
			GotoState('TacticalMove', 'DoMove');
			return;
		}
	}

	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	bSuccess = ( HitActor == None );
	if ( !bSuccess )
	{
		duckLeft = !duckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
		bSuccess = ( HitActor == None );
	}
	if ( !bSuccess )
		return;
	LastDuckTime = Level.TimeSeconds;
	if ( FRand() < 0.7 )
		PlayAnim('Fly', 1.6, 0.1);
	else if ( duckLeft )
		PlayAnim('FDodgeL');
	else
		PlayAnim('FDodgeR');
	SetPhysics(PHYS_Flying);
	Destination = Location + 200 * duckDir;
	Velocity = AirSpeed * duckDir;
	GotoState('TacticalMove', 'DoMove');
}

event Landed(vector HitNormal)
{
	SetPhysics(PHYS_Walking);
	if ( !IsAnimating() )
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
	bJustLanded = true;
}

function Step()
{
	PlaySound(sound'step1t', SLOT_Interact);
}

function Flap()
{
	if (Region.Zone.bWaterZone )
		return;
	PlaySound(sound'fly1WL', SLOT_Interact);
}

function SetMovementPhysics()
{
	if ( Region.Zone.bWaterZone )
	{
		SetPhysics(PHYS_Swimming);
		return;
	}
	if (Enemy != None)
	{
		if (Physics == PHYS_None)
			SetPhysics(PHYS_Walking);
		else if (Physics != PHYS_Walking)
			SetPhysics(PHYS_Flying);
	}
	else if (Physics != PHYS_Falling)
		SetPhysics(PHYS_Walking);
}

singular function Falling()
{
	SetPhysics(PHYS_Flying);
}

function PlayWaiting()
{
	if ( Region.Zone.bWaterZone )
	{
		PlayAnim('Fly', 0.35, 0.1);
		return;
	}
	if (AnimSequence == 'Land')
	{
		TweenAnim('Breath', 0.3);
		return;
	}

	PlaySound(sound'breath1WL', SLOT_Interact);
	if (FRand() < 0.9)
		LoopAnim('Breath', 0.2 + 0.7 * FRand());
	else
		LoopAnim('Twirl', 0.5 + 0.5 * FRand());
}

function PlayPatrolStop()
{
	if (Region.Zone.bWaterZone )
		PlayWaiting();
	else if (Physics == PHYS_Flying )
		LoopAnim('Fly', 0.7);
	else
		PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	if (Region.Zone.bWaterZone )
		TweenAnim('Fly', 0.4);
	else if (Physics == PHYS_Flying)
		PlayAnim('Fly', 0.7, 0.1);
	else if ( FRand() < 0.5 )
	{
		PlaySound(sound'laugh1WL', SLOT_Talk);
		PlayAnim('Laugh', 0.7, 0.1);
	}
	else
		PlayAnim('Point', 0.7, 0.1);
}

function TweenToFighter(float tweentime)
{
	if (Physics == PHYS_Flying || Region.Zone.bWaterZone )
		TweenAnim('Fly', tweentime);
	else
		TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( IsAnimating() && ((AnimSequence == 'WalkFire') || (AnimSequence == 'FlyFire')) )
		return;
	if (Physics == PHYS_Flying || Region.Zone.bWaterZone )
	{
		if ( (GetAnimGroup(AnimSequence) != 'Dodge') && ((AnimSequence != 'Fly') || !bAnimLoop) )
			TweenAnim('Fly', tweentime);
	}
	else if ( (AnimSequence != 'Run') || !bAnimLoop )
		TweenAnim('Run', tweentime);
}

function TweenToWalking(float tweentime)
{
	if (Physics == PHYS_Flying || Region.Zone.bWaterZone )
		TweenAnim('Fly', tweentime);
	else
		TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone )
	{
		if ( (AnimSequence != 'Fly') || !bAnimLoop )
			TweenAnim('Fly', tweentime);
		return;
	}
	PlayAnim('Land', 0.2 + 0.8 * FRand());
	SetPhysics(PHYS_Falling);
}

function TweenToPatrolStop(float tweentime)
{
	if (Physics == PHYS_Flying || Region.Zone.bWaterZone)
	{
		if (FRand() < 0.3 && !Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Falling);
			PlayAnim('Land', 0.7);
		}
		else
			TweenAnim('Fly', tweentime);
	}
	else
		TweenAnim('Breath', tweentime);
}

function PlayRunning()
{
	if (Region.Zone.bWaterZone )
		LoopAnim('Fly', -0.5/WaterSpeed,, 0.4);
	else if (Physics == PHYS_Walking)
		LoopAnim('Run', -1.0/GroundSpeed,, 0.4);
	else
		LoopAnim('Fly', -1.0/AirSpeed,, 0.4);
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone )
		LoopAnim('Fly', -0.5/WaterSpeed,, 0.4);
	else if (Physics == PHYS_Walking)
		LoopAnim('Walk', -1.4/GroundSpeed,, 0.4);
	else
		LoopAnim('Fly', -1.7/AirSpeed,, 0.4);
}

function PlayThreatening()
{
	if (Region.Zone.bWaterZone )
		PlayChallenge();
	else if (Physics == PHYS_Walking )
		TweenAnim('Fighter', 0.3);
	else
		LoopAnim('Fly', 0.6);
}

function PlayTurning()
{
	if (Physics == PHYS_Walking && !Region.Zone.bWaterZone)
		TweenAnim('Walk', 0.3);
	else
		LoopAnim('Fly');
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk);
	if ( Physics == PHYS_Flying || Region.Zone.bWaterZone )
		PlayAnim('Dead2A', 0.7, 0.12);
	else
		PlayAnim('Dead1', 0.7, 0.12);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Fly', 0.2);
}

function PlayInAir()
{
	LoopAnim('Fly');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Land');
}

function PlayVictoryDance()
{
	if (Region.Zone.bWaterZone )
		PlayAnim('Fly', 0.7, 0.1);
	else
		PlayAnim('Strike', 0.6, 0.1);
}

function PlayMeleeAttack()
{
	if (Physics == PHYS_Flying)
	{
		PlayRangedAttack();
		return;
	}
	PlayAnim('Strike');
	if ( Target && MeleeDamageTarget(StrikeDamage, (StrikeDamage * 1000.0 * Normal(Target.Location - Location))) )
		PlaySound(Threaten, SLOT_Talk);
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
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

	GetAxes(Rotation,X,Y,Z);
	projStart = Location - 0.5 * CollisionRadius * Y;
	HitActor = Trace(HitLocation, HitNormal,
					 projStart + EnemyDir + EnemyUp,
					 projStart , true);

	if ( !HitActor || (HitActor == Enemy) || (HitActor.bIsPawn && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return (!HitActor || (HitActor == Enemy) || (HitActor.bIsPawn && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) );
}

function PlayRangedAttack()
{
	local vector X,Y,Z, projStart;
	local rotator projRotation;

	if (Physics == PHYS_Flying || Region.Zone.bWaterZone )
		PlayAnim('FlyFire');
	else
		PlayAnim('Fire');

	GetAxes(Rotation,X,Y,Z);
	projStart = Location - 0.5 * CollisionRadius * Y;
	projRotation = AdjustAim(ProjectileSpeed, projStart, 0, bLeadTarget, bWarnTarget);
	spawn(RangedProjectile ,self,'',projStart,projRotation);
}

function PlayMovingAttack()
{
	local vector X,Y,Z, projStart;
	local rotator projRotation;

	if (Physics == PHYS_Flying || Region.Zone.bWaterZone )
		PlayAnim('FlyFire');
	else
	{
		DesiredSpeed = 0.4;
		PlayAnim('WalkFire');
	}
	GetAxes(Rotation,X,Y,Z);
	projStart = Location - 0.5 * CollisionHeight * Y;
	projRotation = AdjustAim(ProjectileSpeed, projStart, 600, bLeadTarget, bWarnTarget);
	if ( FRand() < 0.5 )
	{
		if (FRand() < 0.5)
			projRotation.Yaw += 3072;
		else
			projRotation.Yaw -= 3072;
	}
	spawn(RangedProjectile ,self,'',projStart,projRotation);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if( damageType=='Crushed' && momentum==vect(0,0,0) ) // Crushed by mover.
	{
		if( NextCrushTimer>Level.TimeSeconds )
			return;
		if( BonusSkill>0.f )
			NextCrushTimer = Level.TimeSeconds+1.f; // On extreme difficulty only take single damage from spike.
		else NextCrushTimer = Level.TimeSeconds+0.1f; // Prevent insta-death from falling spike on NaliLord battle (since its framerate dependant).
	}
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

state Charging
{
ignores SeePlayer, HearNoise;

	function HitWall(vector HitNormal, actor Wall)
	{
		if ( (Physics == PHYS_Flying) && (HitNormal.Z > 0.7) && (!Region.Zone.bWaterZone) )
		{
			SetPhysics(PHYS_Walking);
			return;
		}
		Super.HitWall(HitNormal, Wall);
	}

	function BeginState()
	{
		local vector HitLocation, HitNormal;
		local actor HitActor;

		if (Enemy!=none )
		{
			if ( (Enemy.Location.Z > Location.Z + MaxStepHeight) || (FRand() < 0.3) )
			{
				HitActor = Trace(HitLocation, HitNormal, Location + vect(0,0,300), Location, true);
				if (HitActor == none)
				{
					if (Region.Zone.bWaterZone )
						Velocity.Z = Waterspeed;
					else
					{
						Velocity.Z = Airspeed;
						SetPhysics(PHYS_Flying);
					}
				}
			}
			else if ( !Region.Zone.bWaterZone )
			{
				HitActor = Trace(HitLocation, HitNormal, Location - 2 * CollisionHeight * vect(0,0,1), Location, true);
				if (HitActor == Level)
					SetPhysics(PHYS_Falling);
			}
		}
		Super.BeginState();
	}
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( (Physics == PHYS_Flying) && (HitNormal.Z > 0.7) && (!Region.Zone.bWaterZone) )
		{
			SetPhysics(PHYS_Walking);
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('TacticalMove', 'AdjustFromWall');
		}
		else
		{
			super.HitWall(HitNormal, Wall);
		}
	}

	function BeginState()
	{
		local vector HitLocation, HitNormal;
		local actor HitActor;

		if ( (FRand() < 0.3) || (Enemy!=none && (Enemy.Location.Z - Location.Z > MaxStepHeight + 2 * (CollisionHeight - Enemy.CollisionHeight))) )
		{
			HitActor = Trace(HitLocation, HitNormal, Location + vect(0,0,300), Location, true);
			if (HitActor == none)
			{
				if (Region.Zone.bWaterZone )
					Velocity.Z = Waterspeed;
				else
				{
					Velocity.Z = Airspeed;
					SetPhysics(PHYS_Flying);
				}
			}
		}
		else if ( !Region.Zone.bWaterZone )
		{
			HitActor = Trace(HitLocation, HitNormal, Location - 2 * CollisionHeight * vect(0,0,1), Location, true);
			if (HitActor == Level)
				SetPhysics(PHYS_Falling);
		}
		Super.BeginState();
	}
}

State Teleporting
{
ignores TakeDamage, SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died;

	function Tick(float DeltaTime)
	{
		ScaleGlow -= 3 * DeltaTime;
		if ( ScaleGlow < 0.3 )
		{
			PlaySound(sound'Teleport2',, 8.0);
			TriggerEvent(Event,Self,Enemy);
			Destroy();
		}
	} 
	function BeginState()
	{
		bStasis = false;
		SetPhysics(PHYS_None);
		Disable('Tick');
	}

Begin:
	FinishAnim();
	Style = STY_Translucent;
	bUnlit = true;
	ScaleGlow = 2.0;
	Enable('Tick');
}

state Mutilating
{
Ignores TakeDamage;

	function Bump(actor Other)
	{
		if ( Other.bIsPawn && Pawn(Other).bIsPlayer )
			GotoState('Mutilating', 'FinalSequence');
	}

	function EnemyAcquired()
	{
		GotoState('Mutilating', 'FinalSequence');
	}

	function AnimEnd()
	{
		local float decision;

		decision = FRand();
		if ( AnimSequence == 'Grab' )
			PlayAnim('Munch', 0.3 + 0.7 * FRand());
		else if ( decision < 0.2 )
			PlayAnim('GKick1', 0.3 + 0.7 * FRand());
		else if ( decision < 0.4 )
			PlayAnim('GKick2', 0.3 + 0.7 * FRand());
		else if ( decision < 0.6 )
			PlayAnim('GPunch1', 0.3 + 0.7 * FRand());
		else if ( decision < 0.8 )
			PlayAnim('GPunch2', 0.3 + 0.7 * FRand());
		else
			PlayAnim('Grab', 0.3 + 0.7 * FRand());
	}

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		Enemy = None;
		Acceleration = vect(0,0,0);
		SetAlertness(0.0);
	}

FinalSequence:
	Disable('AnimEnd');
	PlayTurning();
	if (Enemy!=none)
		TurnToward(Enemy);
	PlayAnim('Point', 0.7, 0.15);
	FinishAnim();
	PlaySound(sound'laugh1WL', SLOT_Talk);
	PlayAnim('Laugh', 0.7);
	FinishAnim();
	GotoState('Attacking');
Begin:
	TweenToWaiting(0.2);
	bReadyToAttack = false;
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	SetRotation(DesiredRotation);
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_None);
}

defaultproperties
{
	StrikeDamage=40
	CarcassType=Class'UnrealI.WarlordCarcass'
	Aggressiveness=0.900000
	RefireRate=0.700000
	WalkingSpeed=0.250000
	bHasRangedAttack=True
	bMovingRangedAttack=True
	bIsBoss=True
	RangedProjectile=Class'UnrealI.WarlordRocket'
	Acquire=Sound'UnrealI.WarLord.acquire1WL'
	Fear=Sound'UnrealI.WarLord.threat1WL'
	Roam=Sound'UnrealI.WarLord.roam1WL'
	Threaten=Sound'UnrealI.WarLord.threat1WL'
	bCanStrafe=True
	MeleeRange=70.000000
	GroundSpeed=440.000000
	AirSpeed=440.000000
	AccelRate=1500.000000
	SightRadius=3000.000000
	Health=1100
	ReducedDamageType=exploded
	Intelligence=BRAINS_HUMAN
	HitSound1=Sound'UnrealI.WarLord.injur1WL'
	HitSound2=Sound'UnrealI.WarLord.injur2WL'
	Die=Sound'UnrealI.WarLord.DeathCry1WL'
	CombatStyle=0.500000
	NameArticle=" the "
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.WarlordM'
	TransientSoundVolume=12.000000
	CollisionRadius=52.000000
	CollisionHeight=78.000000
	Mass=1000.000000
	Buoyancy=1030.000000
	Style=STY_Masked
	HeadOffset=(X=25,Z=53)
	HeadRadius=16
}