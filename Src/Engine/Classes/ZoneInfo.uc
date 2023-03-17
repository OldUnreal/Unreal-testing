//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native
		NativeReplication;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Zone properties.

var() name   ZoneTag;
var() name   SkyZoneInfoTag; // 227j: Link skybox to specific skyzoneinfo.
var() name   SkyZoneInfoLevelID; // 227j: Target SubLevelID to use skyzoneinfo from.
var() float  MinWalkableZ; // 227j: Minimum floor Z-normal that pawn is allowed to 'walk' on.
var() vector ZoneGravity;
var() vector ZoneVelocity;
var() float  ZoneGroundFriction;
var() float  ZoneFluidFriction;
var() float	 ZoneTerminalVelocity;
var() name   ZonePlayerEvent;
var   int    ZonePlayerCount;
var() float  ZoneTimeDilation; // Local zone time-dilation.
var   int	 NumCarcasses;
var() int	 DamagePerSec;
var() name	 DamageType;
var() localized string DamageString;
var(LocationStrings) localized string ZoneName;
var(LocationStrings) localized string LocationStrings[4];
var LocationID LocationID;
var() int	 MaxCarcasses;
var() sound  EntrySound;	//only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var noedsave skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.

//-----------------------------------------------------------------------------
// Zone flags.

var()		bool   bWaterZone;   // Zone is water-filled.
var() const bool   bFogZone;     // Zone is fog-filled.
var const	bool   bKillZone;    // Zone instantly kills those who enter (unused).
var()		bool   bNeutralZone; // Players can't take damage in this zone.
var			bool   bGravityZone; // Use ZoneGravity (unused).
var()		bool   bPainZone;	 // Zone causes pain.
var()		bool   bDestructive; // Destroys carcasses.
var()		bool   bNoInventory; // Kill all inventory pickups entering this zone.
var()		bool   bMoveProjectiles; // this velocity zone should impart velocity to projectiles and effects

// Reverb:
var(Reverb) bool bReverbZone;
var(Reverb) bool bRaytraceReverb;

// Network:
var bool bRepZoneProperties; // Should replicate zoneinfo properties.

var(DistanceFog) bool bDistanceFogClips; // If enabled, the distance fog will clip rendering beyond distance.
var(DistanceFog) bool bDistanceFog; // Fog is distance fog.
var(DistanceFog) bool bZoneBasedFog; // If enabled, the distance fog will only render inside this zone and not entire map.
var(DistanceFog) float FogDistanceStart; // Starting distance, MUST BE LOWER THAN FogDistance!
var(DistanceFog) color FogColor;
var(DistanceFog) float FogDistance; // End distance of the fog. Although not needed for exponential fog, mappers still may want to use it to adjust max line of sight and clipping. !Needed for bDistanceFogClips and DynamicCoronas!
var(DistanceFog) float FadeTime;    // Timespan in which the fog fades in or over
var(DistanceFog) float FogDensity;	// FogDensity. For exponential fog. Use low values, like 0.0005
var(DistanceFog) int FogMode;		// 0 = Linear, 1 = Exponential, 2 = Exponential Squared, DistanceFog fog does NOT work with SoftDrv or other older renderers like Glide or D3D.

//-----------------------------------------------------------------------------
// Zone light.

var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;
var(Environment) texture EnvironmentMap; // Environment texture for surfaces flagged as 'Environment'
var(Environment) float EnvironmentUScale,EnvironmentVScale; // U/V scale of the environment mapping texture
var(Environment) vector EnvironmentColor; // Color of the environment map overlay (0-1).
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;
var(ZoneLight) vector ViewFlash, ViewFog;
var(ZoneLight) float DirtyShadowLevel; //Threshold for DirtyShadows Surface flag.
var(ZoneLight) byte LightMapDetailLevels[4];
var(ZoneLight) float LightSharpnessFactor; // 227j: Make lighting more sharp vs gouraud surfaces.
var(ZoneLight) float LightNormalMinAng; // 227j: Minimum dot product factor to allow light source to be considered on mesh face.

//-----------------------------------------------------------------------------
// Reverb.

// Settings.
var(Reverb) float SpeedOfSound;
var(Reverb) byte MasterGain;
var(Reverb) int  CutoffHz;
var(Reverb) byte Delay[6];
var(Reverb) byte Gain[6];

// 227 Ambients
var(EFX) enum EAmbients
{
	REVERB_PRESET_GENERIC,
	REVERB_PRESET_PADDEDCELL,
	REVERB_PRESET_ROOM,
	REVERB_PRESET_BATHROOM,
	REVERB_PRESET_LIVINGROOM,
	REVERB_PRESET_STONEROOM,
	REVERB_PRESET_AUDITORIUM,
	REVERB_PRESET_CONCERTHALL,
	REVERB_PRESET_CAVE,
	REVERB_PRESET_ARENA,
	REVERB_PRESET_HANGAR,
	REVERB_PRESET_CARPETTEDHALLWAY,
	REVERB_PRESET_HALLWAY,
	REVERB_PRESET_STONECORRIDOR,
	REVERB_PRESET_ALLEY,
	REVERB_PRESET_FOREST,
	REVERB_PRESET_CITY,
	REVERB_PRESET_MOUNTAINS,
	REVERB_PRESET_QUARRY,
	REVERB_PRESET_PLAIN,
	REVERB_PRESET_PARKINGLOT,
	REVERB_PRESET_SEWERPIPE,
	REVERB_PRESET_UNDERWATER,
	REVERB_PRESET_DRUGGED,
	REVERB_PRESET_DIZZY,
	REVERB_PRESET_PSYCHOTIC,
	REVERB_PRESET_CASTLE_SMALLROOM,
	REVERB_PRESET_CASTLE_SHORTPASSAGE,
	REVERB_PRESET_CASTLE_MEDIUMROOM,
	REVERB_PRESET_CASTLE_LONGPASSAGE,
	REVERB_PRESET_CASTLE_LARGEROOM,
	REVERB_PRESET_CASTLE_HALL,
	REVERB_PRESET_CASTLE_CUPBOARD,
	REVERB_PRESET_CASTLE_COURTYARD,
	REVERB_PRESET_CASTLE_ALCOVE,
	REVERB_PRESET_FACTORY_ALCOVE,
	REVERB_PRESET_FACTORY_SHORTPASSAGE,
	REVERB_PRESET_FACTORY_MEDIUMROOM,
	REVERB_PRESET_FACTORY_LONGPASSAGE,
	REVERB_PRESET_FACTORY_LARGEROOM,
	REVERB_PRESET_FACTORY_HALL,
	REVERB_PRESET_FACTORY_CUPBOARD,
	REVERB_PRESET_FACTORY_COURTYARD,
	REVERB_PRESET_FACTORY_SMALLROOM,
	REVERB_PRESET_ICEPALACE_ALCOVE,
	REVERB_PRESET_ICEPALACE_SHORTPASSAGE,
	REVERB_PRESET_ICEPALACE_MEDIUMROOM,
	REVERB_PRESET_ICEPALACE_LONGPASSAGE,
	REVERB_PRESET_ICEPALACE_LARGEROOM,
	REVERB_PRESET_ICEPALACE_HALL,
	REVERB_PRESET_ICEPALACE_CUPBOARD,
	REVERB_PRESET_ICEPALACE_COURTYARD,
	REVERB_PRESET_ICEPALACE_SMALLROOM,
	REVERB_PRESET_SPACESTATION_ALCOVE,
	REVERB_PRESET_SPACESTATION_MEDIUMROOM,
	REVERB_PRESET_SPACESTATION_SHORTPASSAGE,
	REVERB_PRESET_SPACESTATION_LONGPASSAGE,
	REVERB_PRESET_SPACESTATION_LARGEROOM,
	REVERB_PRESET_SPACESTATION_HALL,
	REVERB_PRESET_SPACESTATION_CUPBOARD,
	REVERB_PRESET_SPACESTATION_SMALLROOM,
	REVERB_PRESET_WOODEN_ALCOVE,
	REVERB_PRESET_WOODEN_SHORTPASSAGE,
	REVERB_PRESET_WOODEN_MEDIUMROOM,
	REVERB_PRESET_WOODEN_LONGPASSAGE,
	REVERB_PRESET_WOODEN_LARGEROOM,
	REVERB_PRESET_WOODEN_HALL,
	REVERB_PRESET_WOODEN_CUPBOARD,
	REVERB_PRESET_WOODEN_SMALLROOM,
	REVERB_PRESET_WOODEN_COURTYARD,
	REVERB_PRESET_SPORT_EMPTYSTADIUM,
	REVERB_PRESET_SPORT_SQUASHCOURT,
	REVERB_PRESET_SPORT_SMALLSWIMMINGPOOL,
	REVERB_PRESET_SPORT_LARGESWIMMINGPOOL,
	REVERB_PRESET_SPORT_GYMNASIUM,
	REVERB_PRESET_SPORT_FULLSTADIUM,
	REVERB_PRESET_SPORT_STADIUMTANNOY,
	REVERB_PRESET_PREFAB_WORKSHOP,
	REVERB_PRESET_PREFAB_SCHOOLROOM,
	REVERB_PRESET_PREFAB_PRACTISEROOM,
	REVERB_PRESET_PREFAB_OUTHOUSE,
	REVERB_PRESET_PREFAB_CARAVAN,
	REVERB_PRESET_DOME_TOMB,
	REVERB_PRESET_PIPE_SMALL,
	REVERB_PRESET_DOME_SAINTPAULS,
	REVERB_PRESET_PIPE_LONGTHIN,
	REVERB_PRESET_PIPE_LARGE,
	REVERB_PRESET_PIPE_RESONANT,
	REVERB_PRESET_OUTDOORS_BACKYARD,
	REVERB_PRESET_OUTDOORS_ROLLINGPLAINS,
	REVERB_PRESET_OUTDOORS_DEEPCANYON,
	REVERB_PRESET_OUTDOORS_CREEK,
	REVERB_PRESET_OUTDOORS_VALLEY,
	REVERB_PRESET_MOOD_HEAVEN,
	REVERB_PRESET_MOOD_HELL,
	REVERB_PRESET_MOOD_MEMORY,
	REVERB_PRESET_DRIVING_COMMENTATOR,
	REVERB_PRESET_DRIVING_PITGARAGE,
	REVERB_PRESET_DRIVING_INCAR_RACER,
	REVERB_PRESET_DRIVING_INCAR_SPORTS,
	REVERB_PRESET_DRIVING_INCAR_LUXURY,
	REVERB_PRESET_DRIVING_FULLGRANDSTAND,
	REVERB_PRESET_DRIVING_EMPTYGRANDSTAND,
	REVERB_PRESET_DRIVING_TUNNEL,
	REVERB_PRESET_CITY_STREETS,
	REVERB_PRESET_CITY_SUBWAY,
	REVERB_PRESET_CITY_MUSEUM,
	REVERB_PRESET_CITY_LIBRARY,
	REVERB_PRESET_CITY_UNDERPASS,
	REVERB_PRESET_CITY_ABANDONED,
	REVERB_PRESET_DUSTYROOM,
	REVERB_PRESET_CHAPEL,
	REVERB_PRESET_SMALLWATERROOM,
	REVERB_PRESET_UNDERSLIME,
	REVERB_PRESET_NONE,
}EFXAmbients;

//MWP:begin
//-----------------------------------------------------------------------------
// Lens flare.

var(LensFlare) texture LensFlare[12];
var(LensFlare) float LensFlareOffset[12];
var(LensFlare) float LensFlareScale[12];

//-----------------------------------------------------------------------------
// per-Zone mesh LOD lighting control

// the number of lights applied to the actor mesh is interpolated between the following
// properties, as a function of the MeshPolyCount for the previous frame.
var(ZoneLight) byte MinLightCount; // Minimum number of lights to use (at MinLightingPolyCount)
var(ZoneLight) byte MaxLightCount; // Maximum number of lights to use (at MaxLightingPolyCount) NOTE: Max value is 32!
var(ZoneLight) int MinLightingPolyCount; // When total mesh polygon count is equal or lower then this many polies, use MinLightCount
var(ZoneLight) int MaxLightingPolyCount; // When total mesh polygon count is equal or higher then this many polies, use MaxLightCount
// (NOTE: the default LOD properties (below) have no effect on the mesh lighting behavior)
//MWP:end

var() export editinline PortalModifier CameraModifier; // 227j: Modify render within this zone.

//=============================================================================
// Network replication.
var transient VisibilityNotify VisNotify; // 227 List of visibility notifies (for online replication).

replication
{
	reliable if ( Role==ROLE_Authority )
		ZoneGravity, ZoneVelocity, ZoneTerminalVelocity,
		ZoneGroundFriction, ZoneFluidFriction,
		AmbientBrightness, AmbientHue, AmbientSaturation,
		TexUPanSpeed, TexVPanSpeed,
		// ViewFlash, ViewFog, // Not replicated because vectors replicated with elements rounded to integers
		bReverbZone,
		FogColor;
}

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

//MWP:begin -- moved out of PreBeginPlay() to allow overriding
//=============================================================================
// Note: This is even called on Editor, but SkyZone variable is not saved!
simulated event LinkToSkybox()
{
	local SkyZoneInfo TempSkyZone,QualitySkyZone;
	local LevelInfo L;
	
	if( SkyZoneInfoLevelID!='' )
	{
		L = Level.FindLevel(SkyZoneInfoLevelID);
		if( L )
		{
			foreach L.AllActors(class 'SkyZoneInfo', TempSkyZone, SkyZoneInfoTag)
			{
				SkyZone = TempSkyZone;
				if ( TempSkyZone.bHighDetail == Level.bHighDetailMode )
					QualitySkyZone = TempSkyZone;
			}
			if( QualitySkyZone )
				SkyZone = QualitySkyZone;
			else if( L.SkyZone==None && SkyZoneInfoTag!='' )
			{
				foreach L.AllActors( class 'SkyZoneInfo', SkyZone)
					break;
			}
		}
	}

	// SkyZone.
	foreach AllActors(class 'SkyZoneInfo', TempSkyZone, SkyZoneInfoTag)
	{
		SkyZone = TempSkyZone;
		if ( TempSkyZone.bHighDetail == Level.bHighDetailMode )
			QualitySkyZone = TempSkyZone;
	}
	if( QualitySkyZone )
		SkyZone = QualitySkyZone;
	else if( SkyZone==None && SkyZoneInfoTag!='' )
	{
		foreach AllActors( class 'SkyZoneInfo', SkyZone)
			break;
	}
}
//MWP:end

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();
}

function Trigger( actor Other, pawn EventInstigator )
{
	if (DamagePerSec != 0)
		bPainZone = true;
}

// When an actor enters this zone.
event ActorEntered( actor Other )
{
	local vector AddVelocity;

	if ( bNoInventory && (Other.Owner == None) && Other.IsA('Inventory') )
	{
		Other.LifeSpan = 1.5;
		return;
	}

	if ( Other.bIsPawn && Pawn(Other).bIsPlayer )
		if ( ++ZonePlayerCount==1 )
			TriggerEvent(ZonePlayerEvent,Self,Pawn(Other));

	if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
	{
		if ( Other.Physics == PHYS_Projectile )
		{
			AddVelocity = ZoneVelocity;
			AddVelocity.Z *= 0.5;
			Other.Velocity += ZoneVelocity;
		}
		else if ( Other.IsA('Effects') && (Other.Physics == PHYS_None) )
		{
			Other.SetPhysics(PHYS_Projectile);
			AddVelocity = ZoneVelocity;
			AddVelocity.Z *= 0.5;
			Other.Velocity = AddVelocity;
		}
	}
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	if ( Other.bIsPawn && Pawn(Other).bIsPlayer )
		if ( --ZonePlayerCount==0 )
			UnTriggerEvent(ZonePlayerEvent,Self,Pawn(Other));
}

defaultproperties
{
	bMoveProjectiles=True
	bStatic=True
	bNoDelete=True
	bAlwaysRelevant=True
	Texture=S_ZoneInfo
	ZoneGravity=(X=0.000000,Y=0.000000,Z=-950.000000)
	ZoneGroundFriction=+00004.000000
	ZoneFluidFriction=+00001.200000
	ZoneTerminalVelocity=+02500.000000
	MaxCarcasses=2
	AmbientSaturation=255
	FogColor=(R=0,G=0,B=0,A=0)
	TexUPanSpeed=+00001.000000
	TexVPanSpeed=+00001.000000
	SpeedOfSound=+08000.000000
	MasterGain=100
	CutoffHz=6000
	FogDistance=0
	Delay(0)=20
	Delay(1)=34
	Gain(0)=150
	Gain(1)=70
	MinLightCount=8
	MaxLightCount=32
	MinLightingPolyCount=1000
	MaxLightingPolyCount=5000
	ZoneTimeDilation=1
	EnvironmentUScale=1
	EnvironmentVScale=1
	EnvironmentColor=(X=0,Y=0,Z=0)
	DirtyShadowLevel=0.25
	LightMapDetailLevels(0)=4
	LightMapDetailLevels(1)=5
	LightMapDetailLevels(2)=6
	LightMapDetailLevels(3)=7
	EFXAmbients=REVERB_PRESET_NONE
	bRepZoneProperties=true
	FogDensity=0.0
	FogMode=0.0
	MinWalkableZ=0.7
	NetUpdateFrequency=0.25
	bForceDirtyReplication=true
	bOnlyDirtyReplication=true
	LightSharpnessFactor=1
}
