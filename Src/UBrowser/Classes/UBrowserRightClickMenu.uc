class UBrowserRightClickMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Refresh, RefreshServer, PingAll, Info, Favorites, PasswordJoin, ServerJoin[2], Website, Copyaddr;

var(Text) localized string RefreshName;
var(Text) localized string FavoritesName;
var(Text) localized string RemoveFavoritesName;
var(Text) localized string RefreshServerName;
var(Text) localized string PingAllName,InfoName;
var(Text) localized string JoinPasswordName,JoinServerName,SpectateServerName,ServerWebsiteName,CopyAddressName;

var UBrowserServerGrid	Grid;
var UBrowserServerList	List;

function Created()
{
	bTransient = True;
	Super.Created();

	ServerJoin[0] = AddMenuItem(JoinServerName, None);
	ServerJoin[1] = AddMenuItem(SpectateServerName, None);
	PasswordJoin = AddMenuItem(JoinPasswordName, None);
	Info = AddMenuItem(InfoName, None);
	Info.bDisabled = !Class'UBrowserInfoClientWindow'.Default.bClassicWindow;
	AddMenuItem("-", None);
	Favorites = AddMenuItem(FavoritesName, None);
	AddMenuItem("-", None);
	RefreshServer = AddMenuItem(RefreshServerName, None);
	PingAll = AddMenuItem(PingAllName, None);
	Refresh = AddMenuItem(RefreshName, None);
	AddMenuItem("-", None);
	Website = AddMenuItem(ServerWebsiteName, None);
	Copyaddr = AddMenuItem(CopyAddressName, None);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Info:
		if (!Info.bDisabled)
			Grid.ShowInfo(List);
		break;
	case Favorites:
		if (UBrowserFavoriteServers(UBrowserServerList(List.Sentinel).Owner) != None)
			UBrowserFavoriteServers(UBrowserServerList(List.Sentinel).Owner).RemoveFavorite(List);
		else
			UBrowserServerListWindow(Grid.GetParent(class'UBrowserServerListWindow')).AddFavorite(List);
		break;
	case Refresh:
		Grid.Refresh();
		break;
	case PingAll:
		Grid.RePing();
		break;
	case RefreshServer:
		Grid.RefreshServer();
		break;
	case PasswordJoin:
		if (!PasswordJoin.bDisabled)
			Grid.PasswordJoinMenu(List);
		break;
	case ServerJoin[0]:
		if (!ServerJoin[0].bDisabled)
			Grid.JoinAServer(List,False);
		break;
	case ServerJoin[1]:
		if (!ServerJoin[1].bDisabled)
			Grid.JoinAServer(List,True);
		break;
	case Website:
		if( !Website.bDisabled )
			Grid.OpenServerWebsite(List);
		break;
	case Copyaddr:
		if( !PasswordJoin.bDisabled )
			Root.CopyText("unreal://"$List.IP$":"$List.GamePort);
		break;
	}

	Super.ExecuteItem(I);
}

function RMouseDown(float X, float Y)
{
	LMouseDown(X, Y);
}

function RMouseUp(float X, float Y)
{
	LMouseUp(X, Y);
}

function ShowWindow()
{
	PasswordJoin.bDisabled = (!List || !List.ValidGamePort());
	Website.bDisabled = (List == None || Len(List.ServerWebPage)==0);
	ServerJoin[0].bDisabled = PasswordJoin.bDisabled;
	ServerJoin[1].bDisabled = PasswordJoin.bDisabled;

	if ( PasswordJoin.bDisabled )
		Info.bDisabled = True;
	else Info.bDisabled = !Class'UBrowserInfoClientWindow'.Default.bClassicWindow;

	if (List != None && UBrowserFavoriteServers(UBrowserServerList(List.Sentinel).Owner) != None)
		Favorites.SetCaption(RemoveFavoritesName);
	else
		Favorites.SetCaption(FavoritesName);

	Favorites.bDisabled = (List == None);
	RefreshServer.bDisabled = Favorites.bDisabled;
	Copyaddr.bDisabled = Favorites.bDisabled;
	Selected = None;

	Super.ShowWindow();
}

function CloseUp()
{
	HideWindow();
}

defaultproperties
{
	RefreshName="&Refresh All Servers"
	FavoritesName="Add to &Favorites"
	RemoveFavoritesName="Remove from &Favorites"
	RefreshServerName="&Ping This Server"
	PingAllName="Ping &All Servers"
	InfoName="&Server and Player Info"
	JoinPasswordName="Join with &Password"
	JoinServerName="&Join server"
	SpectateServerName="Join as &Spectator"
	ServerWebsiteName="Show server &Website"
	CopyAddressName="&Copy server address"
}