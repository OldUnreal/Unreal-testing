//=============================================================================
// UBrowserLocalLink: Receives LAN beacons from servers.
//=============================================================================
class UBrowserLocalLink extends UdpLink
			transient;

// Misc
var UBrowserLocalFact			OwnerFactory;

// Config
var string						BeaconProduct;
var int							ServerBeaconPort;
var int							BeaconPort;

function Start()
{
	if ( BindPort( BeaconPort, true ) )
	{
		SetTimer( 5, false );
	}
	else
	{
		OwnerFactory.QueryFinished(False, "Beacon port in use.");
		return;
	}
	BroadcastBeacon();
}

function Timer()
{
	OwnerFactory.QueryFinished(True);
}

function BroadcastBeacon()
{
	local IpAddr Addr;

	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;

	SendText( Addr, "REPORTQUERY" );
}

event ReceivedText( IpAddr Addr, string Text )
{
	local int n;
	local int QueryPort;
	local string Address;

	n = len(BeaconProduct);
	if ( Left(Text,n+1) ~= (BeaconProduct$" ") )
	{
		QueryPort = int(Mid(Text, n+1));
		Address = IpAddrToString(Addr);
		Address = Left(Address, InStr(Address, ":"));
		OwnerFactory.FoundServer(Address, QueryPort, "", BeaconProduct);
	}
}

defaultproperties
{
}