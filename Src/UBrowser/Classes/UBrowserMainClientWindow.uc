//=============================================================================
// UBrowserMainClientWindow - The main client area
//=============================================================================
class UBrowserMainClientWindow extends UWindowClientWindow;

var globalconfig string		LANTabName;
var() globalconfig enum InitalPageE
{
	PG_NewsPage,
	PG_FavoritesPage,
	PG_AllServersPage
} InitialPage;

var UWindowPageControl		PageControl;
var UWindowPageControlPage	LANPage;
var UWindowPageControlPage	NewsPage;
var UWindowTabControlItem	PageBeforeLAN;
var UBrowserOpenBar			OpenBar;

var UWindowPageControlPage	Favorites;
var UWindowPageControlPage	Recent;
var localized string		FavoritesName,NewsName,RecentName;

var() globalconfig array<string> ServerListTitles;
var() globalconfig array<name> ServerListNames;

var UBrowserServerListWindow FactoryWindows[20];
var array<UBrowserServerListWindow> DynFactoryWindows;

var int NumDynFactoryWindows;

const OpenBarHeight=30;

function Created()
{
	local int i;
	local UWindowPageControlPage P,AllP;
	local UBrowserServerListWindow W;

	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, OpenBarHeight, WinWidth, WinHeight-OpenBarHeight));

	// Add news
	NewsPage = PageControl.AddPage(NewsName, class'UBrowserNewsWindow');

	// Add recent servers
	Recent = PageControl.AddPage(RecentName, class'UBrowserRecentServers');

	// Add favorites
	Favorites = PageControl.AddPage(FavoritesName, class'UBrowserFavoriteServers');

	// Init size.
	NumDynFactoryWindows = Array_Size(ServerListNames);
	Array_Size(DynFactoryWindows,NumDynFactoryWindows);

	for (i=0; i<NumDynFactoryWindows; i++)
	{
		P = PageControl.AddPage(ServerListTitles[i], class'UBrowserServerListWindow', ServerListNames[i]);
		if ( ServerListNames[i]=='UBrowserAll' )
			AllP = P;
		W = UBrowserServerListWindow(P.Page);

		if (string(ServerListNames[i]) ~= LANTabName)
			LANPage = P;

		DynFactoryWindows[i] = W;
		
		if (i<20)
			FactoryWindows[i] = W;
	}

	for (i=0; i<NumDynFactoryWindows; i++)
		if (DynFactoryWindows[i] != None)
			DynFactoryWindows[i].Refresh(False, True);

	//deprecated, for mod compatibility only. Don't use, use DynFactoryWindows instead!
	for(i=0; i<20; i++)
		if(FactoryWindows[i] != None)
			FactoryWindows[i].Refresh(False, True);

	OpenBar	= UBrowserOpenBar(CreateWindow(class'UBrowserOpenBar', 0, 0, WinWidth, OpenBarHeight));

	switch ( InitialPage )
	{
	Case PG_FavoritesPage:
		PageControl.GotoTab(Favorites, True);
		Break;
	Case PG_AllServersPage:
		PageControl.GotoTab(AllP, True);
		Break;
	}
	Super.Created();
	SaveConfig();
}

function SelectLAN()
{
	if (LANPage != None)
	{
		PageBeforeLAN = PageControl.SelectedTab;
		PageControl.GotoTab(LANPage, True);
	}
}

function SelectInternet()
{
	if (PageBeforeLAN != None && PageControl.SelectedTab == LANPage)
		PageControl.GotoTab(PageBeforeLAN, True);
	PageBeforeLAN = None;
}

function Resized()
{
	local float Y;

	Y = 0;

	if (OpenBar.bWindowVisible)
	{
		OpenBar.SetSize(WinWidth, OpenBarHeight);
		Y += OpenBarHeight;
	}

	PageControl.WinTop = Y;
	PageControl.SetSize(WinWidth, WinHeight-Y);
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

function SaveConfigs()
{
	SaveConfig();
}

defaultproperties
{
	LANTabName="UBrowserLAN"
	FavoritesName="Favorites"
	NewsName="Community News"
	RecentName="Recent servers"
}