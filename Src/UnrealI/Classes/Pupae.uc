//=============================================================================
// Pupae.
//=============================================================================
class Pupae extends ScriptedPawn;

#exec TEXTURE IMPORT NAME=JPupae1HD FILE=Models\pupae.pcx GROUP="HD" DETAIL=Dirty
#exec texture IMPORT NAME=JPupae1 FILE=Models\pupae_old.pcx GROUP=Skins DETAIL=Dirty HD=JPupae1HD

#exec MESH IMPORT MESH=Pupae1 ANIVFILE=Models\pupae_a.3d DATAFILE=Models\pupae_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pupae1 X=0 Y=0 Z=-90 YAW=64 PITCH=0 ROLL=-64

#exec MESH SEQUENCE MESH=pupae1 SEQ=All		 STARTFRAME=0	 NUMFRAMES=171
#exec MESH SEQUENCE MESH=pupae1 SEQ=Bite     STARTFRAME=0    NUMFRAMES=15  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=pupae1 SEQ=Crawl    STARTFRAME=15   NUMFRAMES=20  RATE=20
#exec MESH SEQUENCE MESH=pupae1 SEQ=Dead     STARTFRAME=35   NUMFRAMES=18  RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=TakeHit  STARTFRAME=36   NUMFRAMES=1
#exec MESH SEQUENCE MESH=pupae1 SEQ=Fighter  STARTFRAME=53   NUMFRAMES=6   RATE=6
#exec MESH SEQUENCE MESH=pupae1 SEQ=Lunge    STARTFRAME=59   NUMFRAMES=15  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=pupae1 SEQ=Munch    STARTFRAME=74   NUMFRAMES=8   RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=Pick     STARTFRAME=82   NUMFRAMES=10  RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=Stab     STARTFRAME=92   NUMFRAMES=10  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=pupae1 SEQ=Tear     STARTFRAME=102  NUMFRAMES=28  RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=Dead2    STARTFRAME=130  NUMFRAMES=18  RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=Dead3    STARTFRAME=148  NUMFRAMES=23  RATE=15

#exec MESHMAP scale MESHMAP=pupae1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=pupae1 NUM=1 TEXTURE=Jpupae1

#exec MESH NOTIFY MESH=Pupae1 SEQ=Dead TIME=0.52 FUNCTION=LandThump

#exec AUDIO IMPORT FILE="Sounds\Pupae\scuttle1.wav" NAME="scuttle1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\injur1.wav" NAME="injur1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\injur2.wav" NAME="injur2pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\roam1.wav" NAME="roam1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\hiss1.wav" NAME="hiss1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\hiss2.wav" NAME="hiss2pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\hiss3.wav" NAME="hiss3pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\bite1pp.wav" NAME="bite1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\tear1b.wav" NAME="tear1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\munch1pp.wav" NAME="munch1p" GROUP="Pupae"
#exec AUDIO IMPORT FILE="Sounds\Pupae\death1b.wav" NAME="death1pp" GROUP="Pupae"

//-----------------------------------------------------------------------------
// Pupae variables.

// Attack damage.
var() byte BiteDamage;		// Basic damage done by bite.
var() byte LungeDamage;		// Basic damage done by bite.
var(Sounds) sound bite;
var(Sounds) sound stab;
var(Sounds) sound lunge;
var(Sounds) sound chew;
var(Sounds) sound tear;

//-----------------------------------------------------------------------------
// Pupae functions.

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MaxDesiredSpeed = 0.7 + 0.1 * skill;
	if( BonusSkill>0.f )
	{
		MeleeRange = Default.MeleeRange*(1.f + BonusSkill*0.25f);
		if( BonusSkill>1.f && Intelligence==BRAINS_NONE && Rand(3)==0 ) // 227j: Give capability to follow players.
			Intelligence = BRAINS_Mammal;
	}
}

function JumpOffPawn()
{
	Super.JumpOffPawn();
	PlayAnim('crawl', 1.0, 0.2);
}

function SetMovementPhysics()
{
	SetPhysics(PHYS_Falling);
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Pupae') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Skaarj') )
	{
		if ( Other.IsA('SkaarjBerserker') )
			return ATTITUDE_Ignore;
		else
			return ATTITUDE_Friendly;
	}
	else if ( Other.IsA('WarLord') || Other.IsA('Queen') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('ScriptedPawn') )
		return ATTITUDE_Hate;
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;
	animspeed = 0.4 + 0.6 * FRand();
	decision = FRand();
	if ( !bool(NextAnim) || (decision < 0.4) ) //pick first waiting animation
	{
		if ( !bQuiet )
			PlaySound(Chew, SLOT_Talk, 0.7,,800);
		NextAnim = 'Munch';
	}
	else if (decision < 0.55)
		NextAnim = 'Pick';
	else if (decision < 0.7)
	{
		if ( !bQuiet )
			PlaySound(Stab, SLOT_Talk, 0.7,,800);
		NextAnim = 'Stab';
	}
	else if (decision < 0.7)
		NextAnim = 'Bite';
	else
		NextAnim = 'Tear';

	LoopAnim(NextAnim, animspeed);
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
	if ( FRand() < 0.3 )
		PlayWaiting();
	else
		PlayAnim('Fighter');
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (AnimSequence != 'Crawl' || !bAnimLoop)
		TweenAnim('Crawl', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Crawl', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Munch', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Munch', tweentime);
}

function PlayRunning()
{
	PlaySound(sound'scuttle1pp', SLOT_Interact);
	LoopAnim('Crawl', -4.0/GroundSpeed,,0.4);
}

function PlayWalking()
{
	PlaySound(sound'scuttle1pp', SLOT_Interact);
	LoopAnim('Crawl', -4.0/GroundSpeed,,0.4);
}

function PlayThreatening()
{
	PlayWaiting();
}

function PlayTurning()
{
	TweenAnim('Crawl', 0.3);
}

function PlayDying(name DamageType, vector HitLocation)
{
	local carcass carc;

	PlaySound(Die, SLOT_Talk, 3.5 * TransientSoundVolume);
	if ( FRand() < 0.35 )
		PlayAnim('Dead', 0.7, 0.1);
	else if ( FRand() < 0.5 )
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rotang(16.48,0,90) );
		if (carc != None)
		{
			carc.Mesh = mesh'PupaeHead';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Dead2', 0.7, 0.1);
	}
	else
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rotang(16.48,0,90) );
		if (carc != None)
		{
			carc.Mesh = mesh'PupaeBody';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Dead3', 0.7, 0.1);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	PlayAnim('TakeHit');
}

function PlayVictoryDance()
{
	PlayAnim('Stab', 1.0, 0.1);
}

function PlayMeleeAttack()
{
	local float dist, decision;
	local vector AimDir;

	if ( Target == None )
	{
		PlayWaiting();
		return;
	}
	decision = FRand();
	dist = VSize(Target.Location - Location);
	if ((dist > CollisionRadius + Target.CollisionRadius + 45)
		|| (Abs(Location.Z - Target.Location.Z) < FMax(CollisionHeight, Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Target.CollisionHeight)))
		decision = 0.0;

	if (Physics == PHYS_Falling)
		decision = 1.0;
	if (Target == None)
		decision = 1.0;

	if (decision < 0.15)
	{
		PlaySound(Lunge, SLOT_Interact);
		Enable('Bump');
		PlayAnim('Lunge');
		
		if( (Target.Location.Z-Target.CollisionHeight)>Location.Z ) // 227j: Aim higher when lunging uphill.
			AimDir = Target.Location + Target.CollisionHeight * vect(0,0,1.25);
		else AimDir = Target.Location + Target.CollisionHeight * vect(0,0,0.75);
		
		if( BonusSkill>0.f ) // 227j: Lead target on higher difficulties (and gain more speed)!
		{
			if( Rand(3) )
				AimDir+=Target.Velocity*((dist/600.f)*(FRand()*0.4f+0.75f));
			Velocity = 600 * Normal(AimDir - Location);
		}
		else Velocity = 450 * Normal(AimDir - Location);
		if (dist > CollisionRadius + Target.CollisionRadius + 35)
			Velocity.Z += 0.7 * dist;
		SetPhysics(PHYS_Falling);
		GoToState('MeleeAttack','WaitForAttack'); // 227j: Don't let challenge anim interrupt this melee move.
	}
	else
	{
		PlaySound(Stab, SLOT_Interact);
		PlayAnim('Stab');
		MeleeRange = 50;
		MeleeDamageTarget(BiteDamage, vect(0,0,0));
		MeleeRange = Default.MeleeRange;
	}
	if( BonusSkill>0.f )
		MeleeRange = Default.MeleeRange*(1.f + BonusSkill*0.25f);
}

// 227j: Allow pupaes lunge uphill.
function bool IsInMeleeRange( Pawn Other )
{
	if( Level.Game.bUseClassicBalance )
		return Super.IsInMeleeRange(Other);
	return VSizeSq(Location - Other.Location) < Square(MeleeRange + CollisionRadius + Other.CollisionRadius);
}

// 227j: Let pupae deal melee damage from underneath.
function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation;

	if( Level.Game.bUseClassicBalance )
		return Super.MeleeDamageTarget(hitdamage, pushdir);
	if ( Target==self )
		Target = none;
	if ( !Target && HasAliveEnemy() )   // allow non pawn targets
		Target = Enemy;
	if ( !IsLiveActor(Target) || (Target.bIsPawn && Pawn(Target).Health<=0) )
		return false;

	if ( (VSize2DSq(Target.Location - Location) <= Square(MeleeRange * 1.4 + Target.CollisionRadius + CollisionRadius))
		 && (Abs(Location.Z - Target.Location.Z) <= (MeleeRange*1.4 + CollisionHeight + Target.CollisionHeight)) )
	{
		if ( FastTrace(Target.Location, Location) && Target.TraceThisActor(Target.Location,Location,HitLocation) )
		{
			Target.TakeDamage(hitdamage, Self, HitLocation, pushdir, 'hacked');
			return true;
		}
	}
	return false;
}

state MeleeAttack
{
	ignores SeePlayer, HearNoise, Falling;

	singular function Bump(actor Other)
	{
		Disable('Bump');
		if ( (Other == Target) && (AnimSequence == 'Lunge') && MeleeDamageTarget(LungeDamage, vect(0,0,0)))
		{
			if (Rand(2))
				PlaySound(Tear, SLOT_Interact);
			else
				PlaySound(Bite, SLOT_Interact);
		}
	}
}

auto state StartUp
{
	function SetMovementPhysics()
	{
		SetPhysics(PHYS_None); // don't fall at start
	}
}

state Waiting
{
	function SeePlayer(Actor SeenPlayer)
	{
		// 227j: Sometimes make a surprise attack (at QueenEnd walls).
		if( AttitudeToPlayer == ATTITUDE_Ignore && BonusSkill>1.f && Pawn(SeenPlayer).bIsPlayer && IsInMeleeRange(Pawn(SeenPlayer)) && Rand(8)==0 )
		{
			AttitudeToPlayer = ATTITUDE_Hate;
			if (SetEnemy(Pawn(SeenPlayer)))
			{
				Target = SeenPlayer;
				DesiredRotation = rotator(SeenPlayer.Location-Location);
				PlayMeleeAttack();
			}
			else AttitudeToPlayer = ATTITUDE_Ignore;
		}
		else Global.SeePlayer(SeenPlayer);
	}

TurnFromWall:
	WaitForLanding();
	if ( NearWall(70) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Disable('Bump');
	Timer();
Begin:
	WaitForLanding();
	TweenToWaiting(0.4);
	bReadyToAttack = false;
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_None);
KeepWaiting:
	NextAnim = '';
}

defaultproperties
{
	BiteDamage=10
	LungeDamage=20
	Bite=Sound'UnrealI.Pupae.bite1pp'
	Stab=Sound'UnrealI.Pupae.hiss1pp'
	lunge=Sound'UnrealI.Pupae.hiss2pp'
	Chew=Sound'UnrealI.Pupae.munch1p'
	Tear=Sound'UnrealI.Pupae.tear1pp'
	CarcassType=Class'UnrealI.PupaeCarcass'
	Aggressiveness=10.000000
	Acquire=Sound'UnrealI.Pupae.hiss2pp'
	Fear=Sound'UnrealI.Pupae.hiss1pp'
	Roam=Sound'UnrealI.Pupae.roam1pp'
	Threaten=Sound'UnrealI.Pupae.hiss3pp'
	bCanStrafe=True
	MeleeRange=280.000000
	GroundSpeed=260.000000
	WaterSpeed=100.000000
	JumpZ=340.000000
	Visibility=100
	SightRadius=3000.000000
	PeripheralVision=-0.400000
	Health=65
	Intelligence=BRAINS_NONE
	HitSound1=Sound'UnrealI.Pupae.injur1pp'
	HitSound2=Sound'UnrealI.Pupae.injur2pp'
	Die=Sound'UnrealI.Pupae.death1pp'
	CombatStyle=1.000000
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Pupae1'
	CollisionRadius=28.000000
	CollisionHeight=9.000000
	Mass=80.000000
	RotationRate=(Pitch=3072,Yaw=65000,Roll=0)
	HeadOffset=(X=24)
	HeadRadius=8
	bIsCrawler=true
}
