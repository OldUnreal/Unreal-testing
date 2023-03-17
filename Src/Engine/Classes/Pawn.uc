//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends Actor
	abstract
		native
			NativeReplication;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Pawn variables.

// General flags.
var bool		bBehindView;		// Outside-the-player view.
var bool		bIsPlayer;			// Pawn is a player or a player-bot.
var bool		bJustLanded;		// used by eyeheight adjustment
var bool		bUpAndOut;			// used by swimming
var bool		bIsWalking;
var const bool	bHitSlopedWall;		// used by Physics
var travel bool	bNeverSwitchOnPickup;	// if true, don't automatically switch to picked up weapon
var bool		bWarping;			// Set when travelling through warpzone (so shouldn't telefrag)
var bool		bUpdatingDisplay;	// to avoid infinite recursion through inventory setdisplay
var bool		bClientSimFall;		// Simulate falling physics on client
var bool		bClientTick;		// If enabled, Pawn receives Tick on client side.
var bool		bUseNoWalkInAir;	// Manual override for bNoWalkInAir option
var bool		bNoStopAtLedge;		// Don't stop at ledge even when walking/crouching.
var() bool		bPostRender2D;		// Should call PostRender2D on this pawn when visible.
var bool		bShovePawns;		// If 2 Pawns with this flag collides, they will push off each other.

//AI flags
var(Combat) bool	bCanStrafe; // AI is allowed to strafe.
var(Orders) bool	bFixedStart;
var const bool		bReducedSpeed; // used by movement nativees
var		bool		bCanJump;
var		bool 		bCanWalk;
var		bool		bCanSwim;
var		bool		bCanFly;
var		bool		bCanOpenDoors;
var		bool		bCanDoSpecial;
var		bool		bDrowning;
var const bool		bLOSflag;			// used for alternating LineOfSight traces
var 	bool 		bFromWall;
var		bool		bHunting;			// tells navigation code that pawn is hunting another pawn,
//	so fall back to finding a path to a visible pathnode if none
//	are reachable
var		bool		bAvoidLedges;		// don't get too close to ledges
var		bool		bStopAtLedges;		// if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var		bool		bJumpOffPawn;
var		bool		bShootSpecial;
var		bool		bAutoActivate;
var		bool		bIsHuman;			// for games which care about whether a pawn is a human
var		bool		bIsFemale;
var		bool		bIsMultiSkinned;
var		bool		bCountJumps;

// 227 flags
var(AI)	bool		bEnhancedSightCheck;	// If enabled, AI can see through transparent/masked BSP etc. Also faster.
var(Networking) bool bRepHealth;			// Replicate this pawns health for everyone (otherwise net owner only).
var(AI) bool		bDoAutoSerpentine;		// AI should automatically serpentine when running allong pathnodes.
var(Movement) bool	bIsCrawler;				// If true, PHYS_Walking will adjust rotation to floor direction.
var		bool		bIsBleeding;			// Make sure to set this to false as well when you're destroying the above.
var()	bool		bIsAmbientCreature;		// To be used to determine if being attacked by AI, to simplify some code.
var transient NavigationPoint LastAnchor;	// Navigation helper, used internally.

// Ticked pawn timers
var		float		SightCounter;	//Used to keep track of when to check player visibility
var		float	   PainTime;		//used for getting PainTimer() messages (for Lava, no air, etc.)
var		float		SpeechTime;

// Physics updating time monitoring (for AI monitoring reaching destinations)
var const	float		AvgPhysicsTime;

// Additional pawn region information.
var PointRegion FootRegion;
var PointRegion HeadRegion;

// Navigation AI
var 	float		MoveTimer;
var 	Actor		MoveTarget;		// set by movement natives
var		Actor		FaceTarget;		// set by strafefacing native
var		vector	 	Destination;	// set by Movement natives
var	 	vector		Focus;			// set by Movement natives
var		float		DesiredSpeed;
var		float		MaxDesiredSpeed;
var(Combat) float	MeleeRange; // Max range for melee attack (not including collision radii)
var		float		SerpentineDist,SerpentineTime; // Used by serpentine movement.
var		vector		MovementStart;
var transient vector LastReachTest;	// Most recent PointReach/ActorReachable last reachable test spot.
									// Note: If test spot is too far out (over 1200uu) or out of sight that it wont even try, this will be set to own location.

// Player and enemy movement.
var(Movement) norepnotify float	GroundSpeed;	// The maximum ground speed.
var(Movement) norepnotify float	WaterSpeed;		// The maximum swimming speed.
var(Movement) norepnotify float	AirSpeed;		// The maximum flying speed.
var(Movement) norepnotify float	AccelRate;		// max acceleration rate
var(Movement) norepnotify float	JumpZ;			// vertical acceleration w/ jump
var(Movement) norepnotify float	MaxStepHeight;	// Maximum size of upward/downward step.
var(Movement) norepnotify float	AirControl;		// amount of AirControl available to the pawn
var(Movement) float				WalkingPct;		// Movement speed multiplier while walking/crouching.
var float			ShoveCollisionRadius; // Percent of collision radius this Pawn will hard block if bShovePawn.
var(Display) editinline PhysicsAnimation PhysicsAnim; // Physics based animation notify.

// AI basics.
var	 	float		MinHitWall;		// Minimum HitNormal dot Velocity.Normal to get a HitWall from the

// physics
var() 	byte	   	Visibility;	  //How visible is the pawn? 0 = invisible.
// 128 = normal.  255 = highly visible.
var		float		Alertness; // -1 to 1 ->Used within specific states for varying reaction to stimuli
var		float 		Stimulus; // Strength of stimulus - Set when stimulus happens, used in Acquisition state
var(AI) float		SightRadius;	 //Maximum seeing distance.
var(AI) float		PeripheralVision;//Cosine of limits of peripheral vision.
var(AI) float		HearingThreshold;  //Minimum noise loudness for hearing
var(AI) float		HuntOffDistance; // The distance pawn can see the hunting target with FindPathToward/bHunting.
var		vector		LastSeenPos; 		// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;		// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var		float		LastSeenTime;
var	 	Pawn		Enemy;
var		Texture		GroundTexture;

// Player info.
var travel Weapon	   Weapon;		// The pawn's current weapon.
var Weapon				PendingWeapon;	// Will become weapon once current weapon is put down
var travel Inventory	SelectedItem;	// currently selected inventory item

// Pawn DamageInfo - helper vars for blood effects.
var transient Pawn LastDamageInstigator;	// The damage instigator
var transient vector LastDamageHitLocation;	// HitLocation for pawn damage
var transient vector LastDamageMomentum;	// Momentum for pawn damage
var transient name LastDamageType;			// Pawn damage type
var transient float LastDamageTime;			// Pawn damage time
var transient bool bLastDamageSpawnedBlood;	// Damage spawned blood.

// Movement.
var norepnotify rotator ViewRotation;  	// View rotation.
var vector			WalkBob;
var() float	  	BaseEyeHeight; 	// Base eye height above collision center.
var norepnotify float EyeHeight;	 	// Current eye height, adjusted for bobbing and stairs.
var	const	vector	Floor;			// Normal of floor pawn is standing on (only used by PHYS_Spider)
var float			SplashTime;		// time of last splash

// View
var float		OrthoZoom;	 // Orthogonal/map view zoom factor.
var() float	  FovAngle;	  // X field of view angle in degrees, usually 90.

// Player game statistics.
var int			DieCount, ItemCount, KillCount, SecretCount, Spree;

// Health
var() travel int	  Health;		  // Health: 100 = normal maximum

// Inherent Armor (for creatures).
var() name	ReducedDamageType; // Either a damagetype name or 'All', 'AllEnvironment' (Burned, Corroded, Frozen)
var() float ReducedDamagePct;

// Inventory to drop when killed (for creatures)
var() class<inventory> DropWhenKilled;

// Zone pain
var(Movement) float		UnderWaterTime;  	//how much time pawn can go without air (in seconds)

var(AI) enum EAttitude  //important - order in decreasing importance
{
	ATTITUDE_Fear,		//will try to run away
	ATTITUDE_Hate,		// will attack enemy
	ATTITUDE_Frenzy,	//will attack anything, indiscriminately
	ATTITUDE_Threaten,	// animations, but no attack
	ATTITUDE_Ignore,
	ATTITUDE_Friendly,
	ATTITUDE_Follow 	//accepts player as leader
} AttitudeToPlayer;	//determines how creature will react on seeing player (if in human form)

var(AI) enum EIntelligence //important - order in increasing intelligence
{
	BRAINS_NONE, //only reacts to immediate stimulus
	BRAINS_REPTILE, //follows to last seen position
	BRAINS_MAMMAL, //simple navigation (limited path length)
	BRAINS_HUMAN   //complex navigation, team coordination, use environment stuff (triggers, etc.)
}	Intelligence;

var(AI) float		Skill;			// skill, scaled by game difficulty (add difficulty to this value)
var		actor		SpecialGoal;	// used by navigation AI
var		float		SpecialPause;

// Sound and noise management
var const 	vector 		noise1spot;
var const 	float 		noise1time;
var const	pawn		noise1other;
var const	float		noise1loudness;
var const 	vector 		noise2spot;
var const 	float 		noise2time;
var const	pawn		noise2other;
var const	float		noise2loudness;
var			float		LastPainSound;

// chained pawn list
var const	pawn		nextPawn;

// Common sounds
var(Sounds)	sound	HitSound1;
var(Sounds)	sound	HitSound2;
var(Sounds)	sound	Land;
var(Sounds)	sound	Die;
var(Sounds) sound	WaterStep;

// Input buttons.
var input byte
bZoom, bRun, bLook, bDuck, bSnapLevel,
bStrafe, bFire, bAltFire, bFreeLook,
bExtra0, bExtra1, bExtra2, bExtra3;

var(Combat) float CombatStyle; // -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
var NavigationPoint home; //set when begin play, used for retreating and attitude checks

var name NextState; //for queueing states
var name NextLabel; //for queueing states

var float SoundDampening;
var(Pawn) float DamageScaling;

var(Orders) name AlarmTag; // tag of object to go to when see player
var(Orders) name SharedAlarmTag;
var	Decoration	carriedDecoration;

var Name PlayerReStartState;

var() localized  string MenuName; //Name used for this pawn type in menus (e.g. player selection)
var() localized  string MenuNameDative; // Dative of a Name used for this pawn type in localized kill messages
var() localized  string NameArticle; //article used in conjunction with this class (e.g. "a", "an")

var() byte VoicePitch; //for speech
var() class<VoicePack> VoiceType; //for speech
var float OldMessageTime; //to limit frequency of voice messages

// Route Cache for Navigation
var NavigationPoint RouteCache[16];

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

// 227 enhancements
var Actor BleedingActor; //Destroy() this from anything and bleeding will stop.
var(AI) float SightDistanceMulti; // Multiply this AI's sight distance with this.
var transient float TeleportHackTime; // C++ code timer.

// shadow decal
var transient Actor Shadow;

var class<actor> Pawn_BloodsprayClass;
var class<actor> Pawn_BleedingClass;

// lip synching stuff, idea from Deus Ex - only implemented in ALAudio.
var bool bIsSpeaking;		// are we speaking now
var bool bWasSpeaking;		// were we speaking last frame?  (should we close our mouth?)
var string lastPhoneme;	// phoneme last spoken
var string nextPhoneme;	// phoneme to speak next

var(AI) enum EPawnSightCheck
{
	SEE_PlayersOnly, // See bIsPlayer Pawns only
	SEE_All, // See all Pawns
	SEE_None // Don't perform any sight checks
}  SightCheckType; // Type of pawns AI can see (only players, everything or nothing).

var transient const vector TransitFloor; // 227j: for smooth rotation changes on PHYS_Spidering.
var bool bNoPhysicsRotation; // 227j: Allow this Pawn to do own independent rotation.

var() float BeaconOffset;			// PostRender2D positioning height (CollisionHeight*BeaconOffset).
var() float MaxFrobDistance;		// Max distance frob checks are being done.
var transient Actor FrobTarget;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		Weapon, PlayerReplicationInfo, Health;
	reliable if ( Role==ROLE_Authority && bNetOwner )
		bIsPlayer, CarriedDecoration, SelectedItem,
		GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, MaxStepHeight, AirControl,
		bBehindView;
	unreliable if ( (Role==ROLE_Authority && bNetOwner && bIsPlayer && bNetInitial) || bDemoRecording )
		ViewRotation;
	unreliable if ( Role==ROLE_Authority && bNetOwner )
		MoveTarget;
	unreliable if ( Role==ROLE_Authority )
		bCanFly;
	reliable if ( bDemoRecording )
		EyeHeight;

	// Functions the server calls on the client side.
	reliable if ( Role==ROLE_Authority && RemoteRole==ROLE_AutonomousProxy )
		ClientDying, ClientReStart, ClientGameEnded, ClientSetRotation, ClientSetLocation;
	unreliable if ( Role==ROLE_Authority && (!bDemoRecording || bClientDemoNetFunc) )
		ClientHearSound;
	reliable if ( Role == ROLE_Authority && (!bDemoRecording || bClientDemoNetFunc) )
		ClientMessage, TeamMessage, ClientVoiceMessage;//,ClientStopSound
	unreliable if ( Role<ROLE_Authority )
		SendVoiceMessage, NextItem, SwitchToBestWeapon, bExtra0, bExtra1, bExtra2, bExtra3, TeamBroadcast;

	// Input sent from the client to the server.
	unreliable if ( Role<ROLE_AutonomousProxy )
		bZoom, bRun, bLook, bDuck, bSnapLevel, bStrafe;
}

// Latent Movement.
// Note that MoveTo sets the actor's Destination, and MoveToward sets the
// actor's MoveTarget.  Actor will rotate towards destination

native(500) final latent function MoveTo( vector NewDestination, optional float speed);
native(502) final latent function MoveToward(actor NewTarget, optional float speed, optional float SerpentineDist);
native(504) final latent function StrafeTo(vector NewDestination, vector NewFocus);
native(506) final latent function StrafeFacing(vector NewDestination, actor NewTarget);
native(508) final latent function TurnTo(vector NewFocus);
native(510) final latent function TurnToward(actor NewTarget);

// native AI functions
//LineOfSightTo() returns true if any of several points of Other is visible
// (origin, top, bottom)
native(514) final function bool LineOfSightTo(actor Other);
// CanSee() similar to line of sight, but also takes into account Pawn's peripheral vision
native(533) final function bool CanSee(actor Other);

/* Path finding:
@ bSinglePath - See if actor is only reachable within 4 first pathnodes (false).
@ bClearPaths - Clear path data before finding path to new destination (true).
@ DetourWeight - For DeathMatch bots, how much weight will bots put on items on their path (scaling value, 0). */
native(518) final function Actor FindPathTo(vector aPoint, optional bool bSinglePath,
												optional bool bClearPaths, optional float DetourWeight );
native(517) final function Actor FindPathToward(actor anActor, optional bool bSinglePath,
												optional bool bClearPaths, optional float DetourWeight );

native(525) final function NavigationPoint FindRandomDest(optional bool bClearPaths);

native(522) final function ClearPaths();
native(523) final function vector EAdjustJump();

//Reachable returns what part of direct path from Actor to aPoint is traversable
//using the current locomotion method
native(521) final function bool pointReachable(vector aPoint);
native(520) final function bool actorReachable(actor anActor);

/* PickWallAdjust()
Check if could jump up over obstruction (only if there is a knee height obstruction)
If so, start jump, and return current destination
Else, try to step around - return a destination 90 degrees right or left depending on traces
out and floor checks
*/
native(526) final function bool PickWallAdjust();
native(524) final function int FindStairRotation(float DeltaTime);
native(527) final latent function WaitForLanding();
native(540) final function actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns);

// Changed in 227j: These functions do nothing anymore, PawnList is updated by C++ codes.
native(529) final function AddPawn();
native(530) final function RemovePawn();

// Pick best pawn target
native(531) final function pawn PickTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);
native(534) final function actor PickAnyTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);

// Get inventory.
native(321) final iterator function AllInventory( class<Inventory> BaseClass, out Inventory Inv, optional bool bExactClass );

// Force end to sleep
native function StopWaiting();

// Support for StopSoundSlot() / StopAllSoundSlots(). You NEVER want to call this directly.
//native simulated event ClientStopSound( int ActorIndex, int SlotMask ); maybe later.

event MayFall(); //return true if allowed to fall - called by engine when pawn is about to fall

simulated event RenderOverlays( canvas Canvas )
{
	if ( Weapon != None )
		Weapon.RenderOverlays(Canvas);
}

simulated function String GetHumanName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	if ( MenuName=="" )
		MenuName = string(Class.Name);
	return NameArticle$MenuName;
}

simulated function byte GetTeamNum()
{
	if ( PlayerReplicationInfo != None )
		Return PlayerReplicationInfo.Team;
	Return 255;
}

function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	if ( Level.NetMode==NM_Client )
		Return;
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
	bMeshEnviromap = bEnviromap;

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
	bUpdatingDisplay = false;
}

function SetDefaultDisplayProperties()
{
	if ( Level.NetMode==NM_Client )
		Return;
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	if ( Weapon != None )
		Weapon.SetDefaultDisplayProperties();
	bUpdatingDisplay = false;
}

//
// Client gateway functions.
//
event ClientMessage( coerce string S, optional name Type, optional bool bBeep );
event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type );

event FellOutOfWorld()
{
	local int OldHealth;

	if (Role != ROLE_Authority || !CanInteractWithWorld())
		return;
	if( PlayerReplicationInfo )
	{
		SetPhysics(PHYS_None);
		if (Health > 0)
		{
			OldHealth = Health;
			Health = -1;
			Died(None, 'fell', Location);
			if (Health > 0)
				Health = OldHealth;
		}
	}
	else if (Health > 0)
	{
		Died(None, 'fell', Location);
		if( !bDeleteMe )
		{
			if( Region.ZoneNumber==0 )
				Error(Name@"fell out of the world!");
			else if (Health <= 0)
				Destroy();
		}
	}
	else SetPhysics(PHYS_None);
}

function PlayRecoil(float Rate);

function SpecialFire();

function bool CheckFutureSight(float DeltaTime)
{
	return true;
}

function RestartPlayer();

//
// Broadcast a message to all players, or all on the same team.
//
function TeamBroadcast( coerce string Msg)
{
	local Pawn P;
	local bool bGlobal;

	if ( Left(Msg, 1) ~= "@" )
	{
		Msg = Right(Msg, Len(Msg)-1);
		bGlobal = true;
	}

	if ( Left(Msg, 1) ~= "." )
		Msg = "."$VoicePitch$Msg;

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
	{
		if ( bGlobal || !Level.Game.bTeamGame )
		{
				foreach AllActors(class'Pawn',P,'Player')
					P.TeamMessage( PlayerReplicationInfo, Msg, 'Say' );
		}
		else
		{
			foreach AllActors(class'Pawn',P,'Player')
				if ( P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team )
					P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay' );
		}
	}
}

//------------------------------------------------------------------------------
// Speech related

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	local Pawn P;
	local bool bNoSpeak;

	if ( Level.TimeSeconds - OldMessageTime < 3 )
		bNoSpeak = true;
	else
		OldMessageTime = Level.TimeSeconds;

	foreach AllActors(class'Pawn',P)
	{
		if( !P.PlayerReplicationInfo )
			continue;

		if ( P.bIsPlayerPawn )
		{
			if ( !bNoSpeak )
			{
				if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
				else if ( Sender.Team == P.PlayerReplicationInfo.Team )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
			}
		}
		else if ( (P.PlayerReplicationInfo == Recipient) || ((messagetype == 'ORDER') && (Recipient == None)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);
function BotVoiceMessage(name messagetype, byte MessageID, Pawn Sender);

//***************************************************************
function HandleHelpMessageFrom(Pawn Other);

function FearThisSpot(Actor ASpot);

function float GetRating()
{
	return 1000;
}

function AddVelocity( vector NewVelocity)
{
	if (Physics == PHYS_Walking)
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	ViewRotation	  = NewRotation;
	NewRotation.Pitch = 0;
	NewRotation.Roll  = 0;
	SetLocation( NewLocation, NewRotation );
}

function ClientSetRotation( rotator NewRotation )
{
	ViewRotation	  = NewRotation;
	NewRotation.Pitch = 0;
	NewRotation.Roll  = 0;
	SetRotation( NewRotation );
}

function ClientDying(name DamageType, vector HitLocation)
{
	PlayDying(DamageType, HitLocation);
	GotoState('Dying');
}

function ClientReStart()
{
	//log("client restart");
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	PlayWaiting();

	if (PlayerReStartState == '' || PlayerReStartState == 'PlayerWalking')
	{
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_SWIMMING);
			GotoState('PlayerSwimming');
		}
		else
			GotoState('PlayerWalking');
	}
	else
		GotoState(PlayerReStartState);

	ResetSavedMoves();
}

function ClientGameEnded()
{
	GotoState('GameEnded');
}

function ResetSavedMoves();

//=============================================================================
// Inventory related functions.

function float AdjustDesireFor(Inventory Inv)
{
	return 0;
}

// toss out the weapon currently held
function TossWeapon()
{
	local vector X,Y,Z;
	if ( Weapon == None )
		return;
	GetAxes(Rotation,X,Y,Z);
	if( Weapon.XLevel!=XLevel )
		Weapon.SendToLevel(Level, Location);
	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X + - 0.5 * CollisionRadius * Y);
}

// The player/bot wants to select next item
exec function NextItem()
{
	if (!CanInteractWithWorld())
		return;
	if( Inventory==None ) // Pawn has no inventory.
	{
		SelectedItem = None;
		return;
	}
	if (SelectedItem==None)
	{
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None)
	{
		SelectedItem = SelectedItem.Inventory.SelectNext();
		if ( SelectedItem == None )
			SelectedItem = Inventory.SelectNext();
	}
	else SelectedItem = Inventory.SelectNext();
}

// FindInventoryType()
// returns the inventory item of the requested class
// if it exists in this pawn's inventory

function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	foreach AllInventory(class<Inventory>(DesiredClass),Inv,true)
		return Inv;
	return None;
}

// Add Item to this pawn's inventory.
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local Inventory Inv;
	local Actor Last;

	// The item should not have been destroyed if we get here.
	if ( NewItem==None || NewItem.bDeleteMe )
		return false;
	Last = Self;
	
	foreach AllInventory(class'Inventory',Inv)
	{
		if ( Inv == NewItem )
			return false;
		Last = Inv;
	}

	// Add to END of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = None;
	Last.Inventory = NewItem;
	
	if( NewItem.XLevel!=XLevel )
		NewItem.SendToLevel(Level, Location);

	return true;
}

// Remove Item from this pawn's inventory, if it exists.
// Returns true if it existed and was deleted, false if it did not exist.
function bool DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local Inventory Inv;

	if ( Item == Weapon )
		Weapon = None;
	
	if( Inventory==Item )
		Inventory = Item.Inventory;
	else
	{
		foreach AllInventory(Class'Inventory',Inv)
		{
			if ( Inv.Inventory == Item )
			{
				Inv.Inventory = Item.Inventory;
				break;
			}
		}
	}
	if ( Item == SelectedItem )
		NextItem(); // Select next inventory item.
	Item.SetOwner(None);
	Return True; // Returns true if it existed and was deleted, false if it did not exist.
}

// Just changed to pendingWeapon
function ChangedWeapon()
{
	local Weapon OldWeapon;

	OldWeapon = Weapon;

	if (Weapon == PendingWeapon)
	{
		if ( Weapon == None )
			SwitchToBestWeapon();
		else if ( Weapon.GetStateName() == 'DownWeapon' )
			Weapon.BringUp();
		PendingWeapon = None;
		return;
	}
	if ( PendingWeapon == None )
		PendingWeapon = Weapon;
	PlayWeaponSwitch(PendingWeapon);
	if ( (PendingWeapon != None) && (PendingWeapon.Mass > 20) && (carriedDecoration != None) )
		DropDecoration();
	if ( Weapon != None )
		Weapon.SetDefaultDisplayProperties();
	Weapon = PendingWeapon;
	Inventory.ChangedWeapon(); // tell inventory that weapon changed (in case any effect was being applied)
	if ( Weapon != None )
	{
		Weapon.RaiseUp(OldWeapon);
		if ( (Level.Game != None) && (Level.Game.Difficulty > 1) )
			MakeNoise(0.1 * Level.Game.Difficulty);
	}
	PendingWeapon = None;
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( (Other.Brush!=None) || Other.bWorldGeometry || Other.bIsMover )
		return true;

	if ( (!bIsPlayer || bWarping) && Other.bIsPawn )
		return true;

	return false;
}

event EncroachedBy( actor Other )
{
	if ( Pawn(Other) != None )
		gibbedBy(Other);
}

function gibbedBy(actor Other)
{
	local pawn instigatedBy;
	local int OldHealth;

	if ( Role < ROLE_Authority || !CanInteractWithWorld() )
		return;
	instigatedBy = pawn(Other);
	if (instigatedBy == None && Other != None)
		instigatedBy = Other.instigator;

	if (Health > 0)
	{
		OldHealth = Health;
		Health = -1000; //make sure gibs
		Died(instigatedBy, 'Gibbed', Location);
		if (Health > 0)
			Health = OldHealth;
	}
}

// Note: Unused!
event PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'suicided', Location);
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Velocity += 60 * VRand();
	Velocity.Z = 180;
	SetPhysics(PHYS_Falling);
}

function UnderLift(Mover M)
{
	local NavigationPoint N;

	// find nearest lift exit and go for that
	if ( (MoveTarget != None) && MoveTarget.IsA('LiftCenter') )
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( N.IsA('LiftExit') && (LiftExit(N).LiftTag == M.Tag)
					&& ActorReachable(N) )
			{
				MoveTarget = N;
				return;
			}
}

singular event BaseChange()
{
	if ( bDeleteMe )
		return;
	if ( !Base && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if( Base && !Base.bDeleteMe )
	{
		if ( Base.bIsPawn )
		{
			if ( Pawn(Base).Health>0 )
				Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , 'stomped');
			if( Base && !Base.bDeleteMe && IsBlockedBy(Base) ) // See if Pawn was gibbed!
				JumpOffPawn();
			else SetPhysics(PHYS_Falling);
		}
		else if ( Decoration(Base) && !Base.bStatic && (Velocity.Z < -400 || (mass> 200 && Physics != PHYS_None && Decoration(Base).bPushable)) )
		{
			Base.TakeDamage((-2* Mass/FMax(Base.Mass, 1) * Velocity.Z/400), Self, Location, 0.5 * Velocity, 'stomped');
			if( !Base || Base.bDeleteMe || !IsBlockedBy(Base) )
				SetPhysics(PHYS_Falling);
		}
	}
}

// Called by Engine when WaitForLanding latent action has been waiting for 2.5 seconds.
event LongFall();

//=============================================================================
// Network related functions.

event Destroyed()
{
	local Inventory Inv;
	local Pawn OtherPawn;

	//RemovePawn();

	foreach AllInventory(Class'Inventory',Inv)
		Inv.Destroy();
	Weapon = None;
	Inventory = None;
	if ( bIsPlayer && (Level.Game != None) )
		Level.Game.Logout(self);
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Destroy();
	foreach AllActors(class'Pawn',OtherPawn)
		OtherPawn.Killed(None, self, '');
}

//=============================================================================
// functions.

//
// native client-side functions.
//
native simulated event ClientHearSound (
	actor Actor,
	int Id,
	sound S,
	vector SoundLocation,
	vector Parameters
);

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	//AddPawn();
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	// Set instigator to self.
	Instigator = Self;
	DesiredRotation = Rotation;
	SightCounter = 0.2 * FRand();  //offset randomly
	if ( Level.Game != None )
		Skill += Level.Game.Difficulty;
	Skill = FClamp(Skill, 0, 3);
	PreSetMovement();

	if ( DrawScale != Default.Drawscale )
	{
		SetCollisionSize(ScaledDefaultCollisionRadius(), ScaledDefaultCollisionHeight());
		Health = Health * DrawScale/Default.DrawScale;
	}

	if (bIsPlayer)
	{
		if (PlayerReplicationInfoClass != None)
			PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
		else
			PlayerReplicationInfo = Spawn(class'PlayerReplicationInfo', Self,,vect(0,0,0),rot(0,0,0));
		InitPlayerReplicationInfo();
	}

	if (!bIsPlayer)
	{
		if ( BaseEyeHeight == 0 )
			BaseEyeHeight = 0.8 * CollisionHeight;
		EyeHeight = BaseEyeHeight;
		if (Fatness == 0) //vary monster fatness slightly if at default
			Fatness = 120 + Rand(8) + Rand(8);
	}

	if ( menuname == "" )
		menuname = string(Class.Name);
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SplashTime = 0;
}

simulated function PostNetBeginPlay()
{
	if( Level.bIsDemoPlayback && PlayerReplicationInfo==None )
	{
		foreach AllActors(class'PlayerReplicationInfo',PlayerReplicationInfo)
			if( PlayerReplicationInfo.Owner==Self )
				break;
	}
}

function PostLoadGame()
{
	ShadowModeChange();
}

// Called by C++ codes BeginPlay.
simulated function ShadowModeChange()
{
	if( !bNoDynamicShadowCast )
	{
		if( !Class'GameInfo'.Default.bCastShadow )
		{
			if( Shadow )
			{
				Shadow.Destroy();
				Shadow = None;
			}
		}
		else if( Class'GameInfo'.Default.bCastProjectorShadows )
		{
			if( Shadow && Shadow.Class!=Class'PawnShadowX' )
			{
				Shadow.Destroy();
				Shadow = Spawn(Class'PawnShadowX',Self);
			}
			else if( !Shadow )
				Shadow = Spawn(Class'PawnShadowX',Self);
		}
		else if( Shadow && Shadow.Class!=Class'PawnShadow' )
		{
			Shadow.Destroy();
			Shadow = Spawn(Class'PawnShadow',Self);
		}
		else if( !Shadow )
			Shadow = Spawn(Class'PawnShadow',Self);
	}
}

/* PreSetMovement()
default for walking creature.  Re-implement in subclass
for swimming/flying capability
*/
function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = false;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

event TravelPostAccept()
{
	if (Health <= 0)
		Health = Default.Health;
}

//=============================================================================
// Multiskin support
static function SetMultiSkin( actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;

	if (SkinName != "")
	{
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
		if ( NewSkin != None )
			SkinActor.Skin = NewSkin;
	}
}

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	SkinName = String(SkinActor.Skin);
	FaceName = "";
}

static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
	local Texture NewSkin;

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( NewSkin != None )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		if (DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
}

//=============================================================================
// Replication
function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.PlayerName = "Player";
}

//=============================================================================
// Animation playing - should be implemented in subclass,
//
// PlayWaiting, PlayRunning, and PlayGutHit, PlayMovingAttack (if used)
// and PlayDying are required to be implemented in the subclass

function PlayRunning()
{
	////log("Error - PlayRunning should be implemented in subclass of"@class);
}

function PlayWalking()
{
	PlayRunning();
}

function PlayWaiting()
{
	////log("Error - PlayWaiting should be implemented in subclass");
}

function PlayMovingAttack()
{
	////log("Error - PlayMovingAttack should be implemented in subclass");
	//Note - must restart attack timer when done with moving attack
	PlayRunning();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function TweenToFighter(float tweentime)
{
}

function TweenToRunning(float tweentime)
{
	TweenToFighter(0.1);
}

function TweenToWalking(float tweentime)
{
	TweenToRunning(tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenToFighter(tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenToFighter(tweentime);
}

function PlayThreatening()
{
	TweenToFighter(0.1);
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayTurning()
{
	TweenToFighter(0.1);
}

function PlayBigDeath(name DamageType);
function PlayHeadDeath(name DamageType);
function PlayLeftDeath(name DamageType);
function PlayRightDeath(name DamageType);
function PlayGutDeath(name DamageType);

function PlayDying(name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;

	if ( Velocity.Z > 250 )
	{
		PlayBigDeath(DamageType);
		return;
	}

	if ( DamageType == 'Decapitated' )
	{
		PlayHeadDeath(DamageType);
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	//first check for head hit
	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{
		if (dotp > 0)
			PlayHeadDeath(DamageType);
		else
			PlayGutDeath(DamageType);
		return;
	}

	if (dotp > 0.71) //then hit in front
		PlayGutDeath(DamageType);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayLeftDeath(DamageType);
		else
			PlayRightDeath(DamageType);
	}
}

function PlayGutHit(float tweentime)
{
	log("Error - play gut hit must be implemented in subclass of"@class);
}

function PlayHeadHit(float tweentime)
{
	PlayGutHit(tweentime);
}

function PlayLeftHit(float tweentime)
{
	PlayGutHit(tweentime);
}

function PlayRightHit(float tweentime)
{
	PlayGutHit(tweentime);
}

function FireWeapon();

/* TraceShot - used by instant hit weapons, and monsters
*/
simulated function Actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace)
{
	local Actor Other;
	
	bTraceHitBoxes = true;
	foreach TraceActors(class'Actor',Other,HitLocation,HitNormal,EndTrace,StartTrace,,TRACE_ProjTargets)
	{
		if( !Other.bIsPawn || Pawn(Other).AdjustHitLocation(HitLocation, (EndTrace - StartTrace)) )
			break;
	}
	bTraceHitBoxes = false;
	
	return Other;
}

/* Adjust hit location - adjusts the hit location in for pawns, and returns
true if it was really a hit, and false if not (for ducking, etc.)
*/
simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.4 * CollisionRadius * TraceDir;

	if ( Mesh!=None && HasAnim(AnimSequence) && (GetAnimGroup(AnimSequence) == 'Ducking') && (AnimFrame > -0.03) )
	{
		maxZ = Location.Z + 0.25 * CollisionHeight;
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
	}
	return true;
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	//first check for head hit
	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{
		if (dotp > 0)
			PlayHeadHit(tweentime);
		else
			PlayGutHit(tweentime);
		return;
	}

	if (dotp > 0.71) //then hit in front
		PlayGutHit( tweentime);
	else if (dotp < -0.71) // then hit in back
		PlayHeadHit(tweentime);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayLeftHit(tweentime);
		else
			PlayRightHit(tweentime);
	}
}

function PlayVictoryDance()
{
	TweenToFighter(0.1);
}

function PlayOutOfWater()
{
	TweenToFalling();
}

function PlayDive();
function TweenToFalling();
function PlayInAir();
function PlayDuck();
function PlayCrawling();

function PlayLanded(float impactVel)
{
	local float landVol;
	//default - do nothing (keep playing existing animation)
	landVol = impactVel/JumpZ;
	landVol = 0.005 * Mass * landVol * landVol;
	PlaySound(Land, SLOT_Interact, FMin(20, landVol));
}

function PlayFiring();
function PlayWeaponSwitch(Weapon NewWeapon);
function TweenToSwimming(float tweentime);


//-----------------------------------------------------------------------------
// Sound functions
function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;

	if (HitSound1 == None)return;
	LastPainSound = Level.TimeSeconds;
	if (FRand() < 0.5)
		PlaySound(HitSound1, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	else
		PlaySound(HitSound2, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0));
}

function Gasp();

function DropDecoration()
{
	if( CarriedDecoration )
		CarriedDecoration.GrabbedBy(Self);
}

function GrabDecoration()
{
	local actor HitActor;

	if( !carriedDecoration )
	{
		HitActor = TraceGrabActor();
		if( HitActor )
			HitActor.GrabbedBy(Self);
	}
}

function Actor TraceGrabActor()
{
	local vector lookDir, HitLocation, HitNormal, T1, T2;
	local actor HitActor;

	// 227k: Accurate trace first.
	lookDir = vector(ViewRotation);
	T1 = Location + EyeHeight * vect(0,0,1);
	T2 = T1 + lookDir * 2.4 * CollisionRadius;
	HitActor = Trace(HitLocation, HitNormal, T2, T1, true);
	if( HitActor && !HitActor.bWorldGeometry )
		return HitActor;
	
	//first trace to find it
	lookDir.Z = 0;
	T1 += lookDir * 0.8 * CollisionRadius;
	T2 = T1 + lookDir * 1.2 * CollisionRadius;
	HitActor = Trace(HitLocation, HitNormal, T2, T1, true);
	if ( !HitActor )
	{
		T1 = T2 - (EyeHeight + CollisionHeight - 2) * vect(0,0,1);
		HitActor = Trace(HitLocation, HitNormal, T1, T2, true);
	}
	else if ( HitActor.bWorldGeometry )
	{
		T2 = HitLocation - lookDir;
		T1 = T2 - (EyeHeight + CollisionHeight - 2) * vect(0,0,1);
		HitActor = Trace(HitLocation, HitNormal, T1, T2, true);
	}
	if ( !HitActor || HitActor.bWorldGeometry )
		HitActor = Trace(HitLocation, HitNormal, Location + lookDir * 1.2 * CollisionRadius, Location, true, GetExtent());
	return HitActor;
}

final function vector GrabbedDecorationPos(Decoration Decoration)
{
	return GrabbedDecorationBasePos(Decoration) + GrabbedDecorationOffset(Decoration);
}

function vector GrabbedDecorationBasePos(Decoration Decoration)
{
	local rotator R;
	R.Yaw = Rotation.Yaw;
	return Location + (0.5 * CollisionRadius + Decoration.CollisionRadius) * vector(R);
}

function vector GrabbedDecorationOffset(Decoration Decoration)
{
	return vect(0, 0, 0);
}

function StopFiring();

/* AdjustAim()
ScriptedPawn version does adjustment for non-controlled pawns.
PlayerPawn version does the adjustment for player aiming help.
Only adjusts aiming at pawns
allows more error in Z direction (full as defined by AutoAim - only half that difference for XY)
*/

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	return ViewRotation;
}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	return ViewRotation;
}

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	// AI controlled creatures may duck
	// if not falling, and projectile time is long enough
	// often pick opposite to current direction (relative to shooter axis)
}

function SetMovementPhysics()
{
	//implemented in sub-class
}

function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType)
{
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					 Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local GameRules GR;

	if ( bDeleteMe || Level.NetMode==NM_Client || !CanInteractWithWorld() )
		return;
	if ( Level.Game && Level.Game.GameRules )
	{
		for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules)
			if (GR.bModifyDamage && GR.PreventDamage(self, instigatedBy, Damage, hitlocation, damageType, momentum))
				return;
		for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules)
			if (GR.bModifyDamage)
				GR.ModifyDamage(self, instigatedBy, Damage, hitlocation, damageType, momentum);
	}
	LastDamageInstigator = instigatedBy;
	LastDamageHitLocation = HitLocation;
	LastDamageMomentum = momentum;
	LastDamageType = damageType;
	LastDamageTime = Level.TimeSeconds;
	bLastDamageSpawnedBlood = false;

	//log(self@"take damage in state"@GetStateName());
	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;
	AddVelocity( momentum );

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
	}
	else
	{
		if ( (InstigatedBy != None) && (InstigatedBy.IsA(Class.Name) || IsA(InstigatedBy.Class.Name)) )
			actualDamage = actualDamage * FMin(1 - ReducedDamagePct, 0.35);
		else if ( (ReducedDamageType == 'All') || ((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
			actualDamage = float(actualDamage) * (1 - ReducedDamagePct);
		if (Inventory != None)
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
	}

	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	if (Health > 0)
	{
		if (instigatedBy != None)
			damageAttitudeTo(instigatedBy);
		PlayHit(actualDamage, hitLocation, damageType, Momentum.Z);
	}
	else if ( !bAlreadyDead )
	{
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		Enemy = instigatedBy;
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else Destroy();
	}
	MakeNoise(1.0);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local GameRules GR;

	if ( bDeleteMe || Level.NetMode==NM_Client || !CanInteractWithWorld() )
		return;

	if ( Level.Game!=None && Level.Game.GameRules!=None )
	{
		for ( GR=Level.Game.GameRules; GR!=None; GR=GR.NextRules )
			if ( GR.bHandleDeaths && GR.PreventDeath(Self,Killer,damageType) )
			{
				Health = Max(1,Health);
				Return;
			}
		for ( GR=Level.Game.GameRules; GR!=None; GR=GR.NextRules )
			if ( GR.bHandleDeaths )
				GR.NotifyKilled(Self,Killer,DamageType);
	}

	Health = Min(0, Health);
	foreach AllActors(class'Pawn',OtherPawn)
		OtherPawn.Killed(Killer, self, damageType);

	if ( BleedingActor!=none && bIsBleeding )
		bIsBleeding = False;

	if ( CarriedDecoration != None )
		DropDecoration();
	Level.Game.Killed(Killer, self, damageType);

	TriggerEvent(Event,Self,Killer);

	Level.Game.DiscardInventory(self);
	Velocity.Z *= 1.3;
	if ( Gibbed(damageType) )
	{
		SpawnGibbedCarcass();
		if ( bIsPlayer )
			HidePlayer();
		else Destroy();
	}
	PlayDying(DamageType, HitLocation);
	if ( Level.Game.bGameEnded )
		return;
	if ( RemoteRole==ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);
	GotoState('Dying');
}

function bool Gibbed(name damageType)
{
	return false;
}

function Carcass SpawnCarcass()
{
	log(self$" should never call base spawncarcass");
	return None;
}

function SpawnGibbedCarcass()
{
}

function HidePlayer()
{
	SetCollision(false, false, false);
	TweenToFighter(0.01);
	bHidden = true;
}

event HearNoise( float Loudness, Actor NoiseMaker);
event SeePlayer( actor Seen );
event UpdateEyeHeight( float DeltaTime );
event EnemyNotVisible();

function Killed(pawn Killer, pawn Other, name damageType)
{
	//implemented in subclass
}

//Typically implemented in subclass
function string KillMessage( name damageType, pawn Other )
{
	local string message;

	message = Level.Game.CreatureKillMessage(damageType, Other);
	if( MenuNameDative!="" )
		return (message$namearticle$MenuNameDative);
	return (message$namearticle$menuname);
}

function damageAttitudeTo(pawn Other);

function Falling()
{
	//Note - physics changes type to PHYS_Falling by default
	PlayInAir();
}

// Not called because it's a waste of resources.
function WalkTexture( texture Texture, vector StepLocation, vector StepNormal );

// Called when player is walking on a new surface type (and LevelInfo.bCheckWalkSurfaces is true)
event WalkTextureChange( texture Texture );

event Landed(vector HitNormal)
{
	SetMovementPhysics();
	if ( !IsAnimating() )
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
	bJustLanded = true;
}

event FootZoneChange(ZoneInfo newFootZone)
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local float splashSize;
	local actor splash;

	if ( Level.NetMode == NM_Client || !CanInteractWithWorld() )
		return;
	if ( Level.TimeSeconds - SplashTime > 0.25 )
	{
		SplashTime = Level.TimeSeconds;
		if (Physics == PHYS_Falling)
			MakeNoise(1.0);
		else
			MakeNoise(0.3);
		if ( FootRegion.Zone.bWaterZone )
		{
			if ( !newFootZone.bWaterZone && (Role==ROLE_Authority) )
			{
				if ( FootRegion.Zone.ExitSound != None )
					PlaySound(FootRegion.Zone.ExitSound, SLOT_Interact, 1);
				if ( FootRegion.Zone.ExitActor != None )
					Spawn(FootRegion.Zone.ExitActor,,,Location - CollisionHeight * vect(0,0,1));
			}
		}
		else if ( newFootZone.bWaterZone && (Role==ROLE_Authority) )
		{
			splashSize = FClamp(0.000025 * Mass * (300 - 0.5 * FMax(-500, Velocity.Z)), 1.0, 4.0 );
			if ( newFootZone.EntrySound != None )
			{
				HitActor = Trace(HitLocation, HitNormal,
								 Location - (CollisionHeight + 40) * vect(0,0,0.8), Location - CollisionHeight * vect(0,0,0.8), false);
				if ( HitActor == None )
					PlaySound(newFootZone.EntrySound, SLOT_Misc, 2 * splashSize);
				else
					PlaySound(WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize);
			}
			if ( newFootZone.EntryActor != None )
			{
				splash = Spawn(newFootZone.EntryActor,,,Location - CollisionHeight * vect(0,0,1));
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
			//log("Feet entering water");
		}
	}

	if (FootRegion.Zone.bPainZone)
	{
		if ( !newFootZone.bPainZone && !HeadRegion.Zone.bWaterZone )
			PainTime = -1.0;
	}
	else if (newFootZone.bPainZone)
	{
		If ( IsA('ScriptedPawn') )
		{
			if ( (ReducedDamageType == 'All') ||
					((ReducedDamageType != '') && (ReducedDamageType == newFootZone.damageType)
					 && ReducedDamagePct > 0 ) )
				PainTime = -1.0;
			else PainTime = 0.01;
		}
		else
			PainTime = 0.01;
	}
}

event HeadZoneChange(ZoneInfo newHeadZone)
{
	if ( Level.NetMode == NM_Client || !CanInteractWithWorld() )
		return;
	if (HeadRegion.Zone.bWaterZone)
	{
		if (!newHeadZone.bWaterZone)
		{
			if ( bIsPlayer && (PainTime > 0) && (PainTime < 8) )
				Gasp();
			if ( Inventory != None )
				Inventory.ReduceDamage(0, 'Breathe', Location); //inform inventory of zone change
			bDrowning = false;
			if ( !FootRegion.Zone.bPainZone )
				PainTime = -1.0;
		}
	}
	else
	{
		if (newHeadZone.bWaterZone)
		{
			if ( !FootRegion.Zone.bPainZone )
				PainTime = UnderWaterTime;
			if ( Inventory != None )
				Inventory.ReduceDamage(0, 'Drowned', Location); //inform inventory of zone change
			//log("Can't breathe");
		}
	}
}

event SpeechTimer();

//Pain timer just expired.
//Check what zone I'm in (and which parts are)
//based on that cause damage, and reset PainTime

event PainTimer()
{
	local float depth;

	//log("Pain Timer");
	if ( (Health <= 0) || (Level.NetMode == NM_Client) || !CanInteractWithWorld() )
		return;

	if ( FootRegion.Zone.bPainZone )
	{
		depth = 0.4;
		if (Region.Zone.bPainZone)
			depth += 0.4;
		if (HeadRegion.Zone.bPainZone)
			depth += 0.2;

		if (FootRegion.Zone.DamagePerSec > 0)
		{
			if ( bIsPlayerPawn )
				Level.Game.SpecialDamageString = FootRegion.Zone.DamageString;
			TakeDamage(int(float(FootRegion.Zone.DamagePerSec) * depth), None, Location, vect(0,0,0), FootRegion.Zone.DamageType);
		}
		else if ( Health < Default.Health )
			Health = Min(Default.Health, Health - depth * FootRegion.Zone.DamagePerSec);

		if (Health > 0)
			PainTime = 1.0;
	}
	else if ( HeadRegion.Zone.bWaterZone )
	{
		TakeDamage(5, None, Location, vect(0,0,0), 'drowned');
		if ( Health > 0 )
			PainTime = 2.0;
	}
}

function bool CheckWaterJump(out vector WallNormal)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, checkpoint, start, checkNorm;

	if( CarriedDecoration )
		return false;
	checkNorm = Normal2D(vector(Rotation));
	checkPoint = Location + CollisionRadius * checkNorm;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, GetExtent(),,,{TRACE_AllColliding | TRACE_Blocking});
	if( HitActor && !HitActor.bIsPawn )
	{
		WallNormal = -1 * HitNormal;
		start = Location;
		start.Z += 1.1 * MaxStepHeight;
		checkPoint = start + 2 * CollisionRadius * checkNorm;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true,,,,{TRACE_AllColliding | TRACE_Blocking});
		if( !HitActor )
			return true;
	}
	return false;
}

function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt;

	if ( Inventory == None )
		return false;

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);

	if ( PendingWeapon == None )
		return false;

	if ( Weapon == None )
		ChangedWeapon();
	else if ( Weapon != PendingWeapon )
		Weapon.PutDown();

	return (usealt > 0);
}

// Ladders...
function StartClimbing( LadderTrigger Other );
function EndClimbing( LadderTrigger Other );

State Dying
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if ( bDeleteMe )
			return;
		Health = Health - Damage;
		Momentum = Momentum/Mass;
		AddVelocity( momentum );
		if ( !bHidden && Gibbed(damageType) )
		{
			bHidden = true;
			SpawnGibbedCarcass();
			if ( bIsPlayer )
				HidePlayer();
			else
				Destroy();
		}
	}

	function Timer()
	{
		if ( !bHidden )
		{
			bHidden = true;
			SpawnCarcass();
			if ( bIsPlayer )
				HidePlayer();
			else
				Destroy();
		}
	}

	event Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		SetTimer(0.3, false);
	}
}

state GameEnded
{
	ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, WarnTarget;

	function BeginState()
	{
		SetPhysics(PHYS_None);
		HidePlayer();
	}
}

// 227f: Pass over attitude check to GameRules.
final function EAttitude GetModifiedAttitude( EAttitude InAttitude, Pawn Hated )
{
	local GameRules GR;

	if ( Level.Game==None || Level.Game.GameRules==None )
		return InAttitude;
	for ( GR=Level.Game.GameRules; GR!=None; GR=GR.NextRules )
		if ( GR.bModifyAI )
			GR.ModifyThreat(Self,Hated,InAttitude);
	return InAttitude;
}

// 227: Return true if a hit ray makes a headshot on this pawn.
simulated function bool IsHeadShot( vector HitLocation, vector TraceDir )
{
	return DefIsHeadShot(HitLocation, TraceDir);
}

final simulated function bool DefIsHeadShot(vector HitLocation, vector TraceDir)
{
	return (HitLocation.Z - Location.Z) > (0.62 * CollisionHeight);
}

// Called when bPostRender2D is enabled and this pawn is in front side of the camera.
// Pos.X/Y are screen position, Pos.Z is the depth scaling 1 -> 0
simulated event PostRender2D( canvas Canvas, vector Pos )
{
	if( Canvas.Viewport.Actor.myHUD!=None )
		Canvas.Viewport.Actor.myHUD.PostRender2D(Canvas,Self,Pos);
}

// ----------------------------------------------------------------------
// HighlightCenterObject()
//
// checks to see if an object can be frobbed, if so, then highlight it
// ----------------------------------------------------------------------

function HighlightCenterObject()
{
	local Actor Other, SmallestTarget;
	local Vector HitLoc, HitNormal, StartTrace, EndTrace;
	local float ReducedMinVolume, ReducedTempVolume; // Volume/(2PI).
	local bool bFirstTarget;

	if ( IsInState('Dying') )
		return;

	// Do this each PlayerTick().

	// Figure out how far ahead we should trace.
	StartTrace = Location;
	EndTrace   = Location + (Vector(ViewRotation) * MaxFrobDistance);

	// adjust for the eye height
	StartTrace.Z += BaseEyeHeight;
	EndTrace.Z   += BaseEyeHeight;

	SmallestTarget   = None;
	ReducedMinVolume = 9999999999999.9;
	bFirstTarget     = True;

	// Find the object that we are looking at
	// make sure we don't select the object that we're carrying
	// use the last traced object as the target...this will handle
	// smaller items under larger items for example
	// ScriptedPawns always have precedence, though
	foreach TraceActors( Class'Actor', Other, HitLoc, HitNormal, EndTrace, StartTrace,, TRACE_ProjTargets)
	{
		//Log( "Target=" $ Other, 'HighlightCenterObject' );

		// Make bsp block frobbing.
		if ( Other==Level )
			break;

		// Don't frob what we carry.
		if ( Other==CarriedDecoration )
			continue;

		if ( !IsFrobbable(Other) )
			continue;

		// Pawns.
		if ( Other.bIsPawn )
		{
			SmallestTarget = Other;
			break;
		}

		// Movers.
		if ( Other.bIsMover && bFirstTarget )
		{
			SmallestTarget = Other;
			break;
		}

		// Changed the ~Radius to a ~Volume based approach.
		ReducedTempVolume = Other.CollisionRadius*Other.CollisionRadius*Other.CollisionHeight;
		if ( ReducedTempVolume<ReducedMinVolume )
		{
			ReducedMinVolume = ReducedTempVolume;
			SmallestTarget   = Other;
			bFirstTarget     = False;
		}
	}

	FrobTarget = SmallestTarget;
}
// ----------------------------------------------------------------------
// IsFrobbable() -- is this actor frobbable?
// ----------------------------------------------------------------------

simulated function bool IsFrobbable( Actor Actor )
{

	if ( Actor==None || Actor.bHidden || Actor.bDeleteMe )
		return False;

	if ( Actor.bIsFrobable )
		return True;

	return false;
}

// Whether this pawn can interact with the game world.
// Valid only when Role >= ROLE_AutonomousProxy.
//
function bool CanInteractWithWorld()
{
	return true;
}

// Whether this pawn's Enemy is a reference to a different alive pawn
function bool HasAliveEnemy()
{
	return (Enemy && !Enemy.bDeleteMe && Enemy.Health>0 && Enemy != self);
}

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	local Inventory Inv;

	if( Shadow )
		Shadow.SendToLevel(Level, Location);

	if( Level.NetMode==NM_Client )
		return;

	foreach AllInventory(class'Inventory',Inv)
		Inv.SendToLevel(Level, Location);
	if ( PlayerReplicationInfo )
		PlayerReplicationInfo.SendToLevel(Level, vect(0,0,0));

	if( bIsPlayer )
		Level.Game.PlayerTraveled(Self, PrevLevel);
}

function bool PreTeleport( Teleporter InTeleporter )
{
	if( Physics==PHYS_Interpolating )
		SpecialGoal = Target; // Temporary, to detect whether if teleportation moved to a new interpolation path.
	return false;
}

function PostTeleport( Teleporter OutTeleporter )
{
	if( Physics==PHYS_Interpolating )
	{
		if( SpecialGoal==Target )
		{
			SpecialGoal = None;
			InterpolationEnded();
		}
		else SpecialGoal = None;
	}
}

function InterpolationEnded()
{
	bInterpolating = false;
	if (Level.NetMode != NM_Client)
	{
		AmbientSound = None;
		bCollideWorld = True;
		if ( Health > 0 )
		{
			SetCollision(true, true, true);
			if( Region.Zone.bWaterZone )
				SetPhysics(PHYS_Swimming);
			else SetPhysics(PHYS_Falling);
		}
	}
}

defaultproperties
{
	AvgPhysicsTime=0.100000
	MaxDesiredSpeed=1.000000
	GroundSpeed=320.000000
	WaterSpeed=200.000000
	AccelRate=500.000000
	JumpZ=325.000000
	MaxStepHeight=25.000000
	AirControl=0.050000
	Visibility=128
	SightRadius=2500.000000
	HearingThreshold=1.000000
	OrthoZoom=40000.000000
	FovAngle=90.000000
	Health=100
	AttitudeToPlayer=ATTITUDE_Hate
	Intelligence=BRAINS_MAMMAL
	noise1time=-10.000000
	noise2time=-10.000000
	SoundDampening=1.000000
	DamageScaling=1.000000
	PlayerReStartState="PlayerWalking"
	NameArticle=" a "
	PlayerReplicationInfoClass=Class'PlayerReplicationInfo'
	bCanTeleport=True
	bIsKillGoal=True
	bStasis=True
	bIsPawn=True
	RemoteRole=ROLE_SimulatedProxy
	AnimSequence="Fighter"
	bDirectional=True
	Texture=Texture'S_Pawn'
	SoundRadius=9
	SoundVolume=240
	TransientSoundVolume=2.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bProjTarget=True
	bRotateToDesired=True
	RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
	NetPriority=4.000000
	SightDistanceMulti=1
	bRepHealth=true
	bUseNoWalkInAir=True
	BeaconOffset=1.05
	bIsAmbientCreature=False
	MaxFrobDistance=112
	ShoveCollisionRadius=0.6
	WalkingPct=0.3
	CollisionFlag=COLLISIONFLAG_Pawn
	bNoDynamicShadowCast=true
}