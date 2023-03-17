//=============================================================================
// ScriptedPawn.
//=============================================================================
class ScriptedPawn extends Pawn
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Generic\land1.wav" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.wav" NAME="LSplash" GROUP="Generic"

var(Pawn) class<carcass> CarcassType;

// Advanced AI attributes.
var(AI) name		TeamTag;
var ScriptedPawn		TeamLeader;
var int			Team;
var int			TeamID;
var(Orders) name		Orders;		//orders a creature is carrying out
							// will be initial state, plus creature will attenmpt
							//to return to this state
var(Orders) name		OrderTag;		// tag of object referred to by orders
var actor			OrderObject;	// object referred to by orders (if applicable)
var(Combat) float		TimeBetweenAttacks; // seconds - modified by difficulty
var name			NextAnim;		// used in states with multiple, sequenced animations
var(Combat) float		Aggressiveness;	//0.0 to 1.0 (typically)
var Pawn			Hated;
var(Combat) float		ReFireRate;		//chance of shooting multiple times in one attack
var Pawn			OldEnemy;
var Pawn			FollowingPawn;
var float			RoamStartTime;
var int			numHuntPaths;
var float			HuntStartTime;
var vector			HidingSpot;
var(Movement) float	WalkingSpeed;
var(AI) name		FirstHatePlayerEvent; // event when first hate player
var(AI) float		BonusSkill; // 227j: Bonus difficulty settings (0-3)

//AI flags
var		bool		bReadyToAttack;	// can attack again
var(Combat) bool		bHasRangedAttack;	// can attack from beyond melee range
var(Combat) bool		bMovingRangedAttack; //can perform ranged attack while moving
var		bool		bCanFire;		//used by TacticalMove and Charging states
var(AI)	bool		bQuiet;
var    	bool		bTeamSpeaking;
var(AI)	bool		bTeamLeader;
var(AI)	bool		bIgnoreFriends;  	//don't react to friend's noises (and make their enemy yours)
var 		bool		bCanSpeak;
var	nowarn	bool 		bIsSpeaking;
var 		bool		bCanBePissed;
var		bool		bCanDuck;
var(AI)	bool		bHateWhenTriggered;
var(Orders) bool		bDelayedPatrol;
var		bool		bStrafeDir;
var(Combat) bool		bIsWuss;		// always takes hit
var(Combat) bool		bLeadTarget;	// lead with projectile attack
var(Combat) bool		bWarnTarget;	// warn target when projectile attack
var		bool		bFirstShot;
var		bool		bCrouching;
var		bool		bFirstHatePlayer;
var		bool		bClearShot;
var		bool		bSpecialGoal;
var		bool		bChangeDir;		// tactical move boolean
var		bool		bMoraleBoosted;
var		bool		bFiringPaused;
var		bool		bSpecialPausing;
var		bool		bGreenBlood;
var		bool		bFrustrated;
var		bool		bInitialFear;
var(AI)	bool		bIsPackHunter; // 227j: AI hint for higher difficulty levels, request backup when needed.
var(AI)	bool		bIsBoss;
var(Orders) bool		bNoWait;		// Friendly creature no wait going to alarm
var(AI)	bool		bTriggerAutoTargeting; // On trigger, make this monsters auto-target enemy species on sight (not only player).

var(Combat) class<actor> RangedProjectile;
var(Combat)	float		ProjectileSpeed;
var     name		LastPainAnim;
var		float		LastPainTime;

var ScriptedPawn	BackupPlan; // 227j: For packhunter AI.

// Headshot detection.
var(HeadRegion) vector	HeadOffset;
var(HeadRegion) float	HeadRadius;

// Sounds
var(Sounds)	sound	Acquire;
var(Sounds)	sound	Fear;
var(Sounds)	sound	Roam;
var(Sounds)	sound	Threaten;

function PreBeginPlay()
{
	local float newskill;
	
	super.PreBeginPlay();

	if ( Level.Game.bVeryLowGore )
		bGreenBlood = true;

	if ( Skill > 2 )
		bLeadTarget = true;
	else if ( (Skill == 0) && (Health < 500) )
	{
		bLeadTarget = false;
		ReFireRate = 0.75 * ReFireRate;
	}

	if ( bIsBoss )
		Health = Health + 0.15 * Skill * Health;

	bInitialFear = (AttitudeToPlayer == ATTITUDE_Fear);

	if (Level.Game.Difficulty > 3)
	{
		if( Class'GameInfo'.Default.bUseClassicBalance && BonusSkill<=0.f )
		{
			newskill = FClamp(Level.Game.Difficulty-3, 1, 3);
			if( Health > 9 ) // give weaker pawns a small boost
				Health += (100 *newskill) / Health;
			Health *= 1+(0.15*newskill);
			SightRadius += 100*newskill;
			ProjectileSpeed += 100*newskill;
			RotationRate.Yaw *= 1+(0.15*newskill);
			AccelRate += 100*newskill;
			GroundSpeed += 10*newskill;
			WaterSpeed += 10*newskill;
			AirSpeed += 10*newskill;
			DamageScaling = Default.DamageScaling+(0.5*newskill);
		}
		else BonusSkill = FMin(BonusSkill+Level.Game.Difficulty-2.f, 3.f);
	}
	if (BonusSkill > 0.f)
	{
		if( AttitudeToPlayer==ATTITUDE_Friendly ) // Make Nalis extra weak to damage.
			Health *= (1.f - (BonusSkill*0.25f));
		else
		{
			if( Level.NetMode!=NM_StandAlone )
			{
				if (Health > 9 ) // give weaker pawns a small boost
					Health += (100.f * BonusSkill) / Health;
				Health *= 1.f + (0.15f * BonusSkill);
			}
			SightDistanceMulti *= (1.f + BonusSkill*0.5f);
			ProjectileSpeed += (BonusSkill * 100.f);
			RotationRate.Yaw *= (1.f+ BonusSkill*0.25f);
			AccelRate += (100.f*BonusSkill);
			groundspeed += (10.f*BonusSkill);
			waterspeed += (10.f*BonusSkill);
			airspeed += (10.f*BonusSkill);
			DamageScaling *= (1.f + BonusSkill*0.25f);
			bQuiet = bQuiet || (FRand()<BonusSkill*0.2f);
		}
	}
}

simulated function BeginPlay()
{
	// Dummy stub for compatibility.
	Super.BeginPlay();
}

// 227g: Headshot detection implemention.
simulated function bool IsHeadShot( vector HitLocation, vector TraceDir )
{
	if( !Class'SinglePlayer'.Default.bUseExactHSDetection || HeadRadius<=0 )
		return (!bIsBoss && Super.IsHeadShot(HitLocation,TraceDir));
	return CheckWithHeadRegion(HitLocation,TraceDir);
}
simulated final function bool CheckWithHeadRegion( vector HitLocation, vector TraceDir )
{
	local vector HeadPos,M,diff;
	local float t,DotMM,Distance;

	HeadPos = Location+PrePivot+((HeadOffset*DrawScale) >> Rotation);

	M = TraceDir * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

	// Find Point-Line Squared Distance
	diff = HeadPos - HitLocation;
	t = M Dot diff;
	if (t > 0)
	{
		DotMM = M dot M;
		if (t < DotMM)
		{
			t = t / DotMM;
			diff = diff - (t * M);
		}
		else
		{
			t = 1;
			diff -= M;
		}
	}
	else t = 0;
	Distance = Sqrt(diff Dot diff);
	return (Distance < (HeadRadius * DrawScale));
}

//*********************************************************************
/* Default ScriptedPawn location specific take hits  - make sure pain frames are named right */
function PlayGutHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'GutHit') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('GutHit', tweentime);
}

function PlayHeadHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'HeadHit') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('HeadHit', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'LeftHit') )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('LeftHit', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'RightHit') )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}

function bool StrafeFromDamage(vector momentum, float Damage,name DamageType, bool bFindDest);

//**********************************************************************

function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
	local Bubble1 bub;
	local bool bOptionalTakeHit;
	local vector BloodOffset;
	local blood2 b;

	if (Damage > 1) //spawn some blood
	{
		if (damageType == 'Drowned')
		{
			bub = spawn(class 'Bubble1',,, Location
						+ 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
			if (bub != None)
				bub.DrawScale = FRand()*0.06+0.04;
		}
		else if ( damageType != 'Corroded' )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;
			b = spawn(class 'BloodBurst',,,hitLocation + BloodOffset, rotator(BloodOffset));
			if ( bGreenBlood && (b != None) ) b.GreenBlood();
			if ( Level.bHighDetailMode )
			{
				if ( bGreenBlood )
					spawn(class'GreenBloodPuff',,, hitLocation + BloodOffset);
				else
					spawn(class'BloodPuff',,, hitLocation + BloodOffset);
			}
		}
	}

	if ( (Weapon != None) && Weapon.bPointing && !bIsPlayer )
	{
		bFire = 0;
		bAltFire = 0;
	}

	bOptionalTakeHit = bIsWuss || ( (Level.TimeSeconds - LastPainTime > 0.3 + 0.25 * skill)
									&& (Damage * FRand() > 0.08 * Health) && (Skill < 3)
									&& (GetAnimGroup(AnimSequence) != 'MovingAttack')
									&& (GetAnimGroup(AnimSequence) != 'Attack') );
	if ( (!bIsPlayer || (Weapon == None) || !Weapon.bPointing)
			&& (bOptionalTakeHit || (MomentumZ > 140) || (bFirstShot && (Damage > 0.015 * (skill + 6) * Health))
				|| (Damage * FRand() > (0.17 + 0.04 * skill) * Health)) )
	{
		PlayTakeHitSound(Damage, damageType, 3);
		PlayHitAnim(HitLocation, Damage);
	}
	else if (NextState == 'TakeHit')
	{
		PlayTakeHitSound(Damage, damageType, 2);
		NextState = '';
	}
}

function PlayHitAnim(vector HitLocation, float Damage)
{
	bFirstShot = false;
	NextAnim = '';
	NextState = 'TakeHit';
	PlayTakeHit(0.08, hitLocation, Damage);
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType)
{
	local Bubble1 bub;
	local BloodBurst b;

	if ( Region.Zone.bDestructive && (Region.Zone.ExitActor != None) )
		Spawn(Region.Zone.ExitActor);
	if (HeadRegion.Zone.bWaterZone)
	{
		bub = spawn(class 'Bubble1',,, Location
					+ 0.3 * CollisionRadius * vector(Rotation) + 0.8 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
		bub = spawn(class 'Bubble1',,, Location
					+ 0.2 * CollisionRadius * VRand() + 0.7 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
		bub = spawn(class 'Bubble1',,, Location
					+ 0.3 * CollisionRadius * VRand() + 0.6 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
	}
	if ( (damageType != 'Burned') && (damageType != 'Corroded')
			&& (damageType != 'Drowned') && (damageType != 'Fell') )
	{
		b = spawn(class 'BloodBurst',self,'', hitLocation);
		if ( bGreenBlood && (b != None) )
			b.GreenBlood();
	}
}

function PlayChallenge()
{
	TweenToFighter(0.1);
}

function ZoneChange(ZoneInfo newZone)
{
	local vector jumpDir;

	if ( newZone.bWaterZone )
	{
		if (!bCanSwim)
			MoveTimer = -1.0;
		else if (Physics != PHYS_Swimming)
		{
			if (Physics != PHYS_Falling)
				PlayDive();
			setPhysics(PHYS_Swimming);
		}
	}
	else if (Physics == PHYS_Swimming)
	{
		if ( bCanFly )
			SetPhysics(PHYS_Flying);
		else
		{
			SetPhysics(PHYS_Falling);
			if ( bCanWalk && (Abs(Acceleration.X) + Abs(Acceleration.Y) > 0) && CheckWaterJump(jumpDir) )
				JumpOutOfWater(jumpDir);
		}
	}
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = 380; //set here so physics uses this for remainder of tick
	PlayOutOfWater();
	bUpAndOut = true;
}

function bool Gibbed(name damageType)
{
	if ( (damageType == 'decapitated') || (damageType == 'shot') )
		return false;
	return ( !bIsBoss && (Mass < 500) && ((Health < -0.5 * (Default.Health + Mass)) ||
										  ((Health < -25 - 0.1 * (Default.Health + Mass) * (0.2 + FRand())) && (FRand() < 0.8))) );
}

singular function SpawnGibbedCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
	}
}

singular function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
		carc.Initfor(self);

	return carc;
}

function JumpOffPawn()
{
	Velocity += (60 + CollisionRadius) * VRand();
	Velocity.Z = 180 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bJumpOffPawn = true;
	if (health > 0 && !bDeleteme)
		SetFall();
}
//-----------------------------------------------------------------------------
// Sound functions

function Speak()
{
	//implemented in speaking subclasses
}

function SpeakTo(ScriptedPawn Other)
{
	//implemented in speaking subclasses
}

function SpeakOrderTo(ScriptedPawn TeamMember)
{
	//implemented in speaking subclasses
}

function PlayAcquisitionSound()
{
	if (Acquire != None)
		PlaySound(Acquire, SLOT_Talk,, true);
}

function PlayFearSound()
{
	if (Fear != None)
		PlaySound(Fear, SLOT_Talk,, true);
}

function PlayRoamingSound()
{
	if ( (Threaten != None) && (FRand() < 0.4) )
		PlaySound(Threaten, SLOT_Talk,, true);
	if (Roam != None)
		PlaySound(Roam, SLOT_Talk,, true);
}

function PlayThreateningSound()
{
	if (Threaten == None) return;
	if (FRand() < 0.6)
		PlaySound(Threaten, SLOT_Talk,, true);
	else
		PlaySound(Acquire, SLOT_Talk,, true);
}

//=============================================================================

// re-implement SetMovementPhysics() in subclass for flying and swimming creatures
function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;

	SetPhysics(PHYS_Walking);
}

function FearThisSpot(Actor aSpot)
{
	Acceleration = vect(0,0,0);
	MoveTimer = -1.0;
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
final function SetAlertness(float NewAlertness)
{
	if ( Alertness != NewAlertness )
	{
		PeripheralVision += 0.707 * (Alertness - NewAlertness); //Used by engine for SeePlayer()
		HearingThreshold += 0.5 * (Alertness - NewAlertness); //Used by engine for HearNoise()
		Alertness = NewAlertness;
	}
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	if( BonusSkill<=1.f )
		bQuiet = false;
	Enemy = None;
	if (!IsAlivePawn(OldEnemy) || OldEnemy == self)
		OldEnemy = None;

	if ( OldEnemy != None )
	{
		Enemy = OldEnemy;
		OldEnemy = None;
		GotoState('Attacking');
	}
	else if (Orders == 'Patroling')
		GotoState('Patroling');
	else if (Orders == 'Guarding')
		GotoState('Guarding');
	else if ( Orders == 'Ambushing' )
		GotoState('Ambushing','FindAmbushSpot');
	else if ( (LikelyState != '') && (FRand() < 0.35) )
		GotoState(LikelyState, LikelyLabel);
	else
		StartRoaming();
}

// check who is roaming/wandering - turn off oldest if too many
function StartRoaming()
{
	local float oldestRoamTime;
	local pawn oldestRoamer, next;
	local int numRoamers;

	RoamStartTime = Level.TimeSeconds;
	oldestRoamTime = RoamStartTime;
	oldestRoamer = None;
	numRoamers = 0;
	next = Level.PawnList;
	while (next != None)
	{
		if ( (ScriptedPawn(next) != None) && !next.bIsPlayer
				&& ((next.IsInState('Roaming')) || (next.IsInState('Wandering'))) )
		{
			numRoamers++;
			if ( (ScriptedPawn(next).RoamStartTime < oldestRoamTime) || (oldestRoamer == None) )
			{
				oldestRoamer = next;
				oldestRoamTime = ScriptedPawn(next).RoamStartTime;
			}
		}
		next = next.nextPawn;
	}
	if ( numRoamers > 4 )
		oldestRoamer.GotoState('Waiting', 'TurnFromWall');
	OrderObject = None;
	OrderTag = '';
	GotoState('Roaming');
}

function Bump(actor Other)
{
	local vector VelDir, OtherDir;
	local float speed;

	if ( Health <= 0 || bDeleteme)
		return;
	if ( Enemy != None )
	{
		if (Other == Enemy)
		{
			GotoState('MeleeAttack');
			return;
		}
		else if ( (Pawn(Other) != None) && SetEnemy(Pawn(Other)) )
		{
			GotoState('MeleeAttack');
			return;
		}
	}
	else
	{
		if (Pawn(Other) != None)
		{
			AnnoyedBy(Pawn(Other));
			if ( SetEnemy(Pawn(Other)) )
			{
				bReadyToAttack = True; //can melee right away
				PlayAcquisitionSound();
				GotoState('Attacking');
				return;
			}
		}
		if ( TimerRate <= 0 )
			setTimer(1.0, false);
		if ( bCanSpeak && (ScriptedPawn(Other) != None) && ((TeamLeader == None) || !TeamLeader.bTeamSpeaking) )
			SpeakTo(ScriptedPawn(Other));
	}

	speed = VSize(Velocity);
	if ( speed > 1 )
	{
		VelDir = Velocity/speed;
		VelDir.Z = 0;
		OtherDir = Normal2D(Other.Location - Location);
		if ( (VelDir dot OtherDir) > 0.8 )
		{
			/*if ( Pawn(Other) == None )
			{
				MoveTimer = -1.0;
				HitWall(-1 * OtherDir, Other);
			} */
			Velocity.X = VelDir.Y;
			Velocity.Y = -1 * VelDir.X;
			Velocity *= FMax(speed, 280);
		}
	}
	Disable('Bump');
}

singular function Falling()
{
	if (bCanFly)
	{
		SetPhysics(PHYS_Flying);
		return;
	}
	//log(class$" Falling");
	// SetPhysics(PHYS_Falling); //note - done by default in physics
	if (health > 0 && !bDeleteme)
		SetFall();
}

function SetFall()
{
	if (Enemy != None)
	{
		NextState = 'Attacking'; //default
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}
}

function LongFall()
{
	if (health > 0 && !bDeleteme)
	{
		SetFall();
		GotoState('FallingState', 'LongFall');
	}
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	//log(class$" heard noise by "$NoiseMaker.class);
	if ( SetEnemy(NoiseMaker.instigator) )
		LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
}

function SeePlayer(Actor SeenPlayer)
{
	//log(class$" has line of sight to player");
	if (SetEnemy(Pawn(SeenPlayer)))
		LastSeenPos = Enemy.Location;
}

/* FindBestPathToward() assumes the desired destination is not directly reachable,
given the creature's intelligence, it tries to set Destination to the location of the
best waypoint, and returns true if successful
*/
function bool FindBestPathToward(actor desired)
{
	local Actor path;
	local bool success;

	if ( specialGoal != None)
		desired = specialGoal;
	path = None;
	if (Intelligence <= BRAINS_Reptile)
		path = FindPathToward(desired, true);
	else
		path = FindPathToward(desired);

	success = (path != None);
	if (success)
	{
		MoveTarget = path;
		Destination = path.Location;
	}
	return success;
}

function bool NeedToTurn(vector targ)
{
	local int YawErr;

	DesiredRotation = Rotator(targ - location);
	DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
	YawErr = (DesiredRotation.Yaw - (Rotation.Yaw & 65535)) & 65535;
	if ( (YawErr < 4000) || (YawErr > 61535) )
		return false;

	return true;
}

/* NearWall() returns true if there is a nearby barrier at eyeheight, and
changes Focus to a suggested value
*/
function bool NearWall(float walldist)
{
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist;
	if ( !Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false) )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		Focus = Location + ViewDist;
		return true;
	}

	ViewDist *= -1;

	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		Focus = Location + ViewDist;
		return true;
	}

	Focus = Location - LookDir * 300;
	return true;
}

final function FireProjectile(vector StartOffset, float Accuracy)
{
	local vector X,Y,Z, projStart;

	MakeNoise(1.0);
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + StartOffset.X * CollisionRadius * X
				+ StartOffset.Y * CollisionRadius * Y
				+ StartOffset.Z * CollisionRadius * Z;
	spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, Accuracy, bLeadTarget, bWarnTarget));
}

function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
	SetTimer((0.75 + 0.5 * FRand()) * TimeBetweenAttacks, false);
}

function FireWeapon()
{
	local int bUseAltMode;

	if ( Weapon!=None )
	{
		Weapon.RateSelf(bUseAltMode);
		ViewRotation = Rotation;
		if ( bUseAltMode > 0 )
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
		else
		{
			bFire = 1;
			bAltFire = 0;
			Weapon.Fire(1.0);
		}
		PlayFiring();
	}
}

function PlayFiring();

/*
Adjust the aim at target.
	- add aim error (base on skill - FIXME).
	- adjust up or down if barrier
*/

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal, FireDir;
	local float TargetDist, TossSpeed, TossTime;
	local int realYaw,modifier;

	if ( projSpeed == 0 )
		return AdjustAim(projSpeed, projStart, aimerror, leadTarget, warnTarget);
	if ( Target == None && Enemy!=none && !enemy.bDeleteme && enemy!=self )
		Target = Enemy;
	if ( Target == None )
		return Rotation;
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - ProjStart);

	if ( !Target.bIsPawn )
	{
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z)
				|| (TargetDist > projSpeed) )
		{
			TossTime = TargetDist/projSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);
		}
		viewRotation = Rotator(FireSpot - ProjStart);
		return viewRotation;
	}
	aimerror = aimerror * (11 - 10 *
						   ((Target.Location - Location)/TargetDist
							Dot Normal((Target.Location + 1.2 * Target.Velocity) - (ProjStart + Velocity))));

	modifier = FClamp(Level.Game.difficulty-3, 1, 3);
	if (Level.Game.difficulty > 3)
		aimerror *= 1-(0.3*modifier);

	if ( leadTarget )
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * TargetDist/projSpeed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	//try middle
	FireSpot.Z = Target.Location.Z;

	if ( (Target == Enemy) && !FastTrace(FireSpot, ProjStart) )
	{
		FireSpot = LastSeenPos;
		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			bFire = 0;
			bAltFire = 0;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
			SetTimer(TimeBetweenAttacks, false);
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
	if ( FRand() < 0.75 )
	{
		TossSpeed = projSpeed + 0.4 * VSize(Velocity);
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z)
				|| (TargetDist > TossSpeed) )
		{
			TossTime = TargetDist/TossSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);
		}
	}

	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	aimerror = Rand(2 * aimerror) - aimerror;
	FireRotation.Yaw = (FireRotation.Yaw + aimerror) & 65535;

	if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
			&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( (FireRotation.Yaw > Rotation.Yaw + 32768) ||
				((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
			FireRotation.Yaw = Rotation.Yaw - 8192;
		else
			FireRotation.Yaw = Rotation.Yaw + 8192;
	}
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	HitActor = Trace(HitLocation, HitNormal, ProjStart + FMin(VSize(FireSpot-ProjStart), 400) * FireDir, ProjStart, false);
	if ( (HitActor != None) && (HitNormal.Z < 0.7) )
	{
		FireRotation.Yaw = (realYaw - aimerror) & 65535;
		if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
				&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
		{
			if ( (FireRotation.Yaw > Rotation.Yaw + 32768) ||
					((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
				FireRotation.Yaw = Rotation.Yaw - 8192;
			else
				FireRotation.Yaw = Rotation.Yaw + 8192;
		}
		FireDir = vector(FireRotation);
	}

	if ( warnTarget && (Pawn(Target) != None) )
		Pawn(Target).WarnTarget(self, projSpeed, FireDir);

	viewRotation = FireRotation;
	return FireRotation;
}

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local int modifier;

	if ( Target == None )
	{
		if ( HasAliveEnemy() )
			Target = Enemy;
	}
	if ( Target == None)
		return Rotation;
	if ( !Target.bIsPawn )
		return rotator(Target.Location - Location);

	FireSpot = Target.Location;

	aimerror = aimerror * (1 - 10 *
						   ((Normal(Target.Location - Location)
							 Dot Normal((Target.Location + 0.5 * Target.Velocity) - (Location + 0.5 * Velocity))) - 1));

	aimerror = aimerror * (2.4 - 0.5 * (skill + FRand()));
	modifier = FClamp(Level.Game.difficulty-3, 1, 3);
	if (Level.Game.difficulty > 3)
		aimerror *= 1-(0.3*modifier);

	if (leadTarget && (projSpeed > 0))
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * VSize(Target.Location - ProjStart)/projSpeed);
		if ( !FastTrace(FireSpot,ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	HitActor = self; //so will fail first check unless shooting at feet
	if ( bIsPlayer && (Location.Z + 19 >= Target.Location.Z) && Target.bIsPawn
			&& (Weapon != None) && Weapon.bSplashDamage && (0.5 * (skill - 1) > FRand()) )
	{
		// Try to aim at feet
		HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,80), FireSpot, false);
		if ( HitActor != None )
		{
			FireSpot = HitLocation + vect(0,0,3);
			if ( FastTrace(FireSpot,ProjStart) )
				HitActor = None;
			else HitActor = Self;
		}
		else
			HitActor = self;
	}
	if ( HitActor != None )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
		if ( !FastTrace(FireSpot,ProjStart) )
		{
			//try head
			FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
			if ( FastTrace(FireSpot,ProjStart) )
				HitActor = None;
		}
		else HitActor = None;
	}
	if ( (HitActor != None) && (Target == Enemy) )
	{
		FireSpot = LastSeenPos;
		if ( Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.5 * Enemy.CollisionHeight;
		if ( Weapon != None )
		{
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
			if ( HitActor != None )
			{
				bFire = 0;
				bAltFire = 0;
				SetTimer(TimeBetweenAttacks, false);
			}
		}
	}

	FireRotation = Rotator(FireSpot - ProjStart);

	FireRotation.Yaw = FireRotation.Yaw + 0.5 * (Rand(2 * aimerror) - aimerror);
	if (warnTarget && Pawn(Target) != None)
		Pawn(Target).WarnTarget(self, projSpeed, vector(FireRotation));

	FireRotation.Yaw = FireRotation.Yaw & 65535;
	if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
			&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( (FireRotation.Yaw > Rotation.Yaw + 32768) ||
				((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
			FireRotation.Yaw = Rotation.Yaw - 8192;
		else
			FireRotation.Yaw = Rotation.Yaw + 8192;
	}
	viewRotation = FireRotation;
	return FireRotation;
}

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist;
	local eAttitude att;
	local vector X,Y,Z, enemyDir;

	if ( health <= 0 || bDeleteme)
		return;
	att = AttitudeTo(shooter);
	if ( Level.Game.GameRules!=None )
		att = GetModifiedAttitude(att,shooter);
	if ( (att == ATTITUDE_Ignore) || (att == ATTITUDE_Threaten) )
	{
		if ( intelligence >= BRAINS_Mammal )
			damageAttitudeTo(shooter);
		if (att == ATTITUDE_Ignore)
			return;
	}

	// AI controlled creatures may duck if not falling
	if ( !bCanDuck || (Enemy == None) || (Physics == PHYS_Falling) || (Physics == PHYS_Swimming) )
		return;

	if( BonusSkill<=1.f ) // Become aggressive dodger.
	{
		if ( bIsPlayer )
		{
			if ( FRand() > 0.33 * skill )
				return;
		}
		else if ( FRand() > 0.55 + 0.15 * skill )
			return;

		// and projectile time is long enough
		enemyDist = VSize(shooter.Location - Location);
		if (enemyDist/projSpeed < 0.11 + 0.15 * FRand())
			return;
			
		// only if tight FOV
		GetAxes(Rotation,X,Y,Z);
		enemyDir = (shooter.Location - Location)/enemyDist;
		if ((enemyDir Dot X) < 0.8)
			return;
	}
	else Y = Normal(Location - shooter.Location) Cross vect(0,0,1);

	if ( (FireDir Dot Y) > 0 )
		TryToDuck(-Y, true);
	else TryToDuck(Y, false);
}

function TryToDuck(vector DuckDir, bool bReversed)
{
	//implemented in subclasses that can duck
}

/* TryToCrouch()
See if far enough away, and geometry favorable for crouching
*/
function bool TryToCrouch()
{
	local float ViewDist;
	local vector ViewSpot, StartSpot, ViewDir, Dir2D;

	bCrouching = false;
	if ( Enemy == None )
		return false;
	ViewDist = VSize(Location - Enemy.Location);
	if ( ViewDist < 400 )
		return false;
	if ( FRand() < 0.3 )
		return true;

	ViewSpot = Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1);
	StartSpot = Location - CollisionHeight * vect(0,0,0.5);
	ViewDir = (ViewSpot - StartSpot)/ViewDist;
	Dir2D = ViewDir;
	Dir2D.Z = 0;
	if ( (Dir2D Dot Vector(Rotation)) < 0.8 )
		return false;
	if ( FastTrace(StartSpot + 100 * ViewDir, StartSpot) )
		return false;
	bCrouching = true;
	return true;
}

// Can Stake Out - check if I can see my current Destination point, and so can enemy
function bool CanStakeOut()
{
	if ( (Physics == PHYS_Flying) && !bCanStrafe )
		return false;
	if ( !HasAliveEnemy() )
		return false;
	if ( VSize(Enemy.Location - LastSeenPos) > 800 )
		return false;

	return (FastTrace(LastSeenPos, Location + EyeHeight * vect(0,0,1)) &&
			FastTrace(LastSeenPos, Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)));
}

function TriggerFirstHate()
{
	bFirstHatePlayer = true;
	TriggerEvent(FirstHatePlayerEvent,Self,Enemy);
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;
	local eAttitude newAttitude, oldAttitude;
	local bool noOldEnemy;
	local float newStrength;

	if ( !IsAlivePawn(NewEnemy) || (!bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone) )
		return false;
	if ( NewEnemy == self || NewEnemy.bIsAmbientCreature || Health <= 0 )
		return false;

	noOldEnemy = (Enemy == None);
	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	if ( Level.Game.GameRules!=None )
		newAttitude = GetModifiedAttitude(newAttitude,NewEnemy);
	if ( !noOldEnemy )
	{
		if (Enemy == NewEnemy)
			return true;
		else if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		}
		else if ( newAttitude == ATTITUDE_Friendly )
		{
			if ( bIgnoreFriends || (NewEnemy.Enemy==NewEnemy) )
				return false;
			if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) ) 
			{
				if ( NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer < AttitudeToPlayer) )
					AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
				if ( GetModifiedAttitude(AttitudeTo(NewEnemy.Enemy),NewEnemy.Enemy) < GetModifiedAttitude(AttitudeTo(Enemy),Enemy) )
				{
					OldEnemy = Enemy;
					Enemy = NewEnemy.Enemy;
					result = true;
				}
			}
		}
		else if (newAttitude != ATTITUDE_Ignore) // shouldn't try to change Enemy if newAttitude is ATTITUDE_Ignore, no matter what the value of noOldEnemy is
		{
			oldAttitude = AttitudeTo(Enemy);
			if ( Level.Game.GameRules!=None )
				oldAttitude = GetModifiedAttitude(oldAttitude,Enemy);
			if ( (newAttitude < oldAttitude) ||
					( (newAttitude == oldAttitude)
					  && ((VSize(NewEnemy.Location - Location) < VSize(Enemy.Location - Location))
						  || !LineOfSightTo(Enemy)) ) )
			{
				if ( bIsPlayer && Enemy.bIsPlayerPawn && !NewEnemy.bIsPlayerPawn )
				{
					newStrength = relativeStrength(NewEnemy);
					if ( (newStrength < 0.2) && (relativeStrength(Enemy) < FMin(0, newStrength))
							&& (IsInState('Hunting')) && (Level.TimeSeconds - HuntStartTime < 5) )
						result = false;
					else
					{
						result = true;
						OldEnemy = Enemy;
						Enemy = NewEnemy;
					}
				}
				else
				{
					result = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
			}
		}
	}
	else if ( newAttitude < ATTITUDE_Ignore )
	{
		result = true;
		Enemy = NewEnemy;
	}
	else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
	{
		//log("noticed a friend");
		if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			Enemy = NewEnemy;
			result = true;
		} 
		if (bIgnoreFriends)
			return false;

		if ( NewEnemy.HasAliveEnemy() && NewEnemy.Enemy != self ) 
		{
			result = true;
			Enemy = NewEnemy.Enemy;
			if (Enemy.bIsPlayer)
				AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
			else if ( (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
				Hated = Enemy;
		}
	}

	if ( result )
	{
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Location;
		EnemyAcquired();
		if ( !bFirstHatePlayer && Enemy.bIsPlayer && (FirstHatePlayerEvent != '') )
			TriggerFirstHate();
	}
	else if ( NewEnemy.bIsPlayer && (NewAttitude < ATTITUDE_Threaten) )
		OldEnemy = NewEnemy;
	else if( NewAttitude==ATTITUDE_Follow && (ScriptedPawn(NewEnemy)==None || ScriptedPawn(NewEnemy).FollowingPawn!=Self) )
		FollowTargetAquired(NewEnemy);

	return result;
}

function FollowTargetAquired( Pawn Other );

function Killed(pawn Killer, pawn Other, name damageType)
{
	local Pawn aPawn;
	local ScriptedPawn ScriptedOther;
	local bool bFoundTeam;

	if ( Health <= 0 || bDeleteme )
		return;
	if (Other.bIsPlayer)
		bCanBePissed = true;

	ScriptedOther = ScriptedPawn(Other);
	if ( (TeamTag != '') && (ScriptedOther != None)
			&& (ScriptedOther.TeamTag == TeamTag) )
	{
		if ( ScriptedOther.bTeamLeader )
			TeamTag = '';
		else if ( ScriptedOther.TeamID < TeamID )
			TeamID--;
		else if ( bTeamLeader )
		{
			aPawn = Level.PawnList;
			while ( aPawn != None )
			{
				if ( (ScriptedPawn(aPawn) != None) && (ScriptedPawn(aPawn) != self) &&
						(ScriptedPawn(aPawn).TeamTag == TeamTag) )
				{
					bFoundTeam = true;
					break;
				}
				aPawn = aPawn.nextPawn;
			}
			if ( !bFoundTeam )
			{
				bTeamLeader = false;
				TeamTag = '';
			}
		}
	}

	if ( OldEnemy == Other )
		OldEnemy = None;

	if ( Enemy == Other )
	{
		Enemy = None;
		if ( (Killer != none) && (Killer == self) && (OldEnemy == None) )
		{
			for (aPawn=level.pawnlist; aPawn!=none; aPawn=aPawn.nextpawn)
			{
				if (( aPawn.bCollideActors  && ( !aPawn.IsA('FlockPawn') ))
						&& (VSize(Location - aPawn.Location) < 1000) && CanSee(aPawn) )
				{
					if ( SetEnemy(aPawn) )
					{
						GotoState('Attacking');
						return;
					}
				}
			}
			Target = Other;
			GotoState('VictoryDance');
		}
		else
			GotoState('Attacking');
	}
}

function damageAttitudeTo(pawn Other)
{
	local eAttitude OldAttitude;

	if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) )
		return;
	if ( Other.bIsPlayer ) //change attitude to player
	{ //FIXME - also frenzy or run away against non-players
		if ( (Health < 30) && (Aggressiveness * FRand() > 0.5) )
		{
			AttitudeToPlayer = ATTITUDE_Frenzy;
			Aggressiveness = 1.0;
		}
		else if (AttitudeToPlayer == ATTITUDE_Ignore) AttitudeToPlayer = ATTITUDE_Hate;
		else if (AttitudeToPlayer == ATTITUDE_Threaten) AttitudeToPlayer = ATTITUDE_Hate;
		else if (AttitudeToPlayer == ATTITUDE_Friendly) AttitudeToPlayer = ATTITUDE_Threaten;
	}
	else
	{
		OldAttitude = AttitudeToCreature(Other);
		if (OldAttitude > ATTITUDE_Ignore )
			return;
		else if ( OldAttitude > ATTITUDE_Frenzy )
		{
			//log(class$" hates "$Other.class);
			Hated = Other;
		}
	}
	SetEnemy(Other);
}

function EnemyAcquired()
{
	//log(Class$" just acquired an enemy - no action");
}

/* RelativeStrength()
returns a value indicating the relative strength of other
0.0 = equal to self
> 0 stronger than self
< 0 weaker than self

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)

Assess based on health and weapon
*/

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedStrength, adjustedOther;
	local int bTemp;

	adjustedStrength = health;
	adjustedOther = 0.5 * (Other.health + Other.Default.Health);
	compare = 0.01 * float(adjustedOther - adjustedStrength);
	if ( Intelligence == BRAINS_Human )
	{
		if ( Weapon != None )
		{
			compare -= (Weapon.RateSelf(bTemp) - 0.3);
			if ( bIsPlayer && (Weapon.AIRating < 0.3) )
			{
				compare += 0.2;
				if ( (Other.Weapon != None) && (Other.Weapon.AIRating >= 0.3) )
					compare += 0.3;
			}
		}
		if ( Other.Weapon != None )
			compare += (Other.Weapon.RateSelf(bTemp) - 0.3);
	}
	//log(other.class$" relative strength to "$class$" is "$compare);
	return compare;
}

/* AttitudeTo()
Returns the creature's attitude towards another Pawn
*/
function EAttitude AttitudeTo(Pawn Other)
{
	local EAttitude Attitude;

	if( Other==None )
		return ATTITUDE_Ignore;
	else if( Other.bIsPlayer )
	{
		if ( bIsPlayer && Level.Game.bTeamGame && (Other.PlayerReplicationInfo != none) && (Team == Other.PlayerReplicationInfo.Team) )
			return ATTITUDE_Friendly;
		else if ( (Intelligence > BRAINS_None) &&
				  ((AttitudeToPlayer == ATTITUDE_Hate) || (AttitudeToPlayer == ATTITUDE_Threaten)
				   || (AttitudeToPlayer == ATTITUDE_Fear)) ) //check if afraid
		{
			if (RelativeStrength(Other) > Aggressiveness)
				AttitudeToPlayer = AttitudeWithFear();
			else if (AttitudeToPlayer == ATTITUDE_Fear)
				AttitudeToPlayer = ATTITUDE_Hate;
		}
		return AttitudeToPlayer;
	}
	else if ( (TeamTag != '') && (ScriptedPawn(Other) != None) && (TeamTag == ScriptedPawn(Other).TeamTag) )
		return ATTITUDE_Friendly;
	else
	{
		Attitude = AttitudeToCreature(Other);
		if (Attitude == ATTITUDE_Frenzy || Attitude >= ATTITUDE_Friendly || Hated != Other)
			return Attitude;
		if (RelativeStrength(Other) >= Aggressiveness)
			return AttitudeWithFear();
		return ATTITUDE_Hate;
	}
}

/* AttitudeWithFear()
may fear other, unless near home
*/

function EAttitude AttitudeWithFear()
{
	if ( Homebase(home) == None )
	{
		CombatStyle -= 1.0;
		return ATTITUDE_Hate;
	}
	else if ( VSize(home.Location - Location) < Homebase(home).extent )
	{
		if( FastTrace(home.Location, Location) )
			return ATTITUDE_Hate;
	}

	return ATTITUDE_Fear;
}

/* AttitudeToCreature
Typically implemented in subclass
*/

function EAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.Class == Class )
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
}

/*
Annoyed by another pawn, typically after bumping into it
(only when not already fighting)
*/
function AnnoyedBy(Pawn Other)
{
	local eAttitude att;

	att = AttitudeTo(Other);
	if ( Level.Game.GameRules!=None )
		att = GetModifiedAttitude(att,Other);
	if ( !bCanBePissed || Other.bIsPlayer || (Enemy != None) || (Aggressiveness < 0.4)
			|| (att != ATTITUDE_Ignore) || (FRand() > 0.2) )
		return;

	Hated = Other;
}

function bool ChooseTeamAttackFor(ScriptedPawn TeamMember)
{
	if ( (Enemy == None) && TeamMember != none && (TeamMember.Enemy != None) && LineOfSightTo(TeamMember) )
	{
		if (SetEnemy(TeamMember.Enemy))
			MakeNoise(1.0);
	}
	if ( IsAlivePawn(TeamMember) && !bTeamSpeaking )
		SpeakOrderTo(TeamMember);
	if ( TeamMember == self )
	{
		ChooseLeaderAttack();
		return true;
	}

	if ( TeamMember != none && TeamMember.HasAliveEnemy() && TeamMember.Enemy != self && TeamMember.bReadyToAttack )
	{
		TeamMember.Target = TeamMember.Enemy;
		Enemy=TeamMember.Enemy;
		if (IsAlivePawn(TeamMember))
		{
			if (VSize(Enemy.Location - Location) <= (TeamMember.MeleeRange + TeamMember.Enemy.CollisionRadius + TeamMember.CollisionRadius))
			{
				TeamMember.GotoState('MeleeAttack');
				return true;
			}
			else if (TeamMember.bMovingRangedAttack || TeamMember.TeamID == 1)
				TeamMember.SetTimer(TimeBetweenAttacks, False);
			else if (TeamMember.bHasRangedAttack && (TeamMember.bIsPlayer || TeamMember.Enemy.bIsPlayer) && TeamMember.CanFireAtEnemy())
			{
				if (!TeamMember.bIsPlayer || (3 * FRand() > Skill))
				{
					TeamMember.GotoState('RangedAttack');
					return true;
				}
			}
		}
	}

	if (Enemy == none && TeamMember != none && TeamMember.HasAliveEnemy())
		SetEnemy(TeamMember.Enemy);

	if (IsAlivePawn(TeamMember))
	{
		if (!TeamMember.bHasRangedAttack || TeamMember.TeamID == 1)
			TeamMember.GotoState('Charging');
		else if (TeamMember.TeamID == 2)
		{
			TeamMember.bStrafeDir = true;
			TeamMember.GotoState('TacticalMove', 'NoCharge');
		}
		else if (TeamMember.TeamID == 3)
		{
			TeamMember.bStrafeDir = false;
			TeamMember.GotoState('TacticalMove', 'NoCharge');
		}
		else
			TeamMember.GotoState('TacticalMove');
	}
	return true;
}

function ChooseLeaderAttack()
{
	if (bReadyToAttack && !bMovingRangedAttack)
		GotoState('RangedAttack');
	else
		GotoState('TacticalMove', 'NoCharge');
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation;

	if ( Target==self )
		Target = none;

	if (Target == none )   // allow non pawn targets
	{
		if (HasAliveEnemy())
			Target = Enemy;
	}
	if (!IsLiveActor(Target) || Target.bIsPawn && Pawn(Target).Health <= 0)
		return false;

	if ( (VSizeSq(Target.Location - Location) <= Square(MeleeRange * 1.4 + Target.CollisionRadius + CollisionRadius))
			&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Target.Location.Z)
					<= FMax(CollisionHeight, Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Target.CollisionHeight))) )
	{
		if ( FastTrace(Target.Location, Location) && Target.TraceThisActor(Target.Location,Location,HitLocation) )
		{
			Target.TakeDamage(hitdamage, Self, HitLocation, pushdir, 'hacked');
			return true;
		}
	}
	return false;
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, EnemyUp;
	local actor HitActor;
	local float EnemyDist;

	if (!HasAliveEnemy())
		return false;
	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}

	HitActor = Trace(HitLocation, HitNormal, Location + EnemyDir + EnemyUp, Location, true);

	if ( (HitActor == None) || (HitActor == Enemy)
			|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor = Trace(HitLocation, HitNormal, Location + EnemyDir, Location, true);

	return ( (HitActor == None) || (HitActor == Enemy)
			 || ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) );
}

function PlayMeleeAttack()
{
	log(self$" Error - PlayMeleeAttack should be implemented in subclass");
}

function PlayRangedAttack()
{
	log(self$" Error - PlayRangedAttack should be implemented in subclass");
}

function PlayCombatMove()
{
	if ( !HasAliveEnemy() )
	{
		PlayRunning();
		return;
	}
	if ( bMovingRangedAttack && bReadyToAttack && bCanFire && !NeedToTurn(Enemy.Location) )
	{
		Target = Enemy;
		PlayMovingAttack();
		if ( FRand() > 0.5 * (0.5 + skill * 0.25 + ReFireRate) )
		{
			bReadyToAttack = false;
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false);
		}
	}
	else
	{
		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);
		PlayRunning();
	}
}

function float StrafeAdjust()
{
	local float strafemag;

	strafeMag = Abs( Normal2D(Focus - Location) dot Normal2D(Destination - Location) );
	return ((strafeMag - 2.0)/GroundSpeed);
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn currentEnemy;

	if ( (Other == Self) || (Health <= 0) || (bDeleteme) || EventInstigator == None )
		return;
	if( bTriggerAutoTargeting )
	{
		bTriggerAutoTargeting = false;
		SightCheckType = SEE_All;
		return;
	}
	if ( bHateWhenTriggered )
	{
		if ( EventInstigator.bIsPlayer)
			AttitudeToPlayer = ATTITUDE_Hate;
		else
			Hated = EventInstigator;
	}
	currentEnemy = Enemy;
	SetEnemy(EventInstigator);
	if (Enemy != currentEnemy)
	{
		PlayAcquisitionSound();
		GotoState('Attacking');
	}
}

// 227j: AI is ready to melee attack target (hack for Pupae)
function bool IsInMeleeRange( Pawn Other )
{
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
	{
		if ( VSizeSq(Location - Other.Location) > Square(MeleeRange + CollisionRadius + Other.CollisionRadius) )
			return false;
	}
	else if ( (Abs(Location.Z - Other.Location.Z)
			   > FMax(CollisionHeight, Other.CollisionHeight) + 0.5 * FMin(CollisionHeight, Other.CollisionHeight)) ||
			  (VSizeSq(Location - Other.Location) > Square(MeleeRange + CollisionRadius + Other.CollisionRadius)) )
		return false;
	return true;
}

function AddVelocity( vector NewVelocity)
{
	if( BonusSkill>0.f && VSizeSq(NewVelocity)<{100.0*100.0} ) // 227j: Disable minigun can-can if high difficulty.
		return;
	if ( Health <=0 || bDeleteMe )
	{
		Disable('Hitwall');
		Disable('Bump');
	}
	Super.AddVelocity(NewVelocity);
}

function bool IsSameSpeciesAs( ScriptedPawn Other )
{
	return (Other.Class==Class);
}
function bool CanMakeSafePathTo( Actor Other, out float Dist )
{
	local NavigationPoint N;

	if( ActorReachable(Other) )
	{
		Dist = 1.f;
		return true;
	}
	if( !FindPathToward(Other) )
		return false;
	if( Enemy && RouteCache[1] && ((RouteCache[1].Location-Location) Dot (Enemy.Location-Location))>0.f ) // Don't move towards enemy!
		return false;
	if( RouteCache[0] )
	{
		for( N=RouteCache[0]; N.previousPath; N=N.previousPath )
		{}
		Dist = N.visitedWeight;
	}
	else Dist = VSize(Other.Location-Location);
	return true;
}
function bool AIFindBackup() // 227j: Try to get some backup.
{
	local ScriptedPawn P,Best;
	local float BestDist,Dist;
	
	foreach RadiusActors(class'ScriptedPawn',P,1600.f,,true)
	{
		if( P!=Self && P.Health>0 && !P.Enemy && IsSameSpeciesAs(P) && CanMakeSafePathTo(P, Dist) && (!Best || Dist<BestDist) )
		{
			Best = P;
			BestDist = Dist;
		}
	}
	if( Best )
	{
		BackupPlan = Best;
		return true;
	}
	return false;
}

//**********************************************************************************
//Base Monster AI

auto state StartUp
{
Ignores Bump,TakeDamage,Falling,Landed,BaseChange,Falling;
	
	function InitAmbushLoc()
	{
		local AmbushPoint newspot;
		local float i;

		i = 1.0;
		foreach AllActors( class 'AmbushPoint', newspot, tag )
		{
			if ( !newspot.taken )
			{
				i = i + 1;
				if (FRand() < 1.0/i)
					OrderObject = newspot;
			}
		}
		if (AmbushPoint(OrderObject) != none)
			AmbushPoint(OrderObject).Accept(self);
	}

	function InitPatrolLoc()
	{
		/* IMPLEMENT by Walking throught patrol */
	}

	function SetHome()
	{
		local NavigationPoint aNode;

		aNode = Level.NavigationPointList;

		while ( aNode != None )
		{
			if ( aNode.IsA('HomeBase') && (aNode.tag == tag) )
			{
				home = HomeBase(aNode);
				return;
			}
			aNode = aNode.nextNavigationPoint;
		}
	}

	function SetTeam()
	{
		local Pawn aPawn;
		local bool bFoundTeam;
		if (bTeamLeader)
		{
			TeamLeader = self;
			return;
		}
		TeamID = 1;
		aPawn = Level.PawnList;
		while ( aPawn != None )
		{
			if ( (ScriptedPawn(aPawn) != None) && (aPawn != self) && (ScriptedPawn(aPawn).TeamTag == TeamTag) )
			{
				if ( ScriptedPawn(aPawn).bTeamLeader )
				{
					bFoundTeam = true;
					TeamLeader = ScriptedPawn(aPawn);
				}
				if ( ScriptedPawn(aPawn).TeamID >= TeamID )
					TeamID = ScriptedPawn(aPawn).TeamID + 1;
			}
			aPawn = aPawn.nextPawn;
		}
		if ( !bFoundTeam )
			TeamTag = ''; //didn't find a team leader, so no team
	}

	function SetAlarm()
	{
		local Pawn aPawn, currentWinner;
		local float i;

		currentWinner = self;
		i = 1.0;

		aPawn = Level.PawnList;
		while ( aPawn != None )
		{
			if ( aPawn.IsA('ScriptedPawn') && (ScriptedPawn(aPawn).SharedAlarmTag == SharedAlarmTag) )
			{
				ScriptedPawn(aPawn).SharedAlarmTag = '';
				i += 1;
				if (FRand() < 1.0/i)
					currentWinner = aPawn;
			}
			aPawn = aPawn.nextPawn;
		}

		ScriptedPawn(currentWinner).AlarmTag = SharedAlarmTag;
		SharedAlarmTag = '';
	}

	function BeginState()
	{
		SetMovementPhysics();
		if (Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);
	}

Begin:
	SetHome();
	if (SharedAlarmTag != '')
		SetAlarm();
	if (TeamTag != '')
		SetTeam();
	if (Orders == 'Guarding')
	{
		OrderObject = Spawn(class 'GuardPoint');
		if (OrderTag != '')
			Tag = OrderTag; //so will be triggered if guarded object is touched
	}
	else if (!bFixedStart)
	{
		if (Orders == 'Patroling')
			InitPatrolLoc();
		else if (Orders == 'Ambushing')
			InitAmbushLoc();
	}

	if (Orders != '')
	{
		if (Orders == 'Attacking')
		{
			Orders = '';
			if (Enemy != None)
				GotoState('Attacking');
			else
				StartRoaming();
		}
		else if ( bDelayedPatrol && (Orders == 'Patroling') )
			GotoState('Patroling', 'DelayedPatrol');
		else
			GotoState(Orders);
		if ( Physics == PHYS_Falling )
			SetFall();
		else
			SetMovementPhysics();
	}
	else
		GotoState('Waiting');
}

state Waiting
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}

	function Bump(actor Other)
	{
		//log(Other.class$" bumped "$class);
		if (Pawn(Other) != None)
		{
			if (Enemy == Other)
				bReadyToAttack = True; //can melee right away
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

	function EnemyAcquired()
	{
		GotoState('Acquisition', 'PlayOut');
	}

	function AnimEnd()
	{
		PlayWaiting();
		bStasis = true;
	}

	function Landed(vector HitNormal)
	{
		//SetPhysics(PHYS_None);
		Acceleration = vect(0,0,0);
	}

	function BeginState()
	{
		Target = None;
		Enemy = None;
		bStasis = false;
		Acceleration = vect(0,0,0);
		SetAlertness(0.0);
	}
	function FollowTargetAquired( Pawn Other )
	{
		FollowingPawn = Other;
		GoToState('AIFollowingPawn');
	}

TurnFromWall:
	WaitForLanding();
	if ( NearWall(2 * CollisionRadius + 50) )
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
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	SetRotation(DesiredRotation);
	//if (Physics != PHYS_Falling)
	//	SetPhysics(PHYS_None);
	Acceleration = vect(0,0,0);

KeepWaiting:
	NextAnim = '';
}

state Roaming
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;

		if ( Enemy != None )
			LastSeenPos = Enemy.Location;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else
			GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
		GotoState('Wandering', 'Moving');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function Bump(Actor Other)
	{
		if ( Health <= 0 || bDeleteme )
			return;
		if ( FRand() < 0.03)
			GotoState('Wandering');
		else
			global.Bump(Other);
	}

	function SetFall()
	{
		NextState = 'Roaming';
		NextLabel = 'ContinueRoam';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}
	function FollowTargetAquired( Pawn Other )
	{
		FollowingPawn = Other;
		GoToState('AIFollowingPawn');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			bSpecialGoal = true;
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Roaming', 'Moving');
			return;
		}
		Focus = Destination;
		if ( PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				gotoState('Roaming', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local Actor Path;

		numHuntPaths++;
		if ( numHuntPaths > 80 )
		{
			gotoState('Wandering');
			return;
		}
		if (SpecialGoal != None)
		{
			Path = FindPathToward(SpecialGoal);
			if (Path != None)
			{
				MoveTarget = Path;
				return;
			}
		}
		if ( Orderobject == None )
		{
			OrderObject = FindRandomDest();
			if ( Orderobject!=None )
			{
				GotoState('Roaming', 'pausing');
				Return;
			}
		}
		if ( Orderobject == None )
		{
			GotoState('Wandering');
			return;
		}
		if ( actorReachable(Orderobject) )
		{
			numHuntPaths = 0;
			MoveTarget = Orderobject;
			Orderobject = None;
			if ( VSizeSq(MoveTarget.Location - Location) > Square(2.f * CollisionRadius) )
				return;
		}
		else
		{
			Path = FindPathToward(Orderobject);
			if ( Path != None )
			{
				MoveTarget = Path;
				return;
			}
			else Orderobject = None;
		}
		if ( FRand() < 0.25 )
			GotoState('Wandering');
		else GotoState('Roaming', 'pausing');
	}

	function BeginState()
	{
		SpecialGoal = None;
		bSpecialGoal = false;
		SpecialPause = 0.0;
		Enemy = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
	}

Begin:
	//log(class$" Roaming");

Roam:
	TweenToWalking(0.15);
	NextAnim = '';
	WaitForLanding();
	PickDestination();
	FinishAnim();
	PlayWalking();

Moving:
	if (SpecialPause > 0.0)
	{
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		TweenToWalking(0.1);
		FinishAnim();
		PlayWalking();
	}
	MoveToward(MoveTarget, WalkingSpeed);
	if ( bSpecialGoal )
	{
		bSpecialGoal = false;
		Goto('Roam');
	}
	Acceleration = vect(0,0,0);
	TweenToPatrolStop(0.3);
	FinishAnim();
	NextAnim = '';
Pausing:
	Acceleration = vect(0,0,0);
	PlayPatrolStop();
	FinishAnim();
	if ( !bQuiet && (FRand() < 0.3) )
		PlayRoamingSound();
	Goto('Roam');

ContinueRoam:
	FinishAnim();
	PlayWalking();
	Goto('Roam');

AdjustFromWall:
	if ( !IsAnimating() )
		PlayWalking();
	StrafeTo(Destination, Focus);
	Destination = Focus;
	Goto('Moving');
}

state Wandering
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bdeleteme )
			return;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;

		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else
			GotoState('Attacking');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Wandering';
		NextLabel = 'ContinueWander';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}
	function FollowTargetAquired( Pawn Other )
	{
		FollowingPawn = Other;
		GoToState('AIFollowingPawn');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Wandering', 'Pausing');
			return;
		}
		Focus = Destination;
		if ( PickWallAdjust() && (FRand() < 0.7) )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Wandering', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function bool TestDirection(vector dir, out vector pick)
	{
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		minDist = FMin(150.0, 4*CollisionRadius);
		pick = dir * (minDist + (450 + 12 * CollisionRadius) * FRand());

		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false);
		if( HitActor )
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			if (!FastTrace(pick, Location))
				return false;
		}
		else pick = Location + pick;

		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;

		return (VSizeSq(dist) > Square(minDist));
	}

	function PickDestination()
	{
		local vector pick, pickdir;
		local bool success;

		if( Physics==PHYS_Flying || Physics==PHYS_Swimming )
			pickdir = VRand();
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
			pickdir = Normal2D(pickdir);
		}
		
		success = TestDirection(pickdir, pick);
		if (!success)
			success = TestDirection(-1 * pickdir, pick);

		if (success)
			Destination = pick;
		else
			GotoState('Wandering', 'Turn');
	}

	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
	}

	function BeginState()
	{
		Enemy = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
		Disable('AnimEnd');
		NextAnim = '';
		bCanJump = false;
	}

	function EndState()
	{
		if (JumpZ > 0)
			bCanJump = true;
	}

Begin:
	//log(class$" Wandering");

Wander:
	TweenToWalking(0.15);
	WaitForLanding();
	PickDestination();
	FinishAnim();
	PlayWalking();

Moving:
	Enable('HitWall');
	MoveTo(Destination, WalkingSpeed);
Pausing:
	Acceleration = vect(0,0,0);
	if ( NearWall(2 * CollisionRadius + 50) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	if (FRand() < 0.3)
		PlayRoamingSound();
	Enable('AnimEnd');
	NextAnim = '';
	TweenToPatrolStop(0.2);
	Sleep(1.0);
	Disable('AnimEnd');
	FinishAnim();
	Goto('Wander');

ContinueWander:
	FinishAnim();
	PlayWalking();
	if ( !bQuiet && (FRand() < 0.3) )
		PlayRoamingSound();
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:
	if ( !IsAnimating() )
		PlayWalking();
	StrafeTo(Destination, Focus);
	Destination = Focus;
	Goto('Moving');
}

State Patroling
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
			LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}

	function SetFall()
	{
		NextState = 'Patroling';
		NextLabel = 'ResumePatrol';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Patroling', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Patroling', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( bDelayedPatrol )
		{
			if ( bHateWhenTriggered && EventInstigator!=None )
			{
				if ( EventInstigator.bIsPlayer)
					AttitudeToPlayer = ATTITUDE_Hate;
				else
					Hated = EventInstigator;
			}
			GotoState('Patroling', 'Patrol');
		}
		else
			Global.Trigger(Other, EventInstigator);
	}

	function Timer()
	{
		Enable('Bump');
	}

	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function EnemyAcquired()
	{
		//log(Class$" just acquired an enemy");
		GotoState('Acquisition');
	}

	function PickDestination()
	{
		local Actor path;

		path = None;
		if (SpecialGoal != None)
			path = FindPathToward(SpecialGoal);
		else if ( OrderObject != None )
			path = FindPathToward(OrderObject);
		if (path != None)
		{
			MoveTarget = path;
			Destination = path.Location;
		}
		else
			OrderObject = None;
	}

	function FindNextPatrol()
	{
		local PatrolPoint pat;
		if ( (PatrolPoint(OrderObject) != None) && (PatrolPoint(OrderObject).nextPatrol == OrderTag) )
			OrderObject = PatrolPoint(OrderObject).NextPatrolPoint;
		else
		{
			foreach AllActors( class 'Patrolpoint', pat, OrderTag )
			{
				OrderObject = pat;
				return;
			}
		}
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		Enemy = None;
		NextAnim = '';
		Disable('AnimEnd');
		SetAlertness(0.0);
		bReadyToAttack = (FRand() < 0.3 + 0.2 * skill);
	}

AdjustFromWall:
	if ( !IsAnimating() )
		PlayWalking();
	StrafeTo(Destination, Focus);
	Destination = Focus;
	MoveTo(Destination);
	Goto('MoveToPatrol');

ResumePatrol:
	if (MoveTarget != None)
	{
		PlayWalking();
		MoveToward(MoveTarget, WalkingSpeed);
		Goto('ReachedPatrol');
	}
	else
		Goto('Patrol');

Begin:
	sleep(0.1);

Patrol: //FIXME -add stasis mode? - also set random start point in roam area
	WaitForLanding();
	FindNextPatrol();
	Disable('AnimEnd');
	if (PatrolPoint(OrderObject) != None)
	{
		////log("Move to next patrol point");
		if ( !bQuiet && (FRand() < 0.4) )
			PlayRoamingSound();
		TweenToWalking(0.3);
		FinishAnim();
		PlayWalking();
		numHuntPaths = 0;

MoveToPatrol:
		if (actorReachable(OrderObject))
			MoveToward(OrderObject, WalkingSpeed);
		else
		{
			PickDestination();
			if (OrderObject != None)
			{
SpecialNavig:
				if (SpecialPause > 0.0)
				{
					Acceleration = vect(0,0,0);
					TweenToPatrolStop(0.3);
					Sleep(SpecialPause);
					SpecialPause = 0.0;
					TweenToWalking(0.1);
					FinishAnim();
					PlayWalking();
				}
				numHuntPaths++;
				MoveToward(MoveTarget, WalkingSpeed);
				if ( numHuntPaths < 30 )
					Goto('MoveToPatrol');
				else
					Goto('GiveUp');
			}
			else
				Goto('GiveUp');
		}

ReachedPatrol:
		////log("Got to patrol point "$OrderTag);
		OrderTag = Patrolpoint(OrderObject).Nextpatrol;
		////log("Next patrol point "$OrderTag);
		if ( Patrolpoint(OrderObject).pausetime > 0.0 )
		{
			////log("Pause patrol");
			Acceleration = vect(0,0,0);
			TweenToFighter(0.2);
			FinishAnim();
			PlayTurning();
			TurnTo(Location + (Patrolpoint(OrderObject)).lookdir);
			if ( Patrolpoint(OrderObject).PatrolAnim != '' && HasAnim(Patrolpoint(OrderObject).PatrolAnim))
			{
				TweenAnim( Patrolpoint(OrderObject).PatrolAnim, 0.3);
				FinishAnim();
				Patrolpoint(OrderObject).AnimCount = Patrolpoint(OrderObject).numAnims;
				While ( Patrolpoint(OrderObject).AnimCount > 0 )
				{
					Patrolpoint(OrderObject).AnimCount--;
					if (Patrolpoint(OrderObject).PatrolSound != None )
						PlaySound( Patrolpoint(OrderObject).PatrolSound );
					PlayAnim(Patrolpoint(OrderObject).PatrolAnim);
					FinishAnim();
				}
			}
			else
			{
				TweenToPatrolStop(0.3);
				FinishAnim();
				Enable('AnimEnd');
				NextAnim = '';
				PlayPatrolStop();
				////log("stop here for "$(Patrolpoint(OrderObject)).pausetime);
				Sleep((Patrolpoint(OrderObject)).pausetime);
				Disable('AnimEnd');
				FinishAnim();
			}
		}
		Goto('Patrol');
	}

GiveUp:
	//log(self$" gave up patrol");
	Acceleration = vect(0,0,0);
	TweenToPatrolStop(0.3);
	FinishAnim();
DelayedPatrol:
	Enable('AnimEnd');
	PlayPatrolStop();
}

state Guarding
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	Vector momentum, name damageType)
	{
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
			LastSeenPos = Enemy.Location;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Guarding', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Guarding', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local Actor path;

		path = None;
		if (SpecialGoal != None)
			path = FindPathToward(SpecialGoal);
		else if ( OrderObject != None )
			path = FindPathTo(OrderObject.Location);
		//log("Next path is "$path);
		if (path != None)
		{
			MoveTarget = path;
			Destination = path.Location;
		}
		else
			StartRoaming();
	}

	function SetFall()
	{
		NextState = 'Guarding';
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		Enemy = None;
		NextAnim = '';
		SetAlertness(0.0);
	}

AdjustFromWall:
	if ( !IsAnimating() )
		PlayRunning();
	StrafeTo(Destination, Focus);
	Destination = Focus;
	MoveTo(Destination);
	Goto('GoToGuard');

Begin:
	//log(class$" guarding "$OrderObject);
	Disable('AnimEnd');

GoToGuard:
	if ( OrderObject != none && VSizeSq(Location - OrderObject.Location) < Square(2 * CollisionRadius))
		Goto('Turn');
	TweenToRunning(0.2);
	FinishAnim();
	PlayRunning();
	WaitForLanding();
	if (actorReachable(OrderObject))
		MoveToward(OrderObject, FMax(0.75, WalkingSpeed));
	else
	{
		PickDestination();
SpecialNavig:
		if (SpecialPause > 0.0)
		{
			Acceleration = vect(0,0,0);
			TweenToPatrolStop(0.3);
			Sleep(SpecialPause);
			SpecialPause = 0.0;
			TweenToRunning(0.1);
			FinishAnim();
			PlayRunning();
		}
		MoveToward(MoveTarget);
	}
	Goto('GoToGuard');

Turn:
	//log(class$" got to guardpoint");
	Acceleration = vect(0,0,0);
	TweenToFighter(0.3);
	FinishAnim();
	PlayTurning();
	if (OrderObject != none)
		TurnTo( Location + 1000 * vector(OrderObject.Rotation) );

	NextAnim = '';
	bReadyToAttack = false;
	TweenToPatrolStop(0.2);
	FinishAnim();
	Enable('AnimEnd');
	NextAnim = '';
	PlayPatrolStop();
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	//if (Physics != PHYS_Falling)
	//	SetPhysics(PHYS_None);
	Acceleration = vect(0,0,0);
}

state Ambushing
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;

		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}

	function Landed(vector HitNormal)
	{
		//SetPhysics(PHYS_None);
		Acceleration = vect(0,0,0);
	}

	function SetFall()
	{
		NextState = 'Ambushing';
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function AnimEnd()
	{
		PlayWaitingAmbush();
	}

	function EnemyAcquired()
	{
		local Ambushpoint oldspot;

		//log(Class$" just acquired an enemy");
		MakeNoise(1.0);
		oldspot = Ambushpoint(OrderObject);
		if (oldspot != None)
			oldspot.taken = false;
		SetMovementPhysics();
		GotoState('Attacking');
	}

	function FindAmbush()
	{
		local Ambushpoint newspot;
		local float count;
		count = 0;
		//FIXME- instead of looking for pawn's spots, look for any nearby spot
		foreach AllActors( class 'Ambushpoint', newspot, tag )
		{
			if ( !newspot.taken )
			{
				count += 1;
				if (FRand() < 1/count)
					OrderObject = newspot;
			}
		}
	}

	function BeginState()
	{
		Disable('AnimEnd');
		SpecialGoal = None;
		SpecialPause = 0.0;
		OldEnemy = Enemy;
		Enemy = None;
		SetAlertness(0.3);
	}

FindAmbushSpot:
	if ((OldEnemy == None) || (FRand() < 0.7))
	{
		FindAmbush();
		if (Ambushpoint(OrderObject) != None)
		{
			//log("move to ambush spot");
			Disable('Landed');
			OldEnemy = None;
			Ambushpoint(OrderObject).taken = true;
			SetMovementPhysics();
			TweenToRunning(0.2);
			FinishAnim();
			PlayRunning();
MoveToAmbush:
			WaitForLanding();
			if (actorReachable(OrderObject))
				MoveToward(OrderObject);
			else
			{
				if (SpecialGoal != None)
					MoveTarget = FindPathToward(SpecialGoal);
				else
					MoveTarget = FindPathToward(OrderObject);
				if (MoveTarget != None)
				{
SpecialNavig:
					if (SpecialPause > 0.0)
					{
						Acceleration = vect(0,0,0);
						TweenToPatrolStop(0.3);
						Sleep(SpecialPause);
						SpecialPause = 0.0;
						TweenToRunning(0.1);
						FinishAnim();
						PlayRunning();
					}
					MoveToward(MoveTarget);
					Goto('MoveToAmbush');
				}
				else
					StartRoaming();
			}
			if (Physics != PHYS_Falling)
				Acceleration = vect(0,0,0);
			DesiredSpeed = 0.0;
			TweenToFighter(0.2);
			FinishAnim();
			PlayTurning();
			TurnTo(Location + (Ambushpoint(OrderObject)).lookdir);
		}
	}

Begin:
	NextAnim = '';
	Enable('Landed');
	Disable('AnimEnd');

	if (OldEnemy != None)
	{
		////log("turn toward probably enemy dir");
		OldEnemy = None;
		if (Physics != PHYS_Falling)
			Acceleration = vect(0,0,0);
		SetMovementPhysics();
		DesiredSpeed = 0.0;
		TweenToFighter(0.2);
		FinishAnim();
		PlayTurning();
		TurnTo(LastSeenPos); //FIXME - turn to a nearby pathnode?
	}

	DesiredSpeed = 0.0;
	bReadyToAttack = true;
	//log(class$" waiting in ambush");
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	Acceleration = vect(0,0,0);
	TweenToPatrolStop(0.3);
	FinishAnim();
	Enable('AnimEnd');
	NextAnim = '';
	PlayWaitingAmbush();
	setRotation(DesiredRotation);
	//if (Physics != PHYS_Falling)
	//	SetPhysics(PHYS_None);
	Acceleration = vect(0,0,0);
}

/* Acquisition -
Creature has just reacted to stimulus, and set an enemy
- depending on strength of stimulus, and ongoing stimulii, vary time to focus on target and start attacking (or whatever.  FIXME - need some acquisition specific animation
HearNoise and SeePlayer used to improve/change stimulus
*/

state Acquisition
{
	ignores falling, landed; //fixme

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{
		local eAttitude att;

		att = AttitudeTo(shooter);
		if ( ((att == ATTITUDE_Ignore) || (att == ATTITUDE_Threaten)) )
			damageAttitudeTo(shooter);
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
			LastSeenPos = Enemy.Location;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else
			GotoState('Attacking');
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			OldLastSeenPos = LastSeenPos;
			if ( Enemy ==  NoiseMaker.instigator  )
				LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			else if ( (Pawn(NoiseMaker) != None) && (Enemy == Pawn(NoiseMaker).Enemy) )
				LastSeenPos = 0.5 * (Pawn(NoiseMaker).Enemy.Location + VSize(Pawn(NoiseMaker).Enemy.Location - Location) * vector(Rotation));
			if ( VSizeSq(OldLastSeenPos - Enemy.Location) < VSizeSq(LastSeenPos - Enemy.Location) )
				LastSeenPos = OldLastSeenPos;
		}
	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			if( !bQuiet || BonusSkill==0.f )
				PlayAcquisitionSound();
			//log("Enemy Acquired!");
			MakeNoise(1.0);
			NextAnim = '';
			LastSeenPos = Enemy.Location;
			GotoState('Attacking');
		}
	}

	function BeginState()
	{
		Disable('Tick'); //only used for bounding anim time
		SetAlertness(-0.5);
	}

PlayOut:
	Acceleration = vect(0,0,0);
	if ( (AnimFrame < 0.6) && IsAnimating() )
	{
		Sleep(0.05);
		Goto('PlayOut');
	}

Begin:
	SetMovementPhysics();

AcquTurn:
	Acceleration = vect(0,0,0);
	if (NeedToTurn(LastSeenPos))
	{
		PlayTurning();
		TurnTo(LastSeenPos);
	}
	DesiredRotation = Rotator(LastSeenPos - Location);
	TweenToFighter(0.2);
	FinishAnim();
	if ( Enemy == self )
		Enemy = none;  //be sure
	if ( Enemy == None )
		WhatToDoNext('','');
	////log("Stimulus = "$Stimulus);
	if ( AttitudeTo(Enemy) == ATTITUDE_Fear )  //will run away from noise
	{
		LastSeenPos = Enemy.Location;
		MakeNoise(1.0);
		NextAnim = '';
		GotoState('Attacking');
	}
	else
	{     // dont start start monster wars but help if player
		MoveTarget = FindPathToward(Enemy);
		if ((Enemy.bIsPlayer || Level.Game.IsA('TeamGame'))&&(Intelligence > BRAINS_Reptile || Skill>2 )
				&& ( LineOfSightTo(Enemy) || ActorReachable(Enemy) || MoveTarget!=none ))
		{
			LastSeenPos = Enemy.Location;
			MakeNoise(1.0);
			NextAnim = '';
			GotoState('Attacking');
		}
		else   //investigate noise
		{
			////log("investigate noise");
			if ( pointReachable((Location + LastSeenPos) * 0.5) )
			{
				TweenToWalking(0.3);
				FinishAnim();
				PlayWalking();
				MoveTo((Location + LastSeenPos) * 0.5, WalkingSpeed);
				Acceleration = vect(0,0,0);
			}
			WhatToDoNext('','');
		}
	}
}

/* Attacking
Master attacking state - choose which type of attack to do from here
*/
state Attacking
{
	ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local EAttitude AttitudeToEnemy, AttitudeToOldEnemy;
		local pawn changeEn;

		if ( !HasAliveEnemy() )
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
		if ( Level.Game.GameRules!=None )
			AttitudeToEnemy = GetModifiedAttitude(AttitudeToEnemy,Enemy);

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
			if (IsAlivePawn(OldEnemy) && OldEnemy != self)
				AttitudeToOldEnemy = AttitudeTo(OldEnemy);
			else
				OldEnemy = none;

			if (OldEnemy != none &&
				(AttitudeToOldEnemy == ATTITUDE_Hate || AttitudeToOldEnemy == ATTITUDE_Frenzy) &&
				LineOfSightTo(OldEnemy))
			{
				changeEn = enemy;
				enemy = oldenemy;
				oldenemy = changeEn;
			}
			else
			{
				if ( (Orders == 'Guarding') && !LineOfSightTo(OrderObject) )
					GotoState('Guarding');
				else if( bIsPackHunter && AIFindBackup() )
				{
					GotoState('AIRetreat');
					return;
				}
				else if ( !bHasRangedAttack || Enemy.Level!=Level || VSizeSq(Enemy.Location-Location)>Square(600+(FRand()*RelativeStrength(Enemy)-CombatStyle)*600.f) )
					GotoState('Hunting');
				else if ( bIsBoss || (Intelligence > BRAINS_None) )
				{
					HuntStartTime = Level.TimeSeconds;
					NumHuntPaths = 0;
					GotoState('StakeOut');
				}
				else WhatToDoNext('Waiting', 'TurnFromWall');
				return;
			}
		}

		else if ( (TeamLeader != None) && TeamLeader.ChooseTeamAttackFor(self) )
			return;

		if (bReadyToAttack && Enemy.Level==Level )
		{
			Target = Enemy;
			If (VSizeSq(Enemy.Location - Location) <= Square(MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			{
				GotoState('MeleeAttack');
				return;
			}
			else if( bIsPackHunter && AIFindBackup() )
			{
				GotoState('AIRetreat');
				return;
			}
			else if (bMovingRangedAttack)
				SetTimer(TimeBetweenAttacks, False);
			else if (bHasRangedAttack && (bIsPlayer || Enemy.bIsPlayer) && CanFireAtEnemy() )
			{
				if (!bIsPlayer || (2.5 * FRand() > Skill) )
				{
					GotoState('RangedAttack');
					return;
				}
			}
		}
		else if( bIsPackHunter && AIFindBackup() )
		{
			GotoState('AIRetreat');
			return;
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

Begin:
	//log(class$" choose Attack");
	ChooseAttackMode();
}

state Threatening
{
	ignores falling, landed; //fixme

//ignores SeePlayer if enemy is a player //but not hear noise
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme)
			return;
		if (NextState == 'TakeHit')
		{
			bReadyToAttack = true;
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else
		{
			bReadyToAttack = true;
			GotoState('Attacking');
		}
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if (EventInstigator != none && EventInstigator.bIsPlayer)
		{
			Enemy = EventInstigator;
			AttitudeToPlayer = ATTITUDE_Hate;
			GotoState('Attacking');
		}
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		GotoState('Ambushing');
	}

	function EnemyAcquired()
	{
		if (AttitudeTo(Enemy) < ATTITUDE_Threaten)
			GotoState('Attacking');
	}

	function PickGuardDestination()
	{
		local vector desiredDest;
		local Actor path;

		if (OrderObject == none)
		{
			Destination = Location;
			return;
		}

		desiredDest = OrderObject.Location +
					  (OrderObject.CollisionRadius + 2.5 * CollisionRadius) * Normal(Enemy.Location - OrderObject.Location);

		if ( VSizeSq(desiredDest - Location) < {60.0*60.0} )
		{
			Destination = Location;
			return;
		}

		if (pointReachable(desiredDest))
			Destination = desiredDest;
		else
		{
			path = FindPathTo(desiredDest, true);
			if (path != None)
			{
				MoveTarget = path;
				Destination = path.Location;
			}
			else
				Destination = Location;
		}
	}

	function PickThreatenDestination()
	{
		local vector desiredDest;
		local Actor path;

		desiredDest = Location +
					  0.4 * (VSize(Enemy.Location - Location) - CollisionRadius - Enemy.CollisionRadius - MeleeRange)
					  * Normal(Enemy.Location - Location);

		if (pointReachable(desiredDest))
			Destination = desiredDest;
		else
		{
			path = FindPathTo(desiredDest, true);
			if (path != None)
			{
				MoveTarget = path;
				Destination = path.Location;
			}
			else
				Destination = Location;
		}
	}

	function BeginState()
	{
		bCanJump = false;
	}

	function EndState()
	{
		if (JumpZ > 0)
			bCanJump = true;
	}

Begin:
	Acceleration = vect(0,0,0);
	bReadyToAttack = true;
	if (Enemy != none && Enemy.bIsPlayer)
		Disable('SeePlayer'); //but not hear noise
	TweenToPatrolStop(0.2);
	FinishAnim();
	NextAnim = '';

FaceEnemy:
	if (!HasAliveEnemy())
		GotoState('Attacking');
	Acceleration = vect(0,0,0);
	if (NeedToTurn(enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToPatrolStop(0.2);
		FinishAnim();
		NextAnim = '';
	}

Threaten:
	if (!HasAliveEnemy() || AttitudeTo(Enemy) < ATTITUDE_Threaten)
		GotoState('Attacking');

	PlayThreatening();
	FinishAnim();

	if (!HasAliveEnemy() || AttitudeTo(Enemy) < ATTITUDE_Threaten)
		GotoState('Attacking');

	if (Orders == 'Guarding')
	{ //stay between enemy and guard object
		if (Enemy.bIsPlayer && OrderObject != none &&
			(VSizeSq(Enemy.Location - OrderObject.Location) < Square(OrderObject.CollisionRadius + 2 * CollisionRadius + MeleeRange)))
		{
			AttitudeToPlayer = ATTITUDE_Hate;
			GotoState('Attacking');
		}
	}
	else if (FRand() < 0.9 - Aggressiveness) //mostly just turn
		Goto('FaceEnemy');
	else if (VSizeSq(Enemy.Location - Location) < Square(2.5 * (CollisionRadius + Enemy.CollisionRadius + MeleeRange)))
		Goto('FaceEnemy');

	WaitForLanding();
	if (!HasAliveEnemy() || AttitudeTo(Enemy) < ATTITUDE_Threaten)
		GotoState('Attacking');

	if (Orders == 'Guarding') //stay between enemy and guard object
		PickGuardDestination();
	else
		PickThreatenDestination();

	if (Destination != Location)
	{
		TweenToWalking(0.2);
		FinishAnim();
		PlayWalking();
		MoveTo(Destination, WalkingSpeed);
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.2);
		FinishAnim();
		NextAnim = '';
	}

	Goto('FaceEnemy');
}

state Retreating
{
	ignores SeePlayer, EnemyNotVisible, HearNoise;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Retreating';
			NextLabel = 'TakeHit';
			GotoState('TakeHit');
		}
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Retreating';
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
			GotoState('Retreating', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Retreating', 'AdjustFromWall');
		}
		else
		{
			Home = None;
			MoveTimer = -1.0;
		}
	}

	/* if has a base then run toward it if its not visible to player. (FIXME)
	adjusts attitude based on proximity to base
	Else pick a random pathnode not visible to player and run toward it.
	Also - modify weights of paths visible and near to player up.
	*/
	function PickDestination()
	{
		//log("find retreat destination");
		if ( !HasAliveEnemy() )
		{
			WhatToDoNext('','');
			return;
		}

		if ( Level.NavigationPointList == None )
		{
			Aggressiveness += 0.3;
			GotoState( 'Attacking' );
			return;
		}

		if (HomeBase(Home) == None)
		{
			Home = FindRandomDest(); //find temporary home
			if (Home == None)
			{
				if (bReadyToAttack)
				{
					setTimer(3.0, false);
					Target = Enemy;
					GotoState('RangedAttack');
				}
				else
				{
					Aggressiveness += 0.3;
					GotoState('TacticalMove', 'NoCharge');
				}
			}
		}
	}

	function ChangeDestination()
	{
		local actor oldTarget;
		local Actor path;

		oldTarget = Home;
		PickDestination();
		if (Home == oldTarget)
		{
			Aggressiveness += 0.3;
			//log("same old target");
			GotoState('TacticalMove', 'TacticalTick');
		}
		else
		{
			path = FindPathToward(Home);
			if (path == None)
			{
				//log("no new target");
				Aggressiveness += 0.3;
				GotoState('TacticalMove', 'TacticalTick');
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
		if ( Health <= 0 || bDeleteme )
			return;
		if (Pawn(Other) != None)
		{
			if ( (Other == Enemy) || SetEnemy(Pawn(Other)) )
				GotoState('MeleeAttack');
			else if ( (HomeBase(Home) != None)
					  && (VSizeSq(Location - Home.Location) < Square(HomeBase(Home).Extent)) )
				ReachedHome();
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
		if ( Health <= 0 || bDeleteme )
			return;
		if (HasAliveEnemy() && LineOfSightTo(Enemy))
		{
			if (Homebase(home) != None)
			{
				//log(class$" reached home base - turn and fight");
				Aggressiveness += 0.2;
				if ( !bMoraleBoosted )
					health = Min(default.health, health+20);
				MakeNoise(1.0);
				GotoState('Attacking');
			}
			else
				ChangeDestination();
		}
		else
		{
			if (Homebase(home) != None)
				MakeNoise(1.0);
			aggressiveness += 0.2;
			if ( !bMoraleBoosted )
				health = Min(default.health, health+5);
			GotoState('Retreating', 'TurnAtHome');
		}
		bMoraleBoosted = true;
	}

	function PickNextSpot()
	{
		local Actor path;
		local vector dist2d;

		if ( Home == None )
		{
			PickDestination();
			if ( Home == None )
				return;
		}
		//log("find retreat spot");
		dist2d = Home.Location - Location;
		if ((VSize2DSq(dist2d) < Square(2 * CollisionRadius)) && (Abs(dist2d.Z) < CollisionHeight))
			ReachedHome();
		else
		{
			if (ActorReachable(Home))
			{
				//log("almost there");
				path = Home;
				if (HomeBase(Home) == None)
					Home = None;
			}
			else
			{
				if (SpecialGoal != None)
					path = FindPathToward(SpecialGoal);
				else
					path = FindPathToward(Home);
			}

			if (path == None)
				ChangeDestination();
			else
			{
				MoveTarget = path;
				Destination = path.Location;
			}
		}
	}

	function AnimEnd()
	{
		if ( bSpecialPausing )
			PlayPatrolStop();
		else if ( bCanFire && HasAliveEnemy() && LineOfSightTo(Enemy) )
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

Begin:
	//log(class$" retreating");
	if ( !HasAliveEnemy() )
		GotoState('Attacking');
	if ( bReadyToAttack && (FRand() < 0.6) )
	{
		SetTimer(TimeBetweenAttacks, false);
		bReadyToAttack = false;
	}
	TweenToRunning(0.1);
	WaitForLanding();
	PickDestination();

Landed:
	TweenToRunning(0.1);

RunAway:
	PickNextSpot();
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( Enemy!=none && LineOfSightTo(Enemy))
		{
			bFiringPaused = true;
			NextState = 'Retreating';
			NextLabel = 'Moving';
			GotoState('RangedAttack');
		}
		bSpecialPausing = true;
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.25);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		bSpecialPausing = false;
		TweenToRunning(0.1);
	}
Moving:
	if ( !HasAliveEnemy() )
		GotoState('Attacking');
	if ( MoveTarget == None )
	{
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
			(Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z))
									Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0) )
	{
		bCanFire = false;
		MoveToward(MoveTarget);
	}
	else
	{
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	if ( !IsAnimating() )
		PlayRunning();
	StrafeTo(Destination, Focus);
	Destination = Focus;
	MoveTo(Destination);
	Goto('Moving');

TurnAtHome:
	Acceleration = vect(0,0,0);
	if (HomeBase(Home) != None)
		TurnTo(Homebase(Home).lookdir);
	GotoState('Ambushing', 'FindAmbushSpot');
}

state Charging
{
	ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		if ( MoveTarget != Enemy )
			return;

		if ( intelligence == BRAINS_None )
			return;

		bCanJump = ActorReachable(Enemy);
		if ( !bCanJump )
			GotoState('TacticalMove', 'NoCharge');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			bSpecialGoal = true;
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Charging', 'SpecialNavig');
			return;
		}
		Focus = Destination;

		if ( PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				gotoState('Charging', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function SetFall()
	{
		NextState = 'Charging';
		NextLabel = 'ResumeCharge';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
		GotoState('TacticalMove', 'DoStrafeMove');
	}

	function bool StrafeFromDamage(vector momentum, float Damage, name DamageType, bool bFindDest)
	{
		local vector sideDir, extent, HitLocation, HitNormal;
		local actor HitActor;
		local float healthpct;

		if ( (damageType == 'shot') || (damageType == 'jolted') )
			healthpct = 0.17;
		else
			healthpct = 0.25;

		healthpct *= CombatStyle;
		if ( FRand() * Damage < healthpct * Health )
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
		if ( (momentum Dot sidedir) > 0 )
			sidedir *= -1;
		Extent = GetExtent();
		HitActor = Trace(HitLocation, HitNormal, Location + 100 * sideDir, Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Location + 100 * sideDir, Location, false, Extent);
		}
		if (HitActor != None)
			return false;

		if ( Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Location + 100 * sideDir - MaxStepHeight * vect(0,0,1), Location + 100 * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Location + 250 * sideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;

		bWasOnGround = (Physics == PHYS_Walking);
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			if (!HasAliveEnemy())
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			else if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else if ( (Intelligence > BRAINS_Mammal) && bHasRangedAttack && bCanStrafe
					  && StrafeFromDamage(momentum, Damage, damageType, false) )
			{
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
		else if ( (Intelligence > BRAINS_Mammal) && bHasRangedAttack && bCanStrafe
				  && StrafeFromDamage(momentum, Damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) &&
				  (Physics == PHYS_Falling) && (Intelligence == BRAINS_Human) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Velocity += pick * GroundSpeed * 0.7 * sideDir;
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	function AnimEnd()
	{
		PlayCombatMove();
	}

	function Timer()
	{
		bReadyToAttack = True;
		if ( !HasAliveEnemy() )
		{
			GotoState('Attacking');
			return;
		}
		Target = Enemy;
		if (VSizeSq(Enemy.Location - Location)
				<= Square(MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('MeleeAttack');
		else if ( bHasRangedAttack && (FRand() > 0.7 + 0.1 * skill) )
			GotoState('RangedAttack');
		else if ( bHasRangedAttack && !bMovingRangedAttack)
		{
			if ( FRand() < CombatStyle * 0.8 ) //then keep charging
				SetTimer(1.0,false);
			else
				GotoState('Attacking');
		}
	}

	function EnemyNotVisible()
	{
		GotoState('Hunting');
	}

	function BeginState()
	{
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

	function EndState()
	{
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
	if ( !IsAnimating() )
		PlayRunning();
	StrafeTo(Destination, Focus);
	Goto('CloseIn');

ResumeCharge:
	PlayRunning();
	Goto('Charge');

Begin:
	TweenToRunning(0.15);

Charge:
	bFromWall = false;

CloseIn:
	if (!HasAliveEnemy())
		GotoState('Attacking');

	if ( Enemy.Region.Zone.bWaterZone )
	{
		if (!bCanSwim)
			GotoState('TacticalMove', 'NoCharge');
	}
	else if (!bCanFly && !bCanWalk)
		GotoState('TacticalMove', 'NoCharge');

	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
		if (!HasAliveEnemy())
			GotoState('Attacking');
	}
	if ( (Intelligence <= BRAINS_Reptile) || actorReachable(Enemy) )
	{
		bCanFire = true;
		if ( FRand() < 0.3 )
			PlayThreateningSound();
		MoveToward(Enemy);
		if (bFromWall)
		{
			bFromWall = false;
			if (PickWallAdjust())
			{
				if ( Physics == PHYS_Falling )
					SetFall();
				else
					StrafeFacing(Destination, Enemy);
			}
			else
				GotoState('TacticalMove', 'NoCharge');
		}
	}
	else
	{
NoReach:
		if (!HasAliveEnemy())
			GotoState('Attacking');
		bCanFire = false;
		bFromWall = false;
		//log("route to enemy "$Enemy);
		if (!FindBestPathToward(Enemy))
		{
			Sleep(0.0);
			GotoState('TacticalMove', 'NoCharge');
		}
SpecialNavig:
		if ( SpecialPause > 0.0 )
		{
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Charging';
			NextLabel = 'Moving';
			GotoState('RangedAttack');
		}
Moving:
		if (!IsAnimating())
			AnimEnd();
		if (!HasAliveEnemy())
			GotoState('Attacking');
		if (MoveTarget != none)
		{
			if (VSizeSq(MoveTarget.Location - Location) < Square(2.5 * CollisionRadius))
			{
				bCanFire = true;
				StrafeFacing(MoveTarget.Location, Enemy);
			}
			else
			{
				if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
						(Skill - 2 * FRand() + (Normal2D(Enemy.Location - Location) Dot Normal2D(MoveTarget.Location - Location)) < 0) )
				{
					if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
					{
						AnimSequence = '';
						TweenToRunning(0.12);
					}
					MoveToward(MoveTarget);
				}
				else
				{
					bCanFire = true;
					StrafeFacing(MoveTarget.Location, Enemy);
				}
				if ( !bFromWall && (FRand() < 0.5) )
					PlayThreateningSound();
			}
		}
	}
	//log("finished move");
	if (Enemy && VSizeSq(Location - Enemy.Location) < Square(CollisionRadius + Enemy.CollisionRadius + MeleeRange))
		goto('GotThere');
	if ( bIsPlayer || (!bFromWall && bHasRangedAttack && (FRand() > CombatStyle + 0.1)) )
		gotoState('Attacking');
	MoveTimer = 0.0;
	bFromWall = false;
	goto('CloseIn');

GotThere:
	////log("Got to enemy");
	if (!HasAliveEnemy())
		GotoState('Attacking');
	Target = Enemy;
	GotoState('MeleeAttack');

TakeHit:
	if (!HasAliveEnemy())
		GotoState('Attacking');
	TweenToRunning(0.12);
	if (MoveTarget == Enemy)
	{
		bCanFire = true;
		MoveToward(MoveTarget);
	}

	Goto('Charge');
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function SetFall()
	{
		Acceleration = vect(0,0,0);
		Destination = Location;
		NextState = 'Attacking';
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'TacticalMove';
			NextLabel = 'TakeHit';
			GotoState('TakeHit');
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Focus = Destination;
		if (!HasAliveEnemy())
		{
			GotoState('Attacking');
			return;
		}
		if ( bChangeDir || (FRand() < 0.5)
				|| (((Enemy.Location - Location) Dot HitNormal) < 0) )
		{
			DesiredRotation = Rotator(Enemy.Location - location);
			GiveUpTactical(false);
		}
		else
		{
			bChangeDir = true;
			Destination = Location - HitNormal * FRand() * 500;
		}
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
	}

	function AnimEnd()
	{
		PlayCombatMove();
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
		if (!HasAliveEnemy())
		{
			GotoState('Attacking');
			return;
		}
		Target = Enemy;
		if (VSizeSq(Enemy.Location - Location) <= Square(MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('MeleeAttack');
		else if ( bHasRangedAttack && ((!bMovingRangedAttack && (FRand() < 0.8)) || (FRand() > 0.5 + 0.17 * skill)) )
			GotoState('RangedAttack');
	}

	function EnemyNotVisible()
	{
		if (!HasAliveEnemy())
			GotoState('Attacking');
		else if ( aggressiveness > relativestrength(enemy) )
		{
			if (ValidRecovery())
				GotoState('TacticalMove','RecoverEnemy');
			else
				GotoState('Attacking');
		}
		Disable('EnemyNotVisible');
	}


	function bool ValidRecovery()
	{
		if (!HasAliveEnemy())
			return false;
		return FastTrace(Enemy.Location, LastSeeingPos);
	}

	function GiveUpTactical(bool bNoCharge)
	{
		if ( !bNoCharge && (2 * CombatStyle > (3 - Skill) * FRand()) )
			GotoState('Charging');
		else if ( bReadyToAttack && (skill > 3 * FRand() - 1) )
			GotoState('RangedAttack');
		else
			GotoState('RangedAttack', 'Challenge');
	}

	/* PickDestination()
	Choose a destination for the tactical move, based on aggressiveness and the tactical
	situation. Make sure destination is reachable
	*/
	function PickDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);

		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if (!HasAliveEnemy())
		{
			WhatToDoNext('Waiting', 'TurnFromWall');
			return;
		}
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);

		success = false;
		enemydist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( intelligence == BRAINS_Human )
		{
			if ( Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear) && (CombatStyle > 0) )
				Aggression = Aggression - 2 - 2 * CombatStyle;
			if ( Weapon != None )
				Aggression += 2 * Weapon.SuggestAttackStyle();
			if ( Enemy.Weapon != None )
				Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
		}

		if ( enemydist > 1000 )
			Aggression += 1;
		if ( bIsPlayer && !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 140) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Intelligence > BRAINS_Reptile)
						&& (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemydist < 1.1 * (Enemy.Location.Z - Location.Z))
						  && !actorReachable(Enemy) )
				{
					bNoReach = (Intelligence > BRAINS_None);
					aggression = -1.5 * FRand();
				}
			}
		}

		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.15);
				gotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if (enemydist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();

		enemydir = (Enemy.Location - Location)/enemydist;
		minDist = FMin(160.0, 3*CollisionRadius);
		if ( bIsPlayer )
			optDist = 80 + FMin(enemydist, 250 * (FRand() + FRand()));
		else
			optDist = 50 + FMin(enemydist, 500 * FRand());
		Y = (enemydir Cross vect(0,0,1));
		if ( Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else
			enemydir.Z = FMax(0,enemydir.Z);

		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);

		minDest = Location + minDist * (pickdir + enemyPart);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if (success)
				Destination = minDest + (pickdir + enemyPart) * optDist;
		}

		if ( !success )
		{
			collSpec.X = CollisionRadius;
			collSpec.Y = CollisionRadius;
			minDest = Location + minDist * (enemyPart - pickdir);
			HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
			if (HitActor == None)
			{
				success = (Physics != PHYS_Walking);
				if ( !success )
				{
					collSpec.X = FMin(14, 0.5 * CollisionRadius);
					collSpec.Y = collSpec.X;
					HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
					success = (HitActor != None);
				}
				if (success)
					Destination = minDest + (enemyPart - pickdir) * optDist;
			}
			else
			{
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear)) )
					enemyPart = vect(0,0,0);
				else if ( (enemydir Dot enemyPart) < 0 )
					enemyPart = -1 * enemyPart;
				pickdir = Normal(enemyPart - pickdir + HitNormal);
				minDest = Location + minDist * pickdir;
				collSpec.X = CollisionRadius;
				collSpec.Y = CollisionRadius;
				HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
				if (HitActor == None)
				{
					success = (Physics != PHYS_Walking);
					if ( !success )
					{
						collSpec.X = FMin(14, 0.5 * CollisionRadius);
						collSpec.Y = collSpec.X;
						HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
						success = (HitActor != None);
					}
					if (success)
						Destination = minDest + pickdir * optDist;
				}
			}
		}

		if ( !success )
			GiveUpTactical(bNoCharge);
		else
		{
			pickdir = (Destination - Location);
			enemydist = VSize(pickdir);
			if ( enemydist > minDist + 2 * CollisionRadius )
			{
				pickdir = pickdir/enemydist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickdir) < -0.6) )
					Destination = HitLocation - 2 * CollisionRadius * pickdir;
			}
		}
	}

	function BeginState()
	{
		MinHitWall += 0.15;
		bAvoidLedges = ( !bCanJump && (CollisionRadius > 40) );
		bCanJump = false;
		bCanFire = false;
	}

	function EndState()
	{
		bAvoidLedges = false;
		MinHitWall -= 0.15;
		if (JumpZ > 0)
			bCanJump = true;
	}

//FIXME - what if bReadyToAttack at start
TacticalTick:
	Sleep(0.02);
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (!HasAliveEnemy())
		GotoState('Attacking');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(false);

DoMove:
	if ( !bCanStrafe )
	{
DoDirectMove:
		Enable('AnimEnd');
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
		{
			AnimSequence = '';
			TweenToRunning(0.12);
		}
		bCanFire = false;
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);
	}
	if (FRand() < 0.5)
		PlayThreateningSound();

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && ValidRecovery() )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}

NoCharge:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (!HasAliveEnemy())
		GotoState('Attacking');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(true);
	Goto('DoMove');

AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus);
	Destination = Focus;
	Goto('DoMove');

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

RecoverEnemy:
	if (!HasAliveEnemy())
		GotoState('Attacking');
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	Destination = LastSeeingPos + 3 * CollisionRadius * Normal(LastSeeingPos - Location);
	if ( bCanStrafe || (VSizeSq(LastSeeingPos - Location) < Square(3.f * CollisionRadius)) )
		StrafeFacing(Destination, Enemy);
	else
		MoveTo(Destination);
	if ( Weapon == None )
		Acceleration = vect(0,0,0);
	if (HasAliveEnemy() && NeedToTurn(Enemy.Location) )
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	if ( bHasRangedAttack && CanFireAtEnemy() )
	{
		Disable('AnimEnd');
		DesiredRotation = Rotator(Enemy.Location - Location);
		if ( Weapon == None )
		{
			PlayRangedAttack();
			FinishAnim();
			TweenToRunning(0.1);
			bReadyToAttack = false;
			SetTimer(TimeBetweenAttacks, false);
		}
		else
		{
			FireWeapon();
			if ( Weapon.bSplashDamage )
			{
				bFire = 0;
				bAltFire = 0;
			}
		}

		if ( bCanStrafe && (FRand() + 0.1 > CombatStyle) )
		{
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}
	if ( !bMovingRangedAttack )
		bReadyToAttack = false;

	GotoState('Attacking');
}

state Hunting
{
	ignores EnemyNotVisible;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		bCanJump = ( (intelligence == BRAINS_None) || (MoveTarget != None) || PointReachable(Destination) );
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
		GotoState('Wandering', 'Moving');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		bFrustrated = true;
		if (NextState == 'TakeHit')
		{
			if (Enemy != None && AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Hunting';
				NextLabel = 'AfterFall';
			}
			GotoState('TakeHit');
		}
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location;
	}

	function SetFall()
	{
		NextState = 'Hunting';
		NextLabel = 'AfterFall';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		local float rnd;

		if (Global.SetEnemy(NewEnemy))
		{
			rnd = FRand();
			if ( bReadyToAttack && (!bQuiet || BonusSkill==0.f) )
			{
				if (rnd < 0.3)
					PlayAcquisitionSound();
				else if (rnd < 0.6)
					PlayThreateningSound();
			}
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			if ( !bHasRangedAttack || (CombatStyle > FRand()) )
				GotoState('Charging');
			else
				GotoState('Attacking');
			return true;
		}
		return false;
	}

	function AnimEnd()
	{
		PlayRunning();
		Disable('AnimEnd');
	}

	function Timer()
	{
		bReadyToAttack = true;
		Enable('Bump');
		SetTimer(1.0, false);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Hunting', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Hunting', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot;
		local float posZ, elapsed;
		local bool bCanSeeLastSeen;

		// If no enemy, or I should see him but don't, then give up
		if (!HasAliveEnemy())
		{
			Enemy = none;
			WhatToDoNext('','');
			return;
		}

		bAvoidLedges = false;
		elapsed = Level.TimeSeconds - HuntStartTime;
		if( BonusSkill>0.f )
			elapsed*=(1.f - (BonusSkill*0.3f));
		if ( (elapsed > 30) && ((intelligence < BRAINS_Human) || (elapsed > 90)) )
		{
			WhatToDoNext('','');
			return;
		}

		if ( JumpZ > 0 )
			bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			if ( BonusSkill>0.f || bIsBoss || (numHuntPaths < 8 + Skill) || (elapsed < 15)
					|| ((Normal(Enemy.Location - Location) Dot vector(Rotation)) > -0.5) )
			{
				Destination = Enemy.Location;
				MoveTarget = None;
				numHuntPaths++;
			}
			else
				WhatToDoNext('','');
			return;
		}
		numHuntPaths++;

		ViewSpot = Location + EyeHeight * vect(0,0,1);
		bCanSeeLastSeen = false;
		if ( (BonusSkill>0.f) ? (intelligence >= BRAINS_Reptile) : (intelligence > BRAINS_Reptile) )
		{
			bCanSeeLastSeen = FastTrace(LastSeenPos, ViewSpot);
			if ( bCanSeeLastSeen )
				bHunting = !FastTrace(LastSeenPos, Enemy.Location);
			else bHunting = true;
			if ( FindBestPathToward(Enemy) )
				return;
		}

		MoveTarget = None;
		if ( bFromWall )
		{
			bFromWall = false;
			if ( !PickWallAdjust() )
			{
				if ( CanStakeOut() )
					GotoState('StakeOut');
				else
					WhatToDoNext('', '');
			}
			return;
		}

		if ( !bIsBoss && (NumHuntPaths > 20 + int(BonusSkill*5)) && ((Intelligence < BRAINS_Human) || (NumHuntPaths > 60 + int(BonusSkill*10))) )
		{
			WhatToDoNext('', '');
			return;
		}

		if ( LastSeeingPos != vect(1000000,0,0) )
		{
			Destination = LastSeeingPos;
			LastSeeingPos = vect(1000000,0,0);
			if ( FastTrace(Enemy.Location, ViewSpot) )
			{
				If( VSizeSq(Location - Destination) < {20.0*20.0} )
					SetEnemy(Enemy);
				return;
			}
		}

		bAvoidLedges = ( (CollisionRadius > 42) && (Intelligence < BRAINS_Human) );
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot,ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
					GotoState('Hunting', 'AdjustFromWall');
				else if ( bIsBoss || VSize(Enemy.Location - Location) < 1200 )
					GotoState('StakeOut');
				else
				{
					WhatToDoNext('Waiting', 'TurnFromWall');
					return;
				}
			}
		}
		LastSeenPos = Enemy.Location;
	}

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		if ( Enemy == None || Enemy.bDeleteme)
			return false;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;

		if ( FastTrace(Enemy.Location, Location + 2 * Y * CollisionRadius) )
		{
			Destination = Location + 2.5 * Y * CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Location - 2 * Y * CollisionRadius) )
		{
			Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Location - 2.5 * Y * CollisionRadius;
			else
				Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		bFromWall = false;
		SetAlertness(0.5);
		if (Enemy!=none && !Enemy.bDeleteme)
			LastSeenPos = Enemy.Location;
	}

	function EndState()
	{
		bAvoidLedges = false;
		bHunting = false;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus);
	Destination = Focus;
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Begin:
	numHuntPaths = 0;
	HuntStartTime = Level.TimeSeconds;

AfterFall:
	if (!HasAliveEnemy())
		GotoState('Attacking');
	TweenToRunning(0.15);
	bFromWall = false;

Follow:
	WaitForLanding();
	if (!HasAliveEnemy())
		GotoState('Attacking');
	if ( CanSee(Enemy) )
	{
		SetEnemy(Enemy);
		LastSeenPos = Enemy.Location;
	}
	PickDestination();

SpecialNavig:
	if ( SpecialPause > 0.0 )
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		PlayChallenge();
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		Goto('AfterFall');
	}
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget);
	if ( Intelligence < BRAINS_Human )
	{
		if ( FRand() > 0.3 )
			PlayRoamingSound();
		else if ( FRand() > 0.3 )
			PlayThreateningSound();
	}
	if ( (Orders == 'Guarding') && !LineOfSightTo(OrderObject) )
		GotoState('Guarding');
	Goto('Follow');
}

state StakeOut
{
ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		bFrustrated = true;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
			LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			if (Enemy != None && AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			GotoState('TakeHit');
		}
		else
			GotoState('Attacking');
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location;
	}

	function SetFall()
	{
		NextState = 'StakeOut';
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		local float rnd;

		if (Global.SetEnemy(NewEnemy))
		{
			rnd = FRand();
			if (rnd < 0.3)
				PlayAcquisitionSound();
			else if (rnd < 0.6)
				PlayThreateningSound();
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			GotoState('Attacking');
			return true;
		}
		return false;
	}

	function Timer()
	{
		bReadyToAttack = true;
		Enable('Bump');
		SetTimer(1.0, false);
	}

	function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
	{
		local rotator FireRotation;
		local vector FireSpot;

		FireSpot = LastSeenPos;
		aimerror = aimerror * (0.5 * (4 - skill - FRand()));

		if ( !FastTrace(FireSpot, ProjStart) )
		{
			////log("adjust aim up");
			if( Enemy )
				FireSpot.Z += 0.9 * Enemy.CollisionHeight;
			bClearShot = FastTrace(FireSpot, ProjStart);
			if ( !bClearShot )
				FireSpot = LastSeenPos;
		}

		FireRotation = Rotator(FireSpot - ProjStart);

		FireRotation.Yaw = FireRotation.Yaw + 0.5 * (Rand(2 * aimerror) - aimerror);
		viewRotation = FireRotation;
		return FireRotation;
	}

	function BeginState()
	{
		if (!HasAliveEnemy())
		{
			GotoState('Attacking');
			return;
		}
		Acceleration = vect(0,0,0);
		bCanJump = false;
		bClearShot = FastTrace(LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location + vect(0,0,0.8) * EyeHeight);
		bReadyToAttack = true;
		SetAlertness(0.5);
	}

	function EndState()
	{
		if ( JumpZ > 0 )
			bCanJump = true;
	}

Begin:
	Acceleration = vect(0,0,0);
	PlayChallenge();
	TurnTo(LastSeenPos);
	if (!HasAliveEnemy())
		GotoState('Attacking');
	if ( bHasRangedAttack && bClearShot && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 150) && CanStakeOut() )
		PlayRangedAttack();
	FinishAnim();
	PlayChallenge();
	if ( bCrouching && !Region.Zone.bWaterZone )
		Sleep(1);
	bCrouching = false;
	Sleep(1 + FRand());
	if (HasAliveEnemy())
	{
		if ( !bHasRangedAttack || !bClearShot || (VSize(Enemy.Location - Location)
				> 350 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 350) )
			GotoState('Hunting', 'AfterFall');
		else if ( CanStakeOut() )
			goto('Begin');
		else
			GotoState('Hunting', 'AfterFall');
	}
	else
		GotoState('Attacking');
}

state TakeHit
{
	ignores seeplayer, hearnoise, bump, hitwall;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	function Landed(vector HitNormal)
	{
		if (Velocity.Z < -1.4 * JumpZ)
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		bJustLanded = true;
	}

	function Timer()
	{
		bReadyToAttack = true;
		if ( SpeechTime > 0 )
		{
			SpeechTime = -1.0;
			bIsSpeaking = false;
			if ( TeamLeader != None )
				TeamLeader.bTeamSpeaking = false;
		}
	}

	singular function PlayHitAnim(vector HitLocation, float Damage)
	{
		if ( LastPainTime - Level.TimeSeconds > 0.1 )
		{
			PlayTakeHit(0.1, hitLocation, Damage);
			BeginState();
			GotoState('TakeHit', 'Begin');
		}
	}

	function BeginState()
	{
		LastPainTime = Level.TimeSeconds;
		LastPainAnim = AnimSequence;
		if (NextState == 'TakeHit')
			NextState = '';
	}

Begin:
	// Acceleration = Normal(Acceleration);
	FinishAnim();
	if ( skill < 2 )
		Sleep(0.05);
	if ( (Physics == PHYS_Falling) && !Region.Zone.bWaterZone )
	{
		Acceleration = vect(0,0,0);
		NextAnim = '';
		GotoState('FallingState', 'Ducking');
	}
	else if (NextState != '' && NextState != 'TakeHit')
		GotoState(NextState, NextLabel);
	else
		GotoState('Attacking');
}

state FallingState
{
	ignores Bump, Hitwall, WarnTarget;

	function ZoneChange(ZoneInfo newZone)
	{
		Global.ZoneChange(newZone);
		if (newZone.bWaterZone)
		{
			TweenToWaiting(0.15);
			//FIXME - play splash sound and effect
			GotoState('FallingState', 'Splash');
		}
	}

	//choose a jump velocity
	function adjustJump()
	{
		local float velZ;
		local vector FullVel;

		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;

		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		Velocity = FullVel;
		Velocity.Z = JumpZ + velZ;
		Velocity = EAdjustJump();
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (Enemy == None)
		{
			Enemy = instigatedBy;
			NextState = 'Attacking';
			NextLabel = 'Begin';
		}
		if (Enemy != None)
			LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		local bool result;
		result = false;
		if ( Global.SetEnemy(NewEnemy))
		{
			result = true;
			NextState = 'Attacking';
			NextLabel = 'Begin';
		}
		return result;
	}

	function Timer()
	{
		if (Enemy != None)
			bReadyToAttack = true;
	}

	function Landed(vector HitNormal)
	{
		local float landVol, minJumpZ;

		minJumpZ = FMax(JumpZ, 150.0);
		bJustLanded = true;
		if ( (Velocity.Z < -0.8 * minJumpZ) || bUpAndOut)
		{
			MakeNoise(-0.5 * Velocity.Z/minJumpZ);
			PlayLanded(Velocity.Z);
			if ( Velocity.Z < FMin(-600, -3.5 * JumpZ) )
				TakeDamage(-0.04 * (Velocity.Z + FMax(400, 3.5 * JumpZ)), Self, Location, vect(0,0,0), 'fell');
			landVol = Velocity.Z/JumpZ;
			landVol = 0.005 * Mass * FMin(5, landVol * landVol);
			if ( !FootRegion.Zone.bWaterZone )
				PlaySound(Land, SLOT_Interact, FMin(20, landVol));
			if ( health > 0 )
				GotoState('FallingState', 'Landed');
		}
		else if ( Velocity.Z < -0.8 * JumpZ )
		{
			PlayLanded(Velocity.Z);
			GotoState('FallingState', 'FastLanded');
		}
		else
			GotoState('FallingState', 'Done');
	}

	function SeePlayer(Actor SeenPlayer)
	{
		Global.SeePlayer(SeenPlayer);
		disable('SeePlayer');
		disable('HearNoise');
	}

	function EnemyNotVisible()
	{
		enable('SeePlayer');
		enable('HearNoise');
	}

	function SetFall()
	{
		if (!bUpAndOut)
			GotoState('FallingState');
	}

	function EnemyAcquired()
	{
		NextState = 'Acquisition';
		NextLabel = 'Begin';
	}

	function BeginState()
	{
		if (Enemy == None)
			Disable('EnemyNotVisible');
		else
		{
			Disable('HearNoise');
			Disable('SeePlayer');
		}
	}

	function EndState()
	{
		bUpAndOut = false;
	}

LongFall:
	if ( bCanFly )
	{
		SetPhysics(PHYS_Flying);
		Goto('Done');
	}
	Sleep(0.7);
	TweenToFighter(0.2);
	if ( bHasRangedAttack && (Enemy != None) )
	{
		TurnToward(Enemy);
		FinishAnim();
		if ( CanFireAtEnemy() )
		{
			PlayRangedAttack();
			FinishAnim();
		}
		PlayChallenge();
		FinishAnim();
	}
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
FastLanded:
	FinishAnim();
	Goto('Done');
Landed:
	if ( !bIsPlayer ) //bots act like players
		Acceleration = vect(0,0,0);
	FinishAnim();
	if ( !bIsPlayer && (skill < 3) )
		Sleep(0.08);
Done:
	if ( NextAnim == '' )
	{
		bUpAndOut = false;
		if ( NextState != '' )
			GotoState(NextState, NextLabel);
		else
			GotoState('Attacking');
	}
	if ( !bUpAndOut )
	{
		if ( NextAnim == 'Fighter' )
			TweenToFighter(0.2);
		else
			TweenAnim(NextAnim, 0.2);
	}
Splash:
	bUpAndOut = false;
	FinishAnim();
	if ( NextState != '' )
		GotoState(NextState, NextLabel);
	else
		GotoState('Attacking');

Begin:
	if (Enemy == None)
		Disable('EnemyNotVisible');
	else
	{
		Disable('HearNoise');
		Disable('SeePlayer');
	}
	if (bUpAndOut) //water jump
	{
		if ( !bIsPlayer )
		{
			DesiredRotation = Rotation;
			DesiredRotation.Pitch = 0;
			Velocity.Z = 440;
		}
	}
	else
	{
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
			if (NextState != '')
				GotoState(NextState, NextLabel);
			else
				GotoState('Attacking');
		}
		if ( !bJumpOffPawn )
			AdjustJump();
		else
			bJumpOffPawn = false;
PlayFall:
		TweenToFalling();
		FinishAnim();
		PlayInAir();
	}

	if (Physics != PHYS_Falling)
		Goto('Done');
	Sleep(2.0);
	Goto('LongFall');

Ducking:

}

state MeleeAttack
{
	ignores SeePlayer, HearNoise, Bump;
	/* DamageTarget
	check if attack hit target, and if so damage it
	*/
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
		if (!HasAliveEnemy() || VSize(Enemy.Location - Location) > (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('Attacking');
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
		if (HasAliveEnemy())
			Target = Enemy;
		Disable('AnimEnd');
		bReadyToAttack = false;
	}

Begin:
	if ( Enemy != None )
		DesiredRotation = Rotator(Enemy.Location - Location);
	if ( skill < 3 )
		TweenToFighter(0.15);
	else
		TweenToFighter(0.11);

FaceTarget:
	if (!HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');
	Target = Enemy;
	Disable('AnimEnd');
	Sleep(0.0);
	if (!HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');

	Acceleration = vect(0,0,0); //stop
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();
	OldAnimRate = 0;	// force no tween

	if (!HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');

	if( !IsInMeleeRange(Enemy) )
		GotoState('RangedAttack', 'ReadyToAttack');

ReadyToAttack:
	if (!HasAliveEnemy())
		GotoState('Attacking');
	Target = Enemy;
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayMeleeAttack();
	Enable('AnimEnd');
	Sleep(0.0);
Attacking:
	if (!HasAliveEnemy())
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
WaitForAttack:
	Enable('AnimEnd');
	Stop;
}

state RangedAttack
{
	ignores SeePlayer, HearNoise, Bump;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme)
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'RangedAttack';
			NextLabel = 'Begin';
		}
	}

	function StopWaiting()
	{
		Timer();
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		//let attack animation completes
	}

	function KeepAttacking()
	{
		if ( !bFiringPaused && (FRand() > ReFireRate || !CanFireAtEnemy()) )
			GotoState('Attacking');
	}

	function Timer()
	{
		if ( bFiringPaused )
		{
			TweenToRunning(0.12);
			if (NextState == 'RangedAttack')
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			if (NextState != '')
				GotoState(NextState, NextLabel);
			else
				GotoState('Attacking');
		}
	}

	function AnimEnd()
	{
		GotoState('RangedAttack', 'DoneFiring');
	}

	function BeginState()
	{
		Disable('AnimEnd');
		bReadyToAttack = false;
		if ( bFiringPaused )
		{
			SetTimer(SpecialPause, false);
			SpecialPause = 0;
		}
		else
		{
			if (HasAliveEnemy())
				Target = Enemy;
			else
				GotoState('Attacking');
		}
	}

	function EndState()
	{
		bFiringPaused = false;
	}

Challenge:
	Disable('AnimEnd');
	Sleep(0.0);
	Acceleration = vect(0,0,0); //stop
	if ( Enemy != none)
		DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	if ( bCrouching && !Region.Zone.bWaterZone )
		Sleep(0.8 + FRand());
	bCrouching = false;
	TweenToFighter(0.1);
	Goto('FaceTarget');

Begin:
	if (!HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	TweenToFighter(0.15);

FaceTarget:
	Disable('AnimEnd');
	Sleep(0.0);
	if (!HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');
	Target = Enemy;
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();

	if (Enemy != none && VSize(Location - Enemy.Location) < 0.9 * MeleeRange + CollisionRadius + Enemy.CollisionRadius)
		GotoState('MeleeAttack', 'ReadyToAttack');

ReadyToAttack:
	if (!bHasRangedAttack || !HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayRangedAttack();
	Enable('AnimEnd');
	Sleep(0.0);

Firing:
	if (!HasAliveEnemy() || Enemy.Level!=Level)
		GotoState('Attacking');
	TurnToward(Enemy);
	Goto('Firing');

DoneFiring:
	Disable('AnimEnd');
	Sleep(0.0);
	KeepAttacking();
	Goto('FaceTarget');
}

state VictoryDance
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		Enemy = instigatedBy;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		//log(Class$" just acquired an enemy");
		GotoState('Acquisition');
	}

	function PickDestination()
	{
		if (Target == none ||(target.IsA('Pawn') && Pawn(target).health >0) )
		{
			target=none;
			WhatToDoNext('Waiting', 'TurnFromWall');
			return;
		}
		MoveTarget = none;
		if ( ActorReachable(Target) )
		{
			MoveTarget = Target;
			Destination = Target.Location;
		}
		else if (SpecialGoal != None)
		{
			if ( ActorReachable(SpecialGoal) )
				MoveTarget = SpecialGoal;
			else
				WhatToDoNext('Waiting', 'TurnFromWall');
		}
		else
			WhatToDoNext('Waiting', 'TurnFromWall');
	}


	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
	}

Begin:
	if ( (Target == None) || (VSize(Location - Target.Location) <
							  (1.3 * CollisionRadius + Target.CollisionRadius + CollisionHeight - Target.CollisionHeight)) )
		Goto('Taunt');
	WaitForLanding();
	TweenToWalking(0.3);
	FinishAnim();
	PlayWalking();
	Enable('Bump');

MoveToEnemy:
	if ( !IsAnimating() )
		PlayWalking();
	PickDestination();
	Sleep(0.0);
	if (SpecialPause > 0.0)
	{
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		TweenToWalking(0.1);
		FinishAnim();
		PlayWalking();
	}
	if ( MoveTarget == none )
		Goto('Taunt');
	MoveToward(MoveTarget, WalkingSpeed);
	Enable('Bump');
	if ((Target == None) || ( Target.IsA('pawn') && Pawn(Target).health >0 ) || (VSize(Location - Target.Location) <
			(1.3 * CollisionRadius + Target.CollisionRadius + Abs(CollisionHeight - Target.CollisionHeight))))
		Goto('Taunt');
	Goto('MoveToEnemy');

Taunt:
	Acceleration = vect(0,0,0);
	Disable('HitWall');
	TweenToFighter(0.2);
	FinishAnim();
	if (Target!=none)
	{
		PlayTurning();
		TurnToward(Target);
		TweenToFighter(0.2);
		FinishAnim();
	}
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	PlayVictoryDance();
	FinishAnim();
	LastPainTime -= 15.0; //set for state waiting
	WhatToDoNext('Waiting','TurnFromWall');
}

/*
TriggerAlarm is used by unfriendly creatures to run to an actor and trigger something, or by friendly creatures
to lead the player to something */

State TriggerAlarm
{
ignores HearNoise, SeePlayer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		local bool bWasFriendly;

		bWasFriendly = ( (Enemy != None) && Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Friendly) );
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			if ( bWasFriendly && (AttitudeToPlayer < ATTITUDE_Friendly) )
			{
				AlarmTag = '';
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'TriggerAlarm';
				NextLabel = 'Recover';
			}
			GotoState('TakeHit');
		}
	}

	function SetFall()
	{
		NextState = 'TriggerAlarm';
		NextLabel = 'Recover';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function EnemyNotVisible()
	{
		//friendly creatures will stop and wait
		if (Enemy != none && AttitudeTo(Enemy) >= ATTITUDE_Ignore)
			GotoState('AlarmPaused', 'WaitForPlayer');
	}

	function Touch(actor Other)
	{
		if (Other == OrderObject)
		{
			AlarmDone();
			if (IsAlivePawn(Pawn(Other)))
				SetEnemy(Pawn(Other));
		}
	}

	function Bump(actor Other)
	{
		local vector VelDir, OtherDir;
		local float speed;

		if ( Health <= 0 || bDeleteme )
			return;
		if (Other == OrderObject)
		{
			AlarmDone();
			if ( (Pawn(Other) != None) && SetEnemy(Pawn(Other)) )
				GotoState('MeleeAttack');
			return;
		}

		if ( (Pawn(Other) != None) && Pawn(Other).bIsPlayer
				&& (AttitudeToPlayer == ATTITUDE_Friendly) )
			return;

		if ( (Enemy != None && Other == Enemy) || SetEnemy(Pawn(Other)) )
		{
			GotoState('MeleeAttack');
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

	function AlarmDone()
	{
		local pawn OtherPawn;
		local Actor A;
		local AlarmPoint AlarmSpot;

		AlarmSpot = AlarmPoint(OrderObject);
		if ( AlarmSpot != None )
		{
			if ( AlarmSpot.Event != '' )
				foreach AllActors( class 'Actor', A, AlarmSpot.Event )
				{
					if ( (ScriptedPawn(A) != None) && AlarmSpot.bKillMe )
						ScriptedPawn(A).Hated = self;
					A.Trigger( self, instigator );
				}
			if ( AlarmSpot.bDestroyAlarmTriggerer )
			{
				OtherPawn = Level.PawnList;
				while ( OtherPawn != None )
				{
					OtherPawn.Killed(self, self, '');
					OtherPawn = OtherPawn.nextPawn;
				}
				level.game.Killed(self, self, '');
				//log(class$" dying");
				if ( Event != '' )
					foreach AllActors( class 'Actor', A, Event )
					A.Trigger( Self, Instigator );
				Weapon = None;
				Level.Game.DiscardInventory(self);
				Destroy();
				return;
			}
			AlarmTag = AlarmSpot.NextAlarm;
			if ( AlarmSpot.pausetime > 0.0 )
			{
				Acceleration = vect(0,0,0);
				if ( Enemy != none && AttitudeTo(Enemy) > ATTITUDE_Ignore)
					GotoState('AlarmPaused', 'WaitAround');
				else
					GotoState('AlarmPaused');
			}
			else if ( AlarmTag != '' )
			{
				FindAlarm();
				GotoState('TriggerAlarm', 'Begin');
			}
			else if (Enemy != none && AttitudeTo(Enemy) > ATTITUDE_Ignore)
			{
				Acceleration = vect(0,0,0);
				GotoState('Roaming');
			}
			else
			{
				bReadyToAttack = true;
				GotoState('Attacking');
			}
			return;
		}

		AlarmTag = '';

		if (AttitudeToPlayer > ATTITUDE_Ignore)
			GotoState('AlarmPaused', 'WaitAround');
		else
		{
			bReadyToAttack = true;
			GotoState('Attacking');
		}
	}

	function FindAlarm()
	{
		if ( (OrderObject == None) || (OrderObject.Tag != AlarmTag) ) //find alarm object
		{
			if ( (AlarmPoint(OrderObject) != None) && (AlarmPoint(OrderObject).NextAlarm == AlarmTag) )
				OrderObject = AlarmPoint(OrderObject).NextAlarmObject;
			else if ( AlarmTag != '' )
				foreach AllActors(class 'Actor', OrderObject, AlarmTag)
				break;
		}
		if ( (OrderObject == None) || (OrderObject.Tag != AlarmTag) )
		{
			AlarmTag = '';
			GotoState('Attacking');
		}
	}

	function AnimEnd()
	{
		if ( bSpecialPausing )
			PlayPatrolStop();
		else if (!bCanFire)
			PlayRunning();
		else
			PlayCombatMove();
		bReadyToAttack = bMovingRangedAttack;
	}

	function BeginState()
	{
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
		bSpecialPausing = false;
		if ( (Enemy!=none) && !Enemy.bIsPlayer
				|| ((AttitudeToPlayer == ATTITUDE_Fear)
					&& !bInitialFear && (Default.AttitudeToPlayer == ATTITUDE_Friendly)) )
		{
			GotoState('Attacking');
			return;
		}

		FindAlarm();

		if ( (TeamLeader != None) && !TeamLeader.bTeamSpeaking )
			TeamLeader.SpeakOrderTo(self);
	}

Recover:
	if ( (AlarmPoint(OrderObject) != None) && !AlarmPoint(OrderObject).bNoFail
			&& !actorReachable(OrderObject) )
	{
		AlarmTag='';
		GotoState('Attacking');
	}

Begin:
	bReadyToAttack = false;
	if (HasAliveEnemy())
		Target = Enemy;
	TweenToRunning(0.15);
	bFromWall = false;

CloseIn:
	WaitForLanding();
	Enable('AnimEnd');
	if ( OrderObject == None )
	{
		Alarmtag = '';
		GotoState('Attacking');
	}
	If ( actorReachable(OrderObject) )
	{
		if ( bCanStrafe && (AlarmPoint(OrderObject) != None) && AlarmPoint(OrderObject).bStrafeTo && HasAliveEnemy() )
		{
			bCanFire = true;
			StrafeFacing(OrderObject.Location, Enemy);
		}
		else
		{
			bCanFire = false;
			MoveToward(OrderObject);
		}
	}
	else
	{
		if (SpecialGoal != None)
			MoveTarget = FindPathToward(SpecialGoal);
		else
			MoveTarget = FindPathToward(OrderObject);
		if (MoveTarget == None)
		{
			AlarmTag = '';
			log("no path to alarm");
			GotoState('Attacking');
		}
		if ( SpecialPause > 0.0 )
		{
			if ( (AlarmPoint(OrderObject) != None) && AlarmPoint(OrderObject).bStrafeTo )
			{
				bFiringPaused = true;
				NextState = 'Charging';
				NextLabel = 'Moving';
				GotoState('RangedAttack');
			}
			bSpecialPausing = true;
			Acceleration = vect(0,0,0);
			TweenToPatrolStop(0.3);
			if ( (SpecialPause == 2.5) && IsA('Nali') )
				SpecialPause = 8;
			Sleep(SpecialPause);
			SpecialPause = 0.0;
			TweenToRunning(0.1);
			bSpecialPausing = False;
		}
		if ( bCanStrafe && (AlarmPoint(OrderObject) != None) && AlarmPoint(OrderObject).bStrafeTo && HasAliveEnemy() )
		{
			bCanFire = true;
			StrafeFacing(MoveTarget.Location, Enemy);
		}
		else
		{
			bCanFire = false;
			MoveToward(MoveTarget);
		}

		if ( !bNoWait && (AttitudeToPlayer > ATTITUDE_Ignore) && HasAliveEnemy()
				&& ((VSize(Location - Enemy.Location) > CollisionRadius + Enemy.CollisionRadius + 320)
					|| !LineOfSightTo(Enemy)) )
		{
			Acceleration = vect(0,0,0);
			GotoState('AlarmPaused', 'WaitForPlayer');
		}
	}

	if ( ( NavigationPoint(OrderObject) != None)
			&& (VSize(Location - OrderObject.Location) < CollisionRadius + Abs(CollisionHeight - OrderObject.CollisionHeight)) )
		Touch(OrderObject);
	else if ( VSize(Location - OrderObject.Location) <
			  CollisionRadius + CollisionHeight + OrderObject.CollisionRadius + 10 )
		Touch(OrderObject);

	Goto('CloseIn');
}

state AlarmPaused
{
ignores HearNoise;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		local bool bWasFriendly;

		bWasFriendly = ( (Enemy != None) && Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Friendly) );
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			if ( bWasFriendly && (instigatedBy == Enemy) )
				AlarmTag = '';
			if ( AlarmTag == '' )
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'TriggerAlarm';
				NextLabel = 'Recover';
			}
			GotoState('TakeHit');
		}
	}

	function SetFall()
	{
		NextState = 'TriggerAlarm';
		NextLabel = 'Recover';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function Bump(actor Other)
	{
		if ( Health <= 0 || bDeleteme )
			return;
		if (Other == Enemy)
			GotoState('MeleeAttack');
		else if ( (Pawn(Other) != None) && SetEnemy(Pawn(Other)) )
			GotoState('MeleeAttack');
		Disable('Bump');
	}

	function Timer()
	{
		if ( AlarmTag != '' )
			GotoState('TriggerAlarm');
		else
			GotoState('Attacking');
	}

	function FindShootTarget()
	{
		local actor A;

		A = None;
		if ( AlarmPoint(OrderObject).shoottarget != '' )
			ForEach AllActors(class 'Actor', A, AlarmPoint(OrderObject).shoottarget )
			break;

		if ( A == None)
		{
			if ( HasAliveEnemy() )
				Target = Enemy;
			if ( Target == None )
			{
				AlarmTag = '';
				GotoState('Attacking');
			}
		}
		else
		{
			Target = A;
			if (Pawn(Target) != None)
				SetEnemy(Pawn(Target));
		}
	}

	function EnemyNotVisible()
	{
		if (AlarmPoint(OrderObject) != none && AlarmPoint(OrderObject).bStopIfNoEnemy)
		{
			Enable('SeePlayer');
			Disable('EnemyNotVisible');
			Disable('Timer');
			GotoState('AlarmPaused', 'WaitForEnemy');
		}
	}

	function SeePlayer(Actor SeenPlayer)
	{
		Disable('SeePlayer');
		Enable('Timer');
		GotoState('AlarmPaused', 'Begin');
	}

	function PlayWaitAround()
	{
		PlayPatrolStop();
	}

	function BeginState()
	{
		Disable('EnemyNotVisible');
		Disable('SeePlayer');
		Disable('Timer');
	}

WaitForEnemy:
	Acceleration = vect(0,0,0);
	FinishAnim();
	TweenToPatrolStop(0.3);
	FinishAnim();
Waiting:
	PlayPatrolStop();
	FinishAnim();
	Goto('Waiting');

Begin:
	if (!HasAliveEnemy() || AlarmPoint(OrderObject) == none)
		GotoState('Attacking');
	Acceleration = vect(0,0,0);
	Enable('Timer');
	SetTimer( AlarmPoint(OrderObject).pausetime, false );
	if ( bHasRangedAttack && AlarmPoint(OrderObject).bAttackWhilePaused )
	{
		Enable('EnemyNotVisible');
		if ( AlarmPoint(OrderObject).ShootTarget != '' )
			FindShootTarget();
		else
		{
			if ((Enemy != None) && Enemy.bIsPlayer && ( AttitudeToPlayer > ATTITUDE_Hate) )
			{
				AttitudeToPlayer = ATTITUDE_Hate;
				Target = Enemy;
			}
		}
		if ( AlarmPoint(OrderObject).AlarmAnim != '')
		{
			TweenAnim(AlarmPoint(OrderObject).AlarmAnim, 0.2);
			if (IsLiveActor(Target) && NeedToTurn(Target.Location))
				TurnToward(Target);
			FinishAnim();
			if ( AlarmPoint(OrderObject).AlarmSound != None)
				PlaySound( AlarmPoint(OrderObject).AlarmSound);
			PlayAnim(AlarmPoint(OrderObject).AlarmAnim);
			if ( AlarmPoint(OrderObject).ducktime > 0 )
			{
				if ( Target != Enemy )
					Sleep(AlarmPoint(OrderObject).ducktime);
				else if (HasAliveEnemy())
				{
					if ( TimerRate <= 0 )
						SetTimer( AlarmPoint(OrderObject).ducktime + 1, false);
					MoveTimer = TimerCounter;
					While ( TimerCounter < MoveTimer + AlarmPoint(OrderObject).ducktime )
					{
						TurnToward(Enemy);
						sleep(0.0);
					}
				}
			}
		}
Attack:
		if ( Target == self )
			Target=none;
		if ( Target == None )
		{
			if ( HasAliveEnemy() )
				Target = Enemy;
			if ( Target == None )
			{
				AlarmTag = '';
				GotoState('Attacking');
			}
		}
		if (NeedToTurn(Target.Location))
		{
			PlayTurning();
			TurnToward(Target);
		}
		TweenToFighter(0.15);
		FinishAnim();
		if (Target != none)
			DesiredRotation = Rotator(Target.Location - Location);
		PlayRangedAttack();
		FinishAnim();
		Goto('Attack');
	}

	if ( AlarmPoint(OrderObject).bStopIfNoEnemy)
		Enable('EnemyNotVisible');

	if ( NeedToTurn(Location + AlarmPoint(OrderObject).lookdir) )
	{
		PlayTurning();
		TurnTo(Location + AlarmPoint(OrderObject).lookdir);
	}
	if ( AlarmPoint(OrderObject).AlarmAnim != '')
	{
		TweenAnim(AlarmPoint(OrderObject).AlarmAnim, 0.2);
		FinishAnim();
		PlayAnim(AlarmPoint(OrderObject).AlarmAnim);
	}
	else
	{
		TweenToPatrolStop(0.3);
		FinishAnim();
		PlayPatrolStop();
	}
	sleep( AlarmPoint(OrderObject).pausetime );
	Timer();

WaitForPlayer:
	Disable('AnimEnd');
	NextAnim = '';
	Acceleration = vect(0,0,0);
Wait:
	if ( !HasAliveEnemy() )
		GotoState('Attacking');

	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	TweenToWaiting(0.2);
	FinishAnim();
	PlayWaiting();
	FinishAnim();
	if ((Enemy!=none ) && (VSize(Location - Enemy.Location) > CollisionRadius + Enemy.CollisionRadius + 220)
			|| ((Enemy!=none ) && !Enemy.LineOfSightTo(Self)) )
		Goto('Wait');
	TweenToRunning(0.15);
	gotoState('TriggerAlarm');

WaitAround:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0);
	if ( (AlarmPoint(OrderObject) != None) && NeedToTurn(Location + AlarmPoint(OrderObject).lookdir) )
	{
		PlayTurning();
		TurnTo(Location + AlarmPoint(OrderObject).lookdir);
	}
	if ( (AlarmPoint(OrderObject) != None) && AlarmPoint(OrderObject).AlarmAnim != '')
	{
		TweenAnim(AlarmPoint(OrderObject).AlarmAnim, 0.2);
		FinishAnim();
		PlayAnim(AlarmPoint(OrderObject).AlarmAnim);
		FinishAnim();
	}
	else
	{
		TweenToPatrolStop(0.2);
		FinishAnim();
		if (Enemy!=none && NeedToTurn(Enemy.Location))
		{
			PlayTurning();
			TurnToward(Enemy);
			TweenToPatrolStop(0.2);
		}
		PlayWaitAround();
		FinishAnim();
		PlayWaitAround();
		FinishAnim();
		PlayWaitAround();
		FinishAnim();
		TweenToPatrolStop(0.1);
		FinishAnim();
	}
	if (AlarmTag == '')
		WhatToDoNext('','');
	else
		GotoState('TriggerAlarm');
}

state Greeting
{
	ignores SeePlayer, EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		local eAttitude AttEn;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if ( Enemy != None )
		{
			AttEn = AttitudeTo(Enemy);
			if (NextState == 'TakeHit')
			{
				if (AttEn == ATTITUDE_Fear)
				{
					NextState = 'Retreating';
					NextLabel = 'Begin';
				}
				else
				{
					NextState = 'Attacking';
					NextLabel = 'Begin';
				}
				GotoState('TakeHit');
			}
			else
				GotoState('Attacking');
		}
	}

	function Bump(actor Other)
	{
		//log(Other.class$" bumped "$class);
		if ( (Pawn(Other) != None) && (Enemy != Other) )
			SetEnemy(Pawn(Other));
		if ( TimerRate <= 0 )
			setTimer(1.0, false);
		Disable('Bump');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function EnemyAcquired()
	{
		if (AttitudeTo(Enemy) < ATTITUDE_Ignore)
			GotoState('Acquisition', 'PlayOut');
	}

	function AnimEnd()
	{
		PlayWaiting();
	}

	function Landed(vector HitNormal)
	{
		//SetPhysics(PHYS_None);
		Acceleration = vect(0,0,0);
	}

Begin:
	MakeNoise(1.0);
	//log(class$ " greeting");
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.2);
}

// 227g: Added following state
State AIFollowingPawn
{
	function BeginState()
	{
		SpecialGoal = None;
		bSpecialGoal = false;
		SpecialPause = 0.0;
		Enemy = None;
		Disable('AnimEnd');
	}
	function EndState()
	{
		FollowingPawn = None;
	}
	function EnemyAcquired()
	{
		if( FollowingPawn!=None && FollowingPawn.Enemy!=Enemy && LineOfSightTo(FollowingPawn) )
			FollowingPawn.SeePlayer(Enemy); // Warn following pawn too!
		GotoState('Acquisition', 'PlayOut');
	}
	function Killed(pawn Killer, pawn Other, name damageType)
	{
		Global.Killed(Killer,Other,damageType);
		if( FollowingPawn!=None && FollowingPawn==Other )
		{
			FollowingPawn = None;
			if( !SetEnemy(Killer) )
				WhatToDoNext('','');
		}
	}
	final function bool FindWanderDest()
	{
		local vector E,HitLocation,HitNormal;

		Destination.X+=(FRand()-0.5);
		Destination.Y+=(FRand()-0.5);
		Destination.Z = 0;
		Destination = FollowingPawn.Location+Normal(Destination)*(FollowingPawn.CollisionRadius+CollisionRadius+200.f*FRand());
		E.X = CollisionRadius*0.9;
		E.Y = E.X;
		E.Z = CollisionHeight*0.9;
		if( Trace(HitLocation,HitNormal,Destination,Location,true,E)!=None )
			Destination = HitLocation;
		return (VSize(Destination-Location)>50.f);
	}
	function PickDestination()
	{
		local byte i;

		MoveTarget = None;
		if( FollowingPawn==None || FollowingPawn.bDeleteMe || FollowingPawn.Health<=0 )
		{
			WhatToDoNext('','');
			return;
		}
		if( ActorReachable(FollowingPawn) )
		{
			numHuntPaths = 0;
			SpecialGoal = None;
			for( i=0; (i<6 && !FindWanderDest()); ++i ) {}
			return;
		}
		if( ++numHuntPaths>30 )
		{
			WhatToDoNext('','');
			return;
		}
		if( SpecialGoal!=None )
		{
			if( ActorReachable(SpecialGoal) )
			{
				MoveTarget = SpecialGoal;
				SpecialGoal = None;
				return;
			}
			else if( Intelligence>BRAINS_Reptile && FindBestPathToward(SpecialGoal) )
				return;
			else SpecialGoal = None;
		}
		if( Intelligence>BRAINS_Reptile )
		{
			bHunting = true;
			if ( FindBestPathToward(FollowingPawn) )
				return;
		}
		else if( LineOfSightTo(FollowingPawn) )
		{
			MoveTarget = FollowingPawn;
			return;
		}
		Destination = Location+VRand()*(100.f*FRand());
	}
	function AnimEnd()
	{
		if( Acceleration!=vect(0,0,0) )
		{
			if( MoveTarget!=None )
				PlayRunning();
			else PlayWalking();
			Disable('AnimEnd');
		}
		else PlayPatrolStop();
	}
	function SetFall()
	{
		local float velZ;
		local vector FullVel;

		Disable('AnimEnd');
		PlayInAir();

		if( MoveTarget!=None )
			Destination = MoveTarget.Location;
		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;

		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		Velocity = FullVel;
		Velocity.Z = JumpZ + velZ;
		Velocity = EAdjustJump();
	}
	function Landed(vector HitNormal)
	{
		PlayLanded(Velocity.Z);
		Enable('AnimEnd');
	}
	function FollowTargetAquired( Pawn Other )
	{
		if( FollowingPawn!=Other && !LineOfSightTo(FollowingPawn) && LineOfSightTo(Other) )
			FollowingPawn = Other;
	}

Begin:
	if( Physics==PHYS_None )
		SetMovementPhysics();
	if( Physics==PHYS_Falling )
		WaitForLanding();
	TweenToWalking(0.3);
	FinishAnim();
KeepMoving:
	PickDestination();
	if( SpecialPause>0 )
	{
PatrolStop:
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Enable('AnimEnd');
		Sleep(SpecialPause);
		Disable('AnimEnd');
		SpecialPause = 0.0;
		TweenToWalking(0.3);
		FinishAnim();
		GoTo'KeepMoving';
	}
	if( MoveTarget!=None )
	{
		PlayRunning();
		MoveToward(MoveTarget);
	}
	else
	{
		PlayWalking();
		MoveTo(Destination,WalkingSpeed);
		SpecialPause = 0.8+FRand()*1.4;
		GoTo'PatrolStop';
	}
	GoTo'KeepMoving';
}

state AIRetreat // 227j: AI finding backup.
{
ignores EnemyAcquired;

	function BeginState()
	{
		SpecialGoal = None;
		bSpecialGoal = false;
		SpecialPause = 0.0;
		numHuntPaths = 0;
		Disable('AnimEnd');
	}
	function Killed(pawn Killer, pawn Other, name damageType)
	{
		Global.Killed(Killer,Other,damageType);
		if( BackupPlan==Other )
		{
			BackupPlan = None;
			GotoState('Attacking');
		}
	}
	function PickDestination()
	{
		MoveTarget = None;
		if( BackupPlan==None || BackupPlan.bDeleteMe || BackupPlan.Health<=0 || BackupPlan.Enemy )
		{
			BackupPlan = None;
			GotoState('Attacking');
			return;
		}
		if( LineOfSightTo(BackupPlan) )
		{
			GoToState('AIRetreat','NotifyTarget');
			return;
		}
		if( ++numHuntPaths>20 )
		{
			bIsPackHunter = false;
			GotoState('Attacking');
			return;
		}
		if( SpecialGoal!=None )
		{
			if( ActorReachable(SpecialGoal) )
			{
				MoveTarget = SpecialGoal;
				SpecialGoal = None;
				return;
			}
			else if( FindBestPathToward(SpecialGoal) )
				return;
			else SpecialGoal = None;
		}
		bHunting = true;
		if ( FindBestPathToward(BackupPlan) )
			return;
		BackupPlan = None;
		GotoState('Attacking');
	}
	function AnimEnd()
	{
		if( Acceleration!=vect(0,0,0) )
		{
			PlayRunning();
			Disable('AnimEnd');
		}
		else PlayChallenge();
	}
	function SetFall()
	{
		local float velZ;
		local vector FullVel;

		Disable('AnimEnd');
		PlayInAir();

		if( MoveTarget!=None )
			Destination = MoveTarget.Location;
		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;

		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		Velocity = FullVel;
		Velocity.Z = JumpZ + velZ;
		Velocity = EAdjustJump();
	}
	function Landed(vector HitNormal)
	{
		PlayLanded(Velocity.Z);
		Enable('AnimEnd');
	}
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') )
		{
			if( Mover(Wall).HandleDoor(self) )
			{
				if ( SpecialPause > 0 )
					Acceleration = vect(0,0,0);
				GotoState('AIRetreat', 'PatrolStop');
			}
			else
			{
				bIsPackHunter = false;
				GotoState('Attacking');
			}
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('AIRetreat', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

Begin:
	if( Physics==PHYS_None )
		SetMovementPhysics();
	if( Physics==PHYS_Falling )
		WaitForLanding();
	TweenToRunning(0.1);
	Sleep(0.1);
KeepMoving:
	PickDestination();
	if( SpecialPause>0 )
	{
PatrolStop:
		Acceleration = vect(0,0,0);
		TweenToFighter(0.1);
		Enable('AnimEnd');
		Sleep(SpecialPause);
		Disable('AnimEnd');
		SpecialPause = 0.0;
		TweenToRunning(0.1);
		Sleep(0.1);
		GoTo'KeepMoving';
	}
	if( MoveTarget!=None )
	{
		PlayRunning();
		MoveToward(MoveTarget);
	}
	else
	{
		SpecialPause = 0.8+FRand()*1.4;
		GoTo'PatrolStop';
	}
	GoTo'KeepMoving';
NotifyTarget:
	Acceleration = vect(0,0,0);
	if (BackupPlan && NeedToTurn(BackupPlan.Location))
	{
		Disable('AnimEnd');
		PlayTurning();
		TurnToward(BackupPlan);
	}
	TweenToFighter(0.1);
	Enable('AnimEnd');
	Sleep(0.35);
	PlayRoamingSound();
	if( BackupPlan && !BackupPlan.bDeleteMe && BackupPlan.Health>0 && HasAliveEnemy() )
		BackupPlan.SeePlayer(Enemy);
	Sleep(0.35);
	BackupPlan = None;
	GotoState('Attacking');

AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus);
	Destination = Focus;
	Goto('KeepMoving');
}

defaultproperties
{
	CarcassType=Class'CreatureCarcass'
	TimeBetweenAttacks=1.000000
	WalkingSpeed=0.400000
	bLeadTarget=True
	bWarnTarget=True
	bFirstShot=True
	ProjectileSpeed=800.000000
	bFixedStart=True
	AirSpeed=320.000000
	AccelRate=200.000000
	HearingThreshold=0.300000
	Land=Sound'Land1'
	WaterStep=Sound'LSplash'
	CollisionFlag=COLLISIONFLAG_ScriptedPawn
	bNoDynamicShadowCast=false
}