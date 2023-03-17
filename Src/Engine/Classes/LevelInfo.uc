//=============================================================================
// LevelInfo contains information about the current level. There should
// be one per level and it should be actor 0. UnrealEd creates each level's
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	Native
	NativeReplication
	NoUserCreate;

// Textures.
#exec Texture Import File=Textures\DefaultTexture.pcx
#exec Texture Import File=Textures\WhiteTexture.pcx Mips=Off
#exec Texture Import File=Textures\S_Lightgrey.pcx  Name=S_Lightgrey Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var noedsave float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.

// 227j timers:
var noedsave const float RealTimeSeconds; // Actual unscaled time passage.
var noedsave const float NetTimeSeconds; // Network synced (between server and client) TimeSeconds, only while bNetworkTimeSeconds is true.
var const transient float LastDeltaTime,LastRealDeltaTime; // Previous frame DeltaTime and unscaled DeltaTime.
var noedsave const float LastActivityTime; // Most recent TimeSeconds level had some player or projectile activity (for checking when this sub-level should go stasis).

//-----------------------------------------------------------------------------
// Text info about level.

var() localized string Title;			// Title of the level.
var()           string Author;		    // Who built it.
var() localized string IdealPlayerCount;// Ideal number of players for this level. I.E.: 6-8
var() int	RecommendedEnemies;			// number of enemy bots recommended (used by rated games, UT).
var() int	RecommendedTeammates;		// number of friendly bots recommended (used by rated games, UT).
var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             string Pauser;          // If paused, name of person pausing the game.
var levelsummary Summary;
var           string VisibleGroups;		    // List of the group names which were checked when the level was last saved
var           string LockedGroups;		    // List of the group names which were locked when the level was last saved

//-----------------------------------------------------------------------------
// Flags affecting the level.

var() bool			bLonePlayer;			// No multiplayer coordination, i.e. for entranceways.
var noedsave bool	bBegunPlay;				// Whether gameplay has begun.
var bool			bPlayersOnly;			// Only update players.
var bool			bHighDetailMode;		// Client high-detail mode.
var transient bool	bDropDetail;			// frame rate is below DesiredFrameRate, so drop high detail actors
var transient bool	bAggressiveLOD;			// frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool			bStartup;				// Starting gameplay.
var() bool			bHumansOnly;			// Only allow "human" player pawns in this level
var bool			bNoCheating;
var bool			bAllowFOV;

// 227 flags:
var() bool			bSupportsRealCrouching;	// 227: Support crouching f.e. through tunnels with half player height
var() bool			bSupportsCrouchJump;	// 227j: Enable crouch-jumping like in some other games
var() bool			bEnhancedIcePhysics;	// 227j: Fixes crouch/walking speed on ice.
var() bool			bSpecularLight;			/* 227j: Enables specular lighting effect, which causes meshes to be lit improperly.
											 Unfortunately old maps rely on this often, so need to keep it for these.
											 For proper lighting disable it in new maps. */
var config bool		bDisableSpeclarLight;	// Override and disable specular lighting mode.
var bool			bNetworkTimeSeconds;	// Should network NetTimeSeconds (you should use function EnableNetTimeSeconds to enable this).
var noedsave const editconst bool bMirrorMode; // 227j: Level is running with mirror mode enabled.
var() const bool	bDisableRbPhysics;		// 227j: This level should not enable RigidBody physics at all (level optimization).
var() const bool	bDisableSubLevelRbPhys;	// 227j: All sub-levels of this level shouldn't have RigidBody physics enabled (level optimization).
var bool			bPauseRigidBodies;		// 227j: Pause rigidbodies in this level (same as bPlayersOnly enabled).
var() const bool	bRequireHighChannels;	// 227j: This level requires quadruple the network channels count.
var() bool			bShouldStasisLevel;		// 227j: Level should stop ticking if no more player activity left in the level.
var() bool			bShouldChangeMusicTrack;// 227j: This sub-level should change player music track upon entry?

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) music  Song;          // Default song for level.
var(Audio) byte   SongSection;   // Default song order for level.
var(Audio) byte   SongVolume;	 // 227k: Default song volume modifier for the level.
var(Audio) byte   CdTrack;       // Default CD track for level.
var(Audio) float  PlayerDoppler; // Player doppler shift, 0=none, 1=full.
var music		backup_Song;
var byte		backup_SongSection;

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;
var() texture Screenshot;
var texture DefaultTexture;
var texture WhiteTexture;
var Texture TemplateLightTex; // Editor light preview icon.
var noedsave int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching,
	LEVACT_SaveScreenshot
} LevelAction;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string EngineSubVersion; // Engine SubVersion.
var string MinNetVersion; // Min engine version that is net compatible.

//-----------------------------------------------------------------------------
// Gameplay rules

var() class<gameinfo> DefaultGameType; // Default game mode of this level (if none specified in-game on URL).
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var NavigationPoint NavigationPointList;
var const Pawn PawnList;

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Actor Performance Management

var transient int AIProfile[8]; // TEMP statistics
var transient float AvgAITime;	//moving average of Actor time

//-----------------------------------------------------------------------------
// Physics control

var() bool bCheckWalkSurfaces; // Enable texture-specific physics code for Pawns.
var() bool bUTZoneVelocity; // 227j: If disabled, ZoneVelocity works as an accelerator while PHYS_Falling (old pre-UT behaviour).

//-----------------------------------------------------------------------------
// 227 variables:
var SpawnNotify SpawnNotify; // Spawn notification list

var() class<FootStepManager> FootprintManager;		// 227: Current footstep effect manager.
var() class<RealCrouchInfo> RealCrouchInfoClass;	// 227j: Is used to initialize PlayerPawn's RealCrouchInfo when bSupportsRealCrouching is true

var float DemoTimeDilation; // Time dilation of demo playback.

// Used by "ObjectPool" functions
var transient array<Object> ObjList;

// All Objects that should be notified of when actors get destroyed to cleanup references to them (to avoid memory corruptions).
// By default, player console is added to this array.
var transient array<Object> CleanupDestroyedNotify;

var const int		 EdBuildOpt;	  // Editor only, last used build options!

struct export EdViewportInfo
{
	var vector CameraLocation;	// Editor viewport locations.
	var rotator CameraRotation;	// Editor viewport rotations.
	var float OrthoZoom;		// Zoom level.
};
var EdViewportInfo EdViewports[4]; // Editor viewports.

var DynamicZoneInfo DynamicZonesList; // Defines a list of map dynamic zones.
var transient PlayerPawn ReplicationTarget; // Currently pending network replication target player (can be accessed inside replication blocks).
var ETravelType ServerTravelType; // Pending ServerTravel mode.

// Sub-Levels support.
var const editconst LevelInfo	ChildLevel, // Next sub-level
								ParentLevel; // If we are a sub-level, then ParentLevel is set to the top level.

var() private array<name> SubLevels;		// 227j: List of sub-levels attached to this level (level name i.e: 'NyLeve').

var const transient bool bIsDemoPlayback;	// We are currently playing in demo recording.
var const transient bool bIsDemoRecording;	// We are currently recording a demo.
var transient bool bPauseDemo;				// Should pause demo playback.
var bool bPlayerSpawnTrigger;				// Triggers overlapping player on spawn should instantly fire.

// Pathbuilder - these settings are for advanced pathing or usage of UED2.1 for other UEngineGames. Changing these settings can cause extremely weird behavior, Don't mess with it if you don't know what you are doing.
var(PathBuilder) int MaxCommonRadius;	// 227j: max radius to consider in building paths, default 70
var(PathBuilder) int MaxCommonHeight;	// 227j: max typical height for non-human intelligent creatures, default 70
var(PathBuilder) int MinCommonHeight;	// 227j: min typical height for non-human intelligent creatures, default 40
var(PathBuilder) int MinCommonRadius;	// 227j: min typical radius for non-human intelligent creatures, default 24
var(PathBuilder) int CommonRadius;		// 227j: max typical radius of intelligent creatures, default 52
var(PathBuilder) int HumanRadius;		// 227j: normal player pawn radius, default 18
var(PathBuilder) int HumanHeight;		// 227j: normal playerpawn height, default 39

var() byte MaxPortalDepth;				// 227j: Maximum portal render depth (higher values will affect performance and may even crash with stack overflow).

/* Example values

-- DeusEx:
MAXCOMMONRADIUS 115
MAXCOMMONHEIGHT 79
MINCOMMONRADIUS 12
COMMONRADIUS    52
HUMANRADIUS     22
HUMANHEIGHT     51

-- RUNE
MAXCOMMONRADIUS 70
MAXCOMMONHEIGHT 70
MINCOMMONHEIGHT 50
MINCOMMONRADIUS 50
COMMONRADIUS    50
HUMANRADIUS     43
HUMANHEIGHT     20

-- Disneys BearBrothers
MAXCOMMONRADIUS 18
MAXCOMMONHEIGHT 20
MINCOMMONHEIGHT 39
MINCOMMONRADIUS 18
COMMONRADIUS    18
HUMANRADIUS     18
HUMANHEIGHT     39

-- KHG
MAXCOMMONRADIUS 70
MAXCOMMONHEIGHT 70
MINCOMMONHEIGHT 48
MINCOMMONRADIUS 24
COMMONRADIUS    52
HUMANRADIUS     18
HUMANHEIGHT     39

-- NERF!
MAXCOMMONRADIUS 50
MAXCOMMONHEIGHT 60
MINCOMMONHEIGHT 48
MINCOMMONRADIUS 35
COMMONRADIUS    40
HUMANRADIUS     35
HUMANHEIGHT     52

-- DS9:TF
MAXCOMMONRADIUS 40
MAXCOMMONHEIGHT 80
MINCOMMONHEIGHT 14
MINCOMMONRADIUS 14
COMMONRADIUS    22
HUMANRADIUS     22
HUMANHEIGHT     52

-- Undying.
MAXCOMMONRADIUS 150
MAXCOMMONHEIGHT 150
MINCOMMONHEIGHT 70
MINCOMMONRADIUS 30
COMMONRADIUS    52
HUMANRADIUS     18
HUMANHEIGHT     65

-- WOT
MAXCOMMONRADIUS 30
MAXCOMMONHEIGHT 61
MINCOMMONHEIGHT 61
MINCOMMONRADIUS 30
COMMONRADIUS    30
HUMANRADIUS     17
HUMANHEIGHT     46
*/

var private transient float ReplicatedTimeSeconds; // Using as final replicated variable to prevent desync with pre-227 clients!

//-----------------------------------------------------------------------------
// Functions.

//
// Return the URL of this level on the local machine.
//
native function string GetLocalURL();

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native function string GetAddressURL();

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	local GameRules G;

	if( ParentLevel!=None && ParentLevel!=Self )
	{
		ParentLevel.ServerTravel(URL,bItems);
		return;
	}
	if ( Len(NextURL)==0 )
	{
		if ( Game!=None && Game.GameRules!=None )
		{
			for ( G=Game.GameRules; G!=None; G=G.NextRules )
				if ( G.bHandleMapEvents && !G.AllowServerTravel(URL,bItems) )
					return;
		}
		bNextItems          = bItems;
		NextURL             = URL;
		if ( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else NextSwitchCountdown = 0;
	}
}

//-----------------------------------------------------------------------------
// New U227 functions.

// Kick out a net connection from the server.
// Returns True if it successfully kicked the client.
native(666) final function bool KickConnection( NetConnection Other, optional string Reason /*="Kicked"*/ );

/* Very Fast:
Return the connection state of given connection (look at connection states below for results information). */
static native(1703) final function byte GetConState( NetConnection Other );

// State of a connection.
const noexport USOC_Invalid	= 0; // Connection is invalid, possibly uninitialized.
const noexport USOC_Closed	= 1; // Connection permanently closed.
const noexport USOC_Pending	= 2; // Connection is awaiting connection.
const noexport USOC_Open	= 3; // Connection is open.

/* Very fast:
Return the dotted IP-address aswell as port of given connection */
static native(1704) final function string GetConIP( NetConnection Other, out int Port );

/* Very fast:
Return the options connecting client has desired (Index?Name=Blabla?Class=Blabla etc..) */
static native(1705) final function string GetConOpts( NetConnection Other );

/* Very fast:
Return True if current game has some downloaders */
native(1706) final function bool HasDownloaders();

/* Very fast:
Iterate through all connected clients on the server */
native(1707) final iterator function AllConnections( out NetConnection Connect );

/* Very fast:
Iterate through all downloaders in the current game and return their progress */
native(1708) final iterator function AllDownloaders( optional out NetConnection Connect, optional out string File, optional out int Sent, optional out int TotalSz );

/* Very fast:
Return the point region (zone, iLeaf..) of a desired location */
native(1709) final function PointRegion GetLocZone( vector Pos, optional Actor InActor );

/* Very fast:
Find a free object from the list, will allocate a new object and return that if not found. (Read more: http://wiki.beyondunreal.com/Legacy:Object_Pool). */
native(1710) final function coerce Object AllocateObj( Class ObjClass );

/* Very fast:
Free an Object back into object list (after its been used). */
native(1711) final function FreeObject( Object Obj );

/* Very fast:
Return the client's Ident and Identity corresponding to the given connection */
static native(1743) final function GetConIdentity( NetConnection Other, out string Ident, out string Identity );

// UnrealEd only, grab currently selected resource.
// Supports: Level, LevelInfo, Brush, Sound, Music, Class, Texture, Mesh
static native final function Object GetSelectedObject( Class ObjType );

// If this is a sub-level force to wake up from stasis (by updating LastActivityTime to most recent TimeSeconds).
native final function WakeUpLevel();

// Return true if this level has RigidBodies enabled (either bDisableRbPhysics true, or no physics engine set).
native final function bool RigidBodiesEnabled();

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if ( Role==ROLE_Authority )
		Pauser, TimeDilation, bNoCheating, bAllowFOV;
		
	unreliable if ( Role==ROLE_Authority && bNetworkTimeSeconds )
		ReplicatedTimeSeconds;
}

function BeginPlay()
{
	// Make a backup of these for resetting.
	backup_Song = Song;
	backup_SongSection = SongSection;
}
// Reset the level
function Reset()
{
	Song = backup_Song;
	SongSection = backup_SongSection;
}

final function EnableNetTimeSeconds()
{
	bNetworkTimeSeconds = true;
	bOnlyDirtyReplication = false;
	NetUpdateFrequency = 10.f;
}

simulated final function string TitleOrName()
{
	if (Len(Title) == 0 || Title == default.Title)
		return string(Outer.Name);
	return Title;
}

simulated final function string LocalDateAndTime()
{
	return Year $ "-" $ IntToStr(Month, 2) $ "-" $ IntToStr(Day, 2) @ IntToStr(Hour, 2) $ ":" $ IntToStr(Minute, 2) $ ":" $ IntToStr(Second, 2);
}

// Get current viewport client playerpawn actor, returns none if none found (dedicated server).
static invariant native final function PlayerPawn GetLocalPlayerPawn();

// Get the current active level.
static native final function LevelInfo GetLevelInfo();

// Find a level by matching sub-level name.
native final function LevelInfo FindLevel( name LevelID );

// Called client-side when player is connecting but haven't received a playerpawn actor yet.
simulated event PlayerPawn SpawnClientCamera()
{
	local NavigationPoint N,Best;
	local float Score,BestScore;
	
	// Pick a spawnpoint, give priority to enabled playerstarts!
	foreach AllActors(class'NavigationPoint',N)
	{
		Score = FRand();
		if( PlayerStart(N) )
		{
			Score+=2.f;
			if( PlayerStart(N).bEnabled )
				Score+=5.f;
			if( PlayerStart(N).bCoopStart )
				Score+=1.f;
		}
		if( !N.Region.Zone.bWaterZone )
			Score+=0.5f;
		
		if( !Best || Score>BestScore )
		{
			Best = N;
			BestScore = Score;
		}
	}
	if( !Best )
		return None;
	
	return Best.Spawn(class'ClientSpectator',,,,,,,true);
}

defaultproperties
{
	TimeDilation=1.000000
	Title="Untitled"
	Author="Anonymous"
	VisibleGroups="None"
	bHighDetailMode=True
	CdTrack=255
	SongVolume=255
	Brightness=1.000000
	DefaultTexture=Texture'DefaultTexture'
	WhiteTexture=Texture'WhiteTexture'
	TemplateLightTex=Texture'S_Lightgrey'
	bHiddenEd=True
	bWorldGeometry=True
	FootprintManager=Class'FootStepManager'
	EdBuildOpt=149007
	MaxCommonRadius=70
	MaxCommonHeight=70
	MinCommonHeight=40
	MinCommonRadius=24
	CommonRadius=52
	HumanRadius=18
	HumanHeight=39
	bShouldStasisLevel=true
	bShouldChangeMusicTrack=true
	DemoTimeDilation=1
	ServerTravelType=TRAVEL_Relative
	MaxPortalDepth=3
	bPlayerSpawnTrigger=true
}