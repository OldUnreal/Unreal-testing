//=============================================================================
// NetConfigPage.
//=============================================================================
class NetConfigPage expands ModPageContent;

static function LoadUpClassContent( WebQuery Query )
{
	local string GN;

	GN = string(Query.Connection.Level.Game.Class);

	Query.SendTextLine("<!-- Net config -->");
	StartTable(Query);
	AddConfigCheckbox(Query,"Allow older clients",(Query.Connection.Level.ConsoleCommand("Get TcpNetDriver AllowOldCLients")~="True"),"OL");
	AddConfigCheckbox(Query,"Allow downloaders",(Query.Connection.Level.ConsoleCommand("Get TcpNetDriver AllowDownloads")~="True"),"DL");
	AddConfigCheckbox(Query,"Fast downloads",(Query.Connection.Level.ConsoleCommand("Get TcpNetDriver AllowFastDownload")~="True"),"FD");
	AddConfigEditbox(Query,"Redirect downloads to URL",Query.Connection.Level.ConsoleCommand("Get HTTPDownload RedirectToURL"),80,"RD");
	AddConfigEditbox(Query,"Max download size",Query.Connection.Level.ConsoleCommand("Get TcpNetDriver MaxDownloadSize"),15,"MX");
	AddConfigCheckbox(Query,"Do server uplink",Class'UdpServerUplink'.Default.DoUplink,"UP");
	AddConfigEditbox(Query,"Max players",Query.Connection.Level.ConsoleCommand("Get"@GN@"MaxPlayers"),15,"MP");
	AddConfigEditbox(Query,"Max spectators",Query.Connection.Level.ConsoleCommand("Get"@GN@"MaxSpectators"),15,"MS");
	if( Query.UserPrivileges==255 )
		AddConfigEditbox(Query,"Admin password",Query.Connection.Level.ConsoleCommand("Get"@GN@"AdminPassword"),50,"AP");
	AddConfigEditbox(Query,"Game password",Query.Connection.Level.ConsoleCommand("Get"@GN@"GamePassword"),50,"GP");
	AddConfigCheckbox(Query,"Mute spectators",Query.Connection.Level.Game.bMuteSpectators,"ME");
	EndTable(Query);
	Query.SendTextLine("<p><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Submit\">");
	Query.SendTextLine("<!-- End of Net config code-->");
}
Static function ProcessReceivedData( WebQuery Query )
{
	local string GN;

	GN = " "$string(Query.Connection.Level.Game.Class)$" ";
	
	Query.Connection.ConsoleCommand("Set TcpNetDriver AllowOldClients"@Query.GetValue("OL","0"));
	Query.Connection.ConsoleCommand("Set TcpNetDriver AllowDownloads"@Query.GetValue("DL","0"));
	Query.Connection.ConsoleCommand("Set TcpNetDriver AllowFastDownload"@Query.GetValue("FD","0"));
	Query.Connection.ConsoleCommand("Set"@GN@"bMuteSpectators"@Query.GetValue("ME","0"));
	Query.Connection.ConsoleCommand("Set HTTPDownload RedirectToURL"@Query.GetValue("RD",Query.Connection.Level.ConsoleCommand("Get HTTPDownload RedirectToURL")));
	Query.Connection.ConsoleCommand("Set TcpNetDriver MaxDownloadSize"@Query.GetValue("MX",Query.Connection.Level.ConsoleCommand("Get TcpNetDriver MaxDownloadSize")));
	Query.Connection.ConsoleCommand("Set"@GN@"MaxPlayers"@Query.GetValue("MP",Query.Connection.Level.ConsoleCommand("Get"@GN@"MaxPlayers")));
	Query.Connection.ConsoleCommand("Set"@GN@"MaxSpectators"@Query.GetValue("MS",Query.Connection.Level.ConsoleCommand("Get"@GN@"MaxSpectators")));
	if( Query.UserPrivileges==255 )
		Query.Connection.ConsoleCommand("Set"@GN@"AdminPassword"@Query.GetValue("AP",Query.Connection.Level.ConsoleCommand("Get"@GN@"AdminPassword")));
	Query.Connection.ConsoleCommand("Set"@GN@"GamePassword"@Query.GetValue("GP",Query.Connection.Level.ConsoleCommand("Get"@GN@"GamePassword")));
	Class'UdpServerUplink'.Default.DoUplink = bool(Query.GetValue("UP","0"));
	Class'UdpServerUplink'.Static.StaticSaveConfig();
}

defaultproperties
{
	RequiredPrivileges=3
}