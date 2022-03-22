//=============================================================================
// The inventory class, the parent class of all objects which can be
// picked up and carried by actors.
//=============================================================================
class Inventory extends Actor
	abstract
		native
			NativeReplication;

#exec Texture Import File=Textures\Inventry.pcx Name=S_Inventory Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Information relevant to Active/Inactive state.

var() travel byte AutoSwitchPriority; // Autoswitch value, 0=never autoswitch.
var() byte        InventoryGroup;     // The weapon/inventory set, 1-9 (0=none).
var() bool        bActivatable;       // Whether item can be activated.
var() bool	 	  bDisplayableInv;	  // Item displayed in HUD.
var	travel bool   bActive;			  // Whether item is currently activated.
var	  bool		  bSleepTouch;		  // Set when item is touched when leaving sleep state.
var	  bool		  bHeldItem;		  // Set once an item has left pickup state.
var() bool		  bNoInventoryMarker; // 227j: Do not add an inventory spot marker for this item.

// Network replication.
var bool bRepMuzzleFlash; // Replicate muzzle flash variables.
var bool bRepPlayerView; // Replicate player view stuff (offset, mesh, scale).

// 3rd person muzzleflash
var bool bSteadyFlash3rd;
var bool bFirstFrame;
var(MuzzleFlash) bool bMuzzleFlashParticles;
var(MuzzleFlash) bool bToggleSteadyFlash;
var bool	bSteadyToggle;

//-----------------------------------------------------------------------------
// Ambient glow related info.

var(Display) bool bAmbientGlow;		  // Whether to glow or not.

//-----------------------------------------------------------------------------
// Information relevant to Pickup state.

var() bool		bInstantRespawn;	  // Can be tagged so this item respawns instantly.
var() bool		bRotatingPickup;	  // Rotates when in pickup state.
var() localized string PickupMessage; // Human readable description when picked up.
var() localized string ItemName;      // Human readable name of item
var() localized string ItemArticle;   // Human readable article (e.g. "a", "an")
var() float     RespawnTime;          // Respawn after this time, 0 for instant.
var name 		PlayerLastTouched;    // Player who last touched this item.

//-----------------------------------------------------------------------------
// Rendering information.

// Player view rendering info.
var() norepnotify vector PlayerViewOffset;// Offset from view center.
var() mesh        PlayerViewMesh;     // Mesh to render.
var() float       PlayerViewScale;    // Mesh scale.
var() float		  BobDamping;		  // how much to damp view bob

// Pickup view rendering info.
var() mesh        PickupViewMesh;     // Mesh to render.
var() float       PickupViewScale;    // Mesh scale.

// 3rd person mesh.
var() mesh        ThirdPersonMesh;    // Mesh to render.
var() float       ThirdPersonScale;   // Mesh scale.

//-----------------------------------------------------------------------------
// Status bar info.

var() texture     StatusIcon;         // Icon used with ammo/charge/power count.

//-----------------------------------------------------------------------------
// Armor related info.

var() name		  ProtectionType1;	  // Protects against DamageType (None if non-armor).
var() name		  ProtectionType2;	  // Secondary protection type (None if non-armor).
var() travel int  Charge;			  // Amount of armor or charge if not an armor (charge in time*10).
var() int		  ArmorAbsorption;	  // Percent of damage item absorbs 0-100.
var() bool		  bIsAnArmor;		  // Item will protect player.
var() int		  AbsorptionPriority; // Which items absorb damage first (higher=first).
var() inventory	  NextArmor;		  // Temporary list created by Armors to prioritize damage absorption.

//-----------------------------------------------------------------------------
// AI related info.

var() float		  MaxDesireability;	  // Maximum desireability this item will ever have.
var	  InventorySpot myMarker;

//-----------------------------------------------------------------------------
// 3rd person muzzleflash

var byte FlashCount, OldFlashCount;
var(MuzzleFlash) ERenderStyle MuzzleFlashStyle;
var(MuzzleFlash) mesh MuzzleFlashMesh;
var(MuzzleFlash) float MuzzleFlashScale;
var(MuzzleFlash) texture MuzzleFlashTexture;

//-----------------------------------------------------------------------------
// Sound assignments.

var() sound PickupSound, ActivateSound, DeActivateSound, RespawnSound;

//-----------------------------------------------------------------------------
// HUD graphics.

var() texture Icon;
var() localized String M_Activated;
var() localized String M_Selected;
var() localized String M_Deactivated;

// 227j shadows:
var transient Actor Shadow;

var const NavigationPoint DroppedMarker; // 227: Pointer nearby navpoint.
var const Inventory DroppedNext; // 227: Pointer to next dropped item to this navpoint.
var const float DroppedDistance; // 227: Distance to the nearby navpoint.

replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority && bNetOwner )
		bIsAnArmor, Charge, bActivatable, bActive, PlayerViewOffset, PlayerViewMesh, PlayerViewScale;
	unreliable if ( Role==ROLE_Authority )
		FlashCount, bSteadyFlash3rd, ThirdPersonMesh, ThirdPersonScale;
}

// 227j: Mark this item as dropped item to give AI hint.
native final function AddToNavigation();
native final function RemoveFromNavigation();

function PostBeginPlay()
{
	if ( ItemName == "" )
		ItemName = GetItemName(string(Class));

	Super.PostBeginPlay();
}

// Draw first person view of inventory
simulated event RenderOverlays( canvas Canvas )
{
	if ( Owner == None )
		return;
	if ( (Level.NetMode == NM_Client) && (!Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Player == None)) )
		return;
	SetLocation( Owner.Location + CalcDrawOffset(), Pawn(Owner).ViewRotation );
	Canvas.DrawActor(self, false);
}

function String GetHumanName()
{
	return ItemArticle@ItemName;
}

//MWP:begin
// overridable function to ask the inventory object to draw its StatusIcon
simulated function DrawStatusIconAt( canvas Canvas, int X, int Y, optional float Scale )
{
	if ( Scale == 0.0 )
		Scale = 1.0;
	Canvas.SetPos( X, Y );
	Canvas.DrawIcon( StatusIcon, Scale );
}
//MWP:end

//=============================================================================
// AI inventory functions.

event float BotDesireability( pawn Bot )
{
	local Inventory AlreadyHas;
	local float desire;
	local bool bChecked;

	desire = MaxDesireability;

	if ( RespawnTime < 10 )
	{
		bChecked = true;
		AlreadyHas = Bot.FindInventoryType(class);
		if ( (AlreadyHas != None)
				&& (AlreadyHas.Charge >= Charge) )
			return -1;
	}

	if ( bIsAnArmor )
	{
		if ( !bChecked )
			AlreadyHas = Bot.FindInventoryType(class);
		if ( AlreadyHas != None )
			desire *= 0.4;

		desire *= (Charge * 0.005);
		desire *= (ArmorAbsorption * 0.01);
		return desire;
	}
	else return desire;
}

function Weapon RecommendWeapon( out float rating, out int bUseAltMode )
{
	if ( inventory != None )
		return inventory.RecommendWeapon(rating, bUseAltMode);
	else
	{
		rating = -1;
		return None;
	}
}

//=============================================================================
// Inventory travelling across servers.

//
// Called after a travelling inventory item has been accepted into a level.
//
event TravelPreAccept()
{
	Super.TravelPreAccept();
	bHeldItem = true;
	GiveTo( Pawn(Owner) );
	if ( bActive )
		Activate();
}

//=============================================================================
// General inventory functions.

//
// Called by engine when destroyed.
//
function Destroyed()
{
	if (myMarker != None )
		myMarker.markedItem = None;
	// Remove from owner's inventory.
	if ( Pawn(Owner)!=None )
		Pawn(Owner).DeleteInventory( Self );
}

//
// Compute offset for drawing.
//
simulated final function vector CalcDrawOffset()
{
	local vector DrawOffset, WeaponBob;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	
	if( Level.bIsDemoPlayback ) // Special case for demo playback because they may be missing this network information.
	{
		DrawOffset = Default.PlayerViewOffset;
		if ( Class'PlayerPawn'.Default.Handedness == 2 )
			DrawOffset.Y = 0;
		else if ( Class'PlayerPawn'.Default.Handedness==0 )
		{
			DrawOffset.X *= 0.88;
			DrawOffset.Y *= -0.2;
			DrawOffset.Z *= 1.12;
		}
		else DrawOffset.Y *= Class'PlayerPawn'.Default.Handedness;
		
		DrawOffset = DrawOffset >> PawnOwner.ViewRotation;
	}
	else DrawOffset = ((0.01 * PlayerViewOffset) >> PawnOwner.ViewRotation);

	if ( (Level.NetMode == NM_DedicatedServer)
			|| ((Level.NetMode == NM_ListenServer) && (Owner.RemoteRole == ROLE_AutonomousProxy)) )
		DrawOffset += (PawnOwner.BaseEyeHeight * vect(0,0,1));
	else
	{
		DrawOffset += (PawnOwner.EyeHeight * vect(0,0,1));
		WeaponBob = BobDamping * PawnOwner.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
		DrawOffset += WeaponBob;
	}
	return DrawOffset;
}

//
// Become a pickup.
//
function BecomePickup()
{
	if ( Physics != PHYS_Falling )
		RemoteRole    = ROLE_SimulatedProxy;
	Mesh          = PickupViewMesh;
	DrawScale     = PickupViewScale;
	bOnlyOwnerSee = false;
	bHidden       = false;
	bCarriedItem  = false;
	NetPriority   = 2;
	SetCollision( true, false, false );
	bForceNetUpdate = true;
}

//
// Become an inventory item.
//
function BecomeItem()
{
	RemoteRole    = ROLE_DumbProxy;
	Mesh          = PlayerViewMesh;
	DrawScale     = PlayerViewScale;
	bOnlyOwnerSee = true;
	bHidden       = true;
	bCarriedItem  = true;
	NetPriority   = 4;
	SetCollision( false, false, false );
	SetPhysics(PHYS_None);
	SetTimer(0.0,False);
	AmbientGlow = 0;
	bForceNetUpdate = true;
}

//
// Give this inventory item to a pawn.
//
function GiveTo( pawn Other )
{
	Instigator = Other;
	BecomeItem();
	Other.AddInventory( Self );
	GotoState('Idle2');
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
//
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	if ( Level.Game.ShouldRespawn(self) )
	{
		Copy = spawn(Class,Other);
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		GotoState('Sleeping');
	}
	else
		Copy = self;

	Copy.RespawnTime = 0.0;
	Copy.bHeldItem = true;
	Copy.GiveTo( Other );
	return Copy;
}

//
// Set up respawn waiting if desired.
//
function SetRespawn()
{
	if ( Level.Game.ShouldRespawn(self) )
		GotoState('Sleeping');
	else
		Destroy();
}


//
// Toggle Activation of selected Item.
//
function Activate()
{
	if ( bActivatable )
	{
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));

		Pawn(Owner).ClientMessage(ItemName$M_Activated);
		GoToState('Activated');
	}
}

//
// Function which lets existing items in a pawn's inventory
// prevent the pawn from picking something up. Return true to abort pickup
// or if item handles pickup, otherwise keep going through inventory list.
//
function bool HandlePickupQuery( inventory Item )
{
	if ( Item.Class == Class )
		return true;
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

//
// Select first activatable item.
//
function Inventory SelectNext()
{
	if ( bActivatable )
	{
		Pawn(Owner).ClientMessage(ItemName$M_Selected);
		return self;
	}
	if ( Inventory != None )
		return Inventory.SelectNext();
	else
		return None;
}

//
// Toss this item out.
//
function DropFrom(vector StartLocation)
{
	if ( !SetLocation(StartLocation) )
		return;
	RespawnTime = 0.0; //don't respawn
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	BecomePickup();
	NetPriority = 6;
	bCollideWorld = true;
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory(self);
	GotoState('PickUp', 'Dropped');
}

//=============================================================================
// Capabilities: For feeding general info to bots.

// For future use.
function float InventoryCapsFloat( name Property, pawn Other, actor Test );
function string InventoryCapsString( name Property, pawn Other, actor Test );

//=============================================================================
// Firing/using.

// Fire functions which must be implemented in child classes.
function Fire( float Value );
function AltFire( float Value );
function Use( pawn User );

//=============================================================================
// Weapon functions.

//
// Find a weapon in inventory that has an Inventory Group matching F.
//

function Weapon WeaponChange( byte F )
{
	if ( Inventory == None)
		return None;
	else
		return Inventory.WeaponChange( F );
}

//=============================================================================
// Armor functions.

//
// Scan the player's inventory looking for items that reduce damage
// to the player.  If Armor's protection type matches DamageType, then no damage is taken.
// Returns the reduced damage.
//
function int ReduceDamage( int Damage, name DamageType, vector HitLocation )
{
	local Inventory FirstArmor;
	local int ReducedAmount;

	if ( Damage<0 )
		return 0;

	ReducedAmount = Damage;
	FirstArmor = PrioritizeArmor(Damage, DamageType, HitLocation);
	while ( (FirstArmor != None) && (ReducedAmount > 0) )
	{
		ReducedAmount = FirstArmor.ArmorAbsorbDamage(ReducedAmount, DamageType, HitLocation);
		FirstArmor = FirstArmor.nextArmor;
	}
	return ReducedAmount;
}

//
// Return the best armor to use.
//
function inventory PrioritizeArmor( int Damage, name DamageType, vector HitLocation )
{
	local Inventory FirstArmor, InsertAfter;

	if ( Inventory != None )
		FirstArmor = Inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
	else
		FirstArmor = None;

	if ( bIsAnArmor)
	{
		if ( FirstArmor == None )
		{
			nextArmor = None;
			return self;
		}

		// insert this armor into the prioritized armor list
		if ( FirstArmor.ArmorPriority(DamageType) < ArmorPriority(DamageType) )
		{
			nextArmor = FirstArmor;
			return self;
		}
		InsertAfter = FirstArmor;
		while ( (InsertAfter.nextArmor != None)
				&& (InsertAfter.nextArmor.ArmorPriority(DamageType) > ArmorPriority(DamageType)) )
			InsertAfter = InsertAfter.nextArmor;

		nextArmor = InsertAfter.nextArmor;
		InsertAfter.nextArmor = self;
	}
	return FirstArmor;
}

//
// Absorb damage.
//
function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	local int ArmorDamage;

	if ( DamageType != 'Drowned' )
		ArmorImpactEffect(HitLocation);
	if ( (DamageType!='None') && ((ProtectionType1==DamageType) || (ProtectionType2==DamageType)) )
		return 0;

	if (DamageType=='Drowned') Return Damage;

	ArmorDamage = (Damage * ArmorAbsorption) / 100;
	if ( ArmorDamage >= Charge )
	{
		ArmorDamage = Charge;
		Destroy();
	}
	else
		Charge -= ArmorDamage;
	return (Damage - ArmorDamage);
}

//
// Return armor value.
//
function int ArmorPriority(name DamageType)
{
	if ( DamageType == 'Drowned' )
		return 0;
	if ( (DamageType!='None')
			&& ((ProtectionType1==DamageType) || (ProtectionType2==DamageType)) )
		return 1000000;

	return AbsorptionPriority;
}

//
// This function is called by ArmorAbsorbDamage and displays a visual effect
// for an impact on an armor.
//
function ArmorImpactEffect(vector HitLocation) { }

//
// Used to inform inventory when owner jumps.
//
function OwnerJumped()
{
	if ( Inventory != None )
		Inventory.OwnerJumped();
}

//
// Used to inform inventory when owner weapon changes.
//
function ChangedWeapon()
{
	if ( Inventory != None )
		Inventory.ChangedWeapon();
}

// used to ask inventory if it needs to affect its owners display properties
function SetOwnerDisplay()
{
	if ( Inventory != None )
		Inventory.SetOwnerDisplay();
}

function FellOutOfWorld()
{
	if ( Region.ZoneNumber == 0 )
		Error(Name@"fell out of the world!");
	else Destroy();
}

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.

auto state Pickup
{
	singular function ZoneChange( ZoneInfo NewZone )
	{
		local float splashsize;
		local actor splash;

		if ( NewZone.bWaterZone && !Region.Zone.bWaterZone )
		{
			splashSize = 0.000025 * Mass * (250 - 0.5 * Velocity.Z);
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor);
				if ( splash != None )
					splash.DrawScale = 2 * splashSize;
			}
		}
	}

	// Validate touch, and if valid trigger event.
	function bool ValidTouch( actor Other )
	{
		if ( Other.bIsPawn && Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0) && Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, Other, Other.Instigator);
			return true;
		}
		return false;
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			SpawnCopy(Pawn(Other));
			Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			PlaySound (PickupSound);
			if ( Level.Game.Difficulty > 1 )
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
		}
	}

	// Landed on ground.
	function Landed(Vector HitNormal)
	{
		local vector X,Y;
		local rotator R;
		
		R.Yaw = Rotation.Yaw;
		Y = Normal(HitNormal Cross vector(R));
		X = Normal(Y Cross HitNormal);
		SetRotation(OrthoRotation(X,Y,HitNormal));
		SetTimer(2.0, false);
		if( bHeldItem )
			AddToNavigation();
	}

	// Make sure no pawn already touching (while touch was disabled in sleep).
	function CheckTouching()
	{
		local Pawn P;

		bSleepTouch = false;
		CheckEncroachments(); // Update touchlist
		if( IsInState('Pickup') )
		{
			foreach TouchingActors(Class'Pawn',P)
				Touch(P);
		}
	}

	function Timer()
	{
		if ( RemoteRole != ROLE_SimulatedProxy )
		{
			NetPriority = 2;
			RemoteRole = ROLE_SimulatedProxy;
			if (Physics == PHYS_Falling)
				bSimulatedPawnRep = true;
			if ( bHeldItem )
				SetTimer(40.0, false);
			return;
		}

		if ( bHeldItem )
			Destroy();
	}

	function BeginState()
	{
		BecomePickup();
		bCollideWorld = true;
		if ( bHeldItem )
			SetTimer(45, false);
		else
			SetTimer(0, false);
	}

	function EndState()
	{
		bSimulatedPawnRep = Default.bSimulatedPawnRep;
		if (Physics != PHYS_Falling)
			bCollideWorld = false;
		bSleepTouch = false;
		RemoveFromNavigation();
	}

	function Reset()
	{
		if( bHeldItem )
			Destroy();
	}

Begin:
	BecomePickup();
	if ( bRotatingPickup && (Physics != PHYS_Falling) )
		SetPhysics(PHYS_Rotating);

Dropped:
	if ( bAmbientGlow )
		AmbientGlow=255;
	if ( bSleepTouch )
		CheckTouching();
}

//=============================================================================
// Active state: this inventory item is armed and ready to rock!

state Activated
{
	function BeginState()
	{
		bActive = true;
		if ( Pawn(Owner).bIsPlayer && (ProtectionType1 != '') )
			Pawn(Owner).ReducedDamageType = ProtectionType1;
	}

	function EndState()
	{
		bActive = false;
		if ( (Pawn(Owner) != None)
				&& Pawn(Owner).bIsPlayer && (ProtectionType1 != '') )
			Pawn(Owner).ReducedDamageType = '';
	}

	function Activate()
	{
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));

		if ( Pawn(Owner) != None )
			Pawn(Owner).ClientMessage(ItemName$M_Deactivated);
		GoToState('DeActivated');
	}
}

//=============================================================================
// Sleeping state: Sitting hidden waiting to respawn.

State Sleeping
{
	ignores Touch;

	function BeginState()
	{
		BecomePickup();
		bHidden = true;
	}
	function EndState()
	{
		bSleepTouch = true;
	}
	function Reset()
	{
		GoToState( 'Pickup' );
	}
Begin:
	Sleep( ReSpawnTime );
	PlaySound( RespawnSound );
	Sleep( Level.Game.PlaySpawnEffect(self) );
	GoToState( 'Pickup' );
}

function ActivateTranslator(bool bHint)
{
	if ( Inventory!=None )
		Inventory.ActivateTranslator( bHint );
}

//
// Null state.
//
State Idle2
{
}

// Spawn any missing markers.
function NotifyPathDefine( bool bPreNotify )
{
	local vector HL,HN;

	if( bNoInventoryMarker )
	{
		if( myMarker!=None )
			myMarker.Destroy();
		myMarker = None;
	}
	else if( !bPreNotify )
	{
		if( myMarker==None || myMarker.bDeleteMe || myMarker.markedItem!=Self )
			myMarker = Spawn(Class'InventorySpot',,,,rot(0,0,0));
		myMarker.markedItem = Self;

		// Move inventory spot above floor.
		if( Trace(HL,HN,Location-vect(0,0,32),Location,false)!=None )
			HL.Z += myMarker.CollisionHeight;
		else HL = Location;
		
		// Move out from walls.
		myMarker.FindSpot(HL,true);
		
		myMarker.SetLocation(HL);
		myMarker.bHiddenEd = true;
	}
}

// 227j shadows, only if actor is unowned!
function PostLoadGame()
{
	ShadowModeChange();
}
simulated function OwnerChanged()
{
	if( Level.NetMode!=NM_DedicatedServer )
		ShadowModeChange();
	if( Owner ) // Incase custom mod overrides Pickup.EndState
		RemoveFromNavigation();
}
simulated function PostNetBeginPlay()
{
	if( Owner && Shadow )
	{
		Shadow.Destroy();
		Shadow = None;
	}
}

// Called by C++ codes BeginPlay.
simulated function ShadowModeChange()
{
	if( !bNoDynamicShadowCast )
	{
		if( Owner || !Class'GameInfo'.Default.bCastShadow || !Class'GameInfo'.Default.bDecoShadows )
		{
			if( Shadow )
			{
				Shadow.Destroy();
				Shadow = None;
			}
		}
		else if( !Shadow )
			Shadow = Spawn(Class'InventoryShadow',Self);
	}
}

defaultproperties
{
	ItemArticle="a"
	bToggleSteadyFlash=true
	bFirstFrame=true
	bAmbientGlow=True
	bRotatingPickup=True
	PickupMessage="Snagged an item"
	PlayerViewScale=1.000000
	BobDamping=0.960000
	PickupViewScale=1.000000
	ThirdPersonScale=1.000000
	MaxDesireability=0.005000
	M_Activated=" activated"
	M_Selected=" selected"
	M_Deactivated=" deactivated"
	bIsItemGoal=True
	bTravel=True
	DrawType=DT_Mesh
	Texture=Texture'Engine.S_Inventory'
	AmbientGlow=255
	CollisionRadius=30.000000
	CollisionHeight=30.000000
	bCollideActors=True
	bFixedRotationDir=True
	RotationRate=(Yaw=5000)
	DesiredRotation=(Yaw=30000)
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2
	bRepMuzzleFlash=true
	bRepPlayerView=true
}
