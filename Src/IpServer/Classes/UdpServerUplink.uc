//=============================================================================
// UdpServerUplink
//
// Version: 1.3
//
// This uplink is compliant with the GameSpy Uplink Specification.
// The specification is available at http://www.gamespy.com/developer
// and might be of use to progammers who want to adapt their own
// server uplinks.
//
// UdpServerUplink sends a heartbeat to the specified master server
// every five minutes.  The heartbeat is in the form:
//    \heartbeat\QueryPort\gamename\unreal
//
// Full documentation on this class is available at http://unreal.epicgames.com/
//
//=============================================================================
class UdpServerUplink extends UdpLink config;

// Master Uplink Config.
var() config bool		DoUplink;				// If true, do the uplink
var() config int		UpdateMinutes;			// Period of update (in minutes)
var() config string     MasterServerAddress;	// Address of the master server
var() config int		MasterServerPort;		// Optional port that the master server is listening on
var() nowarn config int 		Region;					// Region of the game server
var() name				TargetQueryName;		// Name of the query server object to use.
var IpAddr				MasterServerIpAddr;		// Master server's address.
var string		        HeartbeatMessage;		// The message that is sent to the master server.
var UdpServerQuery      Query;					// The query object.
var int                 CurrentQueryNum;        // Query ID Number.

// Initialize.
function PreBeginPlay()
{
	// If master server uplink isn't wanted, exit.
	if ( !DoUplink )
	{
		Log("DoUplink is not set.  Not connecting to Masterserver.",Class.Name);
		return;
	}

	// Find a the server query handler.
	foreach AllActors(class'UdpServerQuery', Query, TargetQueryName)
		break;

	if ( Query==None )
	{
		Log("Could not find a UdpServerQuery object, aborting.",Class.Name);
		return;
	}

	// Set heartbeat message.
	HeartbeatMessage = "\\heartbeat\\"$Query.Port$"\\gamename\\unreal";

	// Set the Port.
	MasterServerIpAddr.Port = MasterServerPort;

	// Resolve the Address.
	if ( MasterServerAddress=="" )
		MasterServerAddress = "master"$Region$".gamespy.com";
	Resolve( MasterServerAddress );
}

// When master server address is resolved.
function Resolved( IpAddr Addr )
{
	local int UplinkPort;

	// Set the address
	MasterServerIpAddr.Addr = Addr.Addr;

	// Handle failure.
	if ( MasterServerIpAddr.Addr == 0 )
	{
		Log("Invalid master server address ["$MasterServerAddress$"], aborting.",Class.Name);
		return;
	}

	// Bind the local port.
	UplinkPort = Query.Port + 1;
	if ( !BindPort(UplinkPort, true) )
	{
		Log(Name$": Error binding port, aborting.",Class.Name);
		return;
	}
	Log("Master Server is "$MasterServerAddress$":"$MasterServerIpAddr.Port@"on server port"@Port,Class.Name);

	// Start transmitting.
	SetTimer(UpdateMinutes * 60, true);
	Timer();
}

// Host resolution failue.
function ResolveFailed()
{
	Log("Failed to resolve master server address ("$MasterServerAddress$"), aborting.",Class.Name);
}

// Notify the MasterServer we exist.
function Timer()
{
	local bool Result;

	Result = SendText( MasterServerIpAddr, HeartbeatMessage );
	if ( !Result )
		Log( "Failed to send heartbeat to master server ["$MasterServerAddress$"].",Class.Name);
}

// Stop the uplink.
function Halt()
{
	Log("Halting by request.",Class.Name);
	SetTimer(0.0, false);
}

// Resume the uplink.
function Resume()
{
	Log("Resuming by request.",Class.Name);
	SetTimer(UpdateMinutes * 60, true);
	Timer();
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

function string ParseQuery( IpAddr Addr, coerce string QueryStr, int QueryNum, out int PacketNum )
{
	local string QueryType, QueryValue, QueryRest, ValidationString;
	local bool Result;
	local string FinalPacket;

	Result = ParseNextQuery(QueryStr, QueryType, QueryValue, QueryRest, FinalPacket);
	if ( !Result )
		return "";

	if ( QueryType=="basic" )
	{
		// Ignore.
		Result = true;
	}
	else if ( QueryType=="secure" )
	{
		ValidationString = "\\validate\\"$Validate(QueryValue, Query.GameName);
		Result = SendQueryPacket(Addr, ValidationString, QueryNum, ++PacketNum, FinalPacket);
	}
	else if ( QueryType=="portverify" ) // 227k masterserver, verify ports from source connection.
	{
		Query.SendText(Addr, "\\queryport\\"$QueryValue);
		SendDriverMessage(Addr, "\\serverport\\"$QueryValue);
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

defaultproperties
{
	UpdateMinutes=1
	MasterServerPort=27900
	TargetQueryName="MasterUplink"
	RemoteRole=ROLE_None
	DoUplink=False
	Region=0
	bTickRealTime=true
}
