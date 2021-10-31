class UBrowserLocalFact extends UBrowserServerListFactory;

var UBrowserLocalLink		Link;

// Config
var() config string	BeaconProduct;
var config int				ServerBeaconPort;
var config int				BeaconPort;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	// Update status bar
	Owner.Owner.PingFinished();

	if ( Link!=None && (GetPlayerOwner().GetEntryLevel().XLevel==Link.XLevel || GetPlayerOwner().XLevel==Link.XLevel) )
		Link.Destroy();
	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserLocalLink');

	Link.BeaconProduct = BeaconProduct;
	Link.ServerBeaconPort = ServerBeaconPort;
	Link.BeaconPort = BeaconPort;

	Link.OwnerFactory = Self;
	Link.Start();

	Super.Query();
}

function UBrowserServerList FoundServer(string IP, int QueryPort, string Category, string GameName, optional string HostName)
{
	local UBrowserServerList l;

	l = Super.FoundServer(IP, QueryPort, Category, GameName);

	l.bLocalServer = True;

	if (!l.bPinging)
		l.PingServer(True, True, Owner.Owner.bNoSort);

	return l;
}

function QueryFinished(bool bSuccess, optional string ErrorMsg)
{
	if ( GetPlayerOwner().GetEntryLevel().XLevel==Link.XLevel || GetPlayerOwner().XLevel==Link.XLevel )
		Link.Destroy();
	Link = None;

	Super.QueryFinished(bSuccess, ErrorMsg);

	// Update status bar
	Owner.Owner.PingFinished();
}

function Shutdown(optional bool bBySuperset)
{
	if (Link != None && (GetPlayerOwner().GetEntryLevel().XLevel==Link.XLevel || GetPlayerOwner().XLevel==Link.XLevel) )
		Link.Destroy();
	Link = None;
	Super.Shutdown(bBySuperset);
}

defaultproperties
{
	BeaconProduct="unreal"
	ServerBeaconPort=7775
	BeaconPort=7776
	bIncrementalPing=True
}