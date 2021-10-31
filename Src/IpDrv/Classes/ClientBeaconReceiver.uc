//=============================================================================
// ClientBeaconReceiver: Receives LAN beacons from servers.
//=============================================================================
class ClientBeaconReceiver extends UdpBeacon
			transient;

var struct BeaconInfo
{
	var IpAddr      Addr;
	var float       Time;
	var string      Text;
} Beacons[32];

function string GetBeaconAddress( int i )
{
	return IpAddrToString(Beacons[i].Addr);
}

function string GetBeaconText(int i)
{
	return Beacons[i].Text;
}

function BeginPlay()
{
	if ( BindPort( BeaconPort, true ) )
	{
		SetTimer( 1.0, true );
		log( "ClientBeaconReceiver initialized." );
	}
	else
	{
		log( "ClientBeaconReceiver failed: Beacon port in use." );
	}
	BroadcastBeacon();
}

function Destroyed()
{
	log( "ClientBeaconReceiver finished." );
}

function Timer()
{
	local int i, j;
	for ( i=0; i<arraycount(Beacons); i++ )
		if
		(	Beacons[i].Addr.Addr!=0
				&&	Level.TimeSeconds-Beacons[i].Time<BeaconTimeout )
			Beacons[j++] = Beacons[i];
	for ( j=j; j<arraycount(Beacons); j++ )
		Beacons[j].Addr.Addr=0;
}

function BroadcastBeacon()
{
	local IpAddr Addr;

	Addr.Addr = BroadcastAddr;
	Addr.Port = ServerBeaconPort;

	SendText( Addr, "REPORT" );
}

event ReceivedText( IpAddr Addr, string Text )
{
	local int i, n;

	n = len(BeaconProduct);
	if ( left(Text,n+1) ~= (BeaconProduct$" ") )
	{
		Text = mid(Text,n+1);
		Addr.Port = int(Text);
		for ( i=0; i<arraycount(Beacons); i++ )
			if ( Beacons[i].Addr==Addr )
				break;
		if ( i==arraycount(Beacons) )
			for ( i=0; i<arraycount(Beacons); i++ )
				if ( Beacons[i].Addr.Addr==0 )
					break;
		if ( i==arraycount(Beacons) )
			return;
		Beacons[i].Addr      = Addr;
		Beacons[i].Time      = Level.TimeSeconds;
		Beacons[i].Text      = mid(Text,InStr(Text," ")+1);
	}
}

defaultproperties
{
}
