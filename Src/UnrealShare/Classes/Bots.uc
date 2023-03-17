//=============================================================================
// Bots.
//=============================================================================
class Bots extends Pawn
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Generic\land1.wav" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.wav" NAME="LSplash" GROUP="Generic"

var(Pawn) class<carcass> CarcassType;

// Advanced AI attributes.
var Pawn		 	TeamLeader;
var	Actor			OrderObject;
var(Combat) float	TimeBetweenAttacks;  // seconds - modified by difficulty
var 	name		NextAnim;		// used in states with multiple, sequenced animations
var(Combat) float	Aggressiveness; //0.0 to 1.0 (typically)
var   	Pawn		OldEnemy;
var		int			numHuntPaths;
var		float		HuntStartTime,LastDAmmoTime;
var		vector		HidingSpot;
var		float		WalkingSpeed;
var(Combat) float	RefireRate;

//AI flags
var	 	bool   		bReadyToAttack;		// can attack again
var		bool		bCanFire;			//used by TacticalMove and Charging states
var		bool		bCanDuck;
var		bool		bStrafeDir;
var(Combat) bool	bIsWuss;			// always takes hit
var(Combat) bool	bLeadTarget;		// lead target with projectile attack
var(Combat) bool	bWarnTarget;		// warn target when projectile attack
var		bool		bCrouching;
var		bool		bFirstHatePlayer;
var		bool		bClearShot;
var		bool		bSpecialGoal;
var		bool		bChangeDir;			// tactical move boolean
var		bool		bMoraleBoosted;
var		bool		bFiringPaused;
var		bool		bSpecialPausing;
var		bool		bGreenBlood;
var		bool		bFrustrated;
var		bool		bNoShootDecor;
var		bool		bGathering;
var		bool		bCamping;
var config	bool	bVerbose; //for debugging
var		bool		bViewTarget; //is being used as a viewtarget
var		bool		bWantsToCamp;
var		bool		bWallAdjust;
var		bool		bNoClearSpecial;

var Weapon EnemyDropped;
var float PlayerKills;
var float PlayerDeaths;
var float LastInvFind;
var class<Weapon> FavoriteWeapon;
var float Accuracy;

var     name		LastPainAnim;
var		float		LastPainTime;

var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds) sound	Die2;
var(Sounds) sound	Die3;
var(Sounds) sound	Die4;
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound   LandGrunt;
var(Sounds) sound	JumpSound;

var float CampTime;
var float CampingRate;
var float LastCampCheck;
var Ambushpoint AmbushSpot;
var Actor	Pointer;

var transient byte WetSteps;
var int UsingConfigIndex;
var LadderTrigger ActiveLadder;

function PreBeginPlay()
{
	local int newskill;

	bIsPlayer = true;
	Super.PreBeginPlay();
	if (Level.Game.difficulty > 3)
	{
		newskill = FClamp(Level.Game.difficulty-3, 1, 3);

		if (health > 9 ) // give weaker pawns a small boost
			health += (100 *newskill) / health;
		health *= 1+(0.15*newskill);
		SightRadius+= 100*newskill;
		RotationRate.Yaw *= 1+(0.15*newskill);
		AccelRate += 100*newskill;
		groundspeed += 10*newskill;
		waterspeed += 10*newskill;
		airspeed += 10*newskill;
		DamageScaling=default.DamageScaling+(0.5*newskill);
	}
}

simulated function BeginPlay()
{
	Super.BeginPlay();
}

singular event BaseChange()
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local float decorMass;

	if (bDeleteme)
		return;
	if ( (Base != None) && Base.IsA('Mover') )
	{
		// handle shootable secret floors
		if ( Mover(Base).bDamageTriggered && !Mover(Base).bOpening
		        && (MoveTarget != None) )
		{
			HitActor = Trace(HitLocation, HitNormal, MoveTarget.Location, Location, true);
			if ( HitActor == Base )
			{
				Target = Base;
				bShootSpecial = true;
				FireWeapon();
				bFire = 0;
				bAltFire = 0;
				Base.Trigger(Base, Self);
				bShootSpecial = false;
			}
		}
		return;
	}
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if (Pawn(Base) != None)
	{
		if (!Pawn(base).bDeleteme && Pawn(base).Health > 0 )
			Pawn(base).TakeDamage( (1-Velocity.Z/400)* Mass/Pawn(base).Mass, Self,Location,0.5 * Velocity , 'stomped');
		JumpOffPawn();
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		if (!Base.bDeleteme && !Base.bStatic)
			Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, 'stomped');
	}
}

function HaltFiring()
{
	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
	SetTimer((0.75 + 0.5 * FRand()) * TimeBetweenAttacks, false);
	if ( Weapon != None )
		Weapon.Tick(0.001);
}

function float AdjustDesireFor(Inventory Inv)
{
	if ( inv.class == FavoriteWeapon )
		return 0.5;

	return 0;
}

function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt, favalt;
	local inventory MyFav;

	if ( Inventory == None )
		return false;

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);

	if ( PendingWeapon == None )
		return false;

	if ( (FavoriteWeapon != None) && (PendingWeapon.class != FavoriteWeapon) )
	{
		MyFav = FindInventoryType(FavoriteWeapon);
		if ( (MyFav != None) && (Weapon(MyFav).RateSelf(favalt) + 0.22 > PendingWeapon.RateSelf(usealt)) )
		{
			usealt = favalt;
			PendingWeapon = Weapon(MyFav);
		}
	}
	if ( Weapon == None )
		ChangedWeapon();
	else if ( Weapon != PendingWeapon )
		Weapon.PutDown();

	return (usealt > 0);
}

function SpecialFire()
{
	bFiringPaused = true;
	SpecialPause = 0.75 + VSize(Target.Location - Location)/Weapon.AltProjectileSpeed;
	NextState = 'Attacking';
	NextLabel = 'Begin';
	Acceleration = vect(0,0,0);
	GotoState('RangedAttack');
}

//*********************************************************************
/* Default location specific take hits  - make sure pain frames are named right */
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
			spawn(class 'BloodSpray',,,hitLocation + BloodOffset, rotator(BloodOffset));
		}
	}

	bOptionalTakeHit = bIsWuss || ( (Level.TimeSeconds - LastPainTime > 0.3 + 0.25 * skill)
	                                && (Damage * FRand() > 0.08 * Health) && (Skill < 3)
	                                && (GetAnimGroup(AnimSequence) != 'MovingAttack')
	                                && (GetAnimGroup(AnimSequence) != 'Attack') );
	if ( ((Weapon == None) || !Weapon.bPointing) && (GetAnimGroup(AnimSequence) != 'Dodge')
	        && (bOptionalTakeHit || (MomentumZ > 140 && Damage > 0)
	            || (Damage * FRand() > (0.17 + 0.04 * skill) * Health)) )
	{
		PlayTakeHitSound(Damage, damageType, 3);
		PlayHitAnim(HitLocation, Damage);
	}
	else if (NextState == 'TakeHit' && Damage > 0)
	{
		PlayTakeHitSound(Damage, damageType, 2);
		NextState = '';
	}
}

function PlayHitAnim(vector HitLocation, float Damage)
{
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

function AdjustSkill(bool bWinner)
{
	if ( bWinner )
	{
		PlayerKills += 1;
		skill -= 1/Min(PlayerKills, 20);
		skill = FClamp(skill, 0, 3);
	}
	else
	{
		PlayerDeaths += 1;
		skill += 1/Min(PlayerDeaths, 20);
		skill = FClamp(skill, 0, 3);
	}
}

simulated function PlayFootStep()
{
	local sound step;
	local float decision;
	
	if(bDeleteMe)
		return;

	if ( Level.NetMode==NM_DedicatedServer )
		Return; // We don't preform this on dedicated servers.

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			Step = Footstep1;
		else if (decision < 0.67 )
			Step = Footstep2;
		else
			Step = Footstep3;
	}
	if( step==None )
		return;
	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

function PlayDyingSound()
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,2.0,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,2.0,,,Frand()*0.2+0.9);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		PlaySound(Die, SLOT_Talk,2.0);
	else if (rnd < 0.5)
		PlaySound(Die2, SLOT_Talk,2.0);
	else if (rnd < 0.75)
		PlaySound(Die3, SLOT_Talk,2.0);
	else
		PlaySound(Die4, SLOT_Talk,2.0);
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(drown, SLOT_Pain, 1.5);
		else if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		return;
	}
	damage *= FRand();

	if (damage < 8)
		PlaySound(HitSound1, SLOT_Pain,2.0,,,Frand()*0.2+0.9);
	else if (damage < 25)
	{
		if (FRand() < 0.5) PlaySound(HitSound2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		else PlaySound(HitSound3, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
	}
	else
		PlaySound(HitSound4, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
}

function CallForHelp()
{
	local Pawn P;

	If(Health<=0 || bDeleteme)
	return;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('Bots') && P.PlayerReplicationInfo!=None && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			P.HandleHelpMessageFrom(self);
}

function string KillMessage( name damageType, pawn Other )
{
	if ( PlayerReplicationInfo==None )
		return ( Level.Game.PlayerKillMessage(damageType, Other)$MenuName );
	return ( Level.Game.PlayerKillMessage(damageType, Other)$PlayerReplicationInfo.PlayerName );
}

function Gasp()
{
	if ( PainTime < 2 )
		PlaySound(GaspSound, SLOT_Talk, 2.0);
	else
		PlaySound(BreathAgain, SLOT_Talk, 2.0);
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
			if ( bCanWalk && (Abs(Acceleration.X) + Abs(Acceleration.Y) > 0)
			        && (Destination.Z >= Location.Z)
			        && CheckWaterJump(jumpDir) )
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

function PreSetMovement()
{
	if ( Skill == 3 )
	{
		PeripheralVision = -0.1;
		RotationRate.Yaw = 100000;
	}
	else
	{
		PeripheralVision = 0.7 - 0.35 * skill;
		RotationRate.Yaw = 30000 + 16000 * skill;
	}
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.5;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
	if ( skill <= 1 )
	{
		bCanDuck = false;
		MaxDesiredSpeed = 0.8 + 0.1 * skill;
	}
	else
	{
		MaxDesiredSpeed = 1;
		bCanDuck = true;
	}
}

function PainTimer()
{
	if (Health <= 0 || bDeleteme )
		return;

	if (FootRegion.Zone.bPainZone)
		Super.PainTimer();
	else if (HeadRegion.Zone.bWaterZone)
	{
		if (bDrowning)
			self.TakeDamage(5, None, Location, vect(0,0,0), 'drowned');
		else
		{
			bDrowning = true;
			GotoState('FindAir');
		}
		if (Health > 0)
			PainTime = 2.0;
	}
}

function ChangedWeapon()
{
	local int usealt;

	if ( Weapon == PendingWeapon )
	{
		if ( Weapon == None )
			SwitchToBestWeapon();
		else if ( Weapon.GetStateName() == 'DownWeapon' )
			Weapon.GotoState('Idle');
		PendingWeapon = None;
	}
	else
		Super.ChangedWeapon();

	if ( Weapon != None )
	{
		if ( (bFire > 0) || (bAltFire > 0) )
		{
			Weapon.RateSelf(usealt);
			if ( usealt == 0 )
			{
				bAltFire = 0;
				bFire = 1;
				Weapon.Fire(1.0);
			}
			else
			{
				bAltFire = 0;
				bFire = 1;
				Weapon.AltFire(1.0);
			}
		}
		Weapon.SetHand(0);
	}
}

function bool Gibbed(name damageType)
{
	if ( (damageType == 'decapitated') || (damageType == 'shot') )
		return false;
	return ( (Health < -80) || ((Health < -40) && (FRand() < 0.65)) );
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

//=============================================================================

function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( Region.Zone.bWaterZone )
		SetPhysics(PHYS_Swimming);
	else
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
	bFire = 0;
	bAltFire = 0;
	bReadyToAttack = false;
	Enemy = None;
	if ( OldEnemy != None && (OldEnemy.bDeleteme
	                          || OldEnemy.Health <= 0 || OldEnemy==self ) )// be sure
		OldEnemy = None;
	if ( OldEnemy != None )
	{
		Enemy = OldEnemy;
		OldEnemy = None;
		GotoState('Attacking');
	}
	else
	{
		GotoState('Roaming');
		if ( Skill > 2.7 )
			bReadyToAttack = true;
	}
}

function Bump(actor Other)
{
	local vector VelDir, OtherDir;
	local float speed;

	if ( Health <= 0 || bDeleteme )
	{
		//log("Bump while dead");
		return;
	}
	if ( Enemy != None )
	{
		if (Other == Enemy)
		{
			GotoState('RangedAttack');
			return;
		}
		else if ( (Pawn(Other) != None) && SetEnemy(Pawn(Other)) )
		{
			GotoState('RangedAttack');
			return;
		}
	}
	else
	{
		if (Pawn(Other) != None)
		{
			if ( SetEnemy(Pawn(Other)) )
			{
				bReadyToAttack = True; //can melee right away
				GotoState('Attacking');
				return;
			}
		}
		if ( TimerRate <= 0 )
			setTimer(1.0, false);
	}

	speed = VSize(Velocity);
	if ( speed > 1 )
	{
		VelDir = Velocity/speed;
		VelDir.Z = 0;
		OtherDir = Other.Location - Location;
		OtherDir.Z = 0;
		OtherDir = Normal(OtherDir);
		if ( (VelDir Dot OtherDir) > 0.8 )
		{
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
	//if ( Health <= 0 )
	//	log("setfall while dead");
	if (Enemy != None)
	{
		NextState = 'Attacking'; //default
		NextLabel = 'Begin';
		TweenToFalling();
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

function BecomeViewTarget()
{
	bViewTarget = true;
}

event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound, TargetYaw, TargetPitch;
	local Pawn P;
	local rotator OldViewRotation;

	if ( !bViewTarget )
	{
		ViewRotation = Rotation;
		return;
	}

	// update viewrotation
	OldViewRotation = ViewRotation;
	ViewRotation = Rotation;

	//check if still viewtarget
	bViewTarget = false;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('PlayerPawn') && (PlayerPawn(P).ViewTarget == self) )
		{
			bViewTarget = true;
			if ( bVerbose )
				P.ClientMessage(PlayerReplicationInfo.PlayerName$" State "$GetStateName()$" MoveTarget "$MoveTarget, 'CriticalEvent' );
			break;
		}

	if ( !bViewTarget )
		return;

	if ( bVerbose && (MoveTarget != None) )
	{
		if ( Pointer == None )
			Pointer = Spawn(class'WayBeacon', self,, MoveTarget.Location);
		else
			Pointer.SetLocation(MoveTarget.Location);
	}

	if ( Enemy == None )
	{
		ViewRotation.Roll = 0;
		if ( DeltaTime < 0.2 )
		{
			OldViewRotation.Yaw = OldViewRotation.Yaw & 65535;
			OldViewRotation.Pitch = OldViewRotation.Pitch & 65535;
			TargetYaw = float(ViewRotation.Yaw & 65535);
			if ( Abs(TargetYaw - OldViewRotation.Yaw) > 32768 )
			{
				if ( TargetYaw < OldViewRotation.Yaw )
					TargetYaw += 65536;
				else
					TargetYaw -= 65536;
			}
			TargetYaw = float(OldViewRotation.Yaw) * (1 - 5 * DeltaTime) + TargetYaw * 5 * DeltaTime;
			ViewRotation.Yaw = int(TargetYaw);

			TargetPitch = float(ViewRotation.Pitch & 65535);
			if ( Abs(TargetPitch - OldViewRotation.Pitch) > 32768 )
			{
				if ( TargetPitch < OldViewRotation.Pitch )
					TargetPitch += 65536;
				else
					TargetPitch -= 65536;
			}
			TargetPitch = float(OldViewRotation.Pitch) * (1 - 5 * DeltaTime) + TargetPitch * 5 * DeltaTime;
			ViewRotation.Pitch = int(TargetPitch);
		}
	}

	smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
	// smooth up/down stairs
	If ( (Physics == PHYS_Walking) && !bJustLanded)
	{
		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + BaseEyeHeight * smooth;
		bound = -0.5 * CollisionHeight;
		if (EyeHeight < bound)
			EyeHeight = bound;
		else
		{
			bound = CollisionHeight + FMin(FMax(0.0,(OldLocation.Z - Location.Z)), MaxStepHeight);
			if ( EyeHeight > bound )
				EyeHeight = bound;
		}
	}
	else
	{
		smooth = FMax(smooth, 0.35);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
	}
}

/* Adjust hit location - adjusts the hit location in for pawns, and returns
true if it was really a hit, and false if not (for ducking, etc.)
*/
simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;
	if ( BaseEyeHeight == Default.BaseEyeHeight )
		return true;

	maxZ = Location.Z + EyeHeight + 0.25 * CollisionHeight;
	if ( HitLocation.Z > maxZ )
	{
		if ( TraceDir.Z >= 0 )
			return false;
		adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
		HitLocation.Z = maxZ;
		HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
		HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
		if ( VSize(HitLocation - Location) > CollisionRadius )
			return false;
	}
	return true;
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	//log(class$" heard noise by "$NoiseMaker.class);
	if ( SetEnemy(NoiseMaker.instigator) )
		LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
}

function SeePlayer(Actor SeenPlayer)
{
	if (SetEnemy(Pawn(SeenPlayer)))
	{
		LastSeenPos = Enemy.Location;
	}
}

/* FindBestPathToward() assumes the desired destination is not directly reachable, 
given the creature's intelligence, it tries to set Destination to the location of the 
best waypoint, and returns true if successful
*/
function bool FindBestPathToward(actor desired)
{
	local float Detour;

	if ( specialGoal != None)
		desired = specialGoal;
	if( Skill>=1.f )
	{
		Detour = Skill/6.f;
		if( Health<40 )
			Detour*=3.f;
	}
	MoveTarget = FindPathToward(desired,,,Detour); 

	if( MoveTarget!=None )
	{
		Destination = MoveTarget.Location;
		return true;
	}	
	return false;
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
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist;
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
	{
		Focus = Location + ViewDist;
		return true;
	}

	ViewDist *= -1;

	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
	{
		Focus = Location + ViewDist;
		return true;
	}

	Focus = Location - LookDir * 300;
	return true;
}

function FireWeapon()
{
	local bool bUseAltMode;

	if ( (Enemy == None) && bShootSpecial )
	{
		//fake use dispersion pistol
		if( LastDAmmoTime<Level.TimeSeconds )
		{
			PlaySound(Class'DispersionPistol'.Default.AltFireSound, SLOT_None, 1.8*SoundDampening,,,1.2);
			Spawn(Class'DispersionPistol'.Default.ProjectileClass,,, Location,Rotator(Target.Location - Location));
			LastDAmmoTime = Level.TimeSeconds+0.8;
		}
		return;
	}

	bUseAltMode = SwitchToBestWeapon();

	if ( Weapon!=None )
	{
		if ( (Weapon.AmmoType != None) && (Weapon.AmmoType.AmmoAmount <= 0) )
		{
			bReadyToAttack = true;
			return;
		}

		if ( !bFiringPaused && !bShootSpecial && (Enemy != None) )
			Target = Enemy;
		ViewRotation = Rotation;
		if ( bUseAltMode )
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
	bShootSpecial = false;
}

function PlayFiring();

// check for line of sight to target deltatime from now.
function bool CheckFutureSight(float deltatime)
{
	local vector FutureLoc;

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return false;

	FutureLoc = Location + Velocity * deltatime;

	//make sure won't run into something
	if ( !FastTrace(FutureLoc,Location) )
		return false;

	//check if can still see target
	if ( FastTrace(Target.Location + Target.Velocity * deltatime, FutureLoc) )
		return true;

	return false;
}

/*
Adjust the aim at target.
	- add aim error
	- adjust up or down if barrier
*/

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local float TargetDist, TossSpeed, TossTime;

	if ( projSpeed == 0 )
		return AdjustAim(projSpeed, projStart, aimerror, leadTarget, warnTarget);
	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return Rotation;
	if ( !Target.IsA('Pawn') )
		return rotator(Target.Location - Location);

	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - ProjStart);
	aimerror = aimerror * (11 - 10 *
	                       ((Target.Location - Location)/TargetDist
	                        Dot Normal((Target.Location + 0.5 * Target.Velocity) - (ProjStart + 0.5 * Velocity))));

	aimerror = aimerror * (2.4 - 0.5 * (skill + FRand()));
	if ( !leadTarget || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

	if ( leadTarget )
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * TargetDist/projSpeed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	//try middle
	FireSpot.Z = Target.Location.Z;

	if ( !FastTrace(FireSpot,ProjStart) && (Target == Enemy) )
	{
		FireSpot = LastSeenPos;
		if ( Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.5 * Enemy.CollisionHeight;
		if ( Weapon != None && !FastTrace(FireSpot,ProjStart) )
		{
			bFire = 0;
			bAltFire = 0;
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

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local int modifier;

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return Rotation;
	if ( !Target.IsA('Pawn') )
		return rotator(Target.Location - Location);

	FireSpot = Target.Location;
	aimerror = aimerror * (11 - 10 *
	                       (Normal(Target.Location - Location)
	                        Dot Normal((Target.Location + 0.5 * Target.Velocity) - (Location + 0.5 * Velocity))));

	aimerror = aimerror * (2.4 - 0.5 * (skill + FRand()));
	modifier = FClamp(Level.Game.difficulty-3, 1, 3);
	if (Level.Game.difficulty > 3)
		aimerror *= 1-(0.3*modifier);
	if ( !leadTarget || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

	if (leadTarget && (projSpeed > 0))
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * VSize(Target.Location - ProjStart)/projSpeed);
		if ( ((FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1600) && ((Vector(Target.Rotation) Dot Normal(Target.Velocity)) < 0.7))
		 || !FastTrace(FireSpot,ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	HitActor = self; //so will fail first check unless shooting at feet
	if ( (Location.Z + 19 >= Target.Location.Z) && Target.IsA('Pawn')
	        && (Weapon != None) && Weapon.bSplashDamage && (0.5 * (skill - 1) > FRand()) )
	{
		// Try to aim at feet
		HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,80), FireSpot, false);
		if ( HitActor != None )
		{
			FireSpot = HitLocation + vect(0,0,3);
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		}
		else
			HitActor = self;
	}
	if ( HitActor != None )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
		if( FastTrace(FireSpot,ProjStart) )
			HitActor = None;
	}
	if ( HitActor != None )
	{
		////try head
		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
		if( FastTrace(FireSpot,ProjStart) )
			HitActor = None;
	}
	if ( (HitActor != None) && (Target == Enemy) )
	{
		FireSpot = LastSeenPos;
		if ( Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.5 * Enemy.CollisionHeight;
		if ( Weapon != None && !FastTrace(FireSpot,ProjStart) )
		{
			bFire = 0;
			bAltFire = 0;
			SetTimer(TimeBetweenAttacks, false);
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
		damageAttitudeTo(shooter);
		if (att == ATTITUDE_Ignore)
			return;
	}

	// AI controlled creatures may duck if not falling
	if ( !bCanDuck || (Enemy == None) || (Physics == PHYS_Falling) || (Physics == PHYS_Swimming) )
		return;

	if ( FRand() > 0.33 * skill )
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

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	//if ( health <= 0 )
	//	log("duck");
	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 240 * duckDir, Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 240 * duckDir, Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	}
	if ( !bSuccess )
		return;

	if ( HitActor == None )
		HitLocation = Location + 240 * duckDir;

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MaxStepHeight * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return;

	//log("good duck");

	SetFall();
	Velocity = duckDir * 400;
	Velocity.Z = 160;
	PlayDodge(bDuckLeft);
	SetPhysics(PHYS_Falling);
	if ( (Weapon != None) && Weapon.bSplashDamage && ((bFire != 0) || (bAltFire != 0)) && (Enemy != None) && !FastTrace(Enemy.Location,HitLocation)
	 && FastTrace(Enemy.Location,Location) )
	{
		bFire = 0;
		bAltFire = 0;
	}
	GotoState('FallingState','Ducking');
}

function PlayDodge(bool bDuckLeft)
{
	PlayDuck();
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
	if ( FastTrace(StartSpot + 100 * ViewDir,StartSpot) )
		return false;
	bCrouching = true;
	return true;
}

// Can Stake Out - check if I can see my current Destination point, and so can enemy
function bool CanStakeOut()
{
	if ( (Physics == PHYS_Flying) && !bCanStrafe )
		return false;
	if (Enemy == none )
		return false;
	if ( VSize(Enemy.Location - LastSeenPos) > 800 )
		return false;

	return (FastTrace(LastSeenPos, Location + EyeHeight * vect(0,0,1)) && FastTrace(LastSeenPos , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)));
}

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Level.Game.bTeamGame && PlayerReplicationInfo!=None && Other.PlayerReplicationInfo!=None
	        && (PlayerReplicationInfo.Team==Other.PlayerReplicationInfo.Team) )
		return ATTITUDE_Friendly; //teammate

	return ATTITUDE_Hate;
}

function float AssessThreat( Pawn NewThreat )
{
	local float ThreatValue, NewStrength, Dist;

	NewStrength = RelativeStrength(NewThreat);
	if ( !NewThreat.bIsPlayer )
		return NewStrength;

	ThreatValue = FMax(0, NewStrength);
	if ( NewThreat.Health < 20 )
		ThreatValue += 0.3;

	Dist = VSize(NewThreat.Location - Location);
	if ( Dist < 800 )
		ThreatValue += 0.3;
	else if ( Dist > 0.7 * VSize(Enemy.Location - Location) )
		ThreatValue -= 0.25;

	if ( (NewThreat != Enemy) && (Enemy != None) )
	{
		ThreatValue -= 0.2;

		if ( !LineOfSightTo(Enemy) )
		{
			if ( Dist < 1200 )
				ThreatValue += 0.2;
			if ( SpecialPause > 0 )
				ThreatValue += 5;
			if ( IsInState('Hunting') && (NewStrength < 0.2)
			        && (Level.TimeSeconds - HuntStartTime < 3)
			        && (relativeStrength(Enemy) < FMin(0, NewStrength)) )
				ThreatValue -= 0.3;
		}
	}

	if ( NewThreat.IsA('PlayerPawn') )
		ThreatValue += 0.15;

	return ThreatValue;
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;
	local eAttitude newAttitude;

	if (Enemy == NewEnemy)
		return true;

	if ( NewEnemy==Self || NewEnemy==None || NewEnemy.Health<=0 || NewEnemy.bDeleteMe || Health<=0 || NewEnemy.bIsAmbientCreature )
		return false;

	result = false;
	newAttitude = AttitudeTo(NewEnemy);

	if ( Level.Game.GameRules!=None )
		newAttitude = GetModifiedAttitude(newAttitude,NewEnemy);

	if ( newAttitude == ATTITUDE_Friendly )
	{
		NewEnemy = NewEnemy.Enemy;
		if ( (NewEnemy == None) || (NewEnemy == Self) || (NewEnemy.Health <= 0) || NewEnemy.IsA('FlockPawn') || NewEnemy.IsA('FlockMasterPawn'))
			return false;
		if (Enemy == NewEnemy)
			return true;

		newAttitude = AttitudeTo(NewEnemy);
		if ( Level.Game.GameRules!=None )
			newAttitude = GetModifiedAttitude(newAttitude,NewEnemy);
	}

	if ( newAttitude >= ATTITUDE_Ignore )
		return false;

	if ( Enemy != None )
	{
		if ( AssessThreat(NewEnemy) > AssessThreat(Enemy) )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		}
		else if ( OldEnemy == None )
			OldEnemy = NewEnemy;
	}
	else
	{
		result = true;
		Enemy = NewEnemy;
	}

	if ( result )
	{
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Location;
		EnemyAcquired();
	}

	return result;
}

function ReSetSkill()
{
	bDoAutoSerpentine = (Skill>=3); // May strafe more.
	HuntOffDistance = FMax((Skill-2)*1500.f,0.f); // May chose more tactical firing spots while hunting.

	bLeadTarget = (1.5 * FRand() < Skill);
	if ( Skill == 0 )
	{
		Health = 80;
		ReFireRate = 0.75 * Default.ReFireRate;
	}
	else
		ReFireRate = Default.ReFireRate * (1 - 0.25 * skill);

	PreSetMovement();
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local Pawn aPawn;

	if ( Health <= 0 || bDeleteme )
		return;

	if ( OldEnemy == Other )
		OldEnemy = None;

	if ( Enemy == Other )
	{
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = ( skill > 3 * FRand() );
		EnemyDropped = Enemy.Weapon;
		Enemy = None;
		if ( (Killer!=none) && (Killer == self) && (OldEnemy == None) )
		{
			for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.nextPawn )
				if ( ((aPawn.IsA('PlayerPawn') && !aPawn.IsA('Spectator'))
				        || aPawn.IsA('ScriptedPawn') || aPawn.IsA('Bot'))
				        && (VSize(Location - aPawn.Location) < 1000)
				        && CanSee(aPawn) && SetEnemy(aPawn) )
				{
					GotoState('Attacking');
					return;
				}

			Target = Other;
			GotoState('VictoryDance');
		}
		else
			GotoState('Attacking');
	}
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
	if ( Weapon != None )
	{
		compare -= (Weapon.RateSelf(bTemp) - 0.3);
		if ( Weapon.AIRating < 0.4 )
		{
			compare += 0.2;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating >= 0.4) )
				compare += 0.3;
		}
	}
	if ( Other.Weapon != None )
		compare += (Other.Weapon.RateSelf(bTemp) - 0.3);
	//log(other.class$" relative strength to "$class$" is "$compare);
	return compare;
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart;
	local actor HitActor;

	if ( Weapon == None )
		return false;
	if ( Enemy == none || enemy.health <= 0 || enemy.bdeleteme || Enemy == self )
		return false;
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
	if ( Weapon.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location + Enemy.CollisionHeight * vect(0,0,0.7), projStart, true);
	else
		HitActor = Trace(HitLocation, HitNormal,
		                 projStart + 220 * Normal(Enemy.Location + Enemy.CollisionHeight * vect(0,0,0.7) - Location),
		                 projStart, true);

	if ( HitActor == Enemy )
		return true;
	if ( (HitActor != None) && (VSize(HitLocation - Location) < 200) )
		return false;
	if ( (Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) > ATTITUDE_Ignore) )
		return false;

	return true;
}

function PlayMeleeAttack()
{
	//log("play melee attack");
	Acceleration = AccelRate * VRand();
	TweenToWaiting(0.15);
	FireWeapon();
}

function PlayRangedAttack()
{
	TweenToWaiting(0.11);
	FireWeapon();
}

function PlayMovingAttack()
{
	PlayRunning();
	FireWeapon();
}

function PlayOutOfWater()
{
	PlayDuck();
}

//FIXME - here decide when to pause/start firing based on weapon,etc
function PlayCombatMove()
{
	PlayRunning();
	if ( skill >= 2 )
		bReadyToAttack = true;
	if ( bReadyToAttack && bCanFire )
	{
		if ( NeedToTurn(Enemy.Location) )
		{
			bAltFire = 0;
			bFire = 0;
		}
		else
			FireWeapon();
	}
	else
	{
		bFire = 0;
		bAltFire = 0;
	}
}

function float StrafeAdjust()
{
	local vector Focus2D, Loc2D, Dest2D;
	local float strafemag;

	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	strafeMag = Abs( Normal(Focus2D - Loc2D) dot Normal(Dest2D - Loc2D) );

	return ((strafeMag - 2.0)/GroundSpeed);
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn currentEnemy;

	if ( (Other == Self) || (Health <= 0) || (bDeleteme) )
		return;
	currentEnemy = Enemy;
	SetEnemy(EventInstigator);
	if (Enemy != currentEnemy)
		GotoState('Attacking');
}

function AddVelocity( vector NewVelocity)
{
	if ( Health <=0 || bDeleteMe )
	{
		Disable('Hitwall');
		Disable('Bump');
	}
	Super.AddVelocity(NewVelocity);
}

//**********************************************************************************
//Base Monster AI

auto state StartUp
{
	function BeginState()
	{
		SetMovementPhysics();
		if (Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);
	}

Begin:
	WhatToDoNext('','');
}

state Roaming
{
	ignores EnemyNotVisible;

	function Bump(actor Other)
	{
		local vector VelDir, OtherDir;
		local float speed;

		//log(Other.class$" bumped "$class);
		if ( Health <= 0 || bDeleteme )
			return;
		if( Other.bIsPawn )
		{
			if ( (Other == Enemy) || SetEnemy(Pawn(Other)) )
			{
				bReadyToAttack = true;
				GotoState('Attacking');
			}
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
		else if ( bCamping )
			GotoState('Wandering');
		Disable('Bump');
	}

	function HandleHelpMessageFrom(Pawn Other)
	{
		if ( Health <= 0 || bDeleteme )
			return;
		if ( (Health > 70) && (Weapon!=none && Weapon.AIRating > 0.5) && (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		        && (Other.Enemy != None)
		        && (VSize(Other.Enemy.Location - Location) < 1200) )
		{
			SetEnemy(Other.Enemy);
			GotoState('Attacking');
		}
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	                     Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme)
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = '';
			GotoState('TakeHit');
		}
		else if ( !bCanFire && (skill > 3 * FRand()) )
			GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
		GotoState('Wandering', 'Moving');
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{
		bWallAdjust = false;
		NextState = 'Roaming';
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Roaming', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if ( !bWallAdjust && PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Roaming', 'AdjustFromWall');
		}
		else
		{
			MoveTimer = -1.0;
			bWallAdjust = false;
		}
	}

	function PickDestination()
	{
		local inventory Inv, BestInv, KnowPath;
		local float Bestweight, NewWeight, DroppedDist;
		local actor BestPath;
		local decoration Dec;
		local bool bCanReach;

		if ( (EnemyDropped != None) && !EnemyDropped.bDeleteMe
		        && (EnemyDropped.Owner == None) )
		{
			DroppedDist = VSize(EnemyDropped.Location - Location);
			if ( (DroppedDist < 800) && ActorReachable(EnemyDropped) )
			{
				BestWeight = EnemyDropped.BotDesireability(self);
				if ( BestWeight > 0.4 )
				{
					MoveTarget = EnemyDropped;
					EnemyDropped = None;
					return;
				}
				BestInv = EnemyDropped;
				BestWeight = BestWeight/DroppedDist;
				KnowPath = BestInv;
			}
			else
				BestWeight = 0;
		}
		else
			BestWeight = 0;

		EnemyDropped = None;

		//first look at nearby inventory < 600 dist
		foreach visiblecollidingactors(class'Inventory', Inv, 600)
		if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/50 > BestWeight)
		        && (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight) )
		{
			NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
			// log("looking at local "$Inv$" weight "$100000*NewWeight);
			if ( NewWeight > BestWeight )
			{
				BestWeight = NewWeight;
				BestInv = Inv;
			}
		}

		if ( BestInv != None )
		{
			bCanJump = ( BestInv.Location.Z > Location.Z - CollisionHeight - MaxStepHeight );
			bCanReach = ActorReachable(BestInv);
		}
		else
			bCanReach = false;
		bCanJump = true;
		if ( bCanReach )
		{
			//log("Roam to local "$BestInv);
			MoveTarget = BestInv;
			return;
		}
		else if ( KnowPath != None )
		{
			MoveTarget = KnowPath;
			return;
		}

		if ( (Weapon!=none && Weapon.AIRating > 0.5) && (Health > 90) )
		{
			bWantsToCamp = ( bWantsToCamp || (FRand() < CampingRate * FMin(1.0, Level.TimeSeconds - LastCampCheck)) );
			LastCampCheck = Level.TimeSeconds;
		}
		else
			bWantsToCamp = false;

		if ( bWantsToCamp && FindAmbushSpot() )
			return;

		// if none found, check for decorations with inventory
		if ( !bNoShootDecor )
			foreach visiblecollidingactors(class'Decoration', Dec, 500)
			if ( Dec.Contents != None )
			{
				bNoShootDecor = true;
				Target = Dec;
				GotoState('Roaming', 'ShootDecoration');
				return;
			}

		bNoShootDecor = false;
		BestWeight = 0;

		// look for long distance inventory
		BestPath = FindBestInventoryPath(BestWeight, (skill >= 2));
		//log("roam to "$BestPath);
		//log("---------------------------------");
		if ( BestPath != None )
		{
			MoveTarget = BestPath;
			return;
		}

		// if nothing, then wander or camp
		if ( FRand() < 0.35 )
			GotoState('Wandering');
		else
		{
			CampTime = 3.5 + FRand() - skill;
			GotoState('Roaming', 'Camp');
		}
	}

	function bool FindAmbushSpot()
	{
		if ( (AmbushSpot == None) && (Ambushpoint(MoveTarget) != None) )
			AmbushSpot = Ambushpoint(MoveTarget);

		if ( Ambushspot != None )
		{
			Ambushspot.taken = true;
			if ( VSize(Ambushspot.Location - Location) < 2 * CollisionRadius )
			{
				CampTime = 10.0;
				GotoState('Roaming', 'LongCamp');
				return true;
			}
			if ( ActorReachable(Ambushspot) )
			{
				MoveTarget = Ambushspot;
				return true;
			}
			MoveTarget = FindPathToward(Ambushspot);
			if ( MoveTarget != None )
				return true;
			Ambushspot.taken = false;
			Ambushspot = None;
		}
		return false;
	}

	function AnimEnd()
	{
		if ( bCamping )
			PlayWaiting();
		else
			PlayRunning();
	}

	function ShareWithTeam()
	{
		local bool bHaveItem, bIsHealth, bOtherHas;
		local Inventory goalItem;
		local Pawn P;

		goalItem = InventorySpot(MoveTarget).markedItem;
		if ( goalItem == None ) // FIXME REMOVE
		{
			//log(" No marked item for "$MoveTarget);
			return;
		}

		if ( goalItem.IsA('Weapon') )
		{
			if ( (Weapon == None) || (Weapon.AIRating < 0.45) )
				return;
			bHaveItem = (FindInventoryType(goalItem.class) != None);
		}
		else if ( goalItem.IsA('Health') )
		{
			bIsHealth = true;
			if ( Health < 60 )
				return;
		}
		else
			return;

		CampTime = 2.0;

		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			if ( P.bIsPlayer && P.PlayerReplicationInfo!=None && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
			        && ((P.MoveTarget == MoveTarget) || (P.MoveTarget == goalItem)
			            || (!bIsHealth && P.IsA('PlayerPawn') && !P.IsA('Spectator')
			                && (VSize(P.Location - Location) < 1250) && LineOfSightTo(P))) )
			{
				//decide who needs it more
				if ( bIsHealth )
				{
					if ( Health > P.Health + 10 )
					{
						GotoState('Roaming', 'GiveWay');
						return;
					}
					else if ( (P.IsInState('Roaming')) && (Health < P.Health - 10) )
						P.GotoState('Roaming', 'GiveWay');
				}
				else
				{
					bOtherHas = (P.FindInventoryType(goalItem.class) != None);
					if ( !bHaveItem && bOtherHas )
					{
						if ( P.IsInState('Roaming') )
							P.GotoState('Roaming', 'GiveWay');
					}
					else if ( bHaveItem && !bOtherHas )
					{
						GotoState('Roaming', 'GiveWay');
						return;
					}
				}
			}
	}

	function BeginState()
	{
		bNoShootDecor = false;
		bCanFire = false;
		bCamping = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			bSpecialGoal = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

	function EndState()
	{
		if ( AmbushSpot != None )
		{
			AmbushSpot.taken = false;
			if ( Enemy != None )
				AmbushSpot = None;
		}
		bCamping = false;
		bWallAdjust = false;
	}

LongCamp:
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	if ( OrderObject.IsA('AmbushPoint') )
		TurnTo(Location + (Ambushpoint(OrderObject)).lookdir);
	Sleep(CampTime);
	Goto('Begin');

GiveWay:
	// log("sharing");
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(MoveTarget.Location);
	}
	Sleep(CampTime);
	Goto('Begin');

Camp:
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
ReCamp:
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Sleep(CampTime);
	if ( (Weapon != None) && (Weapon.AIRating > 0.4) && (3 * FRand() > skill + 1) )
		Goto('ReCamp');
Begin:
	bCamping = false;
	TweenToRunning(0.1);
	WaitForLanding();

RunAway:
	PickDestination();
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') && InventorySpot(MoveTarget).markedItem!=None )
	{
		if ( Level.Game.bTeamGame )
			ShareWithTeam();
		if ( InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0 )
		{
			if ( InventorySpot(MoveTarget).markedItem.GetStateName() == 'Pickup' )
				MoveTarget = InventorySpot(MoveTarget).markedItem;
			else if ( VSize(Location - MoveTarget.Location) < CollisionRadius )
			{
				CampTime = 3.5 + FRand() - skill;
				Goto('Camp');
			}
		}
	}
	bCamping = false;
	MoveToward(MoveTarget);
	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None ) //FIXME - do this in all landed: !!!
		Goto('RunAway');
	Goto('Moving');

AdjustFromWall:
	bWallAdjust = true;
	bCamping = false;
	StrafeTo(Destination, Focus);
	Destination = Focus;
	MoveTo(Destination);
	bWallAdjust = false;
	Goto('Moving');

ShootDecoration:
	TurnToward(Target);
	if ( Target != None )
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	Goto('RunAway');
}

state Wandering
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
		if (PickWallAdjust())
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
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			HitActor = Trace(HitLocation, HitNormal, pick , Location, false);
			if (HitActor != None)
				return false;
		}
		else
			pick = Location + pick;

		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;

		return (VSize(dist) > minDist);
	}

	function PickDestination()
	{
		local vector pick, pickdir;
		local bool success;
		local float XY;
		//Favor XY alignment
		XY = FRand();
		if (XY < 0.3)
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if (XY < 0.6)
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
		}
		if (Physics != PHYS_Walking)
		{
			pickdir.Z = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}
		else
		{
			pickdir.Z = 0;
			if (XY >= 0.6)
				pickdir = Normal(pickdir);
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
	WaitForLanding();
	PickDestination();
	TweenToWalking(0.2);
	FinishAnim();
	PlayWalking();

Moving:
	Enable('HitWall');
	MoveTo(Destination, WalkingSpeed);
Pausing:
	Acceleration = vect(0,0,0);
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Enable('AnimEnd');
	NextAnim = '';
	TweenToPatrolStop(0.2);
	Sleep(1.0);
	Disable('AnimEnd');
	FinishAnim();
	GotoState('Roaming');

ContinueWander:
	FinishAnim();
	PlayWalking();
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:
	StrafeTo(Destination, Focus);
	Destination = Focus;
	Goto('Moving');
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

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			OldLastSeenPos = LastSeenPos;
			if ( Enemy ==  NoiseMaker.instigator  )
				LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			else if ( (Pawn(NoiseMaker) != None) && (Enemy == Pawn(NoiseMaker).Enemy) )
				LastSeenPos = 0.5 * (Pawn(NoiseMaker).Enemy.Location + VSize(Pawn(NoiseMaker).Enemy.Location - Location) * vector(Rotation));
			if ( VSize(OldLastSeenPos - Enemy.Location) < VSize(LastSeenPos - Enemy.Location) )
				LastSeenPos = OldLastSeenPos;
		}

	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			MakeNoise(1.0);
			NextAnim = '';
			LastSeenPos = Enemy.Location;
			GotoState('Attacking');
		}
	}

	function BeginState()
	{
		//if (health <= 0)
		//	log(self$" acquisition while dead");
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
	Acceleration = vect(0,0,0);
	if (NeedToTurn(LastSeenPos))
	{
		PlayTurning();
		TurnTo(LastSeenPos);
	}
	DesiredRotation = Rotator(LastSeenPos - Location);
	TweenToFighter(0.2);
	FinishAnim();
	////log("Stimulus = "$Stimulus);
	if ( AttitudeTo(Enemy) == ATTITUDE_Fear )  //will run away from noise
	{
		LastSeenPos = Enemy.Location;
		MakeNoise(1.0);
		NextAnim = '';
		GotoState('Attacking');
	}
	else //investigate noise
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

/* Attacking
Master attacking state - choose which type of attack to do from here
*/
state Attacking
{
	ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local pawn changeEn;

		//if ( health <= 0 )
		//	log(self$" choose attack while dead");
		if ((Enemy == None) || (Enemy.Health <= 0) || (Enemy.bDeleteme) || Enemy==self )
		{
			WhatToDoNext('','');
			return;
		}

		AttitudeToEnemy = AttitudeTo(Enemy);
		if ( Level.Game.GameRules!=None )
			AttitudeToEnemy = GetModifiedAttitude(AttitudeToEnemy,Enemy);

		if (AttitudeToEnemy == ATTITUDE_Fear)
		{
			GotoState('Retreating');
			return;
		}
		else if (AttitudeToEnemy == ATTITUDE_Friendly)
		{
			WhatToDoNext('','');
			return;
		}
		else if ( !LineOfSightTo(Enemy) )
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
				if ( VSize(Enemy.Location - Location)
				        > 600 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 600 )
					GotoState('Hunting');
				else
				{
					HuntStartTime = Level.TimeSeconds;
					NumHuntPaths = 0;
					GotoState('StakeOut');
				}
				return;
			}
		}

		if (bReadyToAttack)
		{
			////log("Attack!");
			Target = Enemy;
			If (VSize(Enemy.Location - Location) <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			{
				GotoState('RangedAttack');
				return;
			}
			else
				SetTimer(TimeBetweenAttacks, False);
		}

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


/* Retreating for a bot is going toward an item while still engaged with an enemy, but fearing that enemy (so
no desire to remain engaged)
   TacticalGet is for going to an item while engaged, and remaining engaged. TBD
   Roaming is going to items w/ no enemy. TBD
*/

state Retreating
{
	ignores EnemyNotVisible;

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{
		if ( bCanFire && (FRand() < 0.4) )
			return;

		Super.WarnTarget(shooter, projSpeed, FireDir);
	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( (SeenPlayer == Enemy) || LineOfSightTo(Enemy) )
			return;
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			LastSeenPos = SeenPlayer.Location;
			MakeNoise(1.0);
			GotoState('Attacking');
		}
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( Health <= 0 || bDeleteme )
			return;
		if ( (NoiseMaker.instigator == Enemy) || LineOfSightTo(Enemy) )
			return;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			MakeNoise(1.0);
			GotoState('Attacking');
		}
	}

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
		else if ( !bCanFire && (skill > 3 * FRand()) )
			GotoState('Retreating', 'Moving');
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
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;
		local actor BestPath;
		local bool bTriedFar;

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);

		// do I still fear my enemy?
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			WhatToDoNext('','');
			return;
		}
		else if ( AttitudeTo(Enemy) > ATTITUDE_Fear )
		{
			GotoState('Attacking');
			return;
		}

		bestweight = 0;

		//first look at nearby inventory < 500 dist
		// FIXME reduce favoring of stuff nearer/visible to enemy
		MaxDist = 500 + 70 * skill;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist)
		if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
		        && (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
		        && (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
		{
			NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
			if ( NewWeight > BestWeight )
			{
				SecondWeight = BestWeight;
				BestWeight = NewWeight;
				SecondInv = BestInv;
				BestInv = Inv;
			}
		}

		// see if better long distance inventory
		if ( BestWeight < 0.2 )
		{
			bTriedFar = true;
			BestPath = FindBestInventoryPath(BestWeight, false);
			if ( BestPath != None )
			{
				MoveTarget = BestPath;
				return;
			}
		}

		// if nothing, then tactical move
		if ( (BestInv != None) && ActorReachable(BestInv) )
		{
			MoveTarget = BestInv;
			return;
		}

		if ( (SecondInv != None) && ActorReachable(SecondInv) )
		{
			MoveTarget = BestInv;
			return;
		}
		if ( !bTriedFar )
		{
			BestWeight = 0;
			BestPath = FindBestInventoryPath(BestWeight, false);
			if ( BestPath != None )
			{
				MoveTarget = BestPath;
				return;
			}
		}

		LastInvFind = Level.TimeSeconds;
		GotoState('TacticalMove', 'NoCharge');
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
			{
				bReadyToAttack = true;
				GotoState('Attacking');
			}
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
		if (LineOfSightTo(Enemy))
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
		local float zdiff;

		if ( Home == None )
		{
			PickDestination();
			if ( Home == None )
				return;
		}
		//log("find retreat spot");
		dist2d = Home.Location - Location;
		zdiff = dist2d.Z;
		dist2d.Z = 0.0;
		if ((VSize(dist2d) < 2 * CollisionRadius) && (Abs(zdiff) < CollisionHeight))
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
		if ( bCanFire && LineOfSightTo(Enemy) )
			PlayCombatMove();
		else
			PlayRunning();
	}

	function BeginState()
	{
		if ( Level.Game.bTeamGame )
			CallForHelp();
		bSpecialPausing = false;
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

Begin:
	if ( (TimerRate == 0.0) || (bReadyToAttack && (FRand() < 0.4)) )
	{
		SetTimer(TimeBetweenAttacks, false);
		bReadyToAttack = false;
	}
	TweenToRunning(0.15);
	WaitForLanding();

RunAway:
	if ( Enemy == none || enemy.health <= 0 || enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	PickDestination();
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( Enemy !=none && LineOfSightTo(Enemy) )
		{
			if ( ((Base == None) || (Base == Level))
			        && (FRand() < 0.6) )
				GotoState('TacticalMove', 'NoCharge');
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Retreating';
			NextLabel = 'RunAway';
			GotoState('RangedAttack');
		}
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( Enemy == none || enemy.health <= 0 || enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') && (InventorySpot(MoveTarget).markedItem != None)
	        && (InventorySpot(MoveTarget).markedItem.GetStateName() == 'Pickup')
	        && (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) )
		MoveTarget = InventorySpot(MoveTarget).markedItem;
	if ( (skill < 3) && (!LineOfSightTo(Enemy) ||
	                     (Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z))
	                                             Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0)) )
	{
		HaltFiring();
		MoveToward(MoveTarget);
	}
	else
	{
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

Landed:
	if ( MoveTarget == None )
		Goto('RunAway');
	Goto('Moving');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	StrafeTo(Destination, Focus);
	Destination = Focus;
	MoveTo(Destination);
	Goto('Moving');
}

state Fallback
{
	ignores EnemyNotVisible;

	function EnemyNotVisible()
	{
		local Pawn P;
		if ( (OldEnemy != None) && LineOfSightTo(OldEnemy) )
		{
			P = OldEnemy;
			OldEnemy = Enemy;
			Enemy = P;
		}
	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
			return;
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			LastSeenPos = Enemy.Location;
			MakeNoise(1.0);
		}
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( (NoiseMaker.instigator == Enemy) || LineOfSightTo(Enemy) )
			return;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			MakeNoise(1.0);
		}
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	                     Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Fallback';
			NextLabel = 'TakeHit';
			GotoState('TakeHit');
		}
		else if ( !bCanFire && (skill > 3 * FRand()) )
			GotoState('Fallback', 'Moving');
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Fallback';
		NextLabel = 'Landed';
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
			GotoState('Fallback', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Fallback', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			WhatToDoNext('','');
			return;
		}
		if ( OrderObject == None )
		{
			GotoState('Attacking');
		}
		else if ( (VSize(Location - OrderObject.Location) < 20)
		          || ((VSize(Location - OrderObject.Location) < 600) && LineOfSightTo(OrderObject)) )
		{
			GotoState('Attacking');
		}
		else if ( ActorReachable(OrderObject) )
			MoveTarget = OrderObject;
		else
		{
			MoveTarget = FindPathToward(OrderObject);
			if ( MoveTarget == None )
				GotoState('Attacking');
		}
	}

	function Bump(actor Other)
	{
		local vector VelDir, OtherDir;
		local float speed;

		//log(Other.class$" bumped "$class);
		if ( Health <= 0 || bDeleteme)
			return;
		if ( (Pawn(Other) != None) && (Other != Enemy) )
			SetEnemy(Pawn(Other));

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
	function AnimEnd()
	{
		if ( bCanFire && LineOfSightTo(Enemy) )
			PlayCombatMove();
		else
			PlayRunning();
	}

	function BeginState()
	{
		bCanFire = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

Begin:
	TweenToRunning(0.12);
	WaitForLanding();

RunAway:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	PickDestination();
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( LineOfSightTo(Enemy) )
		{
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Fallback';
			NextLabel = 'RunAway';
			GotoState('RangedAttack');
		}
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		//log("no movetarget");
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	if ( (skill < 3) && (!LineOfSightTo(Enemy) ||
	                     (Skill - FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z))
	                                         Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0)) )
	{
		HaltFiring();
		MoveToward(MoveTarget);
	}
	else
	{
		bReadyToAttack = True;
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

Landed:
	if ( MoveTarget == None )
		Goto('RunAway');
	Goto('Moving');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	StrafeTo(Destination, Focus);
	Destination = Focus;
	MoveTo(Destination);
	Goto('Moving');
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

		bCanJump = ActorReachable(Enemy);
		if ( !bCanJump )
			GotoState('TacticalMove', 'NoCharge');
	}

	function TryToDuck(vector duckDir, bool bReversed)
	{
		if ( FRand() < 0.7 )
		{
			Global.TryToDuck(duckDir, bReversed);
			return;
		}
		if ( MoveTarget == Enemy )
			TryStrafe(duckDir);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Charging', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Charging', 'AdjustFromWall');
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
		local vector sideDir;
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

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;

		Extent.X = CollisionRadius;
		Extent.Y = CollisionRadius;
		Extent.Z = CollisionHeight;
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
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else if ( StrafeFromDamage(momentum, Damage, damageType, false) )
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
		else if ( StrafeFromDamage(momentum, Damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) &&
		          (Physics == PHYS_Falling) ) //weave
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
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			gotoState('Attacking');
			return;
		}
		bReadyToAttack = True;
		Target = Enemy;
		if ( (VSize(Enemy.Location - Location)
		        <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
		        || (FRand() > 0.7 + 0.1 * skill) )
			GotoState('RangedAttack');
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
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
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
	}
	if ( actorReachable(Enemy) )
	{
		bCanFire = true;
		MoveToward(Enemy);
		if (bFromWall)
		{
			bFromWall = false;
			if (PickWallAdjust())
				StrafeFacing(Destination, Enemy);
			else
				GotoState('TacticalMove', 'NoCharge');
		}
	}
	else
	{
NoReach:
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
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
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
			GotoState('Attacking');
		if ( SpecialPause > 0.0 )
		{
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Charging';
			NextLabel = 'Begin';
			GotoState('RangedAttack');
		}
Moving:
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
			GotoState('Attacking');
		if (VSize(MoveTarget.Location - Location) < 2.5 * CollisionRadius)
		{
			bCanFire = true;
			StrafeFacing(MoveTarget.Location, Enemy);
		}
		else
		{
			if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
			        (Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z))
			                                Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0) )
			{
				if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
				{
					AnimSequence = '';
					TweenToRunning(0.12);
				}
				HaltFiring();
				MoveToward(MoveTarget);
			}
			else
			{
				bCanFire = true;
				StrafeFacing(MoveTarget.Location, Enemy);
			}
		}
	}

	GotoState('Attacking');

GotThere:
	////log("Got to enemy");
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Target = Enemy;
	GotoState('RangedAttack');

TakeHit:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
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
		NextAnim = 'Fighter';
		GotoState('FallingState');
	}

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{
		if ( bCanFire && (FRand() < 0.4) )
			return;

		Super.WarnTarget(shooter, projSpeed, FireDir);
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
		//if (PickWallAdjust())
		//	GotoState('TacticalMove', 'AdjustFromWall');
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
		if ( Health <= 0 || bDeleteme )
			return;
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			gotoState('Attacking');
			return;
		}
		bReadyToAttack = True;
		Enable('Bump');
		Target = Enemy;
		if (VSize(Enemy.Location - Location)
		        <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('RangedAttack');
		else if ( FRand() > 0.5 + 0.17 * skill )
			GotoState('RangedAttack');
	}

	function EnemyNotVisible()
	{
		if ( !bGathering && (aggressiveness > relativestrength(enemy)) )
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
		local actor HitActor;
		local vector HitLocation, HitNormal;

		if (Enemy == none || Enemy.bDeleteme || Enemy.Health<=0 || Enemy==self )
			return false;
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, LastSeeingPos, false);
		return (HitActor == None);
	}

	function GiveUpTactical(bool bNoCharge)
	{
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
			GotoState('Attacking');
		else if ( !bNoCharge && (2 * CombatStyle > (3 - Skill) * FRand()) )
			GotoState('Charging');
		else if ( bReadyToAttack && (skill > 3 * FRand() - 1) )
			GotoState('RangedAttack');
		else
			GotoState('RangedAttack', 'Challenge');
	}

	function bool TryToward(inventory Inv, float Weight)
	{
		local bool success;
		local vector pickdir, collSpec, minDest, HitLocation, HitNormal;
		local Actor HitActor;

		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			WhatToDoNext('','');
			return false;
		}
		if ( (Weight < 0.0008) && ((Weight < 0.0008 - 0.0002 * skill)
		                           || !Enemy.LineOfSightTo(Inv)) )
			return false;

		pickdir = Inv.Location - Location;
		if ( Physics == PHYS_Walking )
			pickDir.Z = 0;
		pickDir = Normal(PickDir);

		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);

		minDest = Location + FMin(160.0, 3*CollisionRadius) * pickDir;
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
			if ( success )
			{
				Destination = Inv.Location;
				bGathering = true;
				if ( 2.7 * FRand() < skill )
					GotoState('TacticalMove','DoStrafeMove');
				else
					GotoState('TacticalMove','DoDirectMove');
				return true;
			}
		}

		return false;
	}

	function PainTimer()
	{
		if ( (FootRegion.Zone.bPainZone) && (FootRegion.Zone.DamagePerSec > 0)
		        && (FootRegion.Zone.DamageType != ReducedDamageType) )
			GotoState('Retreating');
		Super.PainTimer();
	}


	/* PickDestination()
	Choose a destination for the tactical move, based on aggressiveness and the tactical
	situation. Make sure destination is reachable
	*/
	function PickDestination(bool bNoCharge)
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;

		// possibly pick nearby inventory
		// higher skill bots will always strafe, lower skill
		// both do this less, and strafe less
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			WhatToDoNext('','');
			return;
		}
		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);
		if ( Level.TimeSeconds - LastInvFind < 2.5 - 0.5 * skill )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		LastInvFind = Level.TimeSeconds;
		bGathering = false;
		BestWeight = 0;
		MaxDist = 600 + 70 * skill;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist)
		if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
		        && (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
		        && (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
		{
			NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
			if ( NewWeight > BestWeight )
			{
				SecondWeight = BestWeight;
				BestWeight = NewWeight;
				SecondInv = BestInv;
				BestInv = Inv;
			}
		}

		if ( BestInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(BestInv, BestWeight) )
			return;

		if ( SecondInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(SecondInv, SecondWeight) )
			return;

		PickRegDestination(bNoCharge);
	}

	function PickRegDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;

		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		{
			WhatToDoNext('','');
			return;
		}
		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);

		success = false;
		enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear) && (CombatStyle > 0) )
			Aggression = Aggression - 2 - 2 * CombatStyle;
		if ( Weapon != None )
			Aggression += 2 * Weapon.SuggestAttackStyle();
		if ( Enemy.Weapon != None )
			Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();

		if ( enemyDist > 1000 )
			Aggression += 1;
		if ( !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 140) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemyDist < 1.1 * (Enemy.Location.Z - Location.Z))
				          && !actorReachable(Enemy) )
				{
					bNoReach = true;
					aggression = -1.5 * FRand();
				}
			}
		}

		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.15);
				GotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();

		enemydir = (Enemy.Location - Location)/enemyDist;
		minDist = FMin(160.0, 3*CollisionRadius);
		optDist = 80 + FMin(EnemyDist, 250 * (FRand() + FRand()));
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
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear)) )
					enemypart = vect(0,0,0);
				else if ( (enemydir Dot enemyPart) < 0 )
					enemyPart = -1 * enemyPart;
				pickDir = Normal(enemyPart - pickdir + HitNormal);
				minDest = Location + minDist * pickDir;
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
						Destination = minDest + pickDir * optDist;
				}
			}
		}

		if ( !success )
			GiveUpTactical(bNoCharge);
		else
		{
			pickDir = (Destination - Location);
			enemyDist = VSize(pickDir);
			if ( enemyDist > minDist + 2 * CollisionRadius )
			{
				pickDir = pickDir/enemyDist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickDir) < -0.6) )
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
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
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
		HaltFiring();
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
			GotoState('Attacking');
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);
	}

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && ValidRecovery() )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}

NoCharge:
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	TweenToRunning(0.15);
	Enable('AnimEnd');
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
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	Destination = LastSeeingPos + 3 * CollisionRadius * Normal(LastSeeingPos - Location);
	if ( bCanStrafe || (VSize(LastSeeingPos - Location) < 3 * CollisionRadius) )
		StrafeFacing(Destination, Enemy);
	else
		MoveTo(Destination);
	if ( Weapon == None )
		Acceleration = vect(0,0,0);
	if ( NeedToTurn(Enemy.Location) )
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	if ( CanFireAtEnemy() )
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
				Acceleration = vect(0,0,0);
				Sleep(0.1);
			}
		}

		if ( (FRand() + 0.1 > CombatStyle) )
		{
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}

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
		bCanJump = ( (MoveTarget != None) || PointReachable(Destination) );
	}

	function Bump(actor Other)
	{
		//log(Other.class$" bumped "$class);
		if (Pawn(Other) != None)
		{
			if (Enemy == Other)
				bReadyToAttack = True; //can melee right away
			SetEnemy(Pawn(Other));
			LastSeenPos = Enemy.Location;
		}
		setTimer(2.0, false);
		Disable('Bump');
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
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
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

	function HearNoise(float Loudness, Actor NoiseMaker)
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
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			if ( CombatStyle > FRand() )
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
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = true;
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
		local actor HitActor;
		local vector HitNormal, HitLocation, nextSpot, ViewSpot;
		local float posZ, elapsed;
		local bool bCanSeeLastSeen;

		// If no enemy, or I should see him but don't, then give up
		if ( Enemy == none || enemy.health <= 0 || enemy.bdeleteme || Enemy == self )
		{
			WhatToDoNext('','');
			return;
		}

		bAvoidLedges = false;
		elapsed = Level.TimeSeconds - HuntStartTime;
		if ( elapsed > 30 )
		{
			WhatToDoNext('','');
			return;
		}

		if ( JumpZ > 0 )
			bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			if ( (numHuntPaths < 8 + Skill) || (elapsed < 15)
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
		HitActor = Trace(HitLocation, HitNormal, LastSeenPos, ViewSpot, false);
		bCanSeeLastSeen = (HitActor == None);
		if ( bCanSeeLastSeen )
		{
			HitActor = Trace(HitLocation, HitNormal, LastSeenPos, Enemy.Location, false);
			bHunting = (HitActor != None);
		}
		else
			bHunting = true;

		if ( FindBestPathToward(Enemy) )
			return;
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

		if ( NumHuntPaths > 60 )
		{
			WhatToDoNext('', '');
			return;
		}

		if ( LastSeeingPos != vect(1000000,0,0) )
		{
			Destination = LastSeeingPos;
			LastSeeingPos = vect(1000000,0,0);
			HitActor = Trace(HitLocation, HitNormal, Enemy.Location, ViewSpot, false);
			if ( HitActor == None )
			{
				If (VSize(Location - Destination) < 20)
				{
					HitActor = Trace(HitLocation, HitNormal, Enemy.Location, ViewSpot, false);
					if (HitActor == None)
					{
						SetEnemy(Enemy);
						return;
					}
				}
				return;
			}
		}

		bAvoidLedges = (CollisionRadius > 42);
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		HitActor = Trace(HitLocation, HitNormal, nextSpot , ViewSpot, false);
		if ( HitActor == None )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			HitActor = Trace(HitLocation, HitNormal, LastSeenPos , ViewSpot, false);
			if ( HitActor != None )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
					GotoState('Hunting', 'AdjustFromWall');
				else if ( VSize(Enemy.Location - Location) < 1200 )
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
		local vector X,Y,Z, HitLocation, HitNormal;
		local actor HitActor;
		local bool bAlwaysTry;
		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;

		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location + 2 * Y * CollisionRadius, false);
		if ( HitActor == None )
		{
			Destination = Location + 2.5 * Y * CollisionRadius;
			return true;
		}

		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location - 2 * Y * CollisionRadius, false);
		if ( HitActor == None )
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
		//if ( health <= 0 )
		//	log(self$" hunting while dead");
		SpecialGoal = None;
		SpecialPause = 0.0;
		bFromWall = false;
		SetAlertness(0.5);
	}

	function EndState()
	{
		bAvoidLedges = false;
		bHunting = false;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
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
	TweenToRunning(0.15);
	bFromWall = false;

Follow:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SetEnemy(Enemy);
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

	Goto('Follow');
}

state StakeOut
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	                     Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme)
			return;
		bFrustrated = true;
		LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
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

	function HearNoise(float Loudness, Actor NoiseMaker)
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
		if (Global.SetEnemy(NewEnemy))
		{
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
		local actor HitActor;
		local vector HitLocation, HitNormal;

		FireSpot = LastSeenPos;
		aimerror = aimerror * (0.5 * (4 - skill - FRand()));

		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			////log("adjust aim up");
			FireSpot.Z += 0.9 * Target.CollisionHeight;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
			bClearShot = (HitActor == None);
		}

		FireRotation = Rotator(FireSpot - ProjStart);

		FireRotation.Yaw = FireRotation.Yaw + 0.5 * (Rand(2 * aimerror) - aimerror);
		viewRotation = FireRotation;
		return FireRotation;
	}

	function BeginState()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;

		Acceleration = vect(0,0,0);
		bCanJump = false;
		HitActor = Trace(HitLocation, HitNormal, LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location + vect(0,0,0.8) * EyeHeight, false);
		bClearShot = (HitActor == None);
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
	if ( bClearShot && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 150)
	        && CanStakeOut() )
		PlayRangedAttack();
	FinishAnim();
	PlayChallenge();
	if ( bCrouching && !Region.Zone.bWaterZone )
		Sleep(1);
	bCrouching = false;
	Sleep(1 + FRand());
	if ( !bClearShot || (VSize(Enemy.Location - Location)
	                     > 300 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 350) )
		GotoState('Hunting', 'AfterFall');
	else if ( CanStakeOut() )
		Goto('Begin');
	else
		GotoState('Hunting', 'AfterFall');
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
		//if ( Health <= 0 )
		//	log(self$" fall from takehit while dead");
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

	singular event BaseChange()
	{
		local float decorMass;

		if (bDeleteme)
			return;
		if ( (Base != None) && Base.IsA('Mover')
		        && ((MoveTarget == Base)
		            || ((MoveTarget != None) && (MoveTarget == Mover(Base).myMarker))) )
		{
			MoveTimer = -1.0;
			MoveTarget = None;
			acceleration = vect(0,0,0);
			return;
		}

		if ( (base == None) && (Physics == PHYS_None) )
			SetPhysics(PHYS_Falling);
		else if (Pawn(Base) != None)
		{
			if (!Pawn(base).bDeleteme && Pawn(base).Health > 0 )
				Pawn(base).TakeDamage( (1-Velocity.Z/400)* Mass/Pawn(base).Mass, Self,Location,0.5 * Velocity , 'stomped');
			JumpOffPawn();
		}
		else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
		{
			decorMass = FMax(Decoration(Base).Mass, 1);
			if (!Base.bDeleteme)
				Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, 'stomped');
		}
	}

	function ZoneChange(ZoneInfo newZone)
	{
		//if ( Health <= 0 )
		//	log("Zonechange in falling state while dead");
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
		local float Z;
		
		Z = Default.JumpZ*0.5f;
		Velocity = SuggestFallVelocity(Location,Destination,FMax(JumpZ-Z,0.f),GroundSpeed,Velocity.Z+Z);
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	                     Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme)
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
		//if ( Health <= 0 )
		//	log(self$" fall from timer while dead");
		if ( Enemy != None )
		{
			bReadyToAttack = true;
			if ( CanFireAtEnemy() )
				GotoState('FallingState', 'FireWhileFalling');
		}
	}

	function Landed(vector HitNormal)
	{
		local vector Vel2D;

		if ( MoveTarget != None )
		{
			Vel2D = Velocity;
			Vel2D.Z = 0;
			if ( (Vel2D Dot (MoveTarget.Location - Location)) < 0 )
				Acceleration = vect(0,0,0);
		}
		//Note - physics changes type to PHYS_Walking by default for landed pawns
		PlayLanded(Velocity.Z);
		if (Velocity.Z < -1.4 * JumpZ)
		{
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
			if (Velocity.Z <= -1100)
			{
				if ( (Velocity.Z < -2000) && (ReducedDamageType != 'All') )
				{
					health = -1000; //make sure gibs
					Died(None, 'fell', Location);
				}
				else if ( Role == ROLE_Authority )
					TakeDamage(-0.15 * (Velocity.Z + 1050), None, Location, vect(0,0,0), 'fell');
			}
			if ( health > 0 )
				GotoState('FallingState', 'Landed');
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
		//if ( Health < 0 )
		//	log(self$" setfall from fall");
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
		//if ( Health <= 0 )
		//	log(self$" entered falling state at "$Level.Timeseconds$ "with next "$NextState);
		if (Enemy == None)
			Disable('EnemyNotVisible');
		else
		{
			Disable('HearNoise');
			Disable('SeePlayer');
		}
		if ( (bFire > 0) || (bAltFire > 0) || (Skill == 3) )
			SetTimer(0.01, false);
	}

	function EndState()
	{
		bUpAndOut = false;
	}

FireWhileFalling:
	if ( Physics != PHYS_Falling )
		Goto('Done');
	TurnToward(Enemy);
	if ( CanFireAtEnemy() )
		FireWeapon();
	Sleep(0.9 + 0.2 * FRand());
	Goto('FireWhileFalling');

LongFall:
	if ( bCanFly )
	{
		SetPhysics(PHYS_Flying);
		Goto('Done');
	}
	Sleep(0.7);
	TweenToFighter(0.2);
	if ( Enemy != None )
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
	if ( Velocity.Z > -20.f && Velocity.Z<=0.f ) //stuck
	{
		SetPhysics(PHYS_Falling);
		if ( Enemy != None )
			Velocity = groundspeed * normal(Enemy.Location - Location);
		else
			Velocity = groundspeed * VRand();

		Velocity.Z = FMax(JumpZ, 250);
	}
	Goto('LongFall');

Landed:
	//log("Playing "$animsequence$" at "$animframe);
	FinishAnim();
	//log("Finished "$animsequence$" at "$animframe);
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
			TweenAnim(NextAnim, 0.12);
	}

Splash:
	bUpAndOut = false;
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
	if ( !bUpAndOut ) // not water jump
	{
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
			GotoState(NextState, NextLabel);
		}
		if ( bJumpOffPawn )
			bJumpOffPawn = false;
		else AdjustJump();
		if( JumpZ>0.f && Velocity.Z>(JumpZ*0.75) && Velocity.Z<(JumpZ*1.1) ) // Marco: Do this check even if bJumpOffPawn because AdjustWall can change it to true aswell.
		{
			PlaySound(JumpSound, SLOT_Talk, 1.0, true, 1200, 1.0);
			if( bCountJumps && Inventory )
				Inventory.OwnerJumped();
		}
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

state RangedAttack
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
		if ( bFiringPaused )
			return;
		if ( (Enemy == None) || (Enemy.Health <= 0)
		        ||(Enemy.bDeleteme) || (!LineOfSightTo(Enemy)) )
		{
			bFire = 0;
			bAltFire = 0;
			GotoState('Attacking');
		}
		else if ( Skill > 3.5 * FRand() - 0.5 )
		{
			bReadyToAttack = true;
			GotoState('TacticalMove');
		}
	}

	function Timer()
	{
		if ( bFiringPaused )
		{
			TweenToRunning(0.12);
			GotoState(NextState, NextLabel);
		}
	}

	function AnimEnd()
	{
		local float decision;

		decision = FRand() - 0.27 * skill - 0.1;
		if ( (bFire == 0) && (bAltFire == 0) )
			decision = decision - 0.5;
		if ( decision < 0 )
			GotoState('RangedAttack', 'DoneFiring');
		else
		{
			PlayWaiting();
			FireWeapon();
		}
	}

	function SpecialFire()
	{
		bFiringPaused = true;
		SetTimer(0.75 + VSize(Target.Location - Location)/Weapon.AltProjectileSpeed, false);
		SpecialPause = 0.0;
		NextState = 'Attacking';
		NextLabel = 'Begin';
	}

	function BeginState()
	{
		Disable('AnimEnd');
		if ( bFiringPaused )
		{
			SetTimer(SpecialPause, false);
			SpecialPause = 0;
		}
		else
		{
			if ( Enemy != none && Enemy.health > 0 && !Enemy.bdeleteme && Enemy != self )
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
	if ( Enemy == none || Enemy.health <= 0 || Enemy.bdeleteme || Enemy == self )
		GotoState('Attacking');
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	if ( bCrouching && !Region.Zone.bWaterZone )
		Sleep(0.8 + FRand());
	bCrouching = false;
	TweenToFighter(0.1);
	Goto('FaceTarget');

Begin:
	if ( Target == None )
	{
		if ( Enemy != none && Enemy.health > 0 && !Enemy.bdeleteme && Enemy!=self )
			Target = Enemy;
		if ( Target == None )
			GotoState('Attacking');
	}
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Target.Location - Location);
	TweenToFighter(0.15);

FaceTarget:
	Disable('AnimEnd');
	if ( Target == None || Target.bdeleteme)
		GotoState('Attacking');
	if (NeedToTurn(Target.Location))
	{
		PlayTurning();
		TurnToward(Target);
		TweenToFighter(0.1);
	}
	FinishAnim();

ReadyToAttack:
	if ( Target == None || Target.bdeleteme)
		GotoState('Attacking');
	DesiredRotation = Rotator(Target.Location - Location);
	PlayRangedAttack();
	Enable('AnimEnd');
Firing:
	if ( Target == None || Target.bdeleteme)
		GotoState('Attacking');
	TurnToward(Target);
	Goto('Firing');
DoneFiring:
	Disable('AnimEnd');
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
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function BeginState()
	{
		//if ( Health < 0 )
		//	log(self$" victory dance while dead");
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
	}

Begin:
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(Target);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();
	PlayVictoryDance();
	FinishAnim();
	WhatToDoNext('Waiting','TurnFromWall');
}


state GameEnded
{
ignores SeePlayer, EnemyNotVisible, HearNoise, TakeDamage, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, PainTimer, StartClimbing;

	function BeginState()
	{
		bFire = 0;
		bAltFire = 0;
		SetPhysics(PHYS_None);
		AnimRate = 0;

		// Freeze frame replication setup.
		SimAnim.X = 10000 * AnimFrame;
		SimAnim.Y = 0;
		SimAnim.Z = 0;
		SimAnim.W = 10000 * AnimLast;
	}
}

state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, PainTimer, StartClimbing;

	function ReStartPlayer()
	{
		if ( bHidden && Level.Game.RestartPlayer(self) )
		{
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			ViewRotation = Rotation;
			ReSetSkill();
			SetPhysics(PHYS_Falling);
			GotoState('Roaming');
		}
		else
			GotoState('Dying', 'TryAgain');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	                     Vector momentum, name damageType)
	{
		if ( !bHidden )
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	function BeginState()
	{
		SetTimer(0, false);
		Enemy = None;
		AmbushSpot = None;
		bFire = 0;
		bAltFire = 0;
	}

	function EndState()
	{
		//if ( Health <= 0 )
		//	log(self$" health still <0"); Debug logging?
	}

Begin:
	Sleep(0.2);
	if ( !bHidden )
	{
		SpawnCarcass();
		HidePlayer();
	}
TryAgain:
	if (Level.Game.Isa('DeathMatchGame'))
		Sleep(0.25 + DeathMatchGame(Level.Game).NumBots * FRand());
	else Sleep(0.25 + FRand() * 5);
	ReStartPlayer();
	Goto('TryAgain');
WaitingForStart:
	bHidden = true;
}

//FIXME - improve FindAir (use paths)
state FindAir
{
ignores SeePlayer, HearNoise, Bump;

	function HeadZoneChange(ZoneInfo newHeadZone)
	{
		Global.HeadZoneChange(newHeadZone);
		if (!newHeadZone.bWaterZone)
			GotoState('Attacking');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
	                     Vector momentum, name damageType)
	{
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 || bDeleteme )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'FindAir';
			NextLabel = 'TakeHit';
			GotoState('TakeHit');
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		//change directions
		Destination = 200 * (Normal(Destination - Location) + HitNormal);
	}

	function AnimEnd()
	{
		if (Enemy != None)
			PlayCombatMove();
		else
			PlayRunning();
	}

	function Timer()
	{
		bReadyToAttack = True;
		settimer(0.5, false);
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		bReadyToAttack = false;
	}

	/* PickDestination()
	*/
	function PickDestination(bool bNoCharge)
	{
		Destination = VRand();
		Destination.Z = 1;
		Destination = Location + 200 * Destination;
	}

Begin:
	//log("Find air");
	TweenToRunning(0.2);
	Enable('AnimEnd');
	PickDestination(false);

DoMove:
	if ( Enemy == None )
		MoveTo(Destination);
	else
	{
		bCanFire = true;
		StrafeFacing(Destination, Enemy);
	}
	GotoState('Attacking');

TakeHit:
	TweenToRunning(0.15);
	Goto('DoMove');

}

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	// Since these 2 functions are identical, let UnrealIPlayer class handle it all.
	Class'UnrealIPlayer'.Static.SetMultiSkin(SkinActor,SkinName,FaceName,TeamNum);
}

/*
227 functions: Do NOT use these functions!!!
otherwise the custom mod may give some compatibility issues
*/

// Ladder AI:
function StartClimbing( LadderTrigger Other )
{
	if( Abs(Velocity.Z)>Other.MaxGrabVelocity || MoveTarget==None || MoveTarget.Location.Z<Other.Location.Z )
		return; // Can't climb the ladder at this time.
	if( Other.ClimbingNoise!=None )
		PlaySound(Other.ClimbingNoise,SLOT_Misc,1.5);
	ActiveLadder = Other;
	SetRotation(Other.Rotation);
	DesiredRotation = Other.Rotation;
	GoToState('PlayerClimbing');
}
function PlayClimbing()
{
	PlayRunning();
}

State PlayerClimbing
{
Ignores AnimEnd,HearNoise,AddVelocity;

	function StartClimbing( LadderTrigger Other )
	{
		ActiveLadder = Other; // Begin next ladder.
	}
	function EndClimbing( LadderTrigger Other )
	{
		local LadderTrigger L;

		if( ActiveLadder==Other )
		{
			ActiveLadder = None;
			foreach TouchingActors(Class'LadderTrigger',L)
				if( L!=Other )
					L.Touch(Self);
			if( ActiveLadder==None )
				DropFromLadder();
		}
	}
	function DropFromLadder()
	{
		PlayInAir();
		Velocity = vector(Rotation)*300.f;
		Velocity.Z = Default.JumpZ*0.5f;
		WhatToDoNext('','');
	}
	function Tick( float Delta )
	{
		// Movement hack!
		Velocity = vect(0,0,0.4f)*AirSpeed;
		if( !MoveSmooth(Velocity*Delta) )
			DropFromLadder();
	}
	function BeginState()
	{
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
		if( Base!=None )
			SetBase(Level);
		PlayClimbing();
	}
	function EndState()
	{
		ActiveLadder = None;
		if( Region.Zone.bWaterZone )
			SetPhysics(PHYS_Swimming);
		else SetPhysics(PHYS_Falling);
	}
}

defaultproperties
{
	UsingConfigIndex=-1
	CarcassType=Class'CreatureCarcass'
	TimeBetweenAttacks=1.000000
	Aggressiveness=0.200000
	WalkingSpeed=0.400000
	RefireRate=0.900000
	bLeadTarget=True
	bWarnTarget=True
	bIsPlayer=True
	bCanStrafe=True
	bAutoActivate=True
	MeleeRange=50.000000
	Intelligence=BRAINS_HUMAN
	GroundSpeed=400.000000
	AirSpeed=400.000000
	AccelRate=2048.000000
	SightRadius=3000.000000
	HearingThreshold=0.300000
	BaseEyeHeight=23.000000
	UnderWaterTime=20.000000
	Land=Sound'Land1'
	WaterStep=Sound'LSplash'
	bStasis=False
	DrawType=DT_Mesh
	LightBrightness=70
	LightHue=40
	LightSaturation=128
	LightRadius=6
	Buoyancy=100.000000
	RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
	NetPriority=8.000000
	bClientSimFall=True
	CollisionFlag=COLLISIONFLAG_Bots
	bNoDynamicShadowCast=false
}