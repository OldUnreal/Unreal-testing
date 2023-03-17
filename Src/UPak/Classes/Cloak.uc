//=============================================================================
// Cloak.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class Cloak expands Pickup;

#exec Texture Import File=Textures\HD_Icons\I_HD_Cloak.bmp Name=I_HD_Cloak Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Cloak FILE=TEXTURES\CLOAK\i_invisi.PCX GROUP="Icons"  MIPS=OFF HD=I_HD_Cloak
#exec TEXTURE IMPORT NAME=CloakTexture FILE=TEXTURES\CLOAK\CloakTexture.PCX GROUP="Cloak"

#exec MESH IMPORT MESH=pyramid ANIVFILE=MODELS\CLOAK\pyramid_a.3d DATAFILE=MODELS\CLOAK\pyramid_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=pyramid X=0 Y=0 Z=50 ROLL=0.59
#exec MESH SEQUENCE MESH=pyramid SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=pyramid SEQ=INVISI STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jpyramid0 FILE=MODELS\CLOAK\pyramidFX.PCX GROUP=Skins FLAGS=2 // SKIN
#exec TEXTURE IMPORT NAME=Jpyramid1 FILE=MODELS\CLOAK\pyramid.PCX GROUP=Skins // Material #1

#exec MESHMAP NEW   MESHMAP=pyramid MESH=pyramid
#exec MESHMAP SCALE MESHMAP=pyramid X=0.04 Y=0.04 Z=0.1

#exec MESHMAP SETTEXTURE MESHMAP=pyramid NUM=0 TEXTURE=Jpyramid0
#exec MESHMAP SETTEXTURE MESHMAP=pyramid NUM=1 TEXTURE=Jpyramid1

#exec AUDIO IMPORT FILE="Sounds\Cloak\CloakOn.WAV" NAME="CloakOn" GROUP="Cloak"
#exec AUDIO IMPORT FILE="Sounds\Cloak\CloakOff.WAV" NAME="CloakOff" GROUP="Cloak"
#exec AUDIO IMPORT FILE="Sounds\Cloak\CloakLoop2.WAV" NAME="CloakLoop2" GROUP="Cloak"
#exec AUDIO IMPORT FILE="Sounds\Cloak\CloakLoop3.WAV" NAME="CloakLoop3" GROUP="Cloak"
#exec AUDIO IMPORT FILE="Sounds\Cloak\CloakLoop1a.WAV" NAME="CloakLoop1a" GROUP="Cloak"
#exec AUDIO IMPORT FILE="Sounds\Cloak\CloakLoop1b.WAV" NAME="CloakLoop1b" GROUP="Cloak"
// add fade-in effect for respawning?

var Weapon LastWeapon;			// Last Weapon wielded by owner
var int CountDown;				// Used in timing the "back to visible" routine
var rotator LastOwnerRotation;	// Used in checking owner's rotation vs last rotation
var bool bExpanding, bEngaging;	// Used in going invis routines (tick)
var bool bEngagingCompleted;	// Used in Timer
var float OwnerFatnessDelta;	// Used in going invis routines (tick)
var Weapon InvisWeaponList[25];	// Array holding all affected weapons
var int ArrayCounter;			// Counter for array
var Actor EffectsActor;			// Actor that plays sound when the cloaking device is active
var() float JumpZAdjustment;
var() float AirControlAdjustment;

function PostBeginPlay()
{
	if (JumpZAdjustment <= 1)
		JumpZAdjustment = 1.5;
}

event float BotDesireability(Pawn Bot)
{
	local Cloak AlreadyHas;

	AlreadyHas = Cloak(Bot.FindInventoryType(class));
	if (AlreadyHas == none)
		return MaxDesireability;
	else
		return 0;
}

function PickupFunction(Pawn Other)
{
	if (Other.IsA('Bots'))
	{
		// Small chance of activating on Pickup, else it heads to Idle2 state.
		if (FRand() < 0.13)
			GotoState('Activated');
	}
}

// ================================================================================================
// Activated State
// ================================================================================================

state Activated
{
	function BeginState()
	{
		bActive = true;
		DisableInventoryEffects();
		Enable('Tick');

		// new sound stuff:
		Owner.PlaySound(sound'CloakOn');

		CloakOwner();

		// "Turn on" the bEngaging part of the Tick function below..
		bEngaging = true;

		// Set their current weapon to be invisible
		if (Pawn(Owner).Weapon != none)
			InvisWeapons(Pawn(Owner).Weapon);

		SetTimer(0.7, true);
	}

	function EndState()
	{
		bActive = false;
	}

	function Activate()
	{
		if (!Level.Game.IsA('CloakMatch'))
			super.Activate();
	}

	function Timer()
	{
		local Bots SP;

		if (Pawn(Owner) == none || Owner.bDeleteMe)
			return;

		EnableInventoryEffects();

		if (!Level.Game.IsA('CloakMatch'))
			Charge--;
		foreach AllActors(class'Bots', SP)
		{
			if (SP.Enemy == Owner)
			{
				SP.Enemy = none;
				SP.Target = none;
			}
		}

		// If the charge is <= 0, use the bEngaging routine in TICK for the flicker effect again..
		// Run the bEngaging routine for about 5 seconds, then destroy it.
		if (Charge <= 0)
		{
			if (++CountDown >= 10)
			{
				Pawn(Owner).ClientMessage(ItemName $ M_Deactivated);
				Destroy();
			}
			else
				bEngaging = true;
		}
		else if (bEngaging && bEngagingCompleted)
			GotoState(, 'Begin');
	}

	function Tick(float DeltaTime)
	{
		local Pawn OwnerPawn;
		local bool bFlicker;
		local float TimeFactor;

		OwnerPawn = Pawn(Owner);
		if (OwnerPawn == none)
			return;

		CloakOwner();

		if (bEngaging)
		{
			OwnerPawn.Fatness = Rand(254);

			if (FRand() < 0.5)
			{
				OwnerPawn.bMeshEnviroMap = true;
				if (OwnerPawn.Texture == none || OwnerPawn.Texture.Name != 'Invis')
					OwnerPawn.Texture = Texture'CloakTexture';
				OwnerPawn.ScaleGlow = 0.08;
			}
			else
			{
				OwnerPawn.Fatness = OwnerPawn.default.Fatness;
				if (OwnerPawn.Texture == none || OwnerPawn.Texture.Name != 'Invis')
				{
					OwnerPawn.bMeshEnviroMap = OwnerPawn.default.bMeshEnviroMap;
					OwnerPawn.Texture = OwnerPawn.default.Texture;
				}
				OwnerPawn.ScaleGlow = 0.95;
			}
		}
		else // Normal checks for normal invisible state. Firing, rotation, speed.
		{
			TimeFactor = DeltaTime * 60; // 60 ticks per second is taken as the normal rate

			OwnerPawn.bMeshEnviroMap = true;
			if (OwnerPawn.Texture == OwnerPawn.default.Texture)
				OwnerPawn.Texture = Texture'CloakTexture';

			if (OwnerPawn.bFire != 0 || OwnerPawn.bAltFire != 0)
				OwnerPawn.ScaleGlow = 0.13;

			if (OwnerPawn.Rotation != LastOwnerRotation && OwnerPawn.ScaleGlow <= 0.14 )
			{
				OwnerPawn.ScaleGlow = 0.4;
				LastOwnerRotation = OwnerPawn.Rotation;
			}
			else if (VSize(OwnerPawn.Velocity) == 0 && OwnerPawn.ScaleGlow > 0.02)
				OwnerPawn.ScaleGlow = FMax(0.02, OwnerPawn.ScaleGlow - 0.01 * TimeFactor);
			else
				bFlicker = true;

			// Extra subtle flickering/slight expanding for effect.
			if (bFlicker)
			{
				if (OwnerFatnessDelta > -14 && !bExpanding)
				{
					OwnerFatnessDelta = FMax(-14, OwnerFatnessDelta - 2 * TimeFactor);
					OwnerPawn.ScaleGlow = FMax(0.01, OwnerPawn.ScaleGlow - 0.01 * TimeFactor);
				}
				else
				{
					bExpanding = true;
					if (OwnerFatnessDelta < 0)
					{
						if (VSize(OwnerPawn.Velocity) > 0)
						{
							OwnerFatnessDelta = FMin(0, OwnerFatnessDelta + 2 * TimeFactor);
							OwnerPawn.ScaleGlow = FMin(0.19, OwnerPawn.ScaleGlow + 0.01 * TimeFactor);
						}
						else
							OwnerFatnessDelta = FMin(0, OwnerFatnessDelta + TimeFactor);
					}
					else
						bExpanding = false;
				}
			}
			else
				OwnerFatnessDelta = FMin(0, OwnerFatnessDelta + 2 * TimeFactor);
			OwnerPawn.Fatness = OwnerPawn.default.Fatness + OwnerFatnessDelta;
		}

		UpdateWeapons();
	}

	// Set a weapon to invis stats, and add it to the affected weapon array.
	function InvisWeapons(Weapon ChangeWeapon)
	{
		CloakOwnerWeapon(ChangeWeapon);
	}

	// Search the array, make sure no weapon is duplicated in it; if no match, add it to the array and
	// increment arraycounter.
	function AddWeaponToList(Weapon AddWeapon)
	{
		AddToInvisWeaponList(AddWeapon);
	}

Begin:

	bEngagingCompleted = false;
	Sleep(2.0 + FRand());
	bEngaging = false;
	bEngagingCompleted = true;
	Disable('Tick');
	OwnerFatnessDelta = 0;
	if (Pawn(Owner) != none)
	{
		Owner.Fatness = Owner.default.Fatness;
		if (Owner.Texture == none || Owner.Texture.Name != 'Invis')
			Owner.Texture = Texture'CloakTexture';
		Owner.bMeshEnviroMap = true;
		Owner.ScaleGlow = 0.75;

		if (Pawn(Owner).Weapon != none)
		{
			AddWeaponToList(Pawn(Owner).Weapon);
			Pawn(Owner).Weapon.ScaleGlow = 0.75;
		}

		Sleep(0.5);
		Enable('Tick');
	}
}

function CloakOwner()
{
	local Pawn OwnerPawn;
	local float JumpZ;

	OwnerPawn = Pawn(Owner);
	if (OwnerPawn == none || OwnerPawn.bDeleteMe)
		return;

	OwnerPawn.Style = STY_Translucent;

	// Invisible to bots/scriptedpawns
	if (Level.Game.IsA('CloakMatch'))
		Pawn(Owner).Visibility = Min(100, Pawn(Owner).Visibility);
	else
		Pawn(Owner).Visibility = 0;

	if (OwnerPawn.AirControl < AirControlAdjustment)
		OwnerPawn.AirControl = AirControlAdjustment;

	JumpZ = OwnerPawn.default.JumpZ * JumpZAdjustment;
	if (OwnerPawn.JumpZ < JumpZ)
		OwnerPawn.JumpZ = JumpZ;
}

function UpdateOwnerWeapon(Weapon Weap)
{
	if (Weap == none)
		return;
	if (Weap != LastWeapon ||
		Weap.Style != STY_Translucent ||
		!Weap.bMeshEnviroMap ||
		Weap.Texture == Weap.default.Texture)
	{
		CloakOwnerWeapon(Weap);
	}
	Weap.ScaleGlow = Owner.ScaleGlow;
}

function CloakOwnerWeapon(Weapon Weap)
{
	if (Weap == none)
		return;
	Weap.Style = STY_Translucent;
	Weap.bMeshEnviroMap = true;
	Weap.Texture = Texture'CloakTexture';
	Weap.ScaleGlow = 0.12;
	AddToInvisWeaponList(Weap);
	LastWeapon = Weap;
}

function AddToInvisWeaponList(Weapon Weap)
{
	local int i;

	for (i = 0; i < ArrayCounter; ++i)
		if (InvisWeaponList[i] == Weap)
			return;

	for (i = 0; i < ArrayCounter; ++i)
		if (InvisWeaponList[i] == none)
		{
			InvisWeaponList[i] = Weap;
			return;
		}

	if (ArrayCounter < ArrayCount(InvisWeaponList))
		InvisWeaponList[ArrayCounter++] = Weap;
}

function UpdateWeapons()
{
	local int i;

	if (Pawn(Owner) == none)
		return;

	UpdateOwnerWeapon(Pawn(Owner).Weapon);
	UpdateOwnerWeapon(Pawn(Owner).PendingWeapon);

	for (i = 0; i < ArrayCounter; ++i)
		if (InvisWeaponList[i] != none &&
			InvisWeaponList[i] != Pawn(Owner).Weapon &&
			InvisWeaponList[i] != Pawn(Owner).PendingWeapon)
		{
			RestoreWeaponVisibility(InvisWeaponList[i]);
		}
}

function RestoreVis()
{
	local Pawn OwnerPawn;

	OwnerPawn = Pawn(Owner);
	if (OwnerPawn == none)
		return;

	OwnerPawn.AirControl = OwnerPawn.default.AirControl;
	OwnerPawn.JumpZ = OwnerPawn.default.JumpZ * Level.Game.PlayerJumpZScaling();
	OwnerPawn.bCountJumps = false; // signal for JumpBoots to adjust JumpZ

	OwnerPawn.ScaleGlow = OwnerPawn.default.ScaleGlow;
	OwnerPawn.Fatness = OwnerPawn.default.Fatness;
	if (Owner.Texture == none || Owner.Texture.Name != 'Invis')
	{
		OwnerPawn.Style = OwnerPawn.default.Style;
		OwnerPawn.bMeshEnviroMap = OwnerPawn.default.bMeshEnviroMap;
		OwnerPawn.Visibility = OwnerPawn.default.Visibility;
	}
	if (OwnerPawn.Texture == Texture'CloakTexture')
		OwnerPawn.Texture = OwnerPawn.default.Texture;
}

function bool UseSpecialEffectsActor()
{
	return Class == class'Cloak';
}

function EnableInventoryEffects()
{
	if (!UseSpecialEffectsActor())
		EffectsActor = Owner;
	else if (EffectsActor == none)
	{
		EffectsActor = Spawn(class'Triggers', Owner, 'Cloak_EffectsActor', Owner.Location);
		if (EffectsActor != none)
		{
			EffectsActor.SetCollision(false);
			EffectsActor.SetPhysics(PHYS_Trailer);
			EffectsActor.RemoteRole = ROLE_SimulatedProxy;
		}
		else
			EffectsActor = Owner;
	}

	EffectsActor.AmbientSound = sound'CloakLoop3';
	EffectsActor.SoundRadius = 500;
	EffectsActor.SoundVolume = 250;
}

function DisableInventoryEffects()
{
	if (Owner != none && (!UseSpecialEffectsActor() || EffectsActor == Owner))
	{
		Owner.AmbientSound = none;
		Owner.SoundRadius = Owner.default.SoundRadius;
		Owner.SoundVolume = Owner.default.SoundVolume;
	}
	if (EffectsActor != none && EffectsActor != Owner)
		EffectsActor.Destroy();
	EffectsActor = none;
}

static function RestoreWeaponVisibility(out Weapon Weap)
{
	if (Weap == none || Weap.bDeleteMe)
		return;
	Weap.Texture = Weap.default.Texture;
	Weap.ScaleGlow = Weap.default.ScaleGlow;
	Weap.bMeshEnviroMap = Weap.default.bMeshEnviroMap;
	Weap.Style = Weap.default.Style;
	Weap = none;
}

function WeaponRestore()
{
	local int i;

	for (i = 0; i < ArrayCounter; ++i)
		RestoreWeaponVisibility(InvisWeaponList[i]);
	ArrayCounter = 0;
}

// Important! This makes sure that the weapon list and player are both restored when the Cloak item is destroyed.
// It's destroyed when a player dies (natural to Unreal pickup inv items) or when it's expired.

event Destroyed()
{
	DisableInventoryEffects();
	RestoreVis();
	WeaponRestore();
	Super.Destroyed();
}

// ================================================================================================
// Deactivated State
// ================================================================================================

state Deactivated
{
	function BeginState()
	{
		Enable('Tick');
		bEngaging = true;
		SetTimer(0.5, true);
	}
	function Timer()
	{
		CountDown++;

		if (CountDown >= 10)
		{
			RestoreVis();
			WeaponRestore();
			DisableInventoryEffects();
			if (Owner != none)
				Owner.PlaySound(sound'CloakOff');
			Disable('Tick');
			SetTimer(0, false);
		}
		else
			bEngaging = true;
	}
	function Tick(float DeltaTime)
	{
		local Pawn OwnerPawn;

		if (bEngaging && Pawn(Owner) != none)
		{
			OwnerPawn = Pawn(Owner);
			CloakOwner();

			// Keep the weapon's scaleglow at the same level the players' is..
			OwnerPawn.Weapon.ScaleGlow = OwnerPawn.ScaleGlow;
			OwnerPawn.Fatness = Rand(254);

			if (FRand() < 0.5)
			{
				OwnerPawn.bMeshEnviroMap = true;
				if (OwnerPawn.Texture == none || OwnerPawn.Texture.Name != 'Invis')
					OwnerPawn.Texture = Texture'CloakTexture';
				OwnerPawn.ScaleGlow = 0.12;
			}
			else
			{
				OwnerPawn.Fatness = OwnerPawn.default.Fatness;
				if (OwnerPawn.Texture == none || OwnerPawn.Texture.Name != 'Invis')
				{
					OwnerPawn.bMeshEnviroMap = OwnerPawn.default.bMeshEnviroMap;
					OwnerPawn.Texture = OwnerPawn.default.Texture;
				}
				OwnerPawn.ScaleGlow = 0.95;
			}

			UpdateWeapons();
		}
	}
}

// ================================================================================================
// Idle2 State
// ================================================================================================

// If a bot owns this, this stuff executes to determine when it activates the item
state Idle2
{
	function BeginState()
	{
		if (Pawn(Owner) != none && Owner.IsA('Bots'))
			SetTimer(1 + FRand(), True);
	}

	// Scan the Radius every 1 + FRand() seconds for any other targets, if any are found, activate the item.
	function Timer()
	{
		local Pawn P;

		if (Pawn(Owner) == none)
		{
			SetTimer(0, false);
			return;
		}
		// Radius could use tweaking
		foreach Owner.RadiusActors(class'Pawn', P, 10000)
		{
			if (P != Owner && P.Visibility > 0)
			{
				GotoState('Activated');
				return;
			}
		}
	}
}

//=============================================================================
// Sleeping state: Sitting hidden waiting to respawn.

state Sleeping
{
	ignores Touch;

	function BeginState()
	{
		BecomePickup();
		LightType = LT_None;
		bUnlit = false;
		bHidden = true;
	}

	function EndState()
	{
		local Pawn P;

		LightType = default.LightType;
		bUnlit = true;

		bSleepTouch = false;
		foreach TouchingActors(class'Pawn', P)
		{
			bSleepTouch = true;
			break;
		}
	}
Begin:
	Sleep(ReSpawnTime);
	PlaySound(RespawnSound);
	Level.Game.PlaySpawnEffect(self);
	Sleep(0.3);
	GoToState('Pickup');
}

defaultproperties
{
	JumpZAdjustment=3.000000
	AirControlAdjustment=6.000000
	bCanActivate=True
	ExpireMessage="disengaged."
	bActivatable=True
	bDisplayableInv=True
	bAmbientGlow=False
	PickupMessage="You got the Cloaking Device."
	ItemName="Cloaking Device"
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'UPak.pyramid'
	Charge=100
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UPak.Icons.I_Cloak'
	M_Activated=" engaged"
	M_Deactivated=" disengaged"
	Mesh=LodMesh'UPak.pyramid'
	SoundRadius=64
	SoundVolume=96
	CollisionRadius=19.799999
	CollisionHeight=13.700000
	LightRadius=4
	LightPeriod=5
	LightPhase=5
	LightCone=8
}
