class UBrowserHTTPLink extends UBrowserBufferedTcpLink;

// Misc
var UBrowserHTTPFact		OwnerFactory;
var IpAddr					MasterServerIpAddr;
var bool					bHasOpened;

// Params
var string					MasterServerAddress;	// Address of the master server
var string					MasterServerURI;
var int						MasterServerTCPPort;	// Optional port that the master server is listening on
var int						MasterServerTimeout;

// Error messages
var localized string		ResolveFailedError;
var localized string		TimeOutError;
var localized string		CouldNotConnectError;

// for WaitFor
const FoundHeader = 1;
const FoundServer = 2;

function BeginPlay()
{
	bHasOpened = False;
	Disable('Tick');
	Super.BeginPlay();
}

function Start()
{
	ResetBuffer();

	MasterServerIpAddr.Port = MasterServerTCPPort;
	Resolve( MasterServerAddress );
}

function DoBufferQueueIO()
{
	Super.DoBufferQueueIO();
	if (bHasOpened && PeekChar() == 0 && !IsConnected())
	{
		OwnerFactory.QueryFinished(True);
		GotoState('Done');
	}
}

function Resolved( IpAddr Addr )
{
	// Set the address
	MasterServerIpAddr.Addr = Addr.Addr;

	// Handle failure.
	if ( MasterServerIpAddr.Addr == 0 )
	{
		Log( "UBrowserHTTPLink: Invalid master server address, aborting." ,'UBrowser');
		return;
	}

	// Display success message.
	Log( "UBrowserHTTPLink: Master Server is "$MasterServerAddress$":"$MasterServerIpAddr.Port ,'UBrowser');

	// Bind the local port.
	if ( !BindPort() )
	{
		Log( "UBrowserHTTPLink: Error binding local port, aborting." ,'UBrowser');
		return;
	}

	Open( MasterServerIpAddr );
	SetTimer(MasterServerTimeout, False);
}

event Timer()
{
	if (!bHasOpened)
	{
		OwnerFactory.QueryFinished(False, CouldNotConnectError$MasterServerAddress);
		GotoState('Done');
	}
}

event Closed()
{
}

// Host resolution failue.
function ResolveFailed()
{
	Log("UBrowserHTTPLink: Failed to resolve master server address, aborting.",'UBrowser');
	OwnerFactory.QueryFinished(False, ResolveFailedError$MasterServerAddress);
	GotoState('Done');
}

event Opened()
{
	Enable('Tick');
	bHasOpened = True;

	// Send request
	SendBufferedData("GET "$MasterServerURI$" HTTP/1.0"$CR$LF);
	SendBufferedData("User-Agent: Unreal"$CR$LF);
	SendBufferedData("Host:"$MasterServerAddress$":"$MasterServerTCPPort$CR$LF$CR$LF);
	WaitFor("200", 10, FoundHeader);
}


function Tick(float DeltaTime)
{
	DoBufferQueueIO();
}

function HandleServer(string Text)
{
	local string	Address;
	local string	Port;

	Address = ParseDelimited(Text, " ", 1);
	Port = ParseDelimited(Text, " ", 3);

	OwnerFactory.FoundServer(Address, int(Port), "", "Unreal");
}

function GotMatch(int MatchData)
{
	switch (MatchData)
	{
	case FoundHeader:
		Enable('Tick');
		if (Chr(PeekChar()) == CR || Chr(PeekChar()) == LF) ReadChar();

		while (Right(WaitResult, 1) == CR || Right(WaitResult, 1) == LF)
			WaitResult=Left(WaitResult, Len(WaitResult) - 1);

		if (WaitResult != "")
			WaitFor(CR, 10, FoundHeader);
		else
			WaitFor(CR, 10, FoundServer);
		break;
	case FoundServer:
		Enable('Tick');
		if (Chr(PeekChar()) == CR || Chr(PeekChar()) == LF) ReadChar();

		while (Right(WaitResult, 1) == CR || Right(WaitResult, 1) == LF)
			WaitResult=Left(WaitResult, Len(WaitResult) - 1);

		// Log("FoundServer >>"$WaitResult$"<<");

		HandleServer(WaitResult);

		WaitFor(CR, 10, FoundServer);
		break;
	default:
		break;
	}
}

function GotMatchTimeout(int MatchData)
{
	// when a match times out
	OwnerFactory.QueryFinished(False, TimeOutError);
	GotoState('Done');
}

// States
state Done
{
Begin:
	Disable('Tick');
}

defaultproperties
{
	ResolveFailedError="The master server could not be resolved: "
	TimeOutError="Timeout talking to the master server"
	CouldNotConnectError="Connecting to the master server timed out: "
}