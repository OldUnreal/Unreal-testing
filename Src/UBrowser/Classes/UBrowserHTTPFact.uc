class UBrowserHTTPFact extends UBrowserServerListFactory;

var UBrowserHTTPLink Link;

var() config string		MasterServerAddress;	// Address of the master server
var() config string		MasterServerURI;
var() config int		MasterServerTCPPort;	// Optional port that the master server is listening on
var() config int		MasterServerTimeout;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserHTTPLink');

	Link.MasterServerAddress = MasterServerAddress;
	Link.MasterServerURI = MasterServerURI;
	Link.MasterServerTCPPort = MasterServerTCPPort;
	Link.MasterServerTimeout = MasterServerTimeout;
	Link.OwnerFactory = Self;
	Link.Start();

	Super.Query();
}

function QueryFinished(bool bSuccess, optional string ErrorMsg)
{
	Link.Destroy();
	Link = None;

	Super.QueryFinished(bSuccess, ErrorMsg);
}

function Shutdown(optional bool bBySuperset)
{
	if (Link != None)
		Link.Destroy();
	Link = None;
	Super.Shutdown(bBySuperset);
}

defaultproperties
{
	MasterServerAddress="master.telefragged.com"
	MasterServerURI="/servers.txt"
	MasterServerTCPPort=80
	MasterServerTimeout=20
}