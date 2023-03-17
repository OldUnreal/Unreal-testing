class WebConnection expands TcpLink;

var bool bWaitingFeed,bPendingSending;

var WebServer WebServer;
var WebAdminManager Manager;
var SubWebManager SubWeb;
var transient WebQuery Query;

var string AddressString;
var int AddressPort;

// Temp data.
var transient int PendingCount;
var transient byte PendingBytes[255];

event Accepted()
{
	local int i;

	WebServer = WebServer(Owner);
	Manager = WebServer.Manager;
	SubWeb = WebServer.SubWeb;

	AddressString = IpAddrToString(RemoteAddr);
	i = InStr(AddressString,":");
	AddressPort = int(Mid(AddressString,i+1));
	AddressString = Left(AddressString,i);
	LinkMode = MODE_Binary;
	ReceiveMode = RMODE_Manual;

	if( SubWeb.IgnoreRequest(Self) )
		Close();
	else
	{
		if( Query==None )
		{
			Query = Level.AllocateObj(class'WebQuery');
			Query.Connection = Self;
			Query.Manager = SubWeb;
		}

		bWaitingFeed = true;
		SetTimer(30, False);
	}
}
function Destroyed()
{
	if( Query!=None )
	{
		Query.Reset();
		Level.FreeObject(Query);
		Query = None;
	}
}

function Tick( float Delta )
{
	local byte i;

	if( bWaitingFeed )
	{
		while( IsDataPending() && i++<20 )
		{
			PendingCount = ReadBinary(255,PendingBytes);
			if( PendingCount==0 )
				break;
			Query.ReceivedBytes(PendingBytes,PendingCount);
			SetTimer(20, False);
		}
		if( Query.bCompleted )
		{
			bWaitingFeed = false;
			SubWeb.ProcessData(Query);
			bPendingSending = !Query.SendData();
		}
	}
	else if( bPendingSending )
	{
		SetTimer(20, False);
		bPendingSending = !Query.SendData();
	}
	else Close();
}

event Closed()
{
	Destroy();
}
event Timer()
{
	Close();
}

defaultproperties
{
}