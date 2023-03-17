//=============================================================================
// Predator.
//=============================================================================
class Predator expands ScriptedPawn;

#exec MESH IMPORT MESH=Predator ANIVFILE=MODELS\Predator\PackLizard_a.3d DATAFILE=MODELS\Predator\PackLizard_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Predator X=0 Y=0 Z=35 YAW=-64

#exec MESH SEQUENCE MESH=Predator SEQ=All      STARTFRAME=0   NUMFRAMES=229
#exec MESH SEQUENCE MESH=Predator SEQ=Death    STARTFRAME=0   NUMFRAMES=25
#exec MESH SEQUENCE MESH=Predator SEQ=Bite     STARTFRAME=25  NUMFRAMES=16 Group=Attack
#exec MESH SEQUENCE MESH=Predator SEQ=Backstep STARTFRAME=41  NUMFRAMES=24
#exec MESH SEQUENCE MESH=Predator SEQ=Idle     STARTFRAME=65  NUMFRAMES=24
#exec MESH SEQUENCE MESH=Predator SEQ=Jump     STARTFRAME=89  NUMFRAMES=15
#exec MESH SEQUENCE MESH=Predator SEQ=Look     STARTFRAME=104 NUMFRAMES=40
#exec MESH SEQUENCE MESH=Predator SEQ=Run      STARTFRAME=144 NUMFRAMES=10
#exec MESH SEQUENCE MESH=Predator SEQ=Threat   STARTFRAME=154 NUMFRAMES=16
#exec MESH SEQUENCE MESH=Predator SEQ=Walk     STARTFRAME=170 NUMFRAMES=14
#exec MESH SEQUENCE MESH=Predator SEQ=Wound    STARTFRAME=184 NUMFRAMES=20
#exec MESH SEQUENCE MESH=Predator SEQ=RunBite  STARTFRAME=204 NUMFRAMES=10 Group=MovingAttack
#exec MESH SEQUENCE MESH=Predator SEQ=JumpBite STARTFRAME=214 NUMFRAMES=15 Group=MovingAttack

#exec TEXTURE IMPORT NAME=JPredator1 FILE=MODELS\Predator\PackLizard1.PCX FLAGS=2
#exec TEXTURE IMPORT NAME=JPredator1 FILE=MODELS\Predator\PackLizard1.PCX GROUP=Skins FLAGS=2 // tail11T2y
#exec TEXTURE IMPORT NAME=JPredator2 FILE=MODELS\Predator\PackLizard2.PCX GROUP=Skins // head4T6y

#exec MESH NOTIFY MESH=Predator SEQ=Bite          TIME=0.50 FUNCTION=BiteDamageTarget
#exec MESH NOTIFY MESH=Predator SEQ=RunBite       TIME=0.50 FUNCTION=BiteDamageTarget
#exec MESH NOTIFY MESH=Predator SEQ=JumpBite      TIME=0.50 FUNCTION=BiteDamageTarget
#exec MESH NOTIFY MESH=Predator SEQ=Run           TIME=0.00 FUNCTION=RunStep
#exec MESH NOTIFY MESH=Predator SEQ=Run           TIME=0.50 FUNCTION=RunStep
#exec MESH NOTIFY MESH=Predator SEQ=Walk          TIME=0.43 FUNCTION=WalkStep
#exec MESH NOTIFY MESH=Predator SEQ=Walk          TIME=0.93 FUNCTION=WalkStep

#exec MESHMAP NEW   MESHMAP=Predator MESH=Predator
#exec MESHMAP SCALE MESHMAP=Predator X=0.45 Y=0.45 Z=0.90

#exec MESHMAP SETTEXTURE MESHMAP=Predator NUM=1 TEXTURE=JPredator1
#exec MESHMAP SETTEXTURE MESHMAP=Predator NUM=2 TEXTURE=JPredator2

#exec AUDIO IMPORT FILE="Sounds\Predator\Bite.wav"  NAME="bite"  GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Death.wav" NAME="die"   GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Fear1.wav" NAME="fear1" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Fear2.wav" NAME="fear2" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Fear3.wav" NAME="fear3" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Hate.wav"  NAME="hate"  GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Hurt1.wav" NAME="hurt1" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Hurt2.wav" NAME="hurt2" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Hurt3.wav" NAME="hurt3" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Step1.wav" NAME="step1" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Step2.wav" NAME="step2" GROUP="Predator"
#exec AUDIO IMPORT FILE="Sounds\Predator\Idle.wav"  NAME="idle"  GROUP="Predator"

//-----------------------------------------------------------------------------
// Predator variables.
// Attack damage.
var() byte BiteDamage;	// Basic damage done by bite.

var() float AttackThreshold;
var() float RetreatThreshold;
var() float GroupRadius;

var() bool bDebugLog;
var() bool bSpecialAttitudeToPlayer; // whether AttitudeToPlayer is used as the initial attitude to player

//var bool AttackSuccess;
var(Sounds) sound hitsound3;
var(Sounds) sound hitsound4;
var(Sounds) sound Bite;
//var(Sounds) sound Die2;
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;
var(Sounds) sound Fear2;
var(Sounds) sound Fear3;

var float GroupHealth;
var float AllHealth;

var PathNodeIterator pni;
struct NavPtInfo
{
	var NavigationPoint NavPt;
	var float Distance;
	var bool bReachable;
	var bool bVisibleToEnemy;
};

var NavPtInfo DestList[32];
var int DestListSize;

function PlayGutHit(float tweentime);
function PlayHeadHit(float tweentime);
function PlayLeftHit(float tweentime);
function PlayRightHit(float tweentime);

function PreBeginPlay()
{
	Super.PreBeginPlay();

	EyeHeight = FMin( CollisionHeight, 48.0 );
	BaseEyeHeight = EyeHeight;

	if( CombatStyle == Default.CombatStyle )
	{
		CombatStyle = CombatStyle + 0.3 * FRand() - 0.15;
	}
}

function RunStep()
{
	if( FRand() < 0.6 )
		PlaySound( FootStep, SLOT_Interact,0.8,,900 );
	else
		PlaySound( FootStep2, SLOT_Interact,0.8,,900 );
}

function WalkStep()
{
	if( FRand() < 0.6 )
		PlaySound( FootStep, SLOT_Interact,0.2,,500 );
	else
		PlaySound( FootStep2, SLOT_Interact,0.2,,500 );
}

function ZoneChange(ZoneInfo newZone)
{
	bCanSwim = newZone.bWaterZone; //only when it must
		
	if( newZone.bWaterZone )
		CombatStyle = 1.0; //always charges when in the water
	else if( Physics == PHYS_Swimming )
		CombatStyle = Default.CombatStyle;

	Super.ZoneChange(newZone);
}

/* PreSetMovement()
*/
function PreSetMovement()
{
	MaxDesiredSpeed = 0.7 + 0.1 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	if ( Intelligence > BRAINS_Mammal )
		bCanDoSpecial = true;
	bCanDuck = true;
}

function SetMovementPhysics()
{
	if( Region.Zone.bWaterZone )
		SetPhysics( PHYS_Swimming );
	else if( Physics != PHYS_Walking )
		SetPhysics( PHYS_Walking );
}

//=========================================================================================
/* AttitudeTo()
Returns the creature's attitude towards another Pawn
*/
function eAttitude AttitudeTo(Pawn Other)
{
	return GetAttitudeToPawn(Other, false);
}

function eAttitude GetAttitudeToPawn(Pawn Other, bool bIgnoreState)
{
	if (Other.bIsPlayer)
	{
		if (AttitudeToPlayer == ATTITUDE_Hate)
			bSpecialAttitudeToPlayer = false;
		if (bSpecialAttitudeToPlayer)
			return AttitudeToPlayer;

		//if( bDebugLog ) log( Self $ " AttitudeTo(" $ Other $ ") GroupHealth " $ GroupHealth $ " Health " $ Health $ " AttackThreshold " $ AttackThreshold );
		if( GroupHealth >= AttackThreshold * Other.Health / 100.0 || AllHealth < AttackThreshold * Other.Health / 100.0 )
		{
			return ATTITUDE_Hate;
		}
		else if( GroupHealth <= RetreatThreshold * Other.Health / 100.0 )
		{
			return ATTITUDE_Fear;
		}
		else if( !bIgnoreState && (IsInState('Hiding') || IsInState('Retreating')) )
		{
			return ATTITUDE_Fear;
		}
		else
		{
			return ATTITUDE_Hate;
		}
	}
	else if ( (TeamTag != '') && (ScriptedPawn(Other) != None) && (TeamTag == ScriptedPawn(Other).TeamTag) )
		return ATTITUDE_Friendly;
	else	
		return AttitudeToCreature(Other);
}

function eAttitude AttitudeWithFear()
{
	return ATTITUDE_Fear;
}

function damageAttitudeTo(pawn Other)
{
	if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) )
		return;
	if( Other.bIsPlayer ) //change attitude to player
	{
		if (AttitudeToPlayer == ATTITUDE_Threaten || AttitudeToPlayer == ATTITUDE_Ignore)
			bSpecialAttitudeToPlayer = false;
		if (!bSpecialAttitudeToPlayer)
			AttitudeToPlayer = ATTITUDE_Fear;
	}
	else if ( ScriptedPawn(Other) == None )
		Hated = Other;
	SetEnemy(Other);
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Predator') )
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Hate;
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

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayDive()
{
	TweenToSwimming( 0.2 );
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	//TweenAnim('gunfix', tweentime);
  TweenAnim('idle', tweentime);
}

function TweenToFighter(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	if ( (AnimSequence == 'Death2') && (AnimFrame > 0.8) )
	{
		SetFall();
		GotoState('FallingState', 'RiseUp');
	}
	else
	{
		//TweenAnim('Fighter', tweentime);
		TweenAnim('Run', tweentime);
	}
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	if ( (AnimSequence == 'Death2') && (AnimFrame > 0.8) )
	{
		SetFall();
		GotoState('FallingState', 'RiseUp');
	}
	else if ( ((AnimSequence != 'Run') && (AnimSequence != 'RunBite')) || !bAnimLoop )
		//TweenAnim('Run', tweentime);
	TweenAnim('Run', tweentime);
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('Walk', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	//TweenAnim('Breath', tweentime);
  TweenAnim('idle', tweentime);
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	LoopAnim('Walk', 0.88);
}

function TweenToSwimming(float tweentime)
{
//	if ( (AnimSequence != 'Swim') || !bAnimLoop )
	//	TweenAnim('Swim', tweentime);
}

function PlaySwimming()
{
	LoopAnim('Walk', -1.0/WaterSpeed,, 0.5);
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if ( (AnimSequence == 'Death2') && (AnimFrame > 0.8) )
	{
		SetFall();
		GotoState('FallingState', 'RiseUp');
	}
	else
		TweenAnim('Walk', 0.3);
}

function PlayBigDeath(name DamageType)
{
	PlayAnim( 'Death', 0.7, 0.1 );
	//PlaySound( Die2, SLOT_Talk, 4.5 * TransientSoundVolume );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayHeadDeath(name DamageType)
{
	local carcass carc;

	if ( (DamageType == 'Decapitated') || ((Health < -20) && (FRand() < 0.5)) )
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Mesh = mesh'PredatorHead';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim( 'Death', 0.7, 0.1 );
		if ( IsA('Predator') && (Velocity.Z < 120) )
		{
			Velocity = GroundSpeed * vector(Rotation);
			Velocity.Z = 150;
		}
	}
	else
		PlayAnim( 'Death', 0.7, 0.1 );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayLeftDeath(name DamageType)
{
	PlayAnim( 'Death', 0.7, 0.1 );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayRightDeath(name DamageType)
{
	PlayAnim( 'Death', 0.7, 0.1 );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume );
}

function PlayGutDeath(name DamageType)
{
	PlayAnim('Death',0.7, 0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float decision;

	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;
	LastPainSound = Level.TimeSeconds;

	decision = FRand(); //FIXME - modify based on damage
	if (decision < 0.25)
		PlaySound(HitSound1, SLOT_Pain, 2.0 * Mult);
	else if (decision < 0.5)
		PlaySound(HitSound2, SLOT_Pain, 2.0 * Mult);
	else if (decision < 0.75)
		PlaySound(HitSound3, SLOT_Pain, 2.0 * Mult);
	else
		PlaySound(HitSound4, SLOT_Pain, 2.0 * Mult);
}

function PlayFearSound()
{
	local float decision;

	decision = FRand();
	if( Fear != None && decision < 0.33 )
		PlaySound( Fear, SLOT_Talk,, true );
	else if( Fear2 != None && decision < 0.67 )
		PlaySound( Fear2, SLOT_Talk,, true );
	else if( Fear3 != None )
		PlaySound( Fear3, SLOT_Talk,, true );
	else if( Fear2 != None )
		PlaySound( Fear2, SLOT_Talk,, true );
	else if( Fear != None )
		PlaySound( Fear, SLOT_Talk,, true );
}

function TweenToFalling()
{
	if ( FRand() < 0.5 )
		TweenAnim('Run', 0.2);
	else
		PlayAnim('Jump',0.7,0.1);
}

function PlayInAir()
{
	if( AnimSequence == 'Run' )
		PlayAnim( 'Run', 0.4 );
	else if( AnimSequence == 'RunBite' )
		PlayAnim( 'RunBite', 0.4 );
	else
		//TweenAnim( 'InAir', 0.4 );
		TweenAnim( 'Idle', 0.4 );
}

function PlayOutOfWater()
{
	//TweenAnim( 'Landed', 0.8 );
}

function PlayLanded(float impactVel)
{
	//if( impactVel > 1.7 * JumpZ )
	//	TweenAnim('Landed',0.1);
	//else
	//	TweenAnim('Land', 0.1);
}
	
function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	if ( (Velocity.Z > 120) && (Health < 0.4 * Default.Health) && (FRand() < 0.33) )
		PlayAnim( 'Wound', 0.7 );
	else if ( (AnimSequence != 'Spin') && (AnimSequence != 'Lunge') && (AnimSequence != 'Death2') )
		Super.PlayTakeHit( tweentime, HitLoc, damage );
}

function BiteDamageTarget()
{
	if( Target != None && (MeleeDamageTarget( BiteDamage, ( BiteDamage * 1000 * Normal( Target.Location - Location ) ) ) ))
		PlaySound(Bite, SLOT_Interact);
}

	
function PlayMeleeAttack()
{
	local vector Dist;
	//AttackSuccess = false;
	//log("Start Melee Attack");
	//Velocity = Normal( Target.Velocity ) * FMin( VSize( Target.Velocity ), GroundSpeed ) * 0.8;
	if (Target != None)
	{
		Dist = Target.Location - Location;
		Velocity = Target.Velocity + Normal( Dist ) * ( VSize( Dist ) - Target.CollisionRadius - CollisionRadius - MeleeRange / 2.0 ) * 0.1;
		if( VSize(Velocity) > 8.0 ) 
		{
			PlayAnim( 'RunBite' );
		}
		else
		{
 			PlayAnim( 'Bite' );
		}
	}
 	//PlaySound( Bite, SLOT_Interact );
}

function float GetGroupHealth()
{
	local Predator Peer;

	GroupHealth = Health;
	foreach VisibleActors( class'Predator', Peer, GroupRadius )
	{
		if( Peer != Self )
		{
			GroupHealth += Peer.Health;
		}
	}
	return GroupHealth;
}

function float GetAllHealth()
{
	local Predator aPredator;

	AllHealth = Health;
	foreach RadiusActors( class'Predator', aPredator, GroupRadius * 4.0 )
	{
		if( aPredator != Self )
		{
			AllHealth += aPredator.Health;
		}
	}
	return AllHealth;
}

function NotifyPeers( name Message, Pawn Other )
{
	local Predator Friend;

	if( bDebugLog ) Log( Self $ " NotifyPeers( " $ Message $ ", " $ Other $ " )" );
	foreach VisibleActors( class'Predator', Friend, GroupRadius )
	{
		if( Friend != Self )
		{
			Friend.PeerNotification( Self, Message, Other );
		}
	}
}

function PeerNotification( Pawn Instigator, name Message, Pawn Other )
{
	if( bDebugLog ) Log( Self $ " ::PeerNotification( " $ Instigator $ ", " $ Message $ ", " $ Other $ " )" );
}

function MayFall()
{
	if( MoveTarget == Enemy && intelligence != BRAINS_None )
	{
		bCanJump = ActorReachable( Enemy );
		if( !bCanJump )
			GotoState( 'TacticalMove', 'NoCharge' );
	}
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, name DamageType )
{
	if( bDebugLog ) Log( Self $ " ::TakeDamage( " $ Damage $ ", " $ InstigatedBy $ ", " $ HitLocation $ ", " $ Momentum $ ", " $ DamageType $ " ) state " $ GetStateName() );
	TakeDamageAndNotifyGroup( Damage, InstigatedBy, Hitlocation, Momentum, DamageType );
}

function TakeDamageAndNotifyGroup( int Damage, Pawn InstigatedBy, Vector hitlocation, Vector momentum, name damageType )
{
	if( bDebugLog ) Log( Self $ " ::TakeDamageAndNotifyGroup( " $ Damage $ ", " $ InstigatedBy $ ", " $ HitLocation $ ", " $ Momentum $ ", " $ damageType $ " )" );
	Super.TakeDamage( Damage, InstigatedBy, hitlocation, momentum, damageType );
	if ( Enemy != None )
		LastSeenPos = Enemy.Location;
	if( bDebugLog ) Log( Self $ " TakeDamage: GroupHealth " $ GetGroupHealth() $ " Health " $ Health );

	if (InstigatedBy != none && InstigatedBy == Enemy &&
		AttitudeTo(Enemy) <= ATTITUDE_Hate &&
		GetGroupHealth() <= RetreatThreshold * InstigatedBy.Health / 100.0 )
	{
		// Check if there are enough creatures left in the level to form an attack group.
		// If not, fight to the death!
		if( GetAllHealth() >= AttackThreshold * InstigatedBy.Health / 100.0 )
		{
			NotifyPeers( 'Retreat', Enemy );
			if( health <= 0 )
			{
				return;
			}
			else if( NextState == 'TakeHit' )
			{
				NextState = 'Hiding';
				NextLabel = 'Immediate';
				GotoState( 'TakeHit' );
			}
			else
			{
				GotoState( 'Hiding' );
			}
		}
		else
		{
			NotifyPeers( 'Attack', Enemy );
			if( health <= 0 )
			{
				return;
			}
			else if( NextState == 'TakeHit' )
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
				GotoState( 'TakeHit' );
			}
			else
			{
				GotoState( 'Attacking' );
			}
		}
	}
	else if( health <= 0 )
	{
		return;
	}
	else if( NextState == 'TakeHit' )
	{
		if( !IsInState( 'FallingState' ) )
		{
			NextState = GetStateName();
			if( NextState == 'Hiding' )
			{
				NextLabel = 'Immediate';
			}
			else
			{
				NextLabel = 'Begin';
			}
		}
		GotoState('TakeHit');
	}
}

function bool InMeleeRange( Pawn Other )
{
	local vector Dist2d;

	Dist2d = Location - Enemy.Location;
	Dist2d.Z = 0;
	return Abs( Location.Z - Other.Location.Z ) <= FMax( CollisionHeight, Other.CollisionHeight ) + 0.5 * FMin( CollisionHeight, Other.CollisionHeight ) &&
		VSize( Dist2d ) <= MeleeRange + CollisionRadius + Enemy.CollisionRadius;
}

// FindBestPathToward() assumes the desired destination is not directly reachable, 
// given the creature's intelligence, it tries to set Destination to the location of the 
// best waypoint, and returns true if successful
function bool FindBestPathToward( actor desired )
{
	local Actor path;
	local bool success;

	if( specialGoal != None )
	{
		desired = specialGoal;
	}
	path = None;
	if( Intelligence <= BRAINS_Reptile )
	{
		path = FindPathToward( desired, true );
	}
	else
	{
		path = FindPathToward( desired );
	}
	/*
	if( ActorReachable( desired ) ) {
		path = desired;
	} else {
		if( pni == None )
		{
			pni = Spawn( class'PathNodeIterator' );
		}
		pni.BuildPath( Location, desired.Location );
		path = pni.GetLast();
		while( path != None && !ActorReachable( path ) )
		{
			path = pni.GetPrevious();
		}
		if( path == None ) {
			path = pni.GetFirst();
		}
	}
	*/
	success = ( path != None );
	if( success )
	{
		MoveTarget = path;
		Destination = path.Location;
	}
	return success;
}

// ====================
// Waiting
// ====================

state Waiting
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;
		if( NextState == 'TakeHit' )
		{
			if (Enemy == none)
				NextState = 'Waiting';
			else if (AttitudeTo(Enemy) > ATTITUDE_Hate)
				NextState = 'Attacking';
			else
				NextState = 'Hiding';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else if ( Enemy != None )
		{
			if (GetGroupHealth() >= AttackThreshold * Enemy.Health / 100.0 ||
				GetAllHealth() < AttackThreshold * Enemy.Health / 100.0 ||
				AttitudeTo(Enemy) > ATTITUDE_Hate)
			{
				NotifyPeers( 'Attack', Enemy );
				GotoState( 'Attacking' );
			}
			else
			{
				NotifyPeers( 'Retreat', Enemy );
				GotoState( 'Hiding' );
			}
		}
	}

	function Bump(actor Other)
	{
		//log(Other.class$" bumped "$class);
		if (Pawn(Other) != None)
		{
			/*if (Enemy == Other)
				bReadyToAttack = True;*/ //can melee right away
			SetEnemy(Pawn(Other));
		}
		if ( TimerRate <= 0 )
			setTimer(1.5, false);
		Disable('Bump');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function PeerNotification( Pawn Instigator, name Message, Pawn Other )
	{
		if( bDebugLog ) Log( Self $ " Waiting::PeerNotification( " $ Instigator $ ", " $ Message $ ", " $ Other $ " )" );
		if( message == 'Attack' )
		{
			if( Other != Enemy && SetEnemy( Other ) )
			{
				LastSeenPos = Enemy.Location;
			}
			GotoState( 'Attacking' );
		}
		// 'Retreat'
	}

	function EnemyAcquired()
	{
		if (GetGroupHealth() >= AttackThreshold * Enemy.Health / 100.0 ||
			GetAllHealth() < AttackThreshold * Enemy.Health / 100.0 ||
			AttitudeTo(Enemy) > ATTITUDE_Hate)
		{
			NotifyPeers( 'Attack', Enemy );
			GotoState('Attacking');
		}
		else
		{
			NotifyPeers( 'Retreat', Enemy );
			GotoState('Hiding');
		}
	}

	function AnimEnd()
	{
		PlayWaiting();
		bStasis = true;
	}

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		Enemy = None;
		bStasis = false;
		Acceleration = vect(0,0,0);
		SetAlertness(0.0);
	}

TurnFromWall:
	if ( NearWall(2 * CollisionRadius + 50) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
Begin:
	TweenToWaiting(0.4);
	bReadyToAttack = false;
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	SetRotation(DesiredRotation);
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_None);
KeepWaiting:
	NextAnim = '';
}

// ====================
// Hiding
// ====================

state Hiding
{
	ignores SeePlayer, EnemyNotVisible, HearNoise;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		if( bDebugLog ) Log( Self $ " Hiding::TakeDamage( " $ Damage $ ", " $ instigatedBy $ ", " $ HitLocation $ ", " $ Momentum $ ", " $ damageType $ " )" );
		TakeDamageAndNotifyGroup( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	}

	function PeerNotification( Pawn Instigator, name Message, Pawn Other )
	{
		if( bDebugLog ) Log( Self $ " Hiding::PeerNotification( " $ Instigator $ ", " $ Message $ ", " $ Other $ " )" );
		if( message == 'Attack' )
		{
			if( Other != Enemy && SetEnemy( Other ) )
			{
				LastSeenPos = Enemy.Location;
			}
			GotoState( 'Attacking' );
		}
	}

	function Timer()
	{
		bReadyToAttack = False;
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Hiding';
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		bSpecialPausing = false;
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Hiding', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Hiding', 'AdjustFromWall');
		else
		{
			Home = None;
			MoveTimer = -1.0;
		}
	}

	function PickDestination()
	{
		local NavigationPoint OldHome;
		local NavigationPoint NavPt;
		//local HomeBase Base;
		local float Distance;
		local float NavPtDist;
		local int i, j;

		// Check for state change

		if (Enemy == none || Enemy.health <= 0 || Enemy.bDeleteMe || Enemy == self)
		{
			WhatToDoNext('', '');
			return;
		}

		if( Level.NavigationPointList == None )
		{
			// This level has no navigation points.  Attack (like a cornered animal).
			RetreatThreshold = 0.0;
			AttackThreshold = 0.0;
			if (GetAttitudeToPawn(Enemy, true) != ATTITUDE_Fear)
				GotoState('Attacking');
			else
				GotoState('Hiding', 'NoWayToHide');
		}
		else
		{
			// Check current Home first
			if( Home != None ) {
				NavPtDist = VSize( Location - Home.Location );
				if( Enemy == None || !Enemy.LineOfSightTo( NavPt ) &&
					NavPtDist > CollisionRadius + Home.CollisionRadius &&
					VSize(Home.Location - Enemy.Location) > NavPtDist &&
					( ActorReachable( Home ) || pni != None && pni.GetCurrent() != None ) ) {
					return;
				}
			}

			OldHome = Home;
			Distance = 1048576.0;
			DestListSize = 0;
			if (bDebugLog) log( Self $ " PickDestination: at " $ Location );
			for( NavPt = Level.NavigationPointList; NavPt != None; NavPt = NavPt.NextNavigationPoint )
			{
				NavPtDist = VSize( Location - NavPt.Location );
				if (bDebugLog) log( Self $ " PickDestination: considering " $ NavPt $ "(" $ NavPt.Tag $ ") at " $ NavPt.Location $ " distance " $ NavPtDist $ " reachable " $ ActorReachable( NavPt ) $ " enemy " $ Enemy $ " LOS " $ Enemy.LineOfSightTo( NavPt ) );
				if( ( Enemy == None || !Enemy.LineOfSightTo( NavPt ) ) &&
					NavPtDist > CollisionRadius + NavPt.CollisionRadius )
				{
					if( NavPtDist < Distance && VSize(NavPt.Location - Enemy.Location) > NavPtDist )
					{
						if (bDebugLog) log( Self $ " PickDestination: selected " $ NavPt $ "(" $ NavPt.Tag $ ") at " $ NavPt.Location $ " reachable " $ ActorReachable( NavPt ) );
						Home = NavPt;
						Distance = NavPtDist;
					}
					if( DestListSize < 32 )
					{
						DestList[DestListSize].NavPt = NavPt;
						DestList[DestListSize].Distance = NavPtDist;
						DestList[DestListSize].bReachable = ActorReachable( NavPt );
						DestList[DestListSize].bVisibleToEnemy = false;
						DestListSize++;
					}
					else
					{
						j = 0;
						for( i = 0; i < DestListSize; i++ )
						{
							if( DestList[i].Distance > DestList[j].Distance )
							{
								j = i;
							}
						}
						DestList[j].NavPt = NavPt;
						DestList[j].Distance = NavPtDist;
						DestList[j].bReachable = ActorReachable( NavPt );
					}
				}
			}

			if( Home == OldHome && pni != None && pni.GetCurrent() != None )
			{
				if( bDebugLog ) log( Self $ " PickDestination: same home " $ Home );
				return;
			}

			if( bDebugLog ) {
				for( i = 0; i < DestListSize; i++ )
				{
					log( Self $ " PickDestination: candidate " $ DestList[i].NavPt $ " distance " $ DestList[i].Distance $ " reachable " $ DestList[i].bReachable );
				}
			}
			
			if( pni == None )
			{
				//pni = Spawn( class'PawnPathNodeIterator' );
				//pni.SetPawn( Self );
				pni = Spawn( class'PathNodeIterator' );
			}

			for( i = 0; i < DestListSize && Home != none; i++ )
			{
				// Build a path to the destination using the path nodes in the level.
				pni.BuildPath( Location, Home.Location );
				if( pni.GetFirst() == None )
				{
					// No path.  Check bReachable.
					for( j = 0; j < DestListSize; j++ )
					{
						if( DestList[j].NavPt == Home )
						{
							break;
						}
					}
					if( j < DestListSize && DestList[j].bReachable )
					{
						break;
					}
					else
					{
						if( bDebugLog ) log( Self $ " PickDestination: no path for " $ Home $ " distance " $ Distance );
						if( j < DestListSize )
						{
							// Pick next destination
							DestList[j].NavPt = None;
							DestList[j].Distance = 0;
							DestList[j].bReachable = false;
						}
						Distance = 1048576.0;
						Home = None;
						for( j = 0; j < DestListSize; j++ )
						{
							if( DestList[j].NavPt != None &&
								DestList[j].Distance < Distance &&
								VSize(DestList[j].NavPt.Location - Enemy.Location) > DestList[j].Distance )
							{
								if( bDebugLog ) log( Self $ " PickDestination: selected " $ DestList[j].NavPt $ "(" $ DestList[j].NavPt.Tag $ ") at " $ DestList[j].NavPt.Location $ " reachable " $ DestList[j].bReachable );
								Home = DestList[j].NavPt;
								Distance = DestList[j].Distance;
							}
						}
					}
				}
				else
				{
					break;
				}
			}

			if( Home == None )
			{
				if( bDebugLog ) log( Self $ " PickDestination found none. Attacking." );
				if (GetAttitudeToPawn(Enemy, true) != ATTITUDE_Fear)
					GotoState('Attacking');
				else
					GotoState('Hiding', 'NoWayToHide');
			}

			if( bDebugLog ) log( Self $ " PickDestination: path to " $ Home );
			NavPt = pni.GetFirst();
			if( NavPt == None )
			{
				if( bDebugLog ) log( Self $ " PickDestination found no path. Attacking." );
				if (GetAttitudeToPawn(Enemy, true) != ATTITUDE_Fear)
					GotoState('Attacking');
				else
					GotoState('Hiding', 'NoWayToHide');
			}

			while( NavPt != None )
			{
				if( bDebugLog ) log( Self $ "     " $ NavPt );
				NavPt = pni.GetNext();
			}
			// Get the point closest to our destination in the path that
			// we can directly reach.
			NavPt = pni.GetLast();
			while( NavPt != None && !ActorReachable( NavPt ) )
			{
				NavPt = pni.GetPrevious();
			}
			if( NavPt == None ) {
				NavPt = pni.GetFirst();
			}

			if( bDebugLog ) log( Self $ " PickDestination: found " $ Home );
		}
	}

	function ChangeDestination()
	{
		local actor oldTarget;
		local Actor path;
		local vector dist2d;
		local float zdiff;
		
		oldTarget = Home;
		PickDestination();
		if (Home == oldTarget)
		{
			Aggressiveness += 0.3;
			//log("same old target");
			GotoState('Hiding','Moving');
		}
		else
		{
			path = pni.GetCurrent();
			if( path != None ) {
				dist2d = path.Location - Location;
				zdiff = dist2d.Z;
				dist2d.Z = 0.0;
				if( (VSize(dist2d) < CollisionRadius + path.CollisionRadius) && (Abs(zdiff) < CollisionHeight + path.CollisionHeight) )
				{
					path = pni.GetNext();
				}
			}

			//path = FindPathToward(Home);
			if (path == None)
			{
				//log("no new target");
				Aggressiveness += 0.3;
			  GotoState('Hiding','Moving');
			}
			else
			{
				MoveTarget = path;
				Destination = path.Location;
			}
		}
	}

	function Bump(actor Other)
	{
		local vector VelDir, OtherDir;
		local float speed;

		//log(Other.class$" bumped "$class);
		if (Pawn(Other) != None)
		{
			/*if ( (Other == Enemy) || SetEnemy(Pawn(Other)) )
			{
				//GotoState('MeleeAttack');
			}
			else if ( (HomeBase(Home) != None)
				&& (VSize(Location - Home.Location) < HomeBase(Home).Extent) )
				ReachedHome();*/
			return;
		}
		if ( TimerRate <= 0 )
			setTimer(1.0, false);
		
		speed = VSize(Velocity);
		if ( speed > 1 )
		{
			VelDir = Velocity/speed;
			VelDir.Z = 0;
			OtherDir = Other.Location - Location;
			OtherDir.Z = 0;
			OtherDir = Normal(OtherDir);
			if ( (VelDir Dot OtherDir) > 0.9 )
			{
				Velocity.X = VelDir.Y;
				Velocity.Y = -1 * VelDir.X;
				Velocity *= FMax(speed, 200);
			}
		}
		Disable('Bump');
	}

	function ReachedHome()
	{
		local NavigationPoint OldHome;

		if (LineOfSightTo(Enemy))
		{
			OldHome = Home;
			PickDestination();
			if (Home != OldHome)
				GotoState('Hiding', 'RunAway');
			else
				GotoState('Hiding', 'NoWayToHide');
		}
		else GotoState('Hiding', 'TurnAtHome');
	}

	function PickNextSpot()
	{
		local Actor path;
		local vector dist2d;
		local float zdiff;

		if( bDebugLog ) log( Self $ " PickNextSpot()" );
		if( Home == None )
		{
			PickDestination();
			if( Home == None )
				return;
		}
		//log("find retreat spot");
		dist2d = Home.Location - Location;
		zdiff = dist2d.Z;
		dist2d.Z = 0.0;	
		if( bDebugLog ) log( Self $ " Home " $ Home $ " Distance " $ VSize(dist2d) $ " Height " $ Abs(zdiff) );
		if( VSize(dist2d) < 2 * CollisionRadius && Abs(zdiff) < CollisionHeight + Home.CollisionHeight )
		{
			if( bDebugLog ) log( Self $ " PickNextSpot() : ReachedHome " $ Home );
			ReachedHome();
		}
		else
		{
			if( ActorReachable(Home) )
			{
				if( bDebugLog ) log( Self $ " PickNextSpot() : Home " $ Home $ " reachable" );
				path = Home;
			}
			else
			{
				path = pni.GetCurrent();
				if( path != None ) {
					dist2d = path.Location - Location;
					zdiff = dist2d.Z;
					dist2d.Z = 0.0;
					if( VSize(dist2d) < CollisionRadius + path.CollisionRadius && Abs(zdiff) < CollisionHeight + path.CollisionHeight )
					{
						path = pni.GetNext();
					}
				}
			}

			if (path == None)
			{
				ChangeDestination();
			}
			else
			{
				if( bDebugLog ) log( Self $ " PickNextSpot() : " $ path $ " to Home " $ Home );
				MoveTarget = path;
				Destination = path.Location;
			}
		}
	}

	function AnimEnd()
	{
		if ( bSpecialPausing )
			PlayPatrolStop();
		else if ( bCanFire && LineOfSightTo(Enemy) )
			PlayCombatMove();
		else
			PlayRunning();
	}

	function BeginState()
	{
		bCanFire = false;
		bSpecialPausing = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

	function TurnAround()
	{
		local Vector Loc;
		local Rotator Rot;
		Loc = Location - Vector( Rotation );
		Rot = Rotator( Loc - Location );
		if( bDebugLog ) log( Self $ " TurnAround from " $ Rotation $ " to " $ Rot );
		DesiredRotation = Rot;
		SetRotation( DesiredRotation );
	}

Begin:
	if( bDebugLog ) log( Self $ " Hiding:Begin" );
	if ( bReadyToAttack && (FRand() < 0.6) )
	{
		SetTimer(TimeBetweenAttacks, false);
		bReadyToAttack = false;
	}
	SetMovementPhysics();

	if( bDebugLog ) log( Self $ " PlayFearSound();" );
	PlayFearSound();
	if( FRand() < 0.3 )
	{
		Disable( 'AnimEnd' );
		if( bDebugLog ) log( Self $ " TweenAnim('Threat', 0,1);" );
		TweenAnim( 'Threat', 0.1 );
		FinishAnim();
		if( bDebugLog ) log( Self $ " PlayAnim('Threat');" );
		PlayAnim( 'Threat' );
		TurnTo( Enemy.Location );
		if( bDebugLog ) log( Self $ " FinishAnim();" );
		FinishAnim();
		NextAnim = '';
		Enable( 'AnimEnd' );
	}
StartRun:
	if( bDebugLog ) log( Self $ " TweenToRunning(0.1);" );
	TweenToRunning(0.1);
	if( bDebugLog ) log( Self $ " WaitForLanding();" );
	WaitForLanding();
	if( bDebugLog ) log( Self $ " PickDestination();" );
	PickDestination();
	if( Home == None )
	{
		// TODO: Find some other way to run.
		if (GetAttitudeToPawn(Enemy, true) != ATTITUDE_Fear)
			GotoState('Attacking');
		else
			Goto('NoWayToHide');
	}

Landed:
	if( bDebugLog ) log( Self $ " Hiding:Landed" );
	TweenToRunning(0.1);
	
RunAway:
	if( bDebugLog ) log( Self $ " Hiding:RunAway" );
	if( Enemy != None &&
		GetAttitudeToPawn(Enemy, true) != ATTITUDE_Fear &&
		( GetGroupHealth() >= AttackThreshold * Enemy.Health / 100.0 ||
		  GetAllHealth() < AttackThreshold * Enemy.Health / 100.0 ) )
	{
		NotifyPeers( 'Attack', Enemy );
		GotoState('Attacking');
	}
	PickNextSpot();

SpecialNavig:
	if( bDebugLog ) log( Self $ " Hiding:SpecialNavig" );
	if( SpecialPause > 0.0 )
	{
/*
		if ( LineOfSightTo(Enemy) )
		{
			bFiringPaused = true;
			NextState = 'Hiding';
			NextLabel = 'Moving';
			GotoState('RangedAttack');
		}
*/
		bSpecialPausing = true;
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.25);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		bSpecialPausing = false;
		TweenToRunning(0.1);
	}

Moving:
	if( bDebugLog ) log( Self $ " Hiding:Moving" );
	if( MoveTarget == None )
	{
		if( Destination == vect(0,0,0) )
			Goto('NoWayToHide');
		else
		{
			bCanFire = false;
			if( bDebugLog ) log( Self $ " MoveTo(" $ Destination $ ")" );
			MoveTo(Destination);
		}
	}
	else
	{
		bCanFire = false;
		if( bDebugLog ) log( Self $ " MoveToward(" $ MoveTarget $ ")" );
		MoveToward(MoveTarget);
	}

	Goto('RunAway');

TakeHit:
	if( bDebugLog ) log( Self $ " Hiding:TakeHit" );
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	if( bDebugLog ) log( Self $ " Hiding:AdjustFromWall" );
	StrafeTo(Destination, Focus);
	MoveTo(Destination);
	Goto('Moving');

AdjustHome:
	if( bDebugLog ) log( Self $ " Hiding:AdjustHome" );
	MoveTo( Destination );

TurnAtHome:
	if( bDebugLog ) log( Self $ " Hiding:TurnAtHome" );
	Acceleration = vect(0,0,0);
	if( Homebase(Home) != None ) {
		if( bDebugLog ) log( Self $ " TurnTo(" $ Homebase(Home).lookdir $ ")" );
		TurnTo(Homebase(Home).lookdir);
		if( bDebugLog ) log( Self $ " Done TurnTo(" $ Homebase(Home).lookdir $ ")" );
	} else {
		TurnTo(Location - vector(Rotation)); // Was: TurnAround();
	}
	GotoState('Waiting');

Immediate:
	SetMovementPhysics();
	PlayFearSound();
	Goto( 'StartRun' );

NoWayToHide:
	Sleep(0);
	if (Enemy == none || Enemy.Health <= 0 || Enemy.bDeleteMe || Enemy == self)
		WhatToDoNext('','');
	GotoState('TacticalMove');
}

// ====================
// Retreating
// ====================

state Retreating
{
ignores SeePlayer, EnemyNotVisible, HearNoise;
ignores TakeDamage, Timer, SetFall, HitWall;
ignores Bump, AnimEnd, BeginState;

Begin:
	GotoState( 'Hiding' );
}

// ====================
// Attacking
// ====================

state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local pawn changeEn;

		if ((Enemy == None) || (Enemy.Health <= 0))
		{
			if (Orders == 'Attacking')
				Orders = '';
			WhatToDoNext('','');
			return;
		}

		if ( (AlarmTag != '') && Enemy.bIsPlayer )
		{
			if (AttitudeToPlayer > ATTITUDE_Ignore)
			{
				GotoState('AlarmPaused', 'WaitForPlayer');
				return;
			}
			else if ( (AttitudeToPlayer != ATTITUDE_Fear) || bInitialFear )
			{
				GotoState('TriggerAlarm');
				return;
			}
		}

		AttitudeToEnemy = AttitudeTo(Enemy);

		if (AttitudeToEnemy == ATTITUDE_Fear)
		{
			GotoState('Retreating');
			return;
		}
		else if (AttitudeToEnemy == ATTITUDE_Threaten)
		{
			GotoState('Threatening');
			return;
		}
		else if (AttitudeToEnemy == ATTITUDE_Friendly)
		{
			if (Enemy.bIsPlayer)
				GotoState('Greeting');
			else
				WhatToDoNext('','');
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
				if ( (Orders == 'Guarding') && !LineOfSightTo(OrderObject) )
					GotoState('Guarding');
				else if ( !bHasRangedAttack || VSize(Enemy.Location - Location)
							> 600 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 600 )
					GotoState('Hunting');
				else if ( bIsBoss || (Intelligence > BRAINS_None) )
				{
					HuntStartTime = Level.TimeSeconds;
					NumHuntPaths = 0;
					GotoState('StakeOut');
				}
				else
					WhatToDoNext('Waiting', 'TurnFromWall');
				return;
			}
		}	
		
		else if ( (TeamLeader != None) && TeamLeader.ChooseTeamAttackFor(self) )
			return;
		
		if (bReadyToAttack)
		{
			////log("Attack!");
			Target = Enemy;
			If (VSize(Enemy.Location - Location) <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			{
				GotoState('MeleeAttack');
				return;
			}
			else if (bMovingRangedAttack)
				SetTimer(TimeBetweenAttacks, False);
			else if (bHasRangedAttack && (bIsPlayer || enemy.bIsPlayer) && CanFireAtEnemy() )
			{
				if (!bIsPlayer || (2.5 * FRand() > Skill) )
				{
					GotoState('RangedAttack');
					return;
				}
			}
		}
			
		//decide whether to charge or make a tactical move
		if ( !bHasRangedAttack )
			GotoState('Charging');
		else
			GotoState('TacticalMove');
		//log("Next state is "$state);
	}
	
	//EnemyNotVisible implemented so engine will update LastSeenPos
	function EnemyNotVisible()
	{
		////log("enemy not visible");
	}

	function Timer()
	{
		bReadyToAttack = True;
	}

	function BeginState()
	{
		if ( TimerRate <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false);
		if (Physics == PHYS_None)
			SetMovementPhysics();
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType )
	{
		if( bDebugLog ) Log( Self $ " Attacking::TakeDamage( " $ Damage $ ", " $ instigatedBy $ ", " $ HitLocation $ ", " $ Momentum $ ", " $ damageType $ " )" );
		TakeDamageAndNotifyGroup( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	}
	function PeerNotification( Pawn Instigator, name Message, Pawn Other )
	{
		if( bDebugLog ) Log( Self $ " Attacking::PeerNotification( " $ Instigator $ ", " $ Message $ ", " $ Other $ ")" );
		//'Attack'
		if( message == 'Retreat' )
		{
			if (Other != Enemy && SetEnemy(Other))
				LastSeenPos = Enemy.Location;
			if (Enemy != none && AttitudeTo(Enemy) <= ATTITUDE_Hate)
				GotoState('Hiding');
		}
	}

Begin:
	//log(class$" choose Attack");
	ChooseAttackMode();
}

// ====================
// Charging
// ====================

state Charging
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType )
	{
		if( bDebugLog ) Log( Self $ " Charging::TakeDamage( " $ Damage $ ", " $ instigatedBy $ ", " $ HitLocation $ ", " $ Momentum $ ", " $ damageType $ " )" );
		TakeDamageAndNotifyGroup( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	}
	function PeerNotification( Pawn Instigator, name Message, Pawn Other )
	{
		if( bDebugLog ) Log( Self $ " Charging::PeerNotification( " $ Instigator $ ", " $ Message $ ", " $ Other $ ")" );
		//'Attack'
		if( message == 'Retreat' )
		{
			if (Other != Enemy && SetEnemy(Other))
				LastSeenPos = Enemy.Location;
			if (Enemy != none && AttitudeTo(Enemy) <= ATTITUDE_Hate)
				GotoState('Hiding');
		}
	}

/*

AdjustFromWall:
	StrafeTo( Destination, Focus );
	Goto( 'CloseIn' );

ResumeCharge:
	PlayRunning();
	Goto( 'Charge' );

Begin:
	TweenToRunning( 0.15 );

Charge:
	bFromWall = false;

CloseIn:
	if( Enemy == None || Enemy.Health <= 0 )
	{
		GotoState( 'Attacking' );
	}

	if( Enemy.Region.Zone.bWaterZone )
	{
		if( !bCanSwim )
		{
			GotoState( 'TacticalMove', 'NoCharge' );
		}
	}
	else if( !bCanFly && !bCanWalk )
	{
		GotoState( 'TacticalMove', 'NoCharge' );
	}

	if( Physics == PHYS_Falling )
	{
		DesiredRotation = Rotator( Enemy.Location - Location );
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if( Intelligence <= BRAINS_Reptile || actorReachable( Enemy ) )
	{
		bCanFire = true;
		if( FRand() < 0.3 )
		{
			PlayThreateningSound();
		}
		MoveToward( Enemy );
		if( bFromWall )
		{
			bFromWall = false;
			if( PickWallAdjust() )
			{
				StrafeFacing( Destination, Enemy );
			}
			else
			{
				GotoState( 'TacticalMove', 'NoCharge' );
			}
		}
	}
	else
	{
NoReach:
		bCanFire = false;
		bFromWall = false;
		//log( "route to enemy " $ Enemy );
		if( !FindBestPathToward( Enemy ) )
		{
			Sleep( 0.0 );
			GotoState( 'TacticalMove', 'NoCharge' );
		}
SpecialNavig:
		if( SpecialPause > 0.0 )
		{
			bFiringPaused = true;
			NextState = 'Charging';
			NextLabel = 'Moving';
			GotoState( 'RangedAttack' );
		}
Moving:
		if( VSize( MoveTarget.Location - Location ) < 2.5 * CollisionRadius )
		{
			bCanFire = true;
			StrafeFacing( MoveTarget.Location, Enemy );
		}
		else
		{
			if( !bCanStrafe || !LineOfSightTo( Enemy ) ||
				( Skill - 2 * FRand() + ( Normal( Enemy.Location - Location - vect(0,0,1) * ( Enemy.Location.Z - Location.Z ) ) 
					Dot Normal( MoveTarget.Location - Location - vect(0,0,1) * ( MoveTarget.Location.Z - Location.Z ) ) ) < 0 ) )
			{
				if( GetAnimGroup( AnimSequence ) == 'MovingAttack' )
				{
					AnimSequence = '';
					TweenToRunning( 0.12 );
				}
				MoveToward( MoveTarget );
			}
			else
			{
				bCanFire = true;
				StrafeFacing( MoveTarget.Location, Enemy );
			}
			if( !bFromWall && FRand() < 0.5 )
			{
				PlayThreateningSound();
			}
		}
	}
	//log("finished move");
	if( VSize( Location - Enemy.Location ) < CollisionRadius + Enemy.CollisionRadius + MeleeRange )
	{
		Goto( 'GotThere' );
	}
	if( bIsPlayer || !bFromWall && bHasRangedAttack && FRand() > CombatStyle + 0.1 )
	{
		GotoState( 'Attacking' );
	}
	MoveTimer = 0.0;
	bFromWall = false;
	Goto( 'CloseIn' );

GotThere:
	////log("Got to enemy");
	Target = Enemy;
	GotoState( 'MeleeAttack' );

TakeHit:
	TweenToRunning( 0.12 );
	if( MoveTarget == Enemy )
	{
		bCanFire = true;
		MoveToward( MoveTarget );
	}

	Goto( 'Charge' );

*/
}

// ====================
// MeleeAttack
// ====================

state MeleeAttack
{
	ignores SeePlayer, HearNoise, Bump; 
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType )
	{
		if( bDebugLog ) Log( Self $ " MeleeAttack::TakeDamage( " $ Damage $ ", " $ instigatedBy $ ", " $ HitLocation $ ", " $ Momentum $ ", " $ damageType $ " )" );
		TakeDamageAndNotifyGroup( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	}
	function PeerNotification( Pawn Instigator, name Message, Pawn Other )
	{
		if( bDebugLog ) Log( Self $ " MeleeAttack::PeerNotification( " $ Instigator $ ", " $ Message $ ", " $ Other $ ")" );
		if( message == 'Retreat' )
		{
			if (Other != Enemy && SetEnemy(Other))
				LastSeenPos = Enemy.Location;
			if (Enemy != none && AttitudeTo(Enemy) <= ATTITUDE_Hate)
				GotoState('Hiding');
		}
	}


Begin:
	if ( Enemy != None )
		DesiredRotation = Rotator(Enemy.Location - Location);
	if ( skill < 3 )
		TweenToFighter(0.15);
	else
		TweenToFighter(0.11);

FaceTarget:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Target = Enemy;
	Disable('AnimEnd');
	Sleep(0.0);
	//Acceleration = vect(0,0,0); //stop
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();
	OldAnimRate = 0;	// force no tween

	if( !InMeleeRange( Enemy ) )
	{
		GotoState( 'Charging' );
	}

ReadyToAttack:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Target = Enemy;
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayMeleeAttack();
	Enable('AnimEnd');
	Sleep(0.0);
Attacking:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	if (NeedToTurn(Enemy.Location))
	{
		TurnToward(Enemy);
		Goto('Attacking');
	}
DoneAttacking:
	Disable('AnimEnd');
	Sleep(0.0);
	KeepAttacking();
	if ( FRand() < 0.3 - 0.1 * skill )
	{
		Acceleration = vect(0,0,0); //stop
		DesiredRotation = Rotator(Enemy.Location - Location);
		PlayChallenge();
		FinishAnim();
		TweenToFighter(0.1);
	}
	Goto('FaceTarget');

}

// ====================
// TakeHit
// ====================

state TakeHit
{
ignores seeplayer, hearnoise, bump, hitwall;

	function Landed(vector HitNormal)
	{
		local float landVol;

		if ( AnimSequence == 'Death2' )
		{
			landVol = 0.75 + Velocity.Z * 0.004;
			LandVol = Mass * landVol * landVol * 0.01;
			//PlaySound(sound'thump', SLOT_Interact, landVol);
			GotoState('FallingState', 'RiseUp');
		}
		else
			Super.Landed(HitNormal);
	}

	function PlayTakeHit(float tweentime, vector HitLoc, int damage)
	{
		if ( AnimSequence != 'Death2' )
			Global.PlayTakeHit(tweentime, HitLoc, damage);
	}

	function BeginState()
	{
		Super.BeginState();
		If ( AnimSequence == 'Death2' )
			GotoState('FallingState');
	}	
}

state FallingState
{
ignores Bump, Hitwall, HearNoise, WarnTarget;

	function Landed(vector HitNormal)
	{
		local float landVol;

		if ( AnimSequence == 'Death2' )
		{
			landVol = 0.75 + Velocity.Z * 0.004;
			LandVol = Mass * landVol * landVol * 0.01;
			//PlaySound(sound'Thump', SLOT_Interact, landVol);
			GotoState('FallingState', 'RiseUp');
		}
		else if ( (AnimSequence == 'LeftDodge') || (AnimSequence == 'RightDodge') )
		{
			landVol = Velocity.Z/JumpZ;
			landVol = 0.008 * Mass * landVol * landVol;
			if ( !FootRegion.Zone.bWaterZone )
				//PlaySound(Land, SLOT_Interact, FMin(20, landVol));
			GotoState('FallingState', 'FinishDodge');
		}
		else
			Super.Landed(HitNormal);
	}

	function PlayTakeHit(float tweentime, vector HitLoc, int damage)
	{
		if ( AnimSequence != 'Death2' )
			Global.PlayTakeHit(tweentime, HitLoc, damage);
	}

LongFall:
	if ( AnimSequence == 'Death2' )
	{
		Sleep(1.5);
		Goto('RiseUp');
	}
	if ( bCanFly )
	{
		SetPhysics(PHYS_Flying);
		Goto('Done');
	}
	Sleep(0.7);
	TweenToFighter(0.2);
	TweenToFalling();
	if ( Velocity.Z > -150 ) //stuck
	{
		SetPhysics(PHYS_Falling);
		if ( Enemy != None )
			Velocity = groundspeed * normal(Enemy.Location - Location);
		else
			Velocity = groundspeed * VRand();

		Velocity.Z = FMax(JumpZ, 250);
	}
	Goto('LongFall');
RiseUp:
	FinishAnim();
	bCanDuck = false;
	DesiredRotation = Rotation;
	Acceleration = vect(0,0,0);
	Sleep(1.0 + 6 * FRand());
	PlayAnim('GetUp', 0.7);
FinishDodge:
	FinishAnim();
	bCanDuck = true;
	Goto('Done');
}

state Hunting
{
ignores EnemyNotVisible;

	function BeginState()
	{
		bCanSwim = true;
		Super.BeginState();
	}

	function EndState()
	{
		if ( !Region.Zone.bWaterZone )
			bCanSwim = false;
		Super.EndState();
	}
}

//=========================================================================================

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local bool duckLeft, bSuccess;
	local actor HitActor;

	//log("duck");
				
	duckDir.Z = 0;
	duckLeft = !bReversed;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	if ( !bSuccess )
	{
		duckLeft = !duckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	}
	if ( !bSuccess )
		return;
	
	if ( HitActor == None )
		HitLocation = Location + 200 * duckDir;
	HitActor = Trace(HitLocation, HitNormal, HitLocation - MaxStepHeight * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return;
		
	//log("good duck");

	SetFall();
	/*
	if ( duckLeft )
		PlayAnim('LeftDodge', 1.35);
	else
		PlayAnim('RightDodge', 1.35);
	*/
	PlayAnim('Jump');
	Velocity = duckDir * GroundSpeed;
	Velocity.Z = 200;
	SetPhysics(PHYS_Falling);
	GotoState('FallingState','Ducking');
}	

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor1, HitActor2;
	local float EnemyDist;
		
	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}
	
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + 0.9 * CollisionRadius * X + CollisionRadius * Y + 0.4 * CollisionHeight * Z;
	HitActor1 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);
	if ( (HitActor1 != Enemy) && (Pawn(HitActor1) != None)
		&& (AttitudeTo(Pawn(HitActor1)) > ATTITUDE_Ignore) )
		return false;
		
	projStart = Location + 0.9 * CollisionRadius * X - CollisionRadius * Y + 0.4 * CollisionHeight * Z;
	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor2 != Enemy) && (Pawn(HitActor2) != None)
		&& (AttitudeTo(Pawn(HitActor2)) > ATTITUDE_Ignore) )
		return false;

	if ( (HitActor2 == None) || (HitActor2 == Enemy) || (HitActor1 == None) || (HitActor1 == Enemy)
		|| (Pawn(HitActor2) != None) || (Pawn(HitActor1) != None) )
		return true;

	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return ( (HitActor2 == None) || (HitActor2 == Enemy)
			|| ((Pawn(HitActor2) != None) && (AttitudeTo(Pawn(HitActor2)) <= ATTITUDE_Ignore)) );
}

function PlayCock()
{
	//PlaySound(Blade, SLOT_Interact,,,800);
}

function PlayPatrolStop()
{
	local float decision;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	decision = FRand();
	if (decision < 0.05)
	{
		SetAlertness(-0.5);
		//PlaySound(HairFlip, SLOT_Talk);
		//PlayAnim('HairFlip', 0.4 + 0.3 * FRand());
	}
	else
	{
		SetAlertness(0.2);	
		//LoopAnim('Breath', 0.3 + 0.6 * FRand());
		LoopAnim('idle', 0.3 + 0.6 * FRand());
	}
}

function PlayChallenge()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	PlayThreateningSound();
	//PlayAnim('Fighter', 0.8 + 0.5 * FRand(), 0.1);
	PlayAnim( 'Threat', 0.8 + 0.5 * FRand(), 0.1 );
}

function PlayRunning()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;

	DesiredSpeed = MaxDesiredSpeed;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	if (Focus == Destination)
	{
		//LoopAnim('Run', -1.0/GroundSpeed,, 0.5);
		LoopAnim('Run', -2.0/GroundSpeed,, 0.5);
		return;
	}	
	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	moveDir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot moveDir;
	if (strafeMag > 0.8)
		//LoopAnim('Run', -1.0/GroundSpeed,, 0.5);
		LoopAnim('Run', -2.0/GroundSpeed,, 0.5);
	else if (strafeMag < -0.8)
		//LoopAnim('Run', -1.0/GroundSpeed,, 0.5);
		LoopAnim('Run', -2.0/GroundSpeed,, 0.5);
	else
	{
		Y = (lookDir Cross vect(0,0,1));
		if ((Y Dot (Dest2D - Loc2D)) > 0)
		{
			if ( (AnimSequence == 'StrafeRight') || (AnimSequence == 'StrafeRightFr') )
				//LoopAnim('StrafeRight', -2.5/GroundSpeed,, 1.0);
				LoopAnim( 'Run', -5.0/GroundSpeed,, 1.0 );
			else
				//LoopAnim('StrafeRight', -2.5/GroundSpeed,0.1, 1.0);
				LoopAnim( 'Run', -5.0/GroundSpeed,0.1, 1.0 );
		}
		else
		{
			if ( (AnimSequence == 'StrafeLeft') || (AnimSequence == 'StrafeLeftFr') )
				//LoopAnim('StrafeLeft', -2.5/GroundSpeed,, 1.0);
				LoopAnim( 'Run', -5.0/GroundSpeed,, 1.0 );
			else
				//LoopAnim('StrafeLeft', -2.5/GroundSpeed,0.1, 1.0);
				LoopAnim( 'Run', -5.0/GroundSpeed,0.1, 1.0 );
		}
	}
}

function PlayMovingAttack()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;

	if (Region.Zone.bWaterZone)
	{
		LoopAnim('RunBite', -1.0/WaterSpeed,, 0.4);
		return;
	}
	DesiredSpeed = MaxDesiredSpeed;

	if (Focus == Destination)
	{
		LoopAnim('RunBite', -2.0/GroundSpeed,, 0.4);
		return;
	}	
	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	moveDir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot moveDir;
	if (strafeMag > 0.8)
		LoopAnim('RunBite', -2.0/GroundSpeed,, 0.4);
	else if (strafeMag < -0.8)
		LoopAnim( 'RunBite', -2.0/GroundSpeed,, 0.4 );
	else
	{
		MoveTimer += 0.2;
		DesiredSpeed = 0.6;
		Y = (lookDir Cross vect(0,0,1));
		if ((Y Dot (Dest2D - Loc2D)) > 0)
		{
			if ( (AnimSequence == 'StrafeRight') || (AnimSequence == 'StrafeRightFr') )
				//LoopAnim('StrafeRightFr', -2.5/GroundSpeed,, 1.0);
				LoopAnim( 'RunBite', -5.0/GroundSpeed,, 1.0 );
			else
				//LoopAnim('StrafeRightFr', -2.5/GroundSpeed,0.1, 1.0);
				LoopAnim( 'RunBite', -5.0/GroundSpeed,0.1, 1.0 );
		}
		else
		{
			if ( (AnimSequence == 'StrafeLeft') || (AnimSequence == 'StrafeLeftFr') )
				//LoopAnim('StrafeLeftFr', -2.5/GroundSpeed,, 1.0);
				LoopAnim( 'RunBite', -5.0/GroundSpeed,, 1.0 );
			else
				//LoopAnim('StrafeLeftFr', -2.5/GroundSpeed,0.1, 1.0);
				LoopAnim( 'RunBite', -5.0/GroundSpeed,0.1, 1.0 );
		}
	}
}

function PlayThreatening()
{
	local float decision, animspeed;

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	decision = FRand();
	animspeed = 0.4 + 0.6 * FRand();
	
	if ( decision < 0.7 )
		PlayAnim('Idle', animspeed, 0.3);
	else if ( decision < 0.9 )
	{
		PlayThreateningSound();
		PlayAnim('Threat', animspeed, 0.3);
	}
	else
	{
		//PlaySound(HairFlip, SLOT_Talk);
		PlayAnim('Threat', animspeed, 0.3);
	}	
}

function PlayVictoryDance()
{
	//PlaySound(HairFlip, SLOT_Talk);
	PlayAnim('Threat', 0.6, 0.1);
}

defaultproperties
{
	BiteDamage=5
	AttackThreshold=300.000000
	RetreatThreshold=150.000000
	GroupRadius=512.000000
	HitSound3=Sound'UPak.Predator.hurt3'
	Bite=Sound'UPak.Predator.Bite'
	footstep=Sound'UPak.Predator.step1'
	Footstep2=Sound'UPak.Predator.step2'
	fear2=Sound'UPak.Predator.fear2'
	fear3=Sound'UPak.Predator.fear3'
	GroupHealth=100.000000
	AllHealth=100.000000
	CarcassType=Class'UPak.PredatorCarcass'
	RefireRate=0.500000
	bIsWuss=True
	bLeadTarget=False
	bWarnTarget=False
	Acquire=Sound'UPak.Predator.hate'
	Fear=Sound'UPak.Predator.fear1'
	Roam=Sound'UPak.Predator.Idle'
	Threaten=Sound'UPak.Predator.hate'
	MeleeRange=60.000000
	GroundSpeed=525.000000
	AccelRate=1200.000000
	JumpZ=225.000000
	PeripheralVision=-1.000000
	UnderWaterTime=-1.000000
	AttitudeToPlayer=ATTITUDE_Ignore
	HitSound1=Sound'UPak.Predator.hurt1'
	HitSound2=Sound'UPak.Predator.hurt2'
	Die=Sound'UPak.Predator.Die'
	CombatStyle=1.000000
	DrawType=DT_Mesh
	Mesh=LodMesh'UPak.Predator'
	AmbientSound=Sound'UPak.Predator.Idle'
	TransientSoundVolume=3.000000
	CollisionRadius=16.000000
	CollisionHeight=32.000000
	Mass=50.000000
	Buoyancy=50.000000
	RotationRate=(Pitch=3072,Yaw=120000,Roll=2048)
	bIsCrawler=true
	bSpecialAttitudeToPlayer=false
}
