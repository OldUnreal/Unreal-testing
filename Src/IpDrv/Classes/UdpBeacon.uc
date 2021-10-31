//=============================================================================
// UdpBeacon: Base class of beacon sender and receiver.
//=============================================================================
class UdpBeacon extends UdpLink
		config
			transient;

var() globalconfig bool       DoBeacon;
var() globalconfig int        ServerBeaconPort;		// Listen port
var() globalconfig int        BeaconPort;			// Reply port
var() globalconfig float      BeaconTimeout;
var() globalconfig string     BeaconProduct;

var int	UdpServerQueryPort;

function BeginPlay()
{
	if ( BindPort(ServerBeaconPort) )
	{
		log( "ServerBeacon listening on port "$ServerBeaconPort );
	}
	else
	{
		log( "ServerBeacon failed: Could not bind port "$ServerBeaconPort );
	}
	BroadcastBeacon(); // Initial notification.
}

function BroadcastBeacon()
{
	local IpAddr Addr;
	local string BeaconText;

	Log( "Broadcasting Beacon" );

	Addr.Addr = BroadcastAddr;
	Addr.Port = BeaconPort;
	BeaconText = Level.Game.GetBeaconText();
	SendText( Addr, BeaconProduct @ Mid(Level.GetAddressURL(),InStr(Level.GetAddressURL(),":")+1) @ BeaconText );
}


function BroadcastBeaconQuery()
{
	local IpAddr Addr;

	Log( "Broadcasting Query Beacon" );

	Addr.Addr = BroadcastAddr;
	Addr.Port = BeaconPort;

	SendText( Addr, BeaconProduct @ UdpServerQueryPort );
}


event ReceivedText( IpAddr Addr, string Text )
{
	if ( Text == "REPORT" )
		BroadcastBeacon();

	if ( Text == "REPORTQUERY" )
		BroadcastBeaconQuery();
}

function Destroyed()
{
	Super.Destroyed();
	Log("ServerBeacon Destroyed");
}


defaultproperties
{
	DoBeacon=True
	ServerBeaconPort=7775
	BeaconPort=7776
	BeaconTimeout=5.000000
	BeaconProduct="unreal"
	RemoteRole=ROLE_None
}
