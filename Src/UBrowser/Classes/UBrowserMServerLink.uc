/* Used for getting master servers list.
Format is:
<VER>1000</VER>
<MSL>www.newsite.com:80/serverslist.txt</MSL> - Optional, link clients to a new list site.
*master.somesite.com:33333:2222* - Some comments can be added here.
*master.othersite.com:66666:2222* - Format is Address:TcpPort:UdpPort
*/
Class UBrowserMServerLink extends UBrowserBufferedTcpLink;

var IpAddr ServerIpAddr;
var string HostURL,HostAddress;
var int HostPort;
var string ReceivedBuffer;

var bool bHeader;

function BeginPlay()
{
	Disable('Tick');
	Super.BeginPlay();

	ResetBuffer();
	ServerIpAddr.Port = Class'UBrowserMasterServerFact'.Default.MasterServersPort;
	HostURL = Class'UBrowserMasterServerFact'.Default.MasterServersURL;
	HostAddress = Class'UBrowserMasterServerFact'.Default.MasterServersSite;
	HostPort = Class'UBrowserMasterServerFact'.Default.MasterServersPort;
	ReceiveMode = RMODE_Event;
	Resolve(HostAddress);
}

function Resolved( IpAddr Addr )
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;

	// Handle failure.
	if ( ServerIpAddr.Addr == 0 )
		return;

	// Bind the local port.
	if ( !BindPort(Rand(5000),true) )
		return;

	Open(ServerIpAddr);
}

// Host resolution failue.
function ResolveFailed()
{
	Destroy();
}

event Opened()
{
	local string OutPut;

	// Send request
	OutPut = "GET "$HostURL$" HTTP/1.0"$CR$LF;
	OutPut = OutPut$"User-Agent: Unreal"$CR$LF;
	OutPut = OutPut$"Host:"$HostAddress$":"$HostPort$CR$LF$CR$LF;
	SendText(OutPut);
	//log("MasterServerLink Output"@OutPut);
}
event ReceivedLine( string Line )
{
	local int i;

	if ( !bHeader )
	{
		i = InStr(Line,"<VER>"); // Assume that the page starts from here.
		if ( i==-1 )
			Return;
		bHeader = True;
		Line = Mid(Line,i+5);
	}
	ReceivedBuffer = ReceivedBuffer$Line;
}
event Closed()
{
	Class'UBrowserMasterServerFact'.Static.UpdateMasterServers(ReceivedBuffer);
	Destroy();
}

defaultproperties
{
	LifeSpan=30
}
