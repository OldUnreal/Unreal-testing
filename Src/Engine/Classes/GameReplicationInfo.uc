//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	NoUserCreate
	NativeReplication
	Native;

var string GameName;				// Assigned by GameInfo.
var bool bTeamGame;						// Assigned by GameInfo.
var int  RemainingTime, ElapsedTime;

var() globalconfig string ServerName;	// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;		// Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;	// Email address of the server admin.
var() nowarn globalconfig int Region;		// Region of the game server.

var() globalconfig bool ShowMOTD;				// Whether or not to display the MOTD.
var() globalconfig string MOTDLine1;		// Message
var() globalconfig string MOTDLine2;		// Of
var() globalconfig string MOTDLine3;		// The
var() globalconfig string MOTDLine4;		// Day

var string GameEndedComments;		// set by gameinfo when game ends

replication
{
	reliable if ( Role == ROLE_Authority )
		GameName, bTeamGame, ServerName, ShortName, AdminName,
		AdminEmail, Region, ShowMOTD, MOTDLine1, MOTDLine2,
		MOTDLine3, MOTDLine4;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		RemainingTime, ElapsedTime;
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode == NM_Client )
	{
		SetTimer(1.0, true);
		// -.:..:: Fix for false information on client.
		ShowMOTD = False;
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
		Region = 0;
		ServerName = "";
		ShortName = "";
		AdminName = "";
		AdminEmail = "";
	}
}

simulated function Timer()
{
	ElapsedTime++;
	if ( RemainingTime > 0 )
		RemainingTime--;
}

defaultproperties
{
	ServerName="Unreal Server"
	ShortName="Unreal Server"
	RemoteRole=ROLE_SimulatedProxy
	bOnlyDirtyReplication=true
}