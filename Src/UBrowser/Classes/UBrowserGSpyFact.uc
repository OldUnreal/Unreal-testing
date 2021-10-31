class UBrowserGSpyFact extends UBrowserServerListFactory;

var array<UBrowserGSpyLink> LinkAr;
var UBrowserGSpyLink Link; // Deprecated.
var int NumLinks,NumFinished;

// Deprecated: Old mod compatibility.
var transient protected string MasterServerAddress;
var transient protected int	MasterServerTCPPort;

struct FMasterServerEntry
{
	var() config string		MasterServerAddress;	// Address of the master server
	var() config int		MasterServerTCPPort;	// Port that the master server is listening on
	var() config int		MasterServerUdpPort;	// Port that the game server should connect to
};
var() config array<FMasterServerEntry> MasterServers;
var() nowarn config int 		Region;					// Region of the game server
var() config int		MasterServerTimeout;
var() config string		GameName;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	local int i;

	DestroyLinks();

	NumLinks = Array_Size(Default.MasterServers);
	Array_Size(LinkAr,NumLinks);
	NumFinished = 0;
	
	for( i=0; i<NumLinks; ++i )
	{
		LinkAr[i] = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserGSpyLink');

		LinkAr[i].MasterServerAddress = Default.MasterServers[i].MasterServerAddress;
		LinkAr[i].MasterServerTCPPort = Default.MasterServers[i].MasterServerTCPPort;
		LinkAr[i].Region = Region;
		LinkAr[i].MasterServerTimeout = MasterServerTimeout;
		LinkAr[i].GameName = GameName;
		LinkAr[i].OwnerFactory = Self;
		LinkAr[i].Start();
	}

	Super.Query();
}

function QueryFinished(bool bSuccess, optional string ErrorMsg)
{
	if( ++NumFinished<NumLinks )
		return;
	DestroyLinks();
	Super.QueryFinished(bSuccess, ErrorMsg);
}

function Shutdown(optional bool bBySuperset)
{
	DestroyLinks();
	Super.Shutdown(bBySuperset);
}

function DestroyLinks()
{
	local int i;
	
	for( i=0; i<NumLinks; ++i )
		if ( LinkAr[i]!=None && (GetPlayerOwner().GetEntryLevel().XLevel==LinkAr[i].XLevel || GetPlayerOwner().XLevel==LinkAr[i].XLevel) )
			LinkAr[i].Destroy();
	Array_Size(LinkAr,0);
	NumLinks = 0;
}

static final function ApplyNewServers( string S )
{
	local int i,P,PB;
	local string V,PV;

	Array_Size(Default.MasterServers,0);
	while( true )
	{
		// Grab next entry.
		i = InStr(S,"*");
		if( i==-1 )
			break;
		S = Mid(S,i+1);
		i = InStr(S,"*");
		if( i==-1 )
		{
			V = S;
			S = "";
		}
		else
		{
			V = Left(S,i);
			S = Mid(S,i+1);
		}
		
		// Grab Tcp port
		i = InStr(V,":");
		if( i==-1 )
			P = 28900;
		else
		{
			PV = Mid(V,i+1);
			V = Left(V,i);
			
			// Grab Upd port
			i = InStr(PV,":");
			if( i==-1 )
				PB = 27900;
			else
			{
				PB = int(Mid(PV,i+1));
				PV = Left(PV,i);
			}
			P = int(PV);
		}
		i = Array_Size(Default.MasterServers);
		Default.MasterServers[i].MasterServerAddress = V;
		Default.MasterServers[i].MasterServerTCPPort = P;
		Default.MasterServers[i].MasterServerUdpPort = PB;
		Log("MasterServer["$i$"] = "$V$":"$P$" UdpPort: "$PB,'UBrowser');
	}
	StaticSaveConfig();
}

defaultproperties
{
	MasterServerTimeout=20
	GameName="unreal"
}