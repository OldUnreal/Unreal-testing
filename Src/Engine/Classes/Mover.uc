//=============================================================================
// The moving brush class.
// This is a built-in Unreal class and it shouldn't be modified.
// 227j notes: SetPhysics and InterpolateEnd will change bForceNetUpdate to true.
//=============================================================================
class Mover extends Brush
	native
	NativeReplication;

var() enum EMoverEncroachType
{
	ME_StopWhenEncroach,
	ME_ReturnWhenEncroach,
	ME_CrushWhenEncroach,
	ME_IgnoreWhenEncroach,
} MoverEncroachType; /* How the mover should react when it encroaches an actor:
StopWhenEncroach - Stop when we hit an actor.
ReturnWhenEncroach - Return to previous position when we hit an actor.
CrushWhenEncroach - Crush the poor helpless actor.
IgnoreWhenEncroach - Ignore encroached actors. */

var() enum EMoverGlideType
{
	MV_MoveByTime,
	MV_GlideByTime,
	MV_AccelOverTime,
	MV_DeAccelOverTime,
} MoverGlideType; /* How the mover moves from one position to another:
MoveByTime - Move linearly.
GlideByTime - Move with smooth acceleration.
AccelOverTime - Accelerate parabolic over time.
DeAccelOverTime - Deaccelerate parabolic over time. */

var() bool       bUseShortestRotation; // rot by -90 instead of +270 and so on.

var() enum EBumpType
{
	BT_PlayerBump,
	BT_PawnBump,
	BT_AnyBump,
} BumpType; /* What classes can bump trigger this mover:
PlayerBump - Can only be bumped by player.
PawnBump - Can be bumped by any pawn.
AnyBump - Can be bumped by any solid actor.
*/

//-----------------------------------------------------------------------------
// Keyframe numbers.
var() byte       KeyNum;           // Current or destination keyframe.
var byte         PrevKeyNum;       // Previous keyframe.
var() const byte NumKeys;          // Number of keyframes in total (0-8).
var() const byte WorldRaytraceKey; // Raytrace the world with the brush here.
var() const byte BrushRaytraceKey; // Raytrace the brush here.

//-----------------------------------------------------------------------------
// Movement parameters.
var() float      MoveTime;         // Time to spend moving between keyframes.
var() float      StayOpenTime;     // How long to remain open before closing.
var() float      OtherTime;        // TriggerPound stay-open time.
var() int        EncroachDamage;   // How much to damage encroached actors.

//-----------------------------------------------------------------------------
// Mover state.
var() bool       bTriggerOnceOnly;		// Go dormant after first trigger.
var() bool       bSlave;				// This brush is a slave.
var() bool		 bUseTriggered;			// Triggered by player grab
var() bool		 bDamageTriggered;		// Triggered by taking damage
var() bool       bDynamicLightMover;	// Apply dynamic lighting to mover.

// 227:
var() bool		 bDirectionalPushOff;	// 227h: Push actors in direction it's rotating.
var() bool		 bAdvancedCamUpdate;	// 227j: updates Roll and Pitch for Pawns additionally.
var() bool		 bUseGoodCollision;		// 227: Use high precision collision detection (good for complex mover shapes).
var() bool		 bIgnoreInventory;		// 227j: Mover will ignore inventory it encroaches (and detonates flares).

var() name       PlayerBumpEvent;		// Optional event to cause when the player bumps the mover.
var() name       BumpEvent;				// Optional event to cause when any valid bumper bumps the mover.
var   actor      SavedTrigger;			// Who we were triggered by.
var() float		 DamageThreshold;		// minimum damage to trigger
var	  int		 numTriggerEvents;		// number of times triggered ( count down to untrigger )
var	  Mover		 Leader;				// for having multiple movers return together
var	  Mover		 Follower;
var() name		 ReturnGroup;			// Movers in same group will return in same time if they bump into any actor (if none, same as tag)
var() float		 DelayTime;				// delay before starting to open

//-----------------------------------------------------------------------------
// Audio.
var(MoverSounds) sound      OpeningSound;     // When start opening.
var(MoverSounds) sound      OpenedSound;      // When finished opening.
var(MoverSounds) sound      ClosingSound;     // When start closing.
var(MoverSounds) sound      ClosedSound;      // When finish closing.
var(MoverSounds) sound      MoveAmbientSound; // Optional ambient sound when moving.

//-----------------------------------------------------------------------------
// Internal.
var vector       KeyPos[8];
var rotator      KeyRot[8];
var vector       BasePos, OldPos, OldPrePivot, SavedPos;
var rotator      BaseRot, OldRot, SavedRot;
var transient const array<int> NotifyLightMaps;
var StaticLightData StaticLightD;
var transient private Mover DynBspNext, FlushNext;
var Actor StuckedActor; // Mover will ignore this actor and attempt to push it out.
var transient private bool bDynBSPDirty;

// AI related
var       NavigationPoint  myMarker;
var		  Actor			TriggerActor;
var		  Actor         TriggerActor2;
var		  Pawn			WaitingPawn;
var		  bool			bOpening, bDelaying;
var		  bool			bPlayerOnly;
var		  Trigger		RecommendedTrigger;

// for client side replication
var		vector			SimOldPos;
var		int				SimOldRotPitch, SimOldRotYaw, SimOldRotRoll;
var		vector			SimInterpolate;
var		vector			RealPosition; // 227j Note: Replication disabled in C++ codes.
var     rotator			RealRotation; // See above.
var		int				ServerUpdate; // See above.
var		int				ClientUpdate;
var transient const	int	LNextKeyNum; // Pending to be deleted.

replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		SimOldPos, SimOldRotPitch, SimOldRotYaw, SimOldRotRoll, SimInterpolate, RealPosition, RealRotation, ServerUpdate;
}

simulated function Timer()
{
	/* Marco: Disabled this timer, cause ClientUpdate isn't even in sync with the ServerUpdate, so its waste of bandwidth.
	if ( Velocity != vect(0,0,0) )
		return;
	if ( Level.NetMode == NM_Client )
	{
		if ( ClientUpdate == ServerUpdate && RealPosition!=vect(0,0,0) )
		{
			Move(RealPosition-Location);
			SetRotation(RealRotation);
		}
	}
	else if ( (Location != RealPosition) || (Rotation != RealRotation) )
	{
		ServerUpdate++;
		RealPosition = Location;
		RealRotation = Rotation;
	}*/
}

// Was grabbed
function GrabbedBy( Pawn Other )
{
	if ( bUseTriggered )
		Trigger( Other, Other );
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	if ( Tag=='' )
		Return;
	ForEach AllActors(class'Actor',A,,Tag)
	{
		if ( A.bIsPawn )
		{
			bPlayerOnly = true;
			return;
		}
		if (TriggerActor == None)
			TriggerActor = A.GetTriggerActor();
		else if ( TriggerActor2 == None )
		{
			TriggerActor2 = A.GetTriggerActor();
			if (TriggerActor == TriggerActor2)
				TriggerActor2 = None;
			else Break;
		}
	}

	if ( TriggerActor == None )
	{
		bPlayerOnly = (BumpType == BT_PlayerBump);
		return;
	}

	bPlayerOnly = ( TriggerActor.IsA('Trigger') && (Trigger(TriggerActor).TriggerType == TT_PlayerProximity) );
	if ( bPlayerOnly && ( TriggerActor2 != None) )
	{
		bPlayerOnly = ( TriggerActor2.IsA('Trigger') && (Trigger(TriggerActor).TriggerType == TT_PlayerProximity) );
		if ( !bPlayerOnly )
		{
			A = TriggerActor;
			TriggerActor = TriggerActor2;
			TriggerActor2 = A;
		}
	}
}

/* set specialgoal/movetarget or special pause if necessary
if mover can't be affected by this pawn, return false
Each mover state should implement the appropriate version
*/
function bool HandleDoor(pawn Other)
{
	return false;
}

function bool HandleTriggerDoor(pawn Other)
{
	local bool bOne, bTwo;
	local float DP1, DP2, Dist1, Dist2;

	if ( bOpening || bDelaying )
	{
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		return true;
	}
	if ( bPlayerOnly && !Other.bIsPlayer )
		return false;
	if ( bUseTriggered )
	{
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		Trigger(Other, Other);
		return true;
	}
	if ( (BumpEvent == tag) || (Other.bIsPlayer && (PlayerBumpEvent == tag)) )
	{
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		if ( Other.Base == Self )
			Trigger(Other, Other);
		return true;
	}
	if ( bDamageTriggered )
	{
		WaitingPawn = Other;
		Other.SpecialGoal = self;
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return false;

		Other.Target = self;
		Other.bShootSpecial = true;
		Other.FireWeapon();
		Trigger(Self, Other);
		Other.bFire = 0;
		Other.bAltFire = 0;
		return true;
	}

	if ( RecommendedTrigger != None )
	{
		Other.SpecialGoal = RecommendedTrigger;
		Other.MoveTarget = RecommendedTrigger;
		return True;
	}

	bOne = ( (TriggerActor != None)
			 && (!TriggerActor.IsA('Trigger') || Trigger(TriggerActor).IsRelevant(Other)) );
	bTwo = ( (TriggerActor2 != None)
			 && (!TriggerActor2.IsA('Trigger') || Trigger(TriggerActor2).IsRelevant(Other)) );

	if ( bOne && bTwo )
	{
		// Dotp, dist
		Dist1 = VSize(TriggerActor.Location - Other.Location);
		Dist2 = VSize(TriggerActor2.Location - Other.Location);
		if ( Dist1 < Dist2 )
		{
			if ( (Dist1 < 500) && Other.ActorReachable(TriggerActor) )
				bTwo = false;
		}
		else if ( (Dist2 < 500) && Other.ActorReachable(TriggerActor2) )
			bOne = false;

		if ( bOne && bTwo )
		{
			DP1 = Normal(Location - Other.Location) Dot (TriggerActor.Location - Other.Location)/Dist1;
			DP2 = Normal(Location - Other.Location) Dot (TriggerActor2.Location - Other.Location)/Dist2;
			if ( (DP1 > 0) && (DP2 < 0) )
				bOne = false;
			else if ( (DP1 < 0) && (DP2 > 0) )
				bTwo = false;
			else if ( Dist1 < Dist2 )
				bTwo = false;
			else
				bOne = false;
		}
	}

	if ( bOne )
	{
		Other.SpecialGoal = TriggerActor;
		Other.MoveTarget = TriggerActor;
		return True;
	}
	else if ( bTwo )
	{
		Other.SpecialGoal = TriggerActor2;
		Other.MoveTarget = TriggerActor2;
		return True;
	}
	return false;
}

function Actor SpecialHandling(Pawn Other)
{
	if ( bDamageTriggered )
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return self;
	}

	if ( BumpType == BT_PlayerBump && !Other.bIsPlayer )
		return None;

	return self;
}

// 227j: AI hint if mover is at a keyframe.
function bool AtKeyFrame( byte Num )
{
	if( !bInterpolating )
		return (KeyNum==Num);
	return (KeyNum==Num && PhysAlpha>0.98f);
}

simulated function OnMirrorMode()
{
	local int i;
	
	Super.OnMirrorMode();
	BasePos.Y *= -1.f;
	BaseRot.Yaw = -BaseRot.Yaw;
	BaseRot.Pitch = -BaseRot.Pitch;
	for( i=0; i<ArrayCount(KeyPos); ++i )
	{
		KeyPos[i].Y *= -1;
		KeyRot[i].Yaw = -KeyRot[i].Yaw;
		KeyRot[i].Pitch = -KeyRot[i].Pitch;
	}
	if( Physics==PHYS_Rotating && !bRotateToDesired )
		RotationRate.Yaw = -RotationRate.Yaw;
}

//-----------------------------------------------------------------------------
// Movement functions.

// Interpolate to keyframe KeyNum in Seconds time.
final function InterpolateTo( byte NewKeyNum, float Seconds )
{
	NewKeyNum = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	if ( NewKeyNum==PrevKeyNum && KeyNum!=PrevKeyNum )
	{
		// Reverse the movement smoothly.
		PhysAlpha = 1.0 - PhysAlpha;
		OldPos    = BasePos + KeyPos[KeyNum];
		OldRot    = BaseRot + KeyRot[KeyNum];
	}
	else
	{
		// Start a new movement.
		OldPos    = Location;
		OldRot    = Rotation;
		PhysAlpha = 0.0;
	}

	// Setup physics.
	SetPhysics(PHYS_MovingBrush);
	bInterpolating   = true;
	PrevKeyNum       = KeyNum;
	KeyNum			 = NewKeyNum;
	PhysRate         = 1.0 / FMax(Seconds, 0.005);

	ClientUpdate++;
	SimOldPos = OldPos;
	SimOldRotYaw = OldRot.Yaw;
	SimOldRotPitch = OldRot.Pitch;
	SimOldRotRoll = OldRot.Roll;
	SimInterpolate.X = 100 * PhysAlpha;
	SimInterpolate.Y = 100 * FMax(0.01, PhysRate);
	SimInterpolate.Z = 256 * PrevKeyNum + KeyNum;
}

final function StopMovement()
{
	SimOldPos = Location;
	SimOldRotYaw = Rotation.Yaw;
	SimOldRotPitch = Rotation.Pitch;
	SimOldRotRoll = Rotation.Roll;
	SimInterpolate.X = 100 * PhysAlpha;
	SimInterpolate.Y = -1.f;
	
	SetPhysics(PHYS_None);
	bInterpolating = false;
}

// Set the specified keyframe.
final function SetKeyframe( byte NewKeyNum, vector NewLocation, rotator NewRotation )
{
	KeyNum         = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	KeyPos[KeyNum] = NewLocation;
	KeyRot[KeyNum] = NewRotation;
}

// Interpolation ended.
function InterpolateEnd( actor Other )
{
	local byte OldKeyNum;

	OldKeyNum  = PrevKeyNum;
	PrevKeyNum = KeyNum;
	PhysAlpha  = 0;

	// If more than two keyframes, chain them.
	if ( KeyNum>0 && KeyNum<OldKeyNum )
	{
		// Chain to previous.
		InterpolateTo(KeyNum-1,MoveTime);
	}
	else if ( KeyNum<NumKeys-1 && KeyNum>OldKeyNum )
	{
		// Chain to next.
		InterpolateTo(KeyNum+1,MoveTime);
	}
	else
	{
		// Finished interpolating.
		AmbientSound = None;
	}
}

//-----------------------------------------------------------------------------
// Mover functions.

// Notify AI that mover finished movement
function FinishNotify()
{
	local Pawn P;

	foreach BasedActors(class'Pawn',P)
	{
		P.StopWaiting();
		if ( (P.SpecialGoal == self) || (P.SpecialGoal == myMarker) )
			P.SpecialGoal = None;
		if ( P == WaitingPawn )
			WaitingPawn = None;
	}

	if ( WaitingPawn != None )
	{
		WaitingPawn.StopWaiting();
		if ( (WaitingPawn.SpecialGoal == self) || (WaitingPawn.SpecialGoal == myMarker) )
			WaitingPawn.SpecialGoal = None;
		WaitingPawn = None;
	}
}

// Handle when the mover finishes closing.
function FinishedClosing()
{
	// Update sound effects.
	PlaySound( ClosedSound, SLOT_None );

	// Notify our triggering actor that we have completed.
	if ( SavedTrigger != None )
		SavedTrigger.EndEvent();
	SavedTrigger = None;
	Instigator = None;
	FinishNotify();
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
	// Update sound effects.
	PlaySound( OpenedSound, SLOT_None );

	// Trigger any chained movers.
	TriggerEvent(Event,Self,Instigator);

	FinishNotify();
}

// Open the mover.
function DoOpen()
{
	bOpening = true;
	bDelaying = false;
	InterpolateTo( 1, MoveTime );
	PlaySound( OpeningSound, SLOT_None );
	AmbientSound = MoveAmbientSound;
}

// Close the mover.
function DoClose()
{
	bOpening = false;
	bDelaying = false;
	InterpolateTo( Max(0,KeyNum-1), MoveTime );
	PlaySound( ClosingSound, SLOT_None );
	UnTriggerEvent(Event,Self,Instigator);
	AmbientSound = MoveAmbientSound;
}

//-----------------------------------------------------------------------------
// Engine notifications.

// When mover enters gameplay.
simulated function BeginPlay()
{
	// timer updates real position every second in network play
	if ( Level.NetMode != NM_Standalone )
	{
		settimer(2.0, true);
		if ( Role < ROLE_Authority )
			return;
	}

	// Init key info.
	Super.BeginPlay();
	KeyNum         = Clamp( KeyNum, 0, ArrayCount(KeyPos)-1 );
	PhysAlpha      = 0.0;

	// Set initial location/rotation.
	Move( BasePos + KeyPos[KeyNum] - Location, BaseRot + KeyRot[KeyNum] );

	// find movers in same group
	if ( ReturnGroup == '' && Tag!=Class.Name )
		ReturnGroup = tag;
}

// Immediately after mover enters gameplay.
function PostBeginPlay()
{
	local mover M;

	//brushes can't be deleted, so if not relevant, make it invisible and non-colliding
	if ( !Level.Game.IsRelevant(self) )
	{
		If( !Brush )
			bHidden = true;
		else
		{
			SetLocation(Location + vect(0,0,20000)); // temp since still in bsp
			RemoteRole = Role_DumbProxy; //Allow clients to see the location update.		
		}
		SetCollision(false, false, false);
		Tag = '';
	}
	else
	{
		FindTriggerActor();
		// Initialize all slaves.
		if( !bSlave )
		{
			foreach AllActors( class 'Mover', M, Tag )
			{
				if ( M.bSlave )
				{
					M.GotoState('');
					M.SetBase( Self );
				}
			}
		}
		if( !Leader )
		{
			Leader = self;
			if( ReturnGroup!='' )
			{
				ForEach AllActors( class'Mover', M )
					if ( (M != self) && (M.ReturnGroup == ReturnGroup) )
					{
						M.Leader = self;
						M.Follower = Follower;
						Follower = M;
					}
			}
		}
		
		// Setup for pre 227j clients.
		ServerUpdate++;
		RealPosition = Location;
		RealRotation = Rotation;
		
		if( RemoteRole==Role_DumbProxy )
			NetUpdateFrequency = 100.f;
	}
}

function MakeGroupStop()
{
	// Stop moving immediately.
	StopMovement();
	AmbientSound = None;
	GotoState( , '' );

	if ( Follower != None )
		Follower.MakeGroupStop();
}

function MakeGroupReturn()
{
	// Abort move and reverse course.
	bInterpolating = false;
	AmbientSound = None;
	bForceNetUpdate = true;
	if ( KeyNum<PrevKeyNum )
		GotoState( , 'Open' );
	else
		GotoState( , 'Close' );

	if ( Follower != None )
		Follower.MakeGroupReturn();
}

// Return true to abort, false to continue.
function bool EncroachingOn( actor Other )
{
	local Pawn P;
	
	if ( Other.IsA('Carcass') || Other.IsA('Decoration') )
	{
		Other.TakeDamage(10000, None, Other.Location, vect(0,0,0), 'Crushed');
		return false;
	}
	if ( Other.IsA('Fragment') )
	{
		Other.Destroy();
		return false;
	}
	if( bIgnoreInventory )
	{
		if ( Other.IsA('Inventory') )
		{
			if( Other.IsA('Weapon') && (Other.Owner == None) && Inventory(Other).RespawnTime==0.f )
				Other.Destroy();
			else Other.TakeDamage(10000, None, Other.Location, vect(0,0,0), 'Crushed'); // Kill flares.
			return false;
		}
	}
	else if( Other.IsA('Weapon') && (Other.Owner == None) && Inventory(Other).RespawnTime==0.f )
	{
		Other.Destroy();
		return false;
	}

	// Damage the encroached actor.
	if ( EncroachDamage != 0 )
		Other.TakeDamage( EncroachDamage, Instigator, Other.Location, vect(0,0,0), 'Crushed' );

	// If we have a bump-player event, and Other is a pawn, do the bump thing.
	P = Pawn(Other);
	if ( P!=None && P.bIsPlayer && PlayerBumpEvent!='' )
	{
		Bump( Other );
		if ( (myMarker != None) && (P.Base != self)
				&& (P.Location.Z < myMarker.Location.Z - P.CollisionHeight - 0.7 * myMarker.CollisionHeight) )
			// pawn is under lift - tell him to move
			P.UnderLift(self);
	}

	// Stop, return, or whatever.
	switch( MoverEncroachType )
	{
	case ME_StopWhenEncroach:
		Leader.MakeGroupStop();
		return true;
	case ME_ReturnWhenEncroach:
		Leader.MakeGroupReturn();
		if ( Other.bIsPawn )
		{
			if ( Pawn(Other).bIsPlayer )
				Other.PlaySound(Pawn(Other).Land, SLOT_Talk);
			else
				Other.PlaySound(Pawn(Other).HitSound1, SLOT_Talk);
		}
		return true;
	case ME_CrushWhenEncroach:
		// Kill it.
		Other.KilledBy( Instigator );
		return false;
	default: // ME_IgnoreWhenEncroach
		// Ignore it.
		return false;
	}
}

// When bumped by player.
function Bump( actor Other )
{
	local Pawn P;

	P = Pawn(Other);
	switch( BumpType )
	{
	case BT_PlayerBump:
		if ( P==None || !P.bIsPlayer )
			return;
		break;
	case BT_PawnBump:
		if ( P==None || (P.Mass < 10) )
			return;
		break;
	}
	TriggerEvent(BumpEvent,Self,P);

	if ( P != None )
	{
		if ( P.bIsPlayer )
			TriggerEvent(PlayerBumpEvent,Self,P);

		if ( P.SpecialGoal == self )
			P.SpecialGoal = None;
	}
}

// When damaged
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if ( bDamageTriggered && (Damage >= DamageThreshold) )
		Trigger(self, instigatedBy);
}

// Reset mover to it's initial state.
function Reset()
{
	Instigator = None;
	SavedTrigger = None;
	bOpening = false;
	bDelaying = false;
	InterpolateTo(0,0);
	AmbientSound = None;
	GoToState('ResetState');
}

// 227j
function bool ShouldRestrictMoverRetriggering()
{
	return Level.Game.bRestrictMoversRetriggering && class == class'Mover';
}

// Notified by movement physics when mover is stuck with an actor inside it
event ActorBecameStuck( Actor Other )
{
	StuckedActor = Other;
}

//-----------------------------------------------------------------------------
// Trigger states.

// When triggered, open, wait, then close.
state() TriggerOpenTimed
{
	function Actor GetTriggerActor()
	{
		local Actor A;

		if ( Tag=='' )
			return Self;
		ForEach AllActors(Class'Actor',A,,Tag)
		if ( A!=Self )
			return A.GetTriggerActor();
		return Self;
	}

	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerOpenTimed', 'Open' );
	}

	function BeginState()
	{
		bOpening = false;
	}

Begin:
	Stop;

Open:
	Disable( 'Trigger' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if ( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Trigger' );
}

// Toggle when triggered.
state() TriggerToggle
{
	function Actor GetTriggerActor()
	{
		local Actor A;

		if ( Tag=='' )
			return Self;
		ForEach AllActors(Class'Actor',A,,Tag)
			if ( A!=Self )
				return A.GetTriggerActor();
		return Self;
	}

	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if ( KeyNum==0 || KeyNum<PrevKeyNum )
			GotoState( 'TriggerToggle', 'Open' );
		else
			GotoState( 'TriggerToggle', 'Close' );
	}

Begin:
	Stop;
Open:
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if ( SavedTrigger!=None )
		SavedTrigger.EndEvent();
	Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
}

// Open when triggered, close when get untriggered.
state() TriggerControl
{
	function Actor GetTriggerActor()
	{
		local Actor A;

		if ( Tag=='' )
			return Self;
		ForEach AllActors(Class'Actor',A,,Tag)
			if ( A!=Self )
				return A.GetTriggerActor();
		return Self;
	}

	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		++numTriggerEvents;
		if (!ShouldRestrictMoverRetriggering() ||
			!bDelaying && (KeyNum == 0 || KeyNum < PrevKeyNum || MoverEncroachType == ME_StopWhenEncroach && !bInterpolating))
		{
			SavedTrigger = Other;
			Instigator = EventInstigator;
			if ( SavedTrigger != None )
				SavedTrigger.BeginEvent();
			GotoState( 'TriggerControl', 'Open' );
		}
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if (--numTriggerEvents <= 0)
		{
			numTriggerEvents = 0;
			if (!ShouldRestrictMoverRetriggering() ||
				!(KeyNum == 0 || KeyNum < PrevKeyNum) || MoverEncroachType == ME_StopWhenEncroach && !bInterpolating)
			{
				SavedTrigger = Other;
				Instigator = EventInstigator;
				SavedTrigger.BeginEvent();
				GotoState( 'TriggerControl', 'Close' );
			}
			if (ShouldRestrictMoverRetriggering())
				bDelaying = false;
		}
	}
	
	function BeginState()
	{
		numTriggerEvents = 0;
	}

Begin:
	Stop;
Open:
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
		if (!bDelaying && ShouldRestrictMoverRetriggering())
			stop;
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if ( SavedTrigger!=None )
		SavedTrigger.EndEvent();
	if ( bTriggerOnceOnly )
		GotoState('');
	Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
}

// Start pounding when triggered.
state() TriggerPound
{
	function Actor GetTriggerActor()
	{
		local Actor A;

		if ( Tag=='' )
			return Self;
		ForEach AllActors(Class'Actor',A,,Tag)
		if ( A!=Self )
			return A.GetTriggerActor();
		return Self;
	}

	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if (ShouldRestrictMoverRetriggering())
		{
			if (++numTriggerEvents == 1 && !bDelaying)
			{
				if (KeyNum == 0 || KeyNum < PrevKeyNum)
				{
					SavedTrigger = Other;
					Instigator = EventInstigator;
					GotoState( 'TriggerPound', 'Open' );
				}
				else if (!bOpening) // special case: initial value of KeyNum is positive
				{
					SavedTrigger = Other;
					Instigator = EventInstigator;
					GotoState( 'TriggerPound', 'Close' );
				}
			}
		}
		else
		{
			numTriggerEvents++;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			GotoState( 'TriggerPound', 'Open' );
		}
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if (--numTriggerEvents <= 0)
		{
			numTriggerEvents = 0;
			SavedTrigger = None;
			if (ShouldRestrictMoverRetriggering())
			{
				if (bOpening || MoverEncroachType == ME_StopWhenEncroach && !bInterpolating)
					GotoState( 'TriggerPound', 'Close' );
				bDelaying = false;
			}
			else
			{
				Instigator = None;
				GotoState( 'TriggerPound', 'Close' );
			}
		}
	}
	
	function BeginState()
	{
		numTriggerEvents = 0;
	}

Begin:
	Stop;
Open:
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
		if (!bDelaying && ShouldRestrictMoverRetriggering())
			stop;
	}
	DoOpen();
	FinishInterpolation();
	Sleep(OtherTime);
Close:
	DoClose();
	FinishInterpolation();
	Sleep(StayOpenTime);
	if ( bTriggerOnceOnly )
		GotoState('');
	if (ShouldRestrictMoverRetriggering() && numTriggerEvents > 0 ||
		!ShouldRestrictMoverRetriggering() && SavedTrigger != none)
	{
		goto 'Open';
	}
}

state() ConstantLoop
{
Ignores UnTrigger,Trigger,Reset;

	function DoOpen()
	{
		local byte i;
		
		if( bOpening )
		{
			i = KeyNum + 1;
			if ( i >= NumKeys ) i = 0;
			PlaySound( OpeningSound );
		}
		else
		{
			i = PrevKeyNum;
			bOpening = true;
			PlaySound( ClosingSound );
		}
		bDelaying = false;
		InterpolateTo( i, MoveTime );
		AmbientSound = MoveAmbientSound;
	}
	function InterpolateEnd(actor Other)
	{
		if( StayOpenTime>0.f )
			AmbientSound = None;
	}
	function BeginState()
	{
		if( OtherTime==0.f )
			OtherTime = 1.f;
		bOpening = true;
	}
	
	function MakeGroupStop()
	{
		// Stop moving immediately.
		bOpening = false;
		StopMovement();
		AmbientSound = None;
		PlaySound( OpenedSound, SLOT_None );
		GotoState( , 'Close' );

		if ( Follower != None )
			Follower.MakeGroupStop();
	}

	function MakeGroupReturn()
	{
		// Abort move and reverse course.
		bOpening = false;
		bInterpolating = false;
		GotoState( , 'Open' );

		if ( Follower != None )
			Follower.MakeGroupReturn();
	}

Begin:
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep(StayOpenTime);

	// Loop forever
	GoTo'Begin';

Open:
	GoTo'Begin';

Close:
	Sleep(OtherTime);
	GoTo'Begin';
}

//-----------------------------------------------------------------------------
// Bump states.

// Open when bumped, wait, then close.
state() BumpOpenTimed
{
	function bool HandleDoor(pawn Other)
	{
		if ( (BumpType == BT_PlayerBump) && !Other.bIsPlayer )
			return false;

		Bump(Other);
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		return true;
	}

	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).bIsPlayer )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		Global.Bump( Other );
		SavedTrigger = None;
		Instigator = Pawn(Other);
		GotoState( 'BumpOpenTimed', 'Open' );
	}
Begin:
	Stop;
Open:
	Disable( 'Bump' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if ( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
}

// Open when bumped, close when reset.
state() BumpButton
{
	function bool HandleDoor(pawn Other)
	{
		if ( (BumpType == BT_PlayerBump) && !Other.bIsPlayer )
			return false;

		Bump(Other);
		return false; //let pawn try to move around this button
	}

	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).bIsPlayer )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		Global.Bump( Other );
		SavedTrigger = Other;
		Instigator = Pawn( Other );
		GotoState( 'BumpButton', 'Open' );
	}
	function BeginEvent()
	{
		bSlave=true;
	}
	function EndEvent()
	{
		bSlave     = false;
		Instigator = None;
		GotoState( 'BumpButton', 'Close' );
	}
Begin:
	Stop;
Open:
	Disable( 'Bump' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if ( bTriggerOnceOnly )
		GotoState('');
	if ( bSlave )
		Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
}

//-----------------------------------------------------------------------------
// Stand states.

// Open when stood on, wait, then close.
state() StandOpenTimed
{
	function bool HandleDoor(pawn Other)
	{
		if ( bPlayerOnly && !Other.bIsPlayer )
			return false;
		Other.SpecialPause = 2.5;
		WaitingPawn = Other;
		if ( Other.Base == self )
			Attach(Other);
		return true;
	}

	function Attach( actor Other )
	{
		local pawn  P;

		P = Pawn(Other);
		if ( (BumpType != BT_AnyBump) && (P == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !P.bIsPlayer )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		SavedTrigger = None;
		GotoState( 'StandOpenTimed', 'Open' );
	}
Begin:
	Stop;
Open:
	Disable( 'Attach' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if ( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Attach' );
}

State ResetState
{
Ignores MakeGroupReturn,MakeGroupStop;

	function InterpolateEnd( actor Other )
	{
		PrevKeyNum = 0;
		PhysAlpha  = 0;
		AmbientSound = None;
	}
Begin:
	Sleep(0.f);
	if( InitialState!='' )
		GoToState(InitialState);
	else GoToState('Auto');
}

defaultproperties
{
	MoverEncroachType=ME_ReturnWhenEncroach
	MoverGlideType=MV_GlideByTime
	NumKeys=2
	BrushRaytraceKey=0
	MoveTime=+00001.000000
	StayOpenTime=+00004.000000
	bStatic=False
	bDynamicLightMover=False
	bShadowCast=True
	bIsMover=True
	CollisionRadius=+00160.000000
	CollisionHeight=+00160.000000
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
	Physics=PHYS_MovingBrush
	InitialState=BumpOpenTimed
	TransientSoundVolume=+00003.000000
	SoundVolume=228
	NetPriority=7
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bUseGoodCollision=True
	CollisionFlag=COLLISIONFLAG_Movers
	NetUpdateFrequency=2
	bNotifyPositionUpdate=true
}