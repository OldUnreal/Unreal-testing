// Used for getting the latest news from some web page.
Class UBrowserServerWebLink extends UBrowserBufferedTcpLink;

var IpAddr ServerIpAddr;
var UBrowserServerWebWin FeedbackObj;
var string ExpectingURL,HostAddress;
var int HostPort;
var string ReceivedBuffer;

var bool bHTMLSiteYet;

function BeginPlay()
{
	Disable('Tick');
	Super.BeginPlay();
}

function ResetBuffer()
{
	OutputQueueLen = 0;
	InputQueueLen = 0;
	InputBufferHead = 0;
	InputBufferTail = 0;
	OutputBufferHead = 0;
	OutputBufferTail = 0;
	bWaiting = false;
	CRLF = Chr(10)$Chr(13);
	CR = Chr(13);
	LF = Chr(10);
	bEOF = False;
	LinkMode = MODE_Line;
	ReceiveMode = RMODE_Event;
	ReceivedBuffer = "";
	bHTMLSiteYet = false;
}

function Start( string HTTPAddress, string HTTPURL, int TCPPort )
{
	ResetBuffer();
	ServerIpAddr.Port = TCPPort;
	ExpectingURL = HTTPURL;
	HostAddress = HTTPAddress;
	HostPort = TCPPort;
	Resolve(HTTPAddress);
}
function Resolved( IpAddr Addr )
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;

	// Handle failure.
	if ( ServerIpAddr.Addr == 0 )
	{
		FeedbackObj.ReceivedError("Invalid master server address, aborting");
		return;
	}

	// Bind the local port.
	if ( !BindPort() )
	{
		FeedbackObj.ReceivedError("Error binding local port, aborting");
		return;
	}

	Open(ServerIpAddr);
	SetTimer(30, False);
}
event Timer()
{
	FeedbackObj.ReceivedError("Query timed out (30 seconds)");
	Destroy();
}

// Host resolution failue.
function ResolveFailed()
{
	FeedbackObj.ReceivedError("Failed to resolve master server address, aborting");
	Destroy();
}

event Opened()
{
	local string OutPut;

	// Send request
	OutPut = "GET "$ExpectingURL$" HTTP/1.0"$CR$LF;
	OutPut = OutPut$"User-Agent: Unreal"$CR$LF;
	OutPut = OutPut$"Host:"$HostAddress$":"$HostPort$CR$LF$CR$LF;
	SendText(OutPut);
}
event ReceivedLine( string Line )
{
	local int i;

	if ( !bHTMLSiteYet )
	{
		i = InStr(Line,"<"); // Assume that the page starts from here.
		if ( i==-1 )
			Return;
		bHTMLSiteYet = True;
		Line = Mid(Line,i);
	}
	// Log(Line);
	ReceivedBuffer = ReceivedBuffer$Line;
}
event Closed()
{
	FeedbackObj.ReceivedSuccess(ReceivedBuffer);
	Destroy();
}
function Destroyed()
{
	FeedbackObj.LinkDestroyed(Self);
	Super.Destroyed();
}

defaultproperties
{
}