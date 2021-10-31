class UBrowserFavoriteServers extends UBrowserServerListWindow;

function Created()
{
	Super.Created();
	Refresh();
}

function AddFavorite(UBrowserServerList Server)
{
	local UBrowserServerList NewItem;

//	Log("Adding Favorite: "$Server.IP);

	if (List.FindExistingServer(Server.IP, Server.QueryPort) == None)
		NewItem = UBrowserServerList(List.CopyExistingListItem(ServerListClass, Server));

	List.Sort();
	UBrowserFavoritesFact(FactoriesAr[0]).SaveFavorites();
}

function RemoveFavorite(UBrowserServerList Item)
{
//	Log("Removing Favorite: "$Item.IP);
	Item.Remove();
	UBrowserFavoritesFact(FactoriesAr[0]).SaveFavorites();
}

defaultproperties
{
	ListFactories(0)="UBrowser.UBrowserFavoritesFact"
}