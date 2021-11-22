//=============================================================================
// Parent class of all weapons.
//=============================================================================
class Weapon extends Inventory
		abstract
			native
				NativeReplication;
				
#exec Texture Import File=Textures\Weapon.pcx Name=S_Weapon Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Weapon ammo/firing information:
// Two-element arrays here are defined for normal fire (0) and alt fire (1).
var() float   MaxTargetRange;    // Maximum distance to target.
var() class<ammo> AmmoName;          // Type of ammo used.
var() byte    ReloadCount;       // Amount of ammo depletion before reloading. 0 if no reloading is done.
var() int     PickupAmmoCount;   // Amount of ammo initially in pick-up item.
var travel ammo	AmmoType;		 // Inventory Ammo being used.
var	  bool	  bPointing;		 // Indicates weapon is being pointed
var() bool	  bInstantHit;		 // If true, instant hit rather than projectile firing weapon
var() bool	  bAltInstantHit;	 // If true, instant hit rather than projectile firing weapon for AltFire
var(WeaponAI) bool	  bWarnTarget;		 // When firing projectile, warn the target
var(WeaponAI) bool	  bAltWarnTarget;	 // When firing alternate projectile, warn the target
var   bool	  bWeaponUp;		 // Used in Active State
var   bool	  bChangeWeapon;	 // Used in Active State
var   bool 	  bLockedOn;
var(WeaponAI) bool	  bSplashDamage;	 // used by bot AI
var()		  bool	  bCanThrow;	//if true, player can toss this weapon out
var(WeaponAI) bool	  bRecommendSplashDamage; //if true, bot preferentially tries to use splash damage
// rather than direct hits
var() bool	  bWeaponStay;
var() bool	  bOwnsCrosshair;	// this weapon is responsible for drawing its own crosshair (in its postrender function)
var	  bool	  bHideWeapon;		// if true, weapon is not rendered
var(WeaponAI) bool	  bMeleeWeapon; //Weapon is only a melee weapon
var() bool	  bRapidFire;		// used by human animations in determining firing animation (for still firing)
var	  bool	  bTossedOut;		// true if weapon was tossed out (so players can't cheat w/ weaponstay)
var() float	  FiringSpeed;		// used by human animations in determining firing speed

var()   vector	FireOffset;		 // Offset from drawing location for projectile/trace start
var()   class<projectile> ProjectileClass;
var()   class<projectile> AltProjectileClass;
var()	name MyDamageType;
var()	name AltDamageType;
var		float	ProjectileSpeed;
var		float	AltProjectileSpeed;
var		float	AimError;		// Aim Error for bots (note this value doubled if instant hit weapon)
var()	float	ShakeMag;
var()	float	ShakeTime;
var()	float   ShakeVert;
var(WeaponAI)	float	AIRating;
var(WeaponAI)	float	RefireRate;
var(WeaponAI)	float	AltRefireRate;

// Third person weapon mesh attachment class (spawned and destroyed by the engine)
var() class<WeaponAttachment> ThirdPersonAttachment;
var transient WeaponAttachment Attachment;

//-----------------------------------------------------------------------------
// Sound Assignments
var() sound 	FireSound;
var() sound 	AltFireSound;
var() sound 	CockingSound;
var() sound 	SelectSound;
var() sound 	Misc1Sound;
var() sound 	Misc2Sound;
var() sound 	Misc3Sound;

var() Localized string MessageNoAmmo;
var() Localized string DeathMessage, FemDeathMessage, FemKillMessage;

var Rotator AdjustedAim;
var transient bool bBreakWeaponChange;

//-----------------------------------------------------------------------------
// Muzzle Flash
// weapon is responsible for setting and clearing bMuzzleFlash whenever it wants the
// MFTexture drawn on the canvas (see RenderOverlays() )
var bool bSetFlashTime;
var(MuzzleFlash) bool bDrawMuzzleFlash;
var byte bMuzzleFlash;
var float FlashTime;
var(MuzzleFlash) float MuzzleScale, FlashY, FlashO, FlashC, FlashLength;
var(MuzzleFlash) int FlashS;	// size of (square) texture/2
var(MuzzleFlash) texture MFTexture;
var(MuzzleFlash) texture MuzzleFlare;
var(MuzzleFlash) float FlareOffset;

// Network replication
//
replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		bHideWeapon; 
	reliable if ( Role==ROLE_Authority && bNetOwner )
		AmmoType, bLockedOn;
	unreliable if ( Role==ROLE_Authority && bNetOwner )
		bMuzzleFlash;
}

//=============================================================================
// Inventory travelling across servers.

function Destroyed()
{
	Super.Destroyed();
	if ( (Pawn(Owner)!=None) && (Pawn(Owner).Weapon == self) )
		Pawn(Owner).Weapon = None;
}

event TravelPostAccept()
{
	Super.TravelPostAccept();
	if ( Pawn(Owner) == None )
		return;
	if ( AmmoName != None )
	{
		AmmoType = Ammo(Pawn(Owner).FindInventoryType(AmmoName));
		if ( AmmoType == None )
		{
			AmmoType = Spawn(AmmoName);	// Create ammo type required
			Pawn(Owner).AddInventory(AmmoType);		// and add to player's inventory
			AmmoType.BecomeItem();
			AmmoType.AmmoAmount = PickUpAmmoCount;
			AmmoType.GotoState('Idle2');
		}
	}
	if ( self == Pawn(Owner).Weapon )
	{
		if ( Owner.IsA('PlayerPawn') )
			SetHand(PlayerPawn(Owner).Handedness);
		BringUp();
	}
	else GoToState('Idle2');
}

//=============================================================================
// Weapon rendering
// Draw first person view of inventory
simulated event RenderOverlays( canvas Canvas )
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;

	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
	{
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;
	}
	if( Level.bIsDemoPlayback )
	{
		bPlayerOwner = false;
		Hand = Class'PlayerPawn'.Default.Handedness;
		if( Hand==2 )
			return;
	}

	if (  (Level.NetMode == NM_Client) && bPlayerOwner && (Hand == 2) )
	{
		bHideWeapon = true;
		return;
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None) )
	{
		MuzzleScale = Default.MuzzleScale * Canvas.ClipX/640.0;
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;
		if ( bMuzzleFlash > 0 )
		{
			if ( Hand == 0 )
				Canvas.SetPos(Canvas.ClipX/2 - MuzzleScale * FlashS + Canvas.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - MuzzleScale * FlashS + Canvas.ClipY * (FlashY + FlashC));
			else
				Canvas.SetPos(Canvas.ClipX/2 - MuzzleScale * FlashS + Canvas.ClipX * (Hand * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - MuzzleScale * FlashS + Canvas.ClipY * FlashY);

			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzzleScale);
			Canvas.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	NewRot = Pawn(Owner).ViewRotation;
	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	SetLocation( Owner.Location + CalcDrawOffset(), newRot );
	Canvas.DrawActor(self, false);
}

//-------------------------------------------------------
// AI related functions

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetWeaponStay();
	MaxDesireability = 1.2 * AIRating;
	if ( ProjectileClass != None )
	{
		ProjectileSpeed = ProjectileClass.Default.Speed;
		MyDamageType = ProjectileClass.Default.MyDamageType;
	}
	if ( AltProjectileClass != None )
	{
		AltProjectileSpeed = AltProjectileClass.Default.Speed;
		AltDamageType = AltProjectileClass.Default.MyDamageType;
	}
	if( Level.Game.Difficulty>5.f )
	{
		bWarnTarget = true;
		bAltWarnTarget = true;
	}
}

function SetWeaponStay()
{
	bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

event float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;

	desire = MaxDesireability + Bot.AdjustDesireFor(self);
	AlreadyHas = Weapon(Bot.FindInventoryType(class));
	if ( AlreadyHas != None )
	{
		if ( (RespawnTime < 10)
				&& ( bHidden || (AlreadyHas.AmmoType == None)
					 || (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo)) )
			return 0;
		if ( (!bHeldItem || bTossedOut) && bWeaponStay )
			return 0;
		if ( AlreadyHas.AmmoType == None )
			return 0.25 * desire;

		if ( AlreadyHas.AmmoType.AmmoAmount > 0 )
			return FMax( 0.25 * desire,
						 AlreadyHas.AmmoType.MaxDesireability
						 * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo/AlreadyHas.AmmoType.AmmoAmount) );
		else
			return 0.05;
	}
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4) )
		return 2*desire;

	return desire;
}

function float RateSelf( out int bUseAltMode )
{
	if ( (AmmoType != None) && (AmmoType.AmmoAmount <=0) )
		return -2;
	bUseAltMode = int(FRand() < 0.4);
	return (AIRating + FRand() * 0.05);
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return 0.0;
}

function float SuggestDefenseStyle()
{
	return 0.0;
}

//-------------------------------------------------------

simulated function PreRender( canvas Canvas );
simulated function PostRender( canvas Canvas );

function bool HandlePickupQuery( inventory Item )
{
	local int OldAmmo;
	local Pawn P;

	if (Item.Class == Class)
	{
		if ( Weapon(item).bWeaponStay && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
			return true;
		P = Pawn(Owner);
		if ( AmmoType != None )
		{
			OldAmmo = AmmoType.AmmoAmount;
			if ( AmmoType.AddAmmo(Weapon(Item).PickupAmmoCount) && (OldAmmo == 0)
					&& (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
				WeaponSet(P);
		}
		P.ClientMessage(Item.PickupMessage, 'Pickup');
		Item.PlaySound(Item.PickupSound);
		Item.SetRespawn();
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// set which hand is holding weapon
function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		PlayerViewOffset.Y = 0;
		FireOffset.Y = 0;
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;

	if ( Hand == 0 )
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
		PlayerViewOffset.Y = -0.2 * Default.PlayerViewOffset.Y;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
	}
	else
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
	}
	PlayerViewOffset *= 100; //scale since network passes vector components as ints
	FireOffset.Y = Default.FireOffset.Y * Hand;
}

//
// Change weapon to that specificed by F matching inventory weapon's Inventory Group.
function Weapon WeaponChange( byte F )
{
	local Weapon newWeapon;

	if (bBreakWeaponChange)
		return none;

	if ( InventoryGroup == F )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
		{
			if ( Inventory == None )
				newWeapon = None;
			else
				newWeapon = Inventory.WeaponChange(F);
			if ( newWeapon == None )
				Pawn(Owner).ClientMessage( ItemName$MessageNoAmmo );
			return newWeapon;
		}
		else
			return self;
	}
	else if ( Inventory == None )
		return None;
	else
		return Inventory.WeaponChange(F);
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
// Also add Ammo to Other's inventory if it doesn't already exist
//
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local Weapon newWeapon;

	if ( Level.Game.ShouldRespawn(self) )
	{
		Copy = spawn(Class,Other);
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		if ( !bWeaponStay )
			GotoState('Sleeping');
	}
	else
		Copy = self;

	Copy.RespawnTime = 0.0;
	Copy.bHeldItem = true;
	Copy.GiveTo( Other );
	newWeapon = Weapon(Copy);
	newWeapon.Instigator = Other;
	newWeapon.GiveAmmo(Other);
	newWeapon.SetSwitchPriority(Other);
	if ( !Other.bNeverSwitchOnPickup )
		newWeapon.WeaponSet(Other);
	newWeapon.AmbientGlow = 0;
	return newWeapon;
}

function SetSwitchPriority(pawn Other)
{
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
			if ( PlayerPawn(Other).WeaponPriority[i] == class.name )
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = class.name;
		for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == '' )
			{
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			}
			else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
			{
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}
	}
}

function GiveAmmo( Pawn Other )
{
	if ( AmmoName == None )
		return;
	AmmoType = Ammo(Other.FindInventoryType(AmmoName));
	if ( AmmoType != None )
		AmmoType.AddAmmo(PickUpAmmoCount);
	else
	{
		AmmoType = Spawn(AmmoName);	// Create ammo type required
		Other.AddInventory(AmmoType);		// and add to player's inventory
		AmmoType.BecomeItem();
		AmmoType.AmmoAmount = PickUpAmmoCount;
		AmmoType.GotoState('Idle2');
	}
}

// Return the switch priority of the weapon (normally AutoSwitchPrioirity, but may be
// modified by environment (or by other factors for bots)
function float SwitchPriority()
{
	local int bTemp;

	if ( !Owner.IsA('PlayerPawn') )
		return RateSelf(bTemp);
	else if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else
		return AutoSwitchPriority;
}

// Compare self to current weapon.  If better than current weapon, then switch
function bool WeaponSet(Pawn Other)
{
	if ( Other.Weapon == self)
		return false;

	if ( Other.Weapon == None )
	{
		Other.PendingWeapon = self;
		Other.ChangedWeapon();
		return true;
	}
	else if ( (Other.Weapon.SwitchPriority() < SwitchPriority())
			  && Other.Weapon.PutDown() )
	{
		Other.PendingWeapon = Self;
		GotoState('');
		return true;
	}
	else
	{
		GoToState('');
		return false;
	}
}

function Weapon RecommendWeapon( out float rating, out int bUseAltMode )
{
	local Weapon Recommended;
	local float oldRating;
	local int oldMode;

	if ( Owner.IsA('PlayerPawn') )
		rating = SwitchPriority();
	else
	{
		rating = RateSelf(bUseAltMode);
		if ( (self == Pawn(Owner).Weapon) && (Pawn(Owner).Enemy != None)
				&& ((AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
			rating += 0.21; // tend to stick with same weapon
	}
	if ( inventory != None )
	{
		Recommended = inventory.RecommendWeapon(oldRating, oldMode);
		if ( (Recommended != None) && (oldRating > rating) )
		{
			rating = oldRating;
			bUseAltMode = oldMode;
			return Recommended;
		}
	}
	return self;
}

// Toss this weapon out
function DropFrom(vector StartLocation)
{
	if ( !SetLocation(StartLocation) )
		return;
	AIRating = Default.AIRating;
	bMuzzleFlash = 0;
	AmbientSound = None;
	if ( AmmoType != None )
	{
		PickupAmmoCount = AmmoType.AmmoAmount;
		AmmoType.AmmoAmount = 0;
	}
	Super.DropFrom(StartLocation);
}

// Become a pickup
function BecomePickup()
{
	Super.BecomePickup();
	SetDisplayProperties(Default.Style, Default.Texture, Default.bUnlit, Default.bMeshEnviromap );
}

//**************************************************************************************
//
// Firing functions and states
//

function CheckVisibility()
{
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if ( PawnOwner && PawnOwner.bHidden && (PawnOwner.Health > 0) && (PawnOwner.Visibility < PawnOwner.Default.Visibility) )
	{
		PawnOwner.bHidden = false;
		PawnOwner.Visibility = PawnOwner.Default.Visibility;
	}
}

function Fire( float Value )
{
	if (AmmoType.UseAmmo(1))
	{
		GotoState('NormalFire');
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		bPointing=True;
		PlayFiring();
		if ( !bRapidFire && (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		if ( Owner && Owner.bHidden )
			CheckVisibility();
	}
}

function AltFire( float Value )
{
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		bPointing=True;
		PlayAltFiring();
		if ( !bRapidFire && (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bAltInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
		if ( Owner && Owner.bHidden )
			CheckVisibility();
	}
}

function PlayFiring()
{
	//Play firing animation and sound
}

function PlayAltFiring()
{
	//Play alt firing animation and sound
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2.75*AimError, False, false);
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
			   + Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000 * X);
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	//Spawn appropriate effects at hit location, any weapon lights, and damage hit actor
}

// Finish a firing sequence
function Finish()
{
	local Pawn PawnOwner;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( PawnOwner.bFire!=0 )
		Global.Fire(0);
	else if ( PawnOwner.bAltFire!=0 )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Fire(float F)
	{
	}
	function AltFire(float F)
	{
	}

Begin:
	FinishAnim();
	Finish();
}

////////////////////////////////////////////////////////
state AltFiring
{
	function Fire(float F)
	{
	}

	function AltFire(float F)
	{
	}

Begin:
	FinishAnim();
	Finish();
}

//**********************************************************************************
// Weapon is up, but not firing
state Idle
{
	function AnimEnd()
	{
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);
	Disable('AnimEnd');
	PlayIdleAnim();
}

//
// Bring newly active weapon up
// Bring newly active weapon up
state Active
{
	function Fire(float F)
	{
	}

	function AltFire(float F)
	{
	}

	function bool PutDown()
	{
		if ( bWeaponUp || (AnimFrame < 0.75) )
			GotoState('DownWeapon');
		else
			bChangeWeapon = true;
		return True;
	}

	function BeginState()
	{
		bChangeWeapon = false;
	}

Begin:
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	PlayPostSelect();
	FinishAnim();
	Finish();
}

//
// Putting down weapon in favor of a new one.
//
State DownWeapon
{
	ignores Fire, AltFire;

	function bool PutDown()
	{
		return true; //just keep putting it down
	}

	function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = 0;
	}

Begin:
	TweenDown();
	FinishAnim();
	Pawn(Owner).ChangedWeapon();
}

function BringUp()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).EndZoom();
	bWeaponUp = false;
	PlaySelect();
	GotoState('Active');
}

function RaiseUp(Weapon OldWeapon)
{
	BringUp();
}

function bool PutDown()
{
	bChangeWeapon = true;
	return true;
}

// 227j: Force weapon to stop firing and put down.
function bool ForcePutDown()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).EndZoom();
	return PutDown();
}

function TweenDown()
{
	if ( (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 1.0, 0.05);
}

function TweenSelect()
{
	TweenAnim('Select',0.001);
}

function PlaySelect()
{
	PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

function PlayPostSelect()
{
}

function PlayIdleAnim()
{
}

defaultproperties
{
	bCanThrow=true
	DeathMessage="%o was killed by %k's %w."
	MaxTargetRange=4096.000000
	ProjectileSpeed=1000.000000
	AltProjectileSpeed=1000.000000
	aimerror=550.000000
	shakemag=300.000000
	shaketime=0.100000
	shakevert=5.000000
	AIRating=0.100000
	RefireRate=0.500000
	AltRefireRate=0.500000
	ItemName="Weapon"
	MessageNoAmmo=" has no ammo."
	AutoSwitchPriority=1
	InventoryGroup=1
	PickupMessage="You got a weapon"
	RespawnTime=30.000000
	PlayerViewOffset=(X=30.000000,Z=-5.000000)
	MaxDesireability=0.500000
	Texture=Texture'Engine.S_Weapon'
	bNoSmooth=True
	MuzzleScale=4.0
	FlashLength=+0.1
	Icon=Texture'Engine.S_Weapon'
	ThirdPersonAttachment=Class'WeaponAttachment'
}
