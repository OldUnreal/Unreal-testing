//=============================================================================
// Logs game events for stat collection
//
// ngLog, ngStats, and ngWorldStats are registered trademarks of
// NetGames USA, Inc. at http://www.netgamesusa.com All rights reserved. A
// ny and all occurrences of code related to supporting their products and
// services appears with their express permission.
//=============================================================================
class StatLog extends Info
	native
	NoUserCreate;

// Internal
var pointer<FMD5Context*> Context;

// State
var bool	bWorld;

// Time
var	float	TimeStamp;

// Log Variables
var() string LocalStandard;		// The standard this log is compliant to.
var() string WorldStandard;		// The standard this log is compliant to.
var() string LogVersion;		// Version of the log standard.
var() string LogInfoURL;		// URL to info on logging standard.
var() string GameName;			// Name of this game.
var() string GameCreator;		// Name of game creator.
var() string GameCreatorURL;	// URL to info on game creator.
var() string DecoderRingURL;	// URL to log format decoder ring.

// Directories
var() string LocalLogDir;
var() string WorldLogDir;

// Object
function BeginPlay()
{
	SetTimer(30.0, True);
}

function Timer()
{
	LogPings();
}

// Logging
function StartLog()
{
	// Implemented in subclass.
}

function StopLog()
{
	// Implemented in subclass.
}

function FlushLog()
{
	// Implemented in subclass.
}

function LogEventString( string EventString )
{
	Log( EventString );
}

// Time
native final function string GetGMTRef();

// Return absolute time.
function string GetAbsoluteTime()
{
	local string AbsoluteTime;
	local string GMTRef;

	AbsoluteTime = string(Level.Year);

	if (Level.Month < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Month;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Month;

	if (Level.Day < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Day;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Day;

	if (Level.Hour < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Hour;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Hour;

	if (Level.Minute < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Minute;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Minute;

	if (Level.Second < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Second;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Second;

	if (Level.Millisecond < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Millisecond;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Millisecond;

	GMTRef = GetGMTRef();

	AbsoluteTime = AbsoluteTime$"."$GMTRef;

	TimeStamp = 0;

	return AbsoluteTime;
}

// A less verbose version...
function string GetShortAbsoluteTime()
{
	local string AbsoluteTime;

	AbsoluteTime = string(Level.Year);

	if (Level.Month < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Month;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Month;

	if (Level.Day < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Day;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Day;

	if (Level.Hour < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Hour;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Hour;

	if (Level.Minute < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Minute;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Minute;

	if (Level.Second < 10)
		AbsoluteTime = AbsoluteTime$".0"$Level.Second;
	else
		AbsoluteTime = AbsoluteTime$"."$Level.Second;

	TimeStamp = 0;

	return AbsoluteTime;
}

// Return a timestamp relative to last absolute time.
function string GetTimeStamp()
{
	local string Time;
	Time = string(TimeStamp);
	Time = Left(Time, InStr(Time, ".") + 3);
	return Time;
}

// Return a logfile name if relevant.
function string GetLogFileName()
{
	return "";
}

// Track relative timestamps.
function Tick(float Delta)
{
	TimeStamp += Delta;
}

// Standard Log Entries
function LogStandardInfo()
{
	if (bWorld)
		LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Log_Standard"$Chr(9)$WorldStandard);
	else
		LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Log_Standard"$Chr(9)$LocalStandard);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Log_Version"$Chr(9)$LogVersion);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Log_Info_URL"$Chr(9)$LogInfoURL);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Game_Name"$Chr(9)$GameName);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Game_Version"$Chr(9)$Level.EngineVersion);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Game_Creator"$Chr(9)$GameCreator);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Game_Creator_URL"$Chr(9)$GameCreatorURL);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Game_Decoder_Ring_URL"$Chr(9)$DecoderRingURL);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Absolute_Time"$Chr(9)$GetAbsoluteTime());
}

function LogServerInfo()
{
	local string NetworkNumber;

	NetworkNumber = Level.Game.GetNetworkNumber();

	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_ServerName"$Chr(9)$Level.Game.GameReplicationInfo.ServerName);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_AdminName"$Chr(9)$Level.Game.GameReplicationInfo.AdminName);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_AdminEmail"$Chr(9)$Level.Game.GameReplicationInfo.AdminEmail);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_Region"$Chr(9)$Level.Game.GameReplicationInfo.Region);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_MOTDLine1"$Chr(9)$Level.Game.GameReplicationInfo.MOTDLine1);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_MOTDLine2"$Chr(9)$Level.Game.GameReplicationInfo.MOTDLine2);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_MOTDLine3"$Chr(9)$Level.Game.GameReplicationInfo.MOTDLine3);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_MOTDLine4"$Chr(9)$Level.Game.GameReplicationInfo.MOTDLine4);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_IP"$Chr(9)$NetworkNumber);
	LogEventString(GetTimeStamp()$Chr(9)$"info"$Chr(9)$"Server_Port"$Chr(9)$Level.Game.GetServerPort());
}

native final function string GetMapFileName();

function LogMapParameters()
{
	local string MapName;

	MapName = GetMapFileName();

	LogEventString(GetTimeStamp()$Chr(9)$"map"$Chr(9)$"Name"$Chr(9)$MapName);
	LogEventString(GetTimeStamp()$Chr(9)$"map"$Chr(9)$"Title"$Chr(9)$Level.Title);
	LogEventString(GetTimeStamp()$Chr(9)$"map"$Chr(9)$"Author"$Chr(9)$Level.Author);
	LogEventString(GetTimeStamp()$Chr(9)$"map"$Chr(9)$"IdealPlayerCount"$Chr(9)$Level.IdealPlayerCount);
	LogEventString(GetTimeStamp()$Chr(9)$"map"$Chr(9)$"LevelEnterText"$Chr(9)$Level.LevelEnterText);
}

function LogPlayerConnect(Pawn Player)
{
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Connect"$Chr(9)$Player.PlayerReplicationInfo.PlayerName$Chr(9)$Player.PlayerReplicationInfo.PlayerID);
	LogPlayerInfo(Player);
}

function LogPlayerInfo(Pawn Player)
{
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"TeamName"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.TeamName);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Team"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.Team);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"TeamID"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.TeamID);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Ping"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.Ping);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"IsABot"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.bIsABot);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Skill"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.Skill);
}

function LogPlayerDisconnect(Pawn Player)
{
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Disconnect"$Chr(9)$Player.PlayerReplicationInfo.PlayerID);
}

function LogKill( int KillerID, int VictimID, string KillerWeaponName, string VictimWeaponName, name DamageType )
{
	LogEventString(GetTimeStamp()$Chr(9)$"kill"$Chr(9)$KillerID$Chr(9)$KillerWeaponName$Chr(9)$VictimID$Chr(9)$VictimWeaponName$Chr(9)$DamageType);
}

function LogTeamKill( int KillerID, int VictimID, string KillerWeaponName, string VictimWeaponName, name DamageType )
{
	LogEventString(GetTimeStamp()$Chr(9)$"teamkill"$Chr(9)$KillerID$Chr(9)$KillerWeaponName$Chr(9)$VictimID$Chr(9)$VictimWeaponName$Chr(9)$DamageType);
}

function LogSuicide(Pawn Killed, name DamageType)
{
	local int KilledID;

	if (Killed == None)
		return;

	KilledID = Killed.PlayerReplicationInfo.PlayerID;

	if (Killed.Weapon != None)
		LogEventString(GetTimeStamp()$Chr(9)$"suicide"$Chr(9)$KilledID$Chr(9)$Killed.Weapon.ItemName$Chr(9)$DamageType);
	else
		LogEventString(GetTimeStamp()$Chr(9)$"suicide"$Chr(9)$KilledID$Chr(9)$"None"$Chr(9)$DamageType);
}

function LogTypingEvent(bool bTyping, Pawn Other)
{
	LogEventString(GetTimeStamp()$Chr(9)$"typing"$Chr(9)$bTyping$Chr(9)$Other.PlayerReplicationInfo.PlayerID);
}

function LogPickup(Inventory Item, Pawn Other)
{
	LogEventString(GetTimeStamp()$Chr(9)$"item_get"$Chr(9)$Item.ItemName$Chr(9)$Other.PlayerReplicationInfo.PlayerID);
}

function LogItemActivate(Inventory Item, Pawn Other)
{
	LogEventString(GetTimeStamp()$Chr(9)$"item_activate"$Chr(9)$Item.ItemName$Chr(9)$Other.PlayerReplicationInfo.PlayerID);
}

function LogItemDeactivate(Inventory Item, Pawn Other)
{
	LogEventString(GetTimeStamp()$Chr(9)$"item_deactivate"$Chr(9)$Item.ItemName$Chr(9)$Other.PlayerReplicationInfo.PlayerID);
}

function LogSpecialEvent(string EventType, optional coerce string Arg1, optional coerce string Arg2, optional coerce string Arg3, optional coerce string Arg4)
{
	local string Event;

	Event = EventType;
	if (Arg1 != "")
		Event = Event$Chr(9)$Arg1;
	if (Arg2 != "")
		Event = Event$Chr(9)$Arg2;
	if (Arg3 != "")
		Event = Event$Chr(9)$Arg3;
	if (Arg4 != "")
		Event = Event$Chr(9)$Arg4;

	LogEventString(GetTimeStamp()$Chr(9)$Event);
}

function LogPings()
{
	local PlayerReplicationInfo PRI;

	foreach AllActors(class'PlayerReplicationInfo', PRI)
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Ping"$Chr(9)$PRI.PlayerID$Chr(9)$PRI.Ping);
}

function LogGameStart()
{
	LogEventString(GetTimeStamp()$Chr(9)$"game_start");
}

function LogGameEnd( string Reason )
{
	LogEventString(GetTimeStamp()$Chr(9)$"game_end"$Chr(9)$Reason);
}

defaultproperties
{
	bHidden=True
	LocalStandard="ngLog"
	WorldStandard="ngLog"
	LogVersion="1.2"
	LogInfoURL="http://www.netgamesusa.com/ngLog/"
	GameName="Unreal"
	GameCreator="Epic MegaGames, Inc."
	GameCreatorURL="http://www.epicgames.com/"
	DecoderRingURL="http://unreal.epicgames.com/Unreal_Log_Decoder_Ring.html"
	LocalLogDir="..\\Logs"
	WorldLogDir="..\\NetGamesUSA.com\\ngWorldStats\\logs"
}