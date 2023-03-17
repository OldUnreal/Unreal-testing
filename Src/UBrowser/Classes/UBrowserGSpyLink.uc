class UBrowserGSpyLink extends UBrowserBufferedTcpLink;

// Misc
var UBrowserGSpyFact		OwnerFactory;
var IpAddr					MasterServerIpAddr;
var bool					bOpened;
var bool					bNewListing;

// Params
var string					MasterServerAddress;	// Address of the master server
var int						MasterServerTCPPort;	// Optional port that the master server is listening on
var nowarn int 					Region;					// Region of the game server
var int						MasterServerTimeout;
var string					GameName;

// Error messages
var localized string		ResolveFailedError;
var localized string		TimeOutError;
var localized string		CouldNotConnectError;

// for WaitFor
const FoundSecureRequest = 1;
const FoundSecret        = 2;
const NextIP             = 3;
const NextAddress        = 4;
const NextServerName     = 5;

function BeginPlay()
{
	Disable('Tick');
	Super.BeginPlay();
}

function Start()
{
	ResetBuffer();

	MasterServerIpAddr.Port = MasterServerTCPPort;

	if ( MasterServerAddress=="" )
		MasterServerAddress = "master"$Region$".gamespy.com";

	Resolve( MasterServerAddress );
}

function DoBufferQueueIO()
{
	Super.DoBufferQueueIO();
}

function Resolved( IpAddr Addr )
{
	// Set the address
	MasterServerIpAddr.Addr = Addr.Addr;

	// Handle failure.
	if ( MasterServerIpAddr.Addr == 0 )
	{
		Log( "UBrowserGSpyLink: Invalid master server address, aborting." ,'UBrowser');
		return;
	}

	// Display success message.
	Log( "UBrowserGSpyLink: Master Server is "$MasterServerAddress$":"$MasterServerIpAddr.Port ,'UBrowser');

	// Bind the local port.
	if ( !BindPort() )
	{
		Log( "UBrowserGSpyLink: Error binding local port, aborting." ,'UBrowser');
		return;
	}

	Open( MasterServerIpAddr );
	SetTimer(MasterServerTimeout, False);
}

event Timer()
{
	if (!bOpened)
	{
		Log("UBrowserGSpyLink: Couldn't connect to master server.");
		OwnerFactory.QueryFinished(False, CouldNotConnectError$MasterServerAddress);
		GotoState('Done');
	}
}

event Closed()
{
//	Log( "Connection to Master server closed" );
}

// Host resolution failue.
function ResolveFailed()
{
	Log("UBrowserGSpyLink: Failed to resolve master server address, aborting.",'UBrowser');
	OwnerFactory.QueryFinished(False, ResolveFailedError$MasterServerAddress);
	GotoState('Done');
}

event Opened()
{
	bOpened = True;
	Enable('Tick');
//	Log( "Successfully connected to Master server" );

	WaitFor("\\basic\\\\secure\\", 5, FoundSecureRequest);
}


function Tick(float DeltaTime)
{
	DoBufferQueueIO();
}

final function string GetLocalIPAddress()
{
	local IpAddr Address;
	local string S;
	
	GetLocalIP(Address);
	S = IpAddrToString(Address);
	return Left(S,InStr(S,":"));
}

function HandleServer(string Text)
{
	local string	Address;
	local string	Port, GamePort;
	local bool		bIsLan;
	local UBrowserServerList L;

	if( Right(Text,1)=="\\" )
		Text = Left(Text,Len(Text)-1);
	Address = ParseDelimited(Text, ":", 1);
	Port = ParseDelimited(Text, ":", 2);
	if( bNewListing )
		GamePort = ParseDelimited(Text, ":", 3);
	
	if( Address=="LAN" )
	{
		bIsLan = true;
		Address = GetLocalIPAddress();
	}
	L = OwnerFactory.FoundServer(Address, int(Port), "", GameName);
	L.bLocalServer = bIsLan;
	if( Len(GamePort) )
		L.SetGamePort(int(GamePort), true);
}

function GotMatch(int MatchData)
{
	switch (MatchData)
	{
	case FoundSecureRequest:
		Enable('Tick');
		//Log("FoundSecureRequest >>"$WaitResult$"<<");
		WaitForCount(6, 5, FoundSecret);
		break;
	case FoundSecret:
		Enable('Tick');
		//Log("FoundSecret >>"$WaitResult$"<<");
		SendBufferedData("\\gamename\\"$GameName$"\\location\\"$Region$"\\validate\\"$Validate(WaitResult, GameName)$"\\final\\");
		GotoState('FoundSecretState');
		break;
	case NextIP:
		Enable('Tick');
		if (WaitResult == "final\\")
		{
			OwnerFactory.QueryFinished(True);
			GotoState('Done');
		}
		else
			WaitFor("\\", 10, NextAddress);
		break;
	case NextAddress:
		Enable('Tick');
		if (WaitResult == "nl\\")
		{
			bNewListing = true;
			WaitFor("\\", 10, NextIP);
		}
		else
		{
			HandleServer(WaitResult);
			WaitFor("\\", 5, NextIP);
		}
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
state FoundSecretState
{
	function Tick(float Delta)
	{
		Global.Tick(Delta);

		// Hack for 0 servers in server list
		if (!IsConnected() && WaitResult == "\\final\\")
		{
			OwnerFactory.QueryFinished(True);
			GotoState('Done');
		}
	}

Begin:
	Enable('Tick');
	Sleep(2);
	SendBufferedData("\\list\\227\\gamename\\"$GameName$"\\final\\");
	WaitFor("ip\\", 30, NextIP);
}

state Done
{
Begin:
	Disable('Tick');
//	Log("Done");
}

defaultproperties
{
	ResolveFailedError="The master server could not be resolved: "
	TimeOutError="Timeout talking to the master server"
	CouldNotConnectError="Connecting to the master server timed out: "
}