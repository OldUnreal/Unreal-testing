//=============================================================================
// UdpServerQuery
//
// Version: 1.5
//
// This query server is compliant with the GameSpy Uplink Specification.
// The specification is available at http://www.gamespy.com/developer
// and might be of use to programmers who are writing or maintaining
// their own stat gathering/game querying software.
//
// Note: Currently, SendText returns false if successful.
//
// Full documentation on this class is available at http://unreal.epicgames.com/
//
//=============================================================================
class UdpServerQuery extends UdpLink config;

// Game Server Config.
var() name					QueryName;			// Name to set this object's Tag to.
var int					    CurrentQueryNum;	// Query ID Number.
var globalconfig string		GameName;
var() globalconfig string	LibraryURL,ServerWebsiteURL;
var string				ServerOSStr;
var string				LibString;

var bool bLibsInit, bShownError;
var globalconfig bool		bShowMutators,bAllowGetGameInfoProps,bAllowGetPPProps;

// Initialize.
function PreBeginPlay()
{
	// Set the Tag
	Tag = QueryName;

	// Bind the listen socket
	if ( !BindPort(Level.Game.GetServerPort(), true) )
	{
		Log("Port failed to bind.",Class.Name);
		return;
	}
	else Log("Bound to port"@Port$".",Class.Name);
	ServerOSStr = ConsoleCommand("OS")$" ("$ConsoleCommand("OS BITMODE")$" bit)";
}

function PostBeginPlay()
{
	local UdpBeacon	Beacon;

	foreach AllActors(class'UdpBeacon', Beacon)
	{
		Beacon.UdpServerQueryPort = Port;
	}
	Super.PostBeginPlay();
}

// Received a query request.
event ReceivedText( IpAddr Addr, string Text )
{
	local string Query;
	local bool QueryRemaining;
	local int  QueryNum, PacketNum;

	// Assign this packet a unique value from 1 to 100
	CurrentQueryNum++;
	if (CurrentQueryNum > 100)
		CurrentQueryNum = 1;
	QueryNum = CurrentQueryNum;

	Query = Text;
	if (Query == "")		// If the string is empty, don't parse it
		QueryRemaining = false;
	else
		QueryRemaining = true;

	while (QueryRemaining)
	{
		Query = ParseQuery(Addr, Query, QueryNum, PacketNum);
		if (Query == "")
			QueryRemaining = false;
		else
			QueryRemaining = true;
	}
}

function bool ParseNextQuery( string Query, out string QueryType, out string QueryValue, out string QueryRest, out string FinalPacket )
{
	local string TempQuery;
	local int ClosingSlash;

	if (Query == "")
		return false;

	// Query should be:
	//   \[type]\<value>
	if (Left(Query, 1) == "\\")
	{
		// Check to see if closed.
		ClosingSlash = InStr(Right(Query, Len(Query)-1), "\\");
		if (ClosingSlash == 0)
			return false;

		TempQuery = Query;

		// Query looks like:
		//  \[type]\
		QueryType = Right(Query, Len(Query)-1);
		QueryType = Left(QueryType, ClosingSlash);

		QueryRest = Right(Query, Len(Query) - (Len(QueryType) + 2));

		if ((QueryRest == "") || (Len(QueryRest) == 1))
		{
			FinalPacket = "final";
			return true;
		}
		else if (Left(QueryRest, 1) == "\\")
			return true;	// \type\\

		// Query looks like:
		//  \type\value
		ClosingSlash = InStr(QueryRest, "\\");
		if (ClosingSlash >= 0)
			QueryValue = Left(QueryRest, ClosingSlash);
		else
			QueryValue = QueryRest;

		QueryRest = Right(Query, Len(Query) - (Len(QueryType) + Len(QueryValue) + 3));
		if (QueryRest == "")
		{
			FinalPacket = "final";
			return true;
		}
		else
			return true;
	}
	else
	{
		return false;
	}
}

function string ParseQuery( IpAddr Addr, coerce string Query, int QueryNum, out int PacketNum )
{
	local string QueryType, QueryValue, QueryRest, ValidationString;
	local bool Result;
	local string FinalPacket;

	Result = ParseNextQuery(Query, QueryType, QueryValue, QueryRest, FinalPacket);
	if ( !Result )
		return "";

	if ( QueryType=="basic" )
	{
		Result = SendQueryPacket(Addr, GetBasic(), QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="info" )
	{
		Result = SendQueryPacket(Addr, GetInfo(), QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="rules" )
	{
		Result = SendQueryPacket(Addr, GetRules(), QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="players" )
	{
		if ( Level.Game.NumPlayers > 0 )
			Result = SendPlayers(Addr, QueryNum, PacketNum, FinalPacket);
		else
			Result = SendQueryPacket(Addr, "", QueryNum, PacketNum, FinalPacket);
	}
	else if ( QueryType=="status" )
	{
		Result = SendQueryPacket(Addr, GetBasic(), QueryNum, ++PacketNum, "");
		Result = SendQueryPacket(Addr, GetInfo(), QueryNum, ++PacketNum, "");
		if ( Level.Game.NumPlayers == 0 )
		{
			Result = SendQueryPacket(Addr, GetRules(), QueryNum, ++PacketNum, FinalPacket);
		}
		else
		{
			Result = SendQueryPacket(Addr, GetRules(), QueryNum, ++PacketNum, "");
			Result = SendPlayers(Addr, QueryNum, PacketNum, FinalPacket);
		}
	}
	else if ( QueryType=="echo" )
	{
		// Respond to an echo with the same string
		Result = SendQueryPacket(Addr, "\\echo\\"$QueryValue, QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="secure" )
	{
		ValidationString = "\\validate\\"$Validate(Left(QueryValue,30), GameName);
		Result = SendQueryPacket(Addr, ValidationString, QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="level_property" )
	{
		Result = SendQueryPacket(Addr, GetLevelProperty(QueryValue), QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="game_property" )
	{
		Result = SendQueryPacket(Addr, GetGameProperty(QueryValue), QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="player_property" )
	{
		Result = SendQueryPacket(Addr, GetPlayerProperty(QueryValue), QueryNum, ++PacketNum, FinalPacket);
	}
	else
	{
		if( !bShownError )
		{
			Log("Unknown query: "$QueryType,Class.Name);
			bShownError = true;
		}
	}
	if ( !Result )
	{
		if( !bShownError )
		{
			Log("Error responding to query ("$QueryType$").",Class.Name);
			bShownError = true;
		}
	}
	return QueryRest;
}

// SendQueryPacket is a wrapper for SendText that allows for packet numbering.
function bool SendQueryPacket(IpAddr Addr, coerce string SendString, int QueryNum, int PacketNum, string FinalPacket)
{
	local bool Result;
	if (FinalPacket == "final")
	{
		SendString = SendString$"\\final\\";
	}
	SendString = SendString$"\\queryid\\"$QueryNum$"."$PacketNum;

	Result = SendText(Addr, SendString);

	return Result;
}

// Return a string of basic information.
function string GetBasic()
{
	local string ResultSet;

	// The name of this game.
	ResultSet = "\\gamename\\"$GameName;

	// The version of this game.
	ResultSet = ResultSet$"\\gamever\\"$Level.EngineVersion$Chr(96+int(Level.EngineSubVersion));

	// The version of this game.
	ResultSet = ResultSet$"\\gamesubver\\"$Level.EngineSubVersion;

	// The most recent network compatible version.
	ResultSet = ResultSet$"\\mingamever\\"$Level.MinNetVersion;

	// The regional location of this game.
	ResultSet = ResultSet$"\\location\\"$Level.Game.GameReplicationInfo.Region;

	return ResultSet;
}

// Return a string of important system information.
function string GetInfo()
{
	local string ResultSet;

	// The server name, i.e.: Bob's Server
	ResultSet = "\\hostname\\"$Level.Game.GameReplicationInfo.ServerName;

	// The short server name
	ResultSet = ResultSet$"\\shortname\\"$Level.Game.GameReplicationInfo.ShortName;

	// The server port.
	ResultSet = ResultSet$"\\hostport\\"$Level.Game.GetServerPort();

	// The map/level name
	if ( Level.Title=="" || Level.Title==Level.Default.Title )
		ResultSet = ResultSet$"\\mapname\\"$string(Outer.Name);
	else ResultSet = ResultSet$"\\mapname\\"$Level.Title;

	// The mod or game type
	ResultSet = ResultSet$"\\gametype\\"$Level.Game.GameName;

	// The gametype class
	ResultSet = ResultSet$"\\GameClass\\"$Level.Game.Class;

	// The number of players
	ResultSet = ResultSet$"\\numplayers\\"$Level.Game.NumPlayers;

	// The maximum number of players
	ResultSet = ResultSet$"\\maxplayers\\"$Level.Game.MaxPlayers;

	// The game mode: openplaying
	ResultSet = ResultSet$"\\gamemode\\openplaying";

	// The version of this game.
	ResultSet = ResultSet$"\\gamever\\"$Level.EngineVersion$Chr(96+int(Level.EngineSubVersion));

	// The subversion of this game.
	ResultSet = ResultSet$"\\gamesubver\\"$Level.EngineSubVersion;

	// The most recent network compatible version.
	ResultSet = ResultSet$"\\mingamever\\"$Level.MinNetVersion;

	// List the required libaries.
	ResultSet = ResultSet$GetLibaries();

	if( Len(ServerWebsiteURL)>0 )
		ResultSet = ResultSet$"\\servurl\\"$ServerWebsiteURL;

	return ResultSet;
}

// Return a string of miscellaneous information.
// Game specific information, user defined data, custom parameters for the command line.
function string GetRules()
{
	local string ResultSet;
	local Mutator M;
	local GameRules G;

	ResultSet = Level.Game.GetRules();

	// Admin's Name
	if ( Level.Game.GameReplicationInfo.AdminName != "" )
		ResultSet = ResultSet$"\\AdminName\\"$Level.Game.GameReplicationInfo.AdminName;

	// Admin's Email
	if ( Level.Game.GameReplicationInfo.AdminEmail != "" )
		ResultSet = ResultSet$"\\AdminEMail\\"$Level.Game.GameReplicationInfo.AdminEmail;

	// Map filename
	ResultSet = ResultSet$"\\mapfilename\\"$Outer.Name;

	// Server OS
	ResultSet = ResultSet$"\\OS\\"$ServerOSStr;

	// Give full mutators list
	if ( bShowMutators )
	{
		For( M=Level.Game.BaseMutator; M!=None; M=M.NextMutator )
		{
			if ( M.Class!=Class'Mutator' )
				ResultSet = ResultSet$"\\Mutator\\"$M.GetHumanName();
		}
	}

	if ( Level.Game.GameRules!=None )
	{
		for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifyRules )
				G.ModifyRules(ResultSet);
	}

	return ResultSet;
}

// Return a string of information on a player.
function string GetPlayer( PlayerPawn P, int PlayerNum )
{
	local string ResultSet,M,S;

	// Name
	ResultSet = "\\player_"$PlayerNum$"\\"$P.PlayerReplicationInfo.PlayerName;

	// Frags
	ResultSet = ResultSet$"\\frags_"$PlayerNum$"\\"$int(P.PlayerReplicationInfo.Score);

	// Ping
	ResultSet = ResultSet$"\\ping_"$PlayerNum$"\\"@P.PlayerReplicationInfo.Ping;

	// Team
	ResultSet = ResultSet$"\\team_"$PlayerNum$"\\"$P.PlayerReplicationInfo.Team;

	// Skin and mesh
	P.GetPlayerModelInfo(M,S);
	ResultSet = ResultSet$"\\skin_"$PlayerNum$"\\"$S$"\\mesh_"$PlayerNum$"\\"$M;

	return ResultSet;
}

// Send data for each player
function bool SendPlayers(IpAddr Addr, int QueryNum, out int PacketNum, string FinalPacket)
{
	local PlayerPawn P;
	local int i,n;
	local bool Result;

	foreach AllActors(class'PlayerPawn',P)
		if( P.PlayerReplicationInfo && !P.IsA('MessagingSpectator') )
			++n;
	if( n==0 )
		return false;

	foreach AllActors(class'PlayerPawn',P)
	{
		if( P.PlayerReplicationInfo && !P.IsA('MessagingSpectator') )
			Result = SendQueryPacket(Addr, GetPlayer(P, i++), QueryNum, ++PacketNum, (i==n && FinalPacket=="final") ? "final" : "") || Result;
	}

	return Result;
}

// Get an arbitrary property from the level object.
function string GetLevelProperty( string Prop )
{
	local string ResultSet;

	ResultSet = "\\"$Prop$"\\"$Level.GetPropertyText(Prop);

	return ResultSet;
}

// Get an arbitrary property from the game object.
function string GetGameProperty( string Prop )
{
	local string ResultSet;

	if ( !bAllowGetGameInfoProps || InStr(Caps(Prop),"PASSWORD")!=-1 ) // Security warning, never give away any possible passwords!
		ResultSet = "\\"$Prop$"\\*Private*";
	else ResultSet = "\\"$Prop$"\\"$Level.Game.GetPropertyText(Prop);

	return ResultSet;
}

// Get an arbitrary property from the players.
function string GetPlayerProperty( string Prop )
{
	local string ResultSet;
	local int i;
	local PlayerPawn P;

	if ( !bAllowGetPPProps || InStr(Caps(Prop),"PASSWORD")!=-1 ) // Security warning, never give away any possible passwords!
		return "";
	foreach AllActors(class'PlayerPawn', P)
	{
		i++;
		ResultSet = ResultSet$"\\"$Prop$"_"$i$"\\"$P.GetPropertyText(Prop);
	}

	return ResultSet;
}

final function string GetLibaries()
{
	local string S;

	if( !bLibsInit )
	{
		LibString = "";
		bLibsInit = true;
		foreach AllLibaries(S,LIBFLAG_ServerLibs)
		{
			if( !IsEngineLib(S) ) // Skip engine libaries.
			{
				LibString = LibString$"\\DLL\\"$S;
				S = Localize("public","LinkVersion",S);
				if( Len(S)>0 && Left(S,1)!="<" )
					LibString = LibString$"/"$S;
			}
		}
		if( Len(LibString)>0 && Len(LibraryURL)>0 )
			LibString = LibString$"\\liburl\\"$LibraryURL;
	}
	return LibString;
}
final function bool IsEngineLib( string S )
{
	return (S~="Core" || S~="Engine" || S~="ALAudio" || S~="Editor" || S~="Emitter" || S~="Fire" || S~="IpDrv" || S~="UWebAdmin" || S~="UPak");
}

defaultproperties
{
	QueryName="MasterUplink"
	GameName="unreal"
	bShowMutators=True
}
