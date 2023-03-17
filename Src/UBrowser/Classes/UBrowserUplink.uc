Class UBrowserUplink extends UdpServerUplink;

function PreBeginPlay()
{
	local int Num,i;

	DoUplink = Class'UdpServerUplink'.Default.DoUplink;
	if ( !DoUplink )
	{
		Super.PreBeginPlay();
		return;
	}

	if( Class'UBrowserMasterServerFact'.Default.LastCheckDay!=Level.Day )
	{
		Class'UBrowserMasterServerFact'.Default.LastCheckDay = Level.Day;
		Class'UBrowserMasterServerFact'.Static.StaticSaveConfig();
		Spawn(class'UBrowserMServerLink');
	}
	Num = class'UBrowserGSpyFact'.Default.MasterServers.Size();
	if( Num<=0 )
	{
		Error("No masterservers specified.");
		return;
	}
	MasterServerAddress = class'UBrowserGSpyFact'.Default.MasterServers[0].MasterServerAddress;
	MasterServerPort = class'UBrowserGSpyFact'.Default.MasterServers[0].MasterServerUdpPort;
	Region = class'UBrowserGSpyFact'.Default.Region;
	
	for( i=1; i<Num; ++i )
	{
		Class'UdpServerUplink'.Default.MasterServerAddress = class'UBrowserGSpyFact'.Default.MasterServers[i].MasterServerAddress;
		Class'UdpServerUplink'.Default.MasterServerPort = class'UBrowserGSpyFact'.Default.MasterServers[i].MasterServerUdpPort;
		Class'UdpServerUplink'.Default.Region = Region;
		Class'UdpServerUplink'.Default.TargetQueryName = TargetQueryName;
		Spawn(class'UdpServerUplink');
	}
	Class'UdpServerUplink'.Default.MasterServerAddress = "";
	Super.PreBeginPlay();
}
