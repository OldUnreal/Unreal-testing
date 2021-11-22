class UBrowserRecentServers extends UBrowserServerListWindow;

function Created()
{
	Super.Created();
	Refresh();
}
final function AddRecentServer(UBrowserServerList Server)
{
	local UBrowserServerList NewItem;

	if (List.FindExistingServer(Server.IP, Server.QueryPort) == None)
		NewItem = UBrowserServerList(List.CopyExistingListItem(ServerListClass, Server));
	UBrowserRecentFact(FactoriesAr[0]).AddServer(Server);
}

defaultproperties
{
	ListFactories(0)="UBrowser.UBrowserRecentFact"
}