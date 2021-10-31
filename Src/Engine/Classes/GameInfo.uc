//=============================================================================
// GameInfo.
//
// default game info is normal single player
//
//=============================================================================
class GameInfo extends Info
	native;

//-----------------------------------------------------------------------------
// Variables.

var int					ItemGoals, KillGoals, SecretGoals; // Special game goals.
var byte					Difficulty;				// 0=easy, 1=medium, 2=hard, 3=very hard. 227 - Up to 6 for coopmode.

var() globalconfig float		AutoAim;				// How much autoaiming to do (1 = none, 0 = always).
// (cosine of max error to correct)
var() float					GameSpeed;				// Scale applied to game rate.
var   float					StartTime;
var() class<PlayerPawn>			DefaultPlayerClass;
var() class<Weapon>			DefaultWeapon;			// Default weapon given to player at start.
var() globalconfig int			MaxSpectators;			// Maximum number of spectators.
var	int					NumSpectators;			// Current number of spectators.
var() globalconfig int			MaxPlayers;
var   int					NumPlayers;
var   int					CurrentID;

var() private globalconfig string	AdminPassword;			// Password to receive bAdmin privileges.
var() private globalconfig string	GamePassword;			// Password to enter game.

var() class<scoreboard>			ScoreBoardType;			// Type of scoreboard this game uses.
var() class<menu>				GameMenuType;			// Type of oldstyle game options menu to display.
var() string					BotMenuType;			// Type of bot menu to display.
var() string					RulesMenuType;			// Type of rules menu to display.
var() string					SettingsMenuType;			// Type of settings menu to display.
var() string					GameUMenuType;			// Type of Game dropdown to display.
var() string					MultiplayerUMenuType;		// Type of Multiplayer dropdown to display.
var() string					GameOptionsMenuType;		// Type of options dropdown to display.
var() class<hud>				HUDType;				// HUD class this game uses.
var() class<MapList>			MapListType;			// Maplist this game uses.
var() string					MapPrefix;				// Prefix characters for names of maps for this game type.
var() string					BeaconName;				// Identifying string used for finding LAN servers.
var() string					SpecialDamageString, FemSpecialDamageString;
var	int							SentText;

// Mutator (for modifying actors as they enter the game)
var class<Mutator>			MutatorClass;
var Mutator					BaseMutator;

// Default waterzone entry and exit effects
var class<ZoneInfo>			WaterZoneType;

// What state a player should start in for this game type
var name					DefaultPlayerState;

// ReplicationInfo
var() class<GameReplicationInfo>	GameReplicationInfoClass;
var GameReplicationInfo			GameReplicationInfo;

// Server Log
var globalconfig string			ServerLogName;

// Statistics Logging
var StatLog					LocalLog;
var StatLog					WorldLog;
var string					LocalLogFileName;
var string					WorldLogFileName;
var() globalconfig string		LocalBatcherURL;			// Batcher URL.
var() globalconfig string		LocalBatcherParams;		// Batcher command line parameters.
var() globalconfig string		LocalStatsURL;			// URL to local stats information.
var() globalconfig string		WorldBatcherURL;			// Batcher URL.
var() globalconfig string		WorldBatcherParams;		// Batcher command line parameters.
var() globalconfig string		WorldStatsURL;			// URL to world stats information.

var localized string			SwitchLevelMessage;
var localized string			DefaultPlayerName;
var localized string			LeftMessage, FemLeftMessage;
var localized string			FailedSpawnMessage;
var localized string			FailedPlaceMessage;
var localized string			FailedTeamMessage;
var localized string			NameChangedMessage;
var localized string			EnteredMessage, FemEnteredMessage;
var localized string			GameName;
var localized string			MaxedOutMessage;
var localized string			WrongPassword;
var localized string			NeedPassword;

// 227 variables =========================================
var const string				LastPreloginIP;		// Warning!!! Do not touch this variable if you want to keep your mod backwards compatible
var const string				LastLoginPlayerNames;	// Use ConsoleCommand("GetPreloginAddress"); instead
var const string				LastPreloginIdentity;
var const string				LastPreloginIdent;
var const string				LastDisconnectReason; // Most recent client disconnection reason.
var() localized string MaleGender,FemaleGender;  // Gender for deathmessages
var GameRules GameRules;						// Mutate some game rules. Do *not* use this if you want your mod backwards compatible.
var AdminAccessManager AccessManager;
const ColorCodeNumber=27; // Text color code ID when drawing on Canvas.

var int GameMaxChannels;	// Maximum number of actor channels available (only for 227j+ clients).

var() globalconfig string		AccessManagerClass;
var(BloodServer) globalconfig int	BleedingDamageMin;	// minimum bleeding damage
var(BloodServer) globalconfig int	BleedingDamageMax;	// maximum bleeding damage
var(Networking) config int		DesiredMaxChannels;		// Desired max actor channels for this game mode (custom map may override this).
var() config string				InventoryDataIni; // Ini filename of the inventory data if GameEngine.bServerSaveInventory is enabled.

// Bitmask flags =========================================
var() config bool				bNoMonsters;				// Whether monsters are allowed in this play mode.
var() globalconfig bool			bMuteSpectators;			// Whether spectators are allowed to speak.
var() config bool				bHumansOnly;				// Whether non human player models are allowed.
var() bool						bRestartLevel;
var() bool						bPauseable;				// Whether the level is pauseable.
var() config bool				bCoopWeaponMode;			// Whether or not weapons stay when picked up.
var() config bool				bClassicDeathmessages;	// Weapon deathmessages if false.
var   globalconfig bool			bLowGore;					// Whether or not to reduce gore.
var	bool						bCanChangeSkin;			// Allow player to change skins in game.
var() bool						bTeamGame;				// This is a teamgame.
var	globalconfig bool			bVeryLowGore;				// Greatly reduces gore.
var() globalconfig bool			bNoCheating;				// Disallows cheating. Hehe.
var() bool						bDeathMatch;				// This game is some type of deathmatch (where players can respawn during gameplay)
var	bool						bGameEnded;				// set when game ends
var	bool						bOverTime;

var globalconfig bool			bLocalLog;
var globalconfig bool			bLocalLogQuery;
var globalconfig bool			bWorldLog;
var bool						bLoggingGame;	// Does this gametype log?

//------------------------------------------------------------------------------
var(BloodServer) globalconfig bool	bBleedingEnabled;			// Turn on bleeding.
var(BloodServer) globalconfig bool	bBleedingDamageEnabled;		// Turn on damage from bleeding.
var(BloodServer) globalconfig bool	bAllHealthStopsBleeding;	// Stops bleeding from all health pickups.
var(BloodServer) globalconfig bool	bBandagesStopBleeding;		// Stops bleeding from bandages only.
var(Networking)	 globalconfig bool	bMessageAdminsAliases;		// Message all admins about new players and their alias names.
var(Networking)  globalconfig bool	bLogNewPlayerAliases;		// Log on console new player aliases.
var(Networking)  globalconfig bool	bLogDownloadsToClient;		// Message all clients about downloads
var(Networking)  globalconfig bool	bHandleDownloadMessaging;	// Should display any downloader messages at all?
var(Networking)  globalconfig bool	bUseClientReplicationInfo;	// Whether synchronization via ClientReplicationInfo should be preferred to the old synchronization method

// 227 additions.
var() globalconfig bool			bShowRecoilAnimations;			// Players/Bots should play third person recoil animations?
var() globalconfig bool			bCastShadow;					// Shadow implementation
var() globalconfig bool			bDecoShadows;					// Decoration cast shadows
var() globalconfig bool			bCastProjectorShadows;			// Use advanced projector shadows instead of decal shadows. Very CPU intensive.
var() globalconfig bool			bUseRealtimeShadow;				// Use blob shadow or realistic shadow
var() globalconfig bool			bNoWalkInAir;					// Do not allow Pawn physics "walk in air" glitch
var() globalconfig bool			bProjectorDecals;				// Use projectors for weapon decals. Very CPU intensive.
var transient const bool		bIsSavedGame;					// Set to true on saved games.
var() globalconfig bool			bAlwaysEnhancedSightCheck;		// Override for SightCheck. Faster than normal SightCheck. Usually set in Pawn with bEnhancedSightCheck. 
																// Increases difficulty but may cause problems with custom maps, since AI can look through transparent surfaces when set.
var() globalconfig bool			bRestrictMoversRetriggering;	// 227j. Specifies how movers in states TriggerControl and TriggerPound should behave:
																// if True, calling Trigger or UnTrigger on such movers will not cause visible effects
																// unless otherwise KeyNum would be changed.
																// By default, only objects of types Engine.Mover and UnrealShare.AttachMover (but not
																// subclasses thereof) are affected by this setting.
//------------------------------------------------------------------------------
// 227j: Used for storing saved game info.
struct SavedGameInfo
{
	var string MapTitle,Timestamp,ExtraInfo;
	var Texture Screenshot;
};

// 227j: Tell FindPlayerStart which level were about to spawn in.
var transient LevelInfo SpawnLevel;

// 227h color code functions:
static invariant native final function StripColorCodes( out string S ); // Strip color codes from a string
static invariant native final function string MakeColorCode( color Color ); // Make a color code string

// Grab a list of saved games!
native(1700) static final iterator function AllSavedGames( out SavedGameInfo Save, out int Index );

// Grab saved game details for UI.
event GetSaveDetails( out SavedGameInfo Info, int Index )
{
	Info.MapTitle = Level.TitleOrName();
	Info.Timestamp = string(Level.Year)$"-"$string(Level.Month)$"-"$string(Level.Day)@string(Level.Hour)$":"$((Level.Minute<10) ? ("0"$string(Level.Minute)) : string(Level.Minute));
}

// Enable clients to run function hooks (see Core/ScriptHook)
// Will instantly network this change to all clients currently connected to server.
native final function SetHooksEnabled( bool bEnable );

// Load a player travel inventory, can be called at anytime after Login.
// Returns false if inventory data not found.
native(920) final function bool LoadTravelInventory( Actor Other, optional string UserID /*=PlayerReplicationInfo.PlayerName*/ );

// Delete a player travel inventory data.
// Returns false if inventory data not found.
native final function bool DeleteTravelInventory( string UserID, optional bool bPawn /*=true*/ );

// Save player travel inventory data.
native final function SaveTravelInventory( Actor Other, optional string UserID /*=PlayerReplicationInfo.PlayerName*/ );

//------------------------------------------------------------------------------

// Engine notifications.
function PreBeginPlay()
{
	StartTime = 0;
	SetTimer(1.0, true);
	SetGameSpeed(GameSpeed);
	Level.bNoCheating = bNoCheating;

	if (GameReplicationInfoClass != None)
		GameReplicationInfo = Spawn(GameReplicationInfoClass);
	else
		GameReplicationInfo = Spawn(class'GameReplicationInfo');
	InitGameReplicationInfo();

	if (bProjectorDecals == True && bCastProjectorShadows == False)
		bCastProjectorShadows = True; // Doesn't make much sense otherwise.
}

function PostBeginPlay()
{
	local ZoneInfo W;

	if ( bVeryLowGore )
		bLowGore = true;

	if ( WaterZoneType != None )
	{
		ForEach AllActors(class'ZoneInfo', W )
		if ( W.bWaterZone )
		{
			if ( W.EntryActor == None )
				W.EntryActor = WaterZoneType.Default.EntryActor;
			if ( W.ExitActor == None )
				W.ExitActor = WaterZoneType.Default.ExitActor;
			if ( W.EntrySound == None )
				W.EntrySound = WaterZoneType.Default.EntrySound;
			if ( W.ExitSound == None )
				W.ExitSound = WaterZoneType.Default.ExitSound;
		}
	}

	// Setup local statistics logging.
	if (bLocalLog && bLoggingGame)
	{
		Log("Initiating local logging...");
		LocalLog = spawn(class'StatLogFile');
		LocalLog.bWorld = False;
		LocalLog.StartLog();
		LocalLog.LogStandardInfo();
		LocalLog.LogServerInfo();
		LocalLog.LogMapParameters();
		LogGameParameters(LocalLog);
		LocalLog.LogGameStart();
		LocalLogFileName = LocalLog.GetLogFileName();
	}

	// Setup world statistics logging.
	if (bWorldLog && bLoggingGame)
	{
		Log("Initiating world logging...");
		WorldLog = spawn(class'StatLogFile');
		WorldLog.bWorld = True;
		WorldLog.StartLog();
		WorldLog.LogStandardInfo();
		WorldLog.LogServerInfo();
		WorldLog.LogMapParameters();
		LogGameParameters(WorldLog);
		WorldLog.LogGameStart();
		WorldLogFileName = WorldLog.GetLogFileName();
	}

	Super.PostBeginPlay();
}

function Timer()
{
	SentText = 0;
}

// Called when game shutsdown.
event GameEnding()
{
	if (LocalLog != None)
	{
		LocalLog.LogGameEnd("serverquit");
		LocalLog.StopLog();
		LocalLog = None;
	}

	if (WorldLog != None)
	{
		WorldLog.LogGameEnd("serverquit");
		WorldLog.StopLog();
		WorldLog = None;
	}
}

function AppShutdown()
{
	GameEnding();
}

function NotifyLevelChange()
{
	GameEnding();
}

final function AdminAccessManager GetAccessManager()
{
	local class<AdminAccessManager> AMC;

	if( AccessManager==None )
	{
		AMC = Class<AdminAccessManager>(DynamicLoadObject(AccessManagerClass,Class'Class'));
		if( AMC==None )
			AMC = Class'AdminAccessManager';
		AccessManager = Spawn(AMC);
	}
	return AccessManager;
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
	GameReplicationInfo.bTeamGame = bTeamGame;
	GameReplicationInfo.GameName = GameName;
}

native function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	// World logging
	if (WorldLog != None)
		return "\\worldlog\\true";
	else return "";
}

// Return the server's port number.
function int GetServerPort()
{
	local string S;
	local int i;

	// Figure out the server's port.
	S = Level.GetAddressURL();
	i = InStr( S, ":" );
	assert(i>=0);
	return int(Mid(S,i+1));
}

function bool SetPause( BOOL bPause, PlayerPawn P )
{
	local PlayerPawn Player;

	if ( bPauseable || P.bAdmin || Level.Netmode==NM_Standalone )
	{
		if ( bPause )
			Level.Pauser = P.PlayerReplicationInfo.PlayerName;
		else
		{
			Level.Pauser = "";
			if (Level.NetMode != NM_Standalone)
				foreach AllActors(class'PlayerPawn', Player)
					Player.ServerTimeStamp = Level.TimeSeconds;
		}
		return True;
	}
	else return False;
}

//------------------------------------------------------------------------------
// Stat Logging.

function LogGameParameters(StatLog StatLog)
{
	if (StatLog == None)
		return;

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameName"$Chr(9)$GameName);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NoMonsters"$Chr(9)$bNoMonsters);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MuteSpectators"$Chr(9)$bMuteSpectators);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"HumansOnly"$Chr(9)$bHumansOnly);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"WeaponsStay"$Chr(9)$bCoopWeaponMode);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"ClassicDeathmessages"$Chr(9)$bClassicDeathmessages);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"LowGore"$Chr(9)$bLowGore);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"VeryLowGore"$Chr(9)$bVeryLowGore);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TeamGame"$Chr(9)$bTeamGame);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameSpeed"$Chr(9)$int(GameSpeed*100));
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxSpectators"$Chr(9)$MaxSpectators);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxPlayers"$Chr(9)$MaxPlayers);
}

//native function ExecuteLocalLogBatcher();
//native function ExecuteWorldLogBatcher();
//native static function BrowseRelativeLocalURL(string URL);

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	GameSpeed = FMax(T, 0.1);
	Level.TimeDilation = GameSpeed;
}

static function ResetGame();

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
	local actor A;
	local zoneinfo Z;
	if ( !Level.bHighDetailMode )
	{
		foreach AllActors(class'Actor', A)
		{
			if ( A.bHighDetail && !A.bGameRelevant )
				A.Destroy();
		}
	}
	foreach AllActors(class'ZoneInfo', Z)
	Z.LinkToSkybox();
}

//
// Return whether an actor should be destroyed in
// this type of game.
//
function bool IsRelevant( actor Other )
{
	local byte bSuperRelevant;

	// let the mutators mutate the actor or choose to remove it
	if (  BaseMutator==None || BaseMutator.IsRelevant(Other, bSuperRelevant) )
	{
		if ( bSuperRelevant == 1 ) // mutator wants to override any logic in here
			return true;
	}
	else return false;

	if
	(	(Difficulty==0 && !Other.bDifficulty0 )
			||  (Difficulty==1 && !Other.bDifficulty1 )
			||  (Difficulty==2 && !Other.bDifficulty2 )
			||  (Difficulty>=3 && !Other.bDifficulty3 )
			||  (!Other.bSinglePlayer && (Level.NetMode==NM_Standalone) )
			||  (!Other.bNet && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
			||  (!Other.bNetSpecial  && (Level.NetMode==NM_Client)) )
		return False;

	if ( bNoMonsters && (Pawn(Other) != None) && !Pawn(Other).bIsPlayer )
		return False;

	if( Other.OddsOfAppearing<1.f && (Difficulty<5 || !Other.bIsPawn) && FRand()>Other.OddsOfAppearing ) // On extreme difficulties, make pawns always appear.
		return False;

	// Update the level info goal counts.
	if ( Other.bIsSecretGoal )
		SecretGoals++;

	if ( Other.bIsItemGoal )
		ItemGoals++;

	if ( Other.bIsKillGoal )
		KillGoals++;

	return True;
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{
	if ( Left(Options,1)=="?" )
	{
		// Get result.
		Result = Mid(Options,1);
		if ( InStr(Result,"?")>=0 )
			Result = Left( Result, InStr(Result,"?") );

		// Update options.
		Options = Mid(Options,1);
		if ( InStr(Options,"?")>=0 )
			Options = Mid( Options, InStr(Options,"?") );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
	if ( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

//
// See if an option was specified in the options string.
//
function bool HasOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while ( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if ( Key ~= InKey )
			return true;
	}
	return false;
}

//
// Find an option in the options string and return it.
//
function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while ( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if ( Key ~= InKey )
			return Value;
	}
	return "";
}

//
// Initialize the game.
//warning: this is called before actors' PreBeginPlay.
//

event InitGame( string Options, out string Error )
{
	local string InOpt, LeftOpt;
	local int pos;
	local class<Mutator> MClass;

	// 227j: Init actor channel size.
	GameMaxChannels = Max(DesiredMaxChannels,256);
	if( Level.bRequireHighChannels )
		GameMaxChannels = Max(GameMaxChannels,4096);

	log( "InitGame:" @ Options );
	MaxPlayers = GetIntOption( Options, "MaxPlayers", MaxPlayers );
	InOpt = ParseOption( Options, "Difficulty" );
	if ( InOpt != "" )
		Difficulty = int(InOpt);
	log( "Difficulty" @ Difficulty );

	InOpt = ParseOption( Options, "AdminPassword");
	if ( InOpt!="" )
		AdminPassword = InOpt;
	//log( "Remote Administration with Password" @ AdminPassword );

	InOpt = ParseOption( Options, "GameSpeed");
	if ( InOpt != "" )
	{
		log("GameSpeed"@InOpt);
		SetGameSpeed(float(InOpt));
	}

	BaseMutator = spawn(MutatorClass);
	log("Base Mutator is "$BaseMutator);
	InOpt = ParseOption( Options, "Mutator");
	if ( InOpt != "" )
	{
		log("Mutators"@InOpt);
		while ( InOpt != "" )
		{
			pos = InStr(InOpt,",");
			if ( pos > 0 )
			{
				LeftOpt = Left(InOpt, pos);
				InOpt = Right(InOpt, Len(InOpt) - pos - 1);
			}
			else
			{
				LeftOpt = InOpt;
				InOpt = "";
			}
			log("Add mutator "$LeftOpt);
			MClass = class<Mutator>(DynamicLoadObject(LeftOpt, class'Class'));
			BaseMutator.AddMutator(Spawn(MClass));
		}
	}

	InOpt = ParseOption( Options, "GamePassword");
	if ( InOpt != "" )
	{
		GamePassWord = InOpt;
		log( "GamePassword" @ InOpt );
	}
	
	InOpt = ParseOption( Options, "InventoryData");
	if ( InOpt != "" )
		InventoryDataIni = InOpt;

	InOpt = ParseOption( Options, "LocalLog");
	if ( InOpt ~= "true" )
		bLocalLog = True;

	InOpt = ParseOption( Options, "WorldLog");
	if ( InOpt ~= "true" )
		bWorldLog = True;

	GetAccessManager().InitGame(Options,Error);
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
	return
		Level.ComputerName
		$	" "
		$	Left(Level.Title,24)
		$	" "
		$	BeaconName
		$	" "
		$	NumPlayers
		$	"/"
		$	MaxPlayers;
}

//
// Optional handling of ServerTravel for network games.
//
function ProcessServerTravel( string URL, bool bItems )
{
	local playerpawn P;
	local string ClientURL;
	local int i,j;

	if (LocalLog != None)
	{
		LocalLog.LogGameEnd("mapchange");
		LocalLog.StopLog();
		LocalLog.Destroy();
		LocalLog = None;
	}

	if (WorldLog != None)
	{
		WorldLog.LogGameEnd("mapchange");
		WorldLog.StopLog();
		WorldLog.Destroy();
		WorldLog = None;
	}
	
	if( Level.NetMode!=NM_StandAlone )
	{
		// Sanitize URL
		ClientURL = URL;
		if( !(Left(URL,8)~="?restart") )
		{
			while( true )
			{
				i = InStr(ClientURL,"?");
				if( i==-1 )
					break;
				j = InStr(ClientURL,"?",i+1);
				if( j==-1 || i==j )
				{
					j = InStr(ClientURL,"#",i+1);
					if( j==-1 || i==j )
					{
						j = InStr(ClientURL,"/",i+1);
						if( j==-1 || i==j )
						{
							ClientURL = Left(ClientURL,i);
							break;
						}
					}
				}
				ClientURL = Left(ClientURL,i)$Mid(ClientURL,j);
			}
		}
	}

	// Notify clients we're switching level and give them time to receive.
	// We call PreClientTravel directly on any local PlayerPawns (ie listen server)
	log("ProcessServerTravel:"@URL);
	foreach AllActors( class'PlayerPawn', P )
	{
		if ( NetConnection(P.Player)!=None )
			P.ClientTravel( ClientURL, TRAVEL_Relative, bItems );
		else
			P.PreClientTravel();
	}

	// Switch immediately if not networking.
	if ( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	out string Error
)
{
	// Do any name or password or name validation here.
	local string InPassword,InSkin;

	Error="";
	InPassword = ParseOption( Options, "Password" );
	InSkin = ParseOption( Options, "Class" );
	if ( GetAccessManager().AtCapacity((InStr(Caps(InSkin),"SPECTATOR")>=0),Error) )
	{
		return;
	}
	else if
	(	GamePassword!=""
			&&	!(InPassword~=GamePassword)
			&&	(AdminPassword=="" || !(InPassword~=AdminPassword)) )
	{
		if ( InPassword == "" )
			Error = NeedPassword;
		else
			Error = WrongPassword;
	}
}

// Called after Prelogin to avoid mod based overrides.
event ULogPlayer( string Options, out string Error )
{
	local string S,PN;
	local PlayerPawn P;
	local GameRules GR;

	PN = Left(ParseOption(Options,"Name"),40);
	if ( Len(Error)==0 )
	{
		if ( bMessageAdminsAliases )
		{
			if ( Len(LastLoginPlayerNames)==0 )
				S = "New player '"$PN$"' ("$LastPreloginIP$")";
			else
				S = "New player '"$PN$"' ("$LastPreloginIP$"):"@LastLoginPlayerNames;

			foreach AllActors(class'PlayerPawn',P)
			{
				if ( P.bAdmin )
					P.ClientMessage(S);
			}
		}
		if ( bLogNewPlayerAliases )
		{
			if ( Len(LastLoginPlayerNames)==0 )
				Log("Pre: '"$PN$"'"@LastPreloginIP,Class.Name);
			else Log("Pre: '"$PN$"'"@LastPreloginIP$":"@LastLoginPlayerNames,Class.Name);
		}
	}
	else if ( bMessageAdminsAliases )
	{
		S = PN@"("$LastPreloginIP$") failed to login:"@Error;
		foreach AllActors(class'PlayerPawn',P)
		{
			if ( P.bAdmin )
				P.ClientMessage(S);
		}
	}

	// Give gamerules an opportunity to modify this.
	if ( GameRules!=None )
	{
		for ( GR=GameRules; GR!=None; GR=GR.NextRules )
			if ( GR.bNotifyLogin )
				GR.OverridePrelogin(Options,PN,Error);
	}
}

event bool UAllowDownload( NetConnection Connection, string FileName, int FileSize )
{
	local PlayerPawn P;
	local string PLN,PLIP,Msg[2],FileStr;
	local GameRules G;
	local int Prt;

	PLN = Level.GetConOpts(Connection);
	PLN = Left(ParseOption("?"$PLN,"Name"),20);
	PLIP = Level.GetConIP(Connection,Prt);

	// Ask if gamerules want to disallow downloading.
	for ( G=GameRules; G!=None; G=G.NextRules )
		if ( G.bNotifyLogin && !G.AllowDownload(Connection,PLN,PLIP,FileName,FileSize) )
			return false;

	if ( !bHandleDownloadMessaging )
		return true;

	FileStr = GetReadableFileSize(FileSize);
	if (bLogDownloadsToClient)
		Msg[1] = "Player"@PLN@"is downloading"@FileName@"("$FileStr$")";
	Msg[0] = PLIP$":"$Prt@PLN@"is downloading"@FileName@"("$FileStr$")";
	
	foreach AllActors(class'PlayerPawn',P)
	{
		if ( P.bAdmin )
			P.ClientMessage(Msg[0]);
		else if (bLogDownloadsToClient)
			P.ClientMessage(Msg[1]);
	}
	return true;
}

// Convert bytes filesize into human readable filesize.
static final function string GetReadableFileSize( int Bytes )
{
	local string S;

	if ( Bytes<1000 )
		return Bytes@"b";
	if ( Bytes<1000000 )
	{
		S = string(float(Bytes)/1024.f);
		S = Left(S,Len(S)-5);
		return S@"kb";
	}
	else
	{
		S = string(float(Bytes)/1048576.f); // 1024 ^ 2 = 1048576
		S = Left(S,Len(S)-5);
		return S@"mb";
	}
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		//log(ParseString@InOpt);
		return int(InOpt);
	}
	return CurrentValue;
}

 // Called when mapchange failed in game.
event NotifyURLFailed( string URL, string Error )
{
	local PlayerPawn P;
   
	if( Level.NetMode==NM_Standalone )
		return;
	foreach AllActors(class'PlayerPawn',P)
		if( P.bAdmin || Viewport(P.Player)!=None )
			P.ClientMessage(Error);
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local NavigationPoint	StartSpot;
	local PlayerPawn	NewPlayer, TestPlayer;
	local string		InName, InPassword, InSkin, InFace;
	local byte		InTeam;
	local GameRules		G;

	if ( SpawnClass==None || SpawnClass==Class'PlayerPawn' || SpawnClass==Class'Camera' || ClassIsChildOf(SpawnClass,class'DemoRecSpectator') )
		SpawnClass = DefaultPlayerClass;
	if ( GameRules!=None )
	{
		for ( G=GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifyLogin )
				G.ModifyPlayerSpawnClass(Options,SpawnClass);
	}

	// Make sure there is capacity. (This might have changed since the PreLogin call).
	if ( GetAccessManager().AtCapacity(ClassIsChildOf(SpawnClass,class'Spectator'),Error) )
		return None;

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 40);
	InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InSkin	   = ParseOption ( Options, "Skin"    );
	InFace     = ParseOption ( Options, "Face"    );
	//log( "Login:" @ InName );
	//if ( InPassword != "" )
	//	log( "Password"@InPassword );

	// Find a start spot.
	StartSpot = FindPlayerStart( InTeam, Portal );
	if ( GameRules!=None )
	{
		for ( G=GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifySpawnPoint )
				G.ModifyPlayerStart(None,StartSpot,InTeam);
	}

	if ( StartSpot == None )
	{
		Error = FailedPlaceMessage;
		return None;
	}

	// Try to match up to existing unoccupied player in level,
	// for savegames.
	if( Level.NetMode==NM_StandAlone )
	{
		foreach AllActors(class'PlayerPawn',TestPlayer)
			if ( TestPlayer.Player==None )
				return TestPlayer; // Found matching unoccupied player, so use this one.
	}

	// If not found, spawn a new player.

	// Make sure this kind of player is allowed.
	if ( (bHumansOnly || Level.bHumansOnly) && !SpawnClass.Default.bIsHuman
			&& !ClassIsChildOf(SpawnClass, class'Spectator') )
		SpawnClass = DefaultPlayerClass;

	NewPlayer = StartSpot.Spawn(SpawnClass,,,StartSpot.Location,StartSpot.Rotation,None);

	// Handle spawn failure.
	if ( NewPlayer == None )
	{
		log("Couldn't spawn player at "$StartSpot);
		Error = FailedSpawnMessage;
		return None;
	}
	NewPlayer.ViewRotation = StartSpot.Rotation; 

	if ( InSkin != "" )
		NewPlayer.static.SetMultiSkin(NewPlayer, InSkin, InFace, InTeam);

	if ( !ChangeTeam(newPlayer, InTeam) )
	{
		Error = FailedTeamMessage;
		return None;
	}

	if ( NewPlayer.IsA('Spectator') && (Level.NetMode == NM_DedicatedServer) )
		NumSpectators++;

	// Init player's administrative privileges
	NewPlayer.Password = InPassword;
	NewPlayer.bAdmin = Len(AdminPassword)!=0 && caps(InPassword)==caps(AdminPassword);

	// Init player's information.
	NewPlayer.ClientSetRotation(NewPlayer.Rotation);
	if ( InName=="" )
		InName=DefaultPlayerName;
	if ( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
		ChangeName( NewPlayer, InName, false );
	if ( NewPlayer.bAdmin )
		GetAccessManager().AdminLogin(NewPlayer);

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// If we are a server, broadcast a welcome message.
	if ( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
	{
		if (NewPlayer.bIsFemale && Len(FemEnteredMessage) > 0)
			BroadcastMessage(NewPlayer.PlayerReplicationInfo.PlayerName $ FemEnteredMessage, false);
		else
			BroadcastMessage(NewPlayer.PlayerReplicationInfo.PlayerName $ EnteredMessage, false);
	}

	// Teleport-in effect.
	StartSpot.PlayTeleportEffect( NewPlayer, true );

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Log it.
	if ( LocalLog != None )
		LocalLog.LogPlayerConnect(NewPlayer);
	if ( WorldLog != None )
		WorldLog.LogPlayerConnect(NewPlayer);

	if ( !NewPlayer.IsA('Spectator') )
		NumPlayers++;
	return newPlayer;
}

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( playerpawn NewPlayer )
{
	// Start player's music.
	if ( bIsSavedGame ) // Loaded from saved game.
		NewPlayer.ClientSetMusic(NewPlayer.Song,NewPlayer.SongSection,Level.CdTrack,MTRAN_FastFade);
	else NewPlayer.ClientSetMusic( NewPlayer.Level.Song, NewPlayer.Level.SongSection, NewPlayer.Level.CdTrack, MTRAN_FastFade );
}

// Called when a bIsPlayer pawn traveled to a new sub-level (see Pawn.OnSubLevelChange)
function PlayerTraveled( Pawn Other, LevelInfo PrevLevel )
{
	if( Other.bIsPlayerPawn && Other.Level.bShouldChangeMusicTrack )
		PlayerPawn(Other).ClientSetMusic( Other.Level.Song, Other.Level.SongSection, Other.Level.CdTrack, MTRAN_FastFade );
}

function string GetPlayerTravelID( PlayerPawn Other, bool bSave )
{
	if( Level.NetMode==NM_StandAlone )
		return "Local";
	return Other.PlayerReplicationInfo.PlayerName;
}

// Called right after Login to give player inventory.
// @bDelete - Matches up to GameEngine.bDeleteTravelInvOnLoad
event OnGetTravelInventory( PlayerPawn Other, bool bDelete )
{
	local string S;
	
	S = GetPlayerTravelID(Other,false);
	if( LoadTravelInventory(Other,S) )
	{
		if( bDelete )
			DeleteTravelInventory(S);
	}
	else AcceptInventory(Other);
}

// Called right after all travel inventory has been spawned but before properties has been applied to them.
event ModifyTravelList( Pawn Other, out array<Actor> TravelList );

// Non-Pawn traveling (GameInfo mostly).
event ModifyActorTravelList( Actor Other, out array<Actor> TravelList );

// Spawn a single incoming traveling item.
event Actor SpawnTravelActor( Class<Actor> ActorClass, Actor DesiredOwner )
{
	return DesiredOwner.Spawn(ActorClass,DesiredOwner,,,,DesiredOwner.Instigator,,true);
}

// Called when level is about to travel to a new level with Level.bNextItems enabled.
event OnPrepareTravel()
{
	local PlayerPawn P;
	local Mutator M;
	
	for( M=BaseMutator; M!=None; M=M.NextMutator )
		if( M.bTravel )
			M.PreServerTravel();
	if( bTravel )
		SaveTravelInventory(Self,string(Class.Name));

	foreach AllActors(class'PlayerPawn',P)
		if( P.bTravel && P.Player!=None )
		{
			if( P.Health>0 )
				SaveTravelInventory(P,GetPlayerTravelID(P,true));
			else DeleteTravelInventory(GetPlayerTravelID(P,true));
		}
}

// Called right before PreBeginPlay to allow gamemode travel stuff to spawn in.
event OnPostTravel()
{
	local Mutator M;
	
	if( bTravel && LoadTravelInventory(Self,string(Class.Name)) )
		DeleteTravelInventory(string(Class.Name),false);
	for( M=BaseMutator; M!=None; M=M.NextMutator )
		if( M.bTravel )
			M.PostServerTravel();
}

//
// Add bot to game.
//
function bool AddBot();

//
// Pawn exits.
//
function Logout( pawn Exiting )
{
	if ( Exiting.bIsPlayerPawn )
	{
		GetAccessManager().AdminLogout(PlayerPawn(Exiting));
		
		if( !Exiting.IsA('Spectator') )
			NumPlayers--;
		else if ( Level.NetMode!=NM_StandAlone )
			NumSpectators--;
	}
	if ( (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) && !Exiting.IsA('Spectator') )
	{
		if( Exiting.bIsPlayerPawn )
		{
			if( Exiting.bIsFemale && Len(FemLeftMessage) )
				BroadcastMessage(Exiting.PlayerReplicationInfo.PlayerName $ FemLeftMessage $ " ("$LastDisconnectReason$")", false);
			else BroadcastMessage(Exiting.PlayerReplicationInfo.PlayerName $ LeftMessage $ " ("$LastDisconnectReason$")", false);
		}
		else if( Exiting.bIsFemale && Len(FemLeftMessage) )
			BroadcastMessage(Exiting.PlayerReplicationInfo.PlayerName $ FemLeftMessage, false);
		else BroadcastMessage(Exiting.PlayerReplicationInfo.PlayerName $ LeftMessage, false);
	}

	if ( LocalLog != None )
		LocalLog.LogPlayerDisconnect(Exiting);
	if ( WorldLog != None )
		WorldLog.LogPlayerDisconnect(Exiting);
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
	//default accept all inventory except default weapon (spawned explicitly)
	// Initialize the inventory.
	AddDefaultInventory( PlayerPawn );

	log( "All inventory from" @ PlayerPawn.PlayerReplicationInfo.PlayerName @ "is accepted" ,'ServerLog');
}

//
// Spawn any default inventory for the player.
//
function AddDefaultInventory(Pawn Player)
{
	if (Player.IsA('Spectator'))
		return;
	Player.JumpZ = Player.default.JumpZ * PlayerJumpZScaling();
	AddPlayerDefaultWeapon(Player);
	ModifyPlayerWithGameRules(Player);
}

function AddPlayerDefaultWeapon(Pawn Player)
{
	local Weapon newWeapon;
	local class<Weapon> WeapClass;

	if (DefaultWeapon == none)
		return;

	WeapClass = BaseMutator.MutatedDefaultWeapon();
	if (WeapClass == none || Player.FindInventoryType(WeapClass) != none)
		return;
	newWeapon = Spawn(WeapClass,,, Player.Location);
	if (newWeapon == none)
		return;
	NewWeapon.LifeSpan = NewWeapon.default.LifeSpan; // prevents destruction when spawning in destructive zones
	newWeapon.Instigator = Player;
	newWeapon.BecomeItem();
	Player.AddInventory(newWeapon);
	newWeapon.BringUp();
	newWeapon.GiveAmmo(Player);
	newWeapon.SetSwitchPriority(Player);
	newWeapon.WeaponSet(Player);
}

function AddPlayerDefaultPickup(Pawn Player, class<Pickup> PickupClass, optional bool bActivate)
{
	local Pickup NewPickup;

	if (Player.FindInventoryType(PickupClass) != none)
		return;
	NewPickup = Spawn(PickupClass,,, Location);
	if (NewPickup == none)
		return;
	NewPickup.LifeSpan = NewPickup.default.LifeSpan; // prevents destruction when spawning in destructive zones
	NewPickup.bHeldItem = true;
	NewPickup.GiveTo(Player);
	if (NewPickup.bActivatable && Player.SelectedItem == none)
		Player.SelectedItem = NewPickup;
	if (bActivate)
		NewPickup.Activate();
	NewPickup.PickupFunction(Player);
}

function ModifyPlayerWithGameRules(Pawn Player)
{
	local GameRules G;

	for (G = GameRules; G != none; G = G.NextRules)
		if (G.bNotifySpawnPoint)
			G.ModifyPlayer(Player);
}

//
// Return the 'best' player start for this player to start from.
// Re-implement for each game type.
//
function NavigationPoint FindPlayerStart( byte Team, optional string incomingName )
{
	local PlayerStart Dest;
	local Teleporter Tel;
	local LevelInfo L;
	
	L = SpawnLevel ? SpawnLevel : Level;
	if ( incomingName!="" )
		foreach L.AllActors( class 'Teleporter', Tel )
			if ( string(Tel.Tag)~=incomingName )
				return Tel;
	foreach L.AllActors( class 'PlayerStart', Dest )
		if ( Dest.bSinglePlayerStart && Dest.bEnabled )
			return Dest;

	// if none, check for any that aren't enabled
	log("WARNING: All single player starts were disabled - picking one anyway!");
	foreach L.AllActors( class 'PlayerStart', Dest )
		if ( Dest.bSinglePlayerStart )
			return Dest;
	log( "No single player start found" );
	
	if( L!=Level )
	{
		foreach AllActors( class 'PlayerStart', Dest )
			if ( Dest.bSinglePlayerStart && Dest.bEnabled )
				return Dest;
		foreach AllActors( class 'PlayerStart', Dest )
			if ( Dest.bSinglePlayerStart )
				return Dest;
	}
	return None;
}

//
// Restart a player.
//
function bool RestartPlayer( pawn aPlayer )
{
	local NavigationPoint startSpot;
	local GameRules G;

	if ( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return true;

	SpawnLevel = aPlayer.Level;
	startSpot = FindPlayerStart(aPlayer.PlayerReplicationInfo.Team);

	if ( GameRules!=None )
	{
		for ( G=GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifySpawnPoint )
				G.ModifyPlayerStart(aPlayer,startSpot,aPlayer.PlayerReplicationInfo.Team);
	}
	SpawnLevel = None;

	if ( startSpot == None )
		return false;
	
	if( aPlayer.Level!=startSpot.Level )
		aPlayer.SendToLevel(startSpot.Level, startSpot.Location);
	else if( !aPlayer.SetLocation(startSpot.Location,startSpot.Rotation) )
		return false;

	startSpot.PlayTeleportEffect(aPlayer, true);
	aPlayer.ViewRotation = aPlayer.Rotation;
	aPlayer.Acceleration = vect(0,0,0);
	aPlayer.Velocity = vect(0,0,0);
	aPlayer.Health = aPlayer.Default.Health;
	aPlayer.SetCollision( true, true, true );
	aPlayer.bCollideWorld = true;
	aPlayer.ClientSetLocation( startSpot.Location, startSpot.Rotation );
	aPlayer.bHidden = false;
	aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
	aPlayer.SoundDampening = aPlayer.Default.SoundDampening;
	if (aPlayer.FootRegion.Zone.bPainZone)
		aPlayer.PainTime = 1;
	else if (aPlayer.HeadRegion.Zone.bWaterZone)
		aPlayer.PainTime = aPlayer.UnderwaterTime;
	AddDefaultInventory(aPlayer);
	return true;
}

//
// Start a player.
//
function StartPlayer(PlayerPawn Player)
{
	if (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer || !bRestartLevel)
	{
		if (Player.PlayerReStartState == '' || Player.PlayerReStartState == 'PlayerWalking')
		{
			if (Player.Region.Zone.bWaterZone)
			{
				Player.SetPhysics(PHYS_SWIMMING);
				Player.GotoState('PlayerSwimming');
			}
			else
				Player.GotoState('PlayerWalking');
		}
		else
			Player.GotoState(Player.PlayerReStartState);
	}
	else
		Player.ClientTravel("?restart", TRAVEL_Relative, false);
} 

//------------------------------------------------------------------------------
// Level death message functions.

//
// Display a death message.
//
function Killed( pawn killer, pawn Other, name damageType )
{
	local string message;
	local string KillerWeaponName;
	local string VictimWeaponName;
	local string DeathMessage;

	if( Killer!=None && Killer.bDeleteMe )
		Killer = None;

	if ( Other.bIsPlayer )
	{
		if ( (Killer == Other) || (Killer == None) )
		{
			// suicide
			if ( LocalLog!=None )
				LocalLog.LogSuicide(Other, damageType);
			if ( WorldLog!=None )
				WorldLog.LogSuicide(Other, damageType);
			message = KillMessage(damageType, Other);
			BroadcastMessage(Other.GetHumanName()$message, false, 'DeathMessage');
		}
		else
		{
			if (Killer.Weapon != None)
			{
				KillerWeaponName = Killer.Weapon.ItemName;
				if (Killer.bIsFemale && Len(Killer.Weapon.FemKillMessage) > 0)
					DeathMessage = Killer.Weapon.FemKillMessage;
				else if (Other.bIsFemale && Len(Killer.Weapon.FemDeathMessage) > 0)
					DeathMessage = Killer.Weapon.FemDeathMessage;
				else
					DeathMessage = Killer.Weapon.DeathMessage;
			}
			if (Other.Weapon != None)
				VictimWeaponName = Other.Weapon.ItemName;

			if ( Other.PlayerReplicationInfo!=None && Killer.PlayerReplicationInfo!=None )
			{
				if ( LocalLog!=None )
					LocalLog.LogKill(
						Killer.PlayerReplicationInfo.PlayerID,
						Other.PlayerReplicationInfo.PlayerID,
						KillerWeaponName,
						VictimWeaponName,
						damageType);
				if ( WorldLog!=None )
					WorldLog.LogKill(
						Killer.PlayerReplicationInfo.PlayerID,
						Other.PlayerReplicationInfo.PlayerID,
						KillerWeaponName,
						VictimWeaponName,
						damageType);
			}
			if (DamageType == 'SpecialDamage' && Len(GetSpecialDamageString(Other)) > 0)
			{
				message = ParseKillMessage(
								Killer.GetHumanName(),
								Other.GetHumanName(),
								KillerWeaponName,
								GetSpecialDamageString(Other),
								Other.bIsFemale);
				BroadcastMessage(message, false, 'DeathMessage');
			}
			else if ( bClassicDeathmessages || (Killer.Weapon == None)
					  || ((DamageType != Killer.Weapon.MyDamageType) && (DamageType != Killer.Weapon.AltDamageType)) )
			{
				message = killer.KillMessage(damageType, Other);
				BroadcastMessage(Other.GetHumanName()$message, false, 'DeathMessage');
			}
			else
			{
				message = ParseKillMessage(
							  Killer.GetHumanName(),
							  Other.GetHumanName(),
							  KillerWeaponName,
							  DeathMessage,
							  Other.bIsFemale);
				BroadcastMessage(message, false, 'DeathMessage');
			}
		}
	}
	if ( Other!=None )
		ScoreKill(killer, Other);
}

// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %g = Victims's Gender
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string WeaponName, string DeathMessage, optional bool bFemale );

function ScoreKill(pawn Killer, pawn Other)
{
	Other.DieCount++;
	if ( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo!=None )
			Other.PlayerReplicationInfo.Score -= 1;
	}
	else if ( killer != None )
	{
		killer.killCount++;
		if ( killer.PlayerReplicationInfo != None )
			killer.PlayerReplicationInfo.Score += 1;
	}
}

//
// Default death message.
//
function string KillMessage( name damageType, pawn Other )
{
	return " died.";
}

// [227j] ASMD combo kill message that may depend on the victim's gender
function string GetSpecialDamageString(Pawn Victim)
{
	// The function shall return empty string whenever SpecialDamageString is empty (even if FemaleSpecialDamageString is nonempty)
	if (Victim.bIsFemale && Len(FemSpecialDamageString) > 0 && Len(SpecialDamageString) > 0)
		return FemSpecialDamageString;
	return SpecialDamageString;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return true;
}

//
// 227j: Sets new ViewTarget for the given player and handles the modification.
// This function is called from PlayerPawn's CheatView, ViewClass, ViewPlayer, ViewPlayerNum, and ViewSelf.
// It can be overridden in custom game classes.
//
function SetViewTarget(PlayerPawn Viewer, Actor ViewTarget, optional bool bQuiet)
{
	if (ViewTarget == Viewer)
		ViewTarget = none;
	Viewer.ViewTarget = ViewTarget;
	Viewer.bBehindView = ViewTarget != none;

	if (ViewTarget != none)
		ViewTarget.BecomeViewTarget();

	if (bQuiet)
		return; // no client messages

	if (ViewTarget == none)
		Viewer.ClientMessage(Viewer.ViewingFrom $ Viewer.OwnCamera, 'Event', true);
	else if (ViewTarget.bIsPawn && Pawn(ViewTarget).PlayerReplicationInfo != none && Len(Pawn(ViewTarget).PlayerReplicationInfo.PlayerName) > 0)
		Viewer.ClientMessage(Viewer.ViewingFrom $ Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
	else
		Viewer.ClientMessage(Viewer.ViewingFrom $ ViewTarget, 'Event', true);
}

//
// Use reduce damage for teamplay modifications, etc.
//
function int ReduceDamage( int Damage, name DamageType, pawn injured, pawn instigatedBy )
{
	if ( injured.Region.Zone.bNeutralZone )
		return 0;
	return Damage;
}

//
// Award a score to an actor.
//
function ScoreEvent( name EventName, actor EventActor, pawn InstigatedBy )
{
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( actor Other )
{
	if ( Level.NetMode == NM_StandAlone )
		return false;
	return Inventory(Other)!=None && Inventory(Other).ReSpawnTime!=0.0;
}

//
// Called when pawn has a chance to pick Item up (i.e. when
// the pawn touches a weapon pickup). Should return true if
// he wants to pick it up, false if he does not want it.
//
function bool PickupQuery( Pawn Other, Inventory item )
{
	local GameRules G;

	if ( GameRules!=None )
	{
		for ( G=GameRules; G!=None; G=G.NextRules )
			if ( G.bHandleInventory && !G.CanPickupInventory(Other,item) )
				Return false;
	}
	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

//
// Discard a player's inventory after he dies.
//
function DiscardInventory( Pawn Other )
{
	local actor dropped;
	local inventory Inv;
	local weapon weap;
	local float speed;

	if ( Other.DropWhenKilled != None )
	{
		dropped = Spawn(Other.DropWhenKilled,,,Other.Location);
		Inv = Inventory(dropped);
		if ( Inv != None )
		{
			Inv.RespawnTime = 0.0; //don't respawn
			Inv.BecomePickup();
		}
		if ( dropped != None )
		{
			dropped.RemoteRole = ROLE_DumbProxy;
			dropped.SetPhysics(PHYS_Falling);
			dropped.bCollideWorld = true;
			dropped.Velocity = Other.Velocity + VRand() * 280;
		}
		if ( Inv != None )
			Inv.GotoState('PickUp', 'Dropped');
	}
	if ( (Other.Weapon!=None) && (Other.Weapon.Class!=DefaultWeapon)
			&& Other.Weapon.bCanThrow )
	{
		speed = VSize(Other.Velocity);
		weap = Other.Weapon;
		if (speed != 0)
			weap.Velocity = Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280);
		else
			weap.Velocity = vect(0, 0, 0);

		Other.TossWeapon();
		if ( weap.PickupAmmoCount == 0 )
			weap.PickupAmmoCount = 1;
	}
	Other.Weapon = None;
	Other.SelectedItem = None;
	foreach Other.AllInventory(class'Inventory',Inv)
		Inv.Destroy();
}

// Return the player jumpZ scaling for this gametype
function float PlayerJumpZScaling()
{
	return 1.0;
}

//
// Try to change a player's name.
//
function ChangeName( Pawn Other, coerce string S, bool bNameChange )
{
	if ( S == "" )
		return;
	StripColorCodes(S);
	Other.PlayerReplicationInfo.PlayerName = S;
	if ( bNameChange )
		Other.ClientMessage( NameChangedMessage $ Other.PlayerReplicationInfo.PlayerName );
}

//
// Return whether a team change is allowed.
//
function bool ChangeTeam(Pawn Other, int N)
{
	Other.PlayerReplicationInfo.Team = N;
	return true;
}

//
// Play an inventory respawn effect.
//
function float PlaySpawnEffect( inventory Inv )
{
	return 0.3;
}

//
// Generate a player killled message.
//
function string PlayerKillMessage( name damageType, pawn Other )
{
	local string message;

	message = " was killed by ";
	return message;
}

//
// Generate a killed by creature message.
//
function string CreatureKillMessage( name damageType, pawn Other )
{
	return " was killed by a ";
}

//
// Send a player to a URL.
//
function SendPlayer( PlayerPawn aPlayer, string URL )
{
	aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

//
// Play a teleporting special effect.
//
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound);

//
// Restart the game.
//
function RestartGame()
{
	Level.ServerTravel( "?Restart", false );
}

//
// Whether players are allowed to broadcast messages now.
//
function bool AllowsBroadcast( actor broadcaster, int Len )
{
	SentText += Len;

	return (SentText < 260);
}

//
// End of game.
//
function EndGame( string Reason )
{
	// don't end game if not really ready
	if ( !SetEndCams(Reason) )
	{
		bOverTime = true;
		return;
	}
	bGameEnded = true;
	TriggerEvent('EndGame',Self,None);

	if (LocalLog != None)
	{
		LocalLog.LogGameEnd(Reason);
		LocalLog.StopLog();
		LocalLog.Destroy();
		LocalLog = None;
	}
	if (WorldLog != None)
	{
		WorldLog.LogGameEnd(Reason);
		WorldLog.StopLog();
		WorldLog.Destroy();
		WorldLog = None;
	}
}

function bool SetEndCams(string Reason)
{
	local pawn aPawn;

	foreach AllActors(class'Pawn',aPawn,'Player')
	{
		aPawn.GotoState('GameEnded');
		aPawn.ClientGameEnded();
	}
	return true;
}

//UGetConnections. Usage: admin UGetConnections if you're logged in as admin, or from server console.
exec final function UGetConnections( PlayerPawn Caller ) //this should never be referenced
{
	if( Level.NetMode!=NM_StandAlone )
		GetAccessManager().GetConnections(Caller);
}

defaultproperties
{
	Difficulty=1
	bRestartLevel=True
	bPauseable=True
	bCanChangeSkin=True
	bNoCheating=True
	AutoAim=0.930000
	GameSpeed=1.000000
	MaxSpectators=2
	BotMenuType="UMenu.UMenuBotConfigSClient"
	RulesMenuType="UMenu.UMenuGameRulesSClient"
	SettingsMenuType="UMenu.UMenuGameSettingsSClient"
	GameUMenuType="UMenu.UMenuGameMenu"
	MultiplayerUMenuType="UMenu.UMenuMultiplayerMenu"
	GameOptionsMenuType="UMenu.UMenuOptionsMenu"
	SwitchLevelMessage="Switching Levels"
	DefaultPlayerName="Player"
	LeftMessage=" left the game."
	FailedSpawnMessage="Failed to spawn player actor"
	FailedPlaceMessage="Could not find starting spot (level might need a 'PlayerStart' actor)"
	FailedTeamMessage="Could not find team for player"
	NameChangedMessage="Name changed to "
	EnteredMessage=" entered the game."
	GameName="Game"
	MaxedOutMessage="Server is already at capacity."
	WrongPassword="The password you entered is incorrect."
	NeedPassword="You need to enter a password to join this game."
	MaxPlayers=16
	MutatorClass=Class'Engine.Mutator'
	DefaultPlayerState=PlayerWalking
	ServerLogName="Server.log"
	bLocalLogQuery=True
	LocalBatcherURL="..\\NetGamesUSA.com\\ngStats\\ngStatsUT.exe"
	LocalBatcherParams=""
	LocalStatsURL="..\\NetGamesUSA.com\\ngStats\\html\\ngStats_Main.html"
	WorldBatcherURL="..\\NetGamesUSA.com\\ngWorldStats\\bin\\ngWorldStats.exe"
	WorldBatcherParams="-d ..\\NetGamesUSA.com\\ngWorldStats\\logs"
	WorldStatsURL="http://www.netgamesusa.com"
	BleedingDamageMin=5
	BleedingDamageMax=20
	bMessageAdminsAliases=True
	bLogNewPlayerAliases=True
	bUseClientReplicationInfo=True
	bCastShadow=False
	bDecoShadows=False
	bUseRealtimeShadow=False
	AccessManagerClass="Engine.AdminAccessManager"
	MaleGender="his"
	FemaleGender="her"
	InventoryDataIni="InventoryData"
	GameMaxChannels=1024
	DesiredMaxChannels=1024
}