class UBrowserRecentFact extends UBrowserServerListFactory
	Config(User);

struct RecentServerType
{
	var config int ServerPort;
	var config string ServerName,ServerIP;
};
var config array<RecentServerType> RecentServer;
var config int MaxEntries;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	local int i,l;

	l = Array_Size(RecentServer);
	for ( i=0; i<l; i++ )
		FoundServer(RecentServer[i].ServerIP, RecentServer[i].ServerPort, "", "Unreal", RecentServer[i].ServerName);

	Super.Query();
	QueryFinished(True);
}
final function AddServer( UBrowserServerList Server )
{
	local int c,i;

	// Remove any same entries
	c = Array_Size(RecentServer);
	for( i=0; i<c; i++ )
		if( RecentServer[i].ServerPort==Server.QueryPort && RecentServer[i].ServerIP==Server.IP )
		{
			Array_Remove(RecentServer,i);
			c--;
			i--;
		}

	Array_Insert(RecentServer,0,1);
	RecentServer[0].ServerName = Class'UBrowserFavoritesFact'.Static.StripIniChars(Server.HostName);
	RecentServer[0].ServerIP = Server.IP;
	RecentServer[0].ServerPort = Server.QueryPort;

	// Remove extra entries
	if( MaxEntries>0 )
	{
		c++;
		if( c>MaxEntries )
			Array_Remove(RecentServer,MaxEntries,(c-MaxEntries));
	}
	SaveConfig();
}

defaultproperties
{
	MaxEntries=20
}