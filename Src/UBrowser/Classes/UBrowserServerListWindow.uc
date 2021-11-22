class UBrowserServerListWindow extends UWindowPageWindow
			PerObjectConfig;

var config array<string>		ListFactories;
var config string				URLAppend;
var config int					AutoRefreshTime;
var config bool					bNoAutoSort;

var UBrowserServerList			List;
var() class<UBrowserServerList>	ServerListClass;
var array<UBrowserServerListFactory> FactoriesAr;
var UBrowserServerListFactory	Factories[10]; // Deprecated.
var array<byte>					QueryDone;
var int							NumFactories;
var UBrowserServerGrid			Grid;
var string						GridClass;
var float						TimeElapsed;
var bool						bPingSuspend;
var bool						bPingResume;
var bool						bPingResumeIntial;
var bool						bNoSort;
var bool						bSuspendPingOnClose;
var UBrowserSubsetList			SubsetList;
var UBrowserSupersetList		SupersetList;

// Status info
enum EPingState
{
	PS_QueryServer,
	PS_QueryFailed,
	PS_Pinging,
	PS_RePinging,
	PS_Done
};

var localized string			PlayerCountName;
var localized string			ServerCountName;
var	localized string			QueryServerText;
var	localized string			QueryFailedText;
var	localized string			PingingText;
var	localized string			CompleteText;

var int							TotalPinged;
var int							TotalServers;
var string						ErrorString;
var EPingState					PingState;

var UWindowVSplitter			VSplitter;
var UBrowserInfoClientWindow	InfoClient;
var UBrowserServerList			InfoItem;
var localized string			InfoName;

var bool bNowOnClassic;

function WindowShown()
{
	local UBrowserSupersetList l;

	Super.WindowShown();
	if( Class'UBrowserInfoClientWindow'.Default.bClassicWindow!=bNowOnClassic )
		ToggleInfoWinType();
	
	if( InfoClient )
	{
		if( UWindowVSplitter(InfoClient.ParentWindow) )
			VSplitter.SplitPos = UWindowVSplitter(InfoClient.ParentWindow).SplitPos;
		InfoClient.Server = InfoItem;
	}

	ResumePinging();

	for (l = UBrowserSupersetList(SupersetList.Next); l; l = UBrowserSupersetList(l.Next))
		l.SuperSetWindow.ResumePinging();
}

function WindowHidden()
{
	local UBrowserSupersetList l;

	Super.WindowHidden();
	SuspendPinging();

	for (l = UBrowserSupersetList(SupersetList.Next); l; l = UBrowserSupersetList(l.Next))
		l.SuperSetWindow.SuspendPinging();
}

function SuspendPinging()
{
	if (bSuspendPingOnClose)
		bPingSuspend = True;
}

function ResumePinging()
{
	bPingSuspend = False;
	if (bPingResume)
	{
		bPingResume = False;
		List.PingNext(bPingResumeIntial, bNoSort);
	}
}

function Created()
{
	local Class<UBrowserServerGrid> C;

	C = class<UBrowserServerGrid>(DynamicLoadObject(GridClass, class'Class'));
	VSplitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));
	VSplitter.MinWinHeight = 60;
	VSplitter.SplitPos = WinHeight - Min(WinHeight / 2, 150);
	VSplitter.SetAcceptsFocus();

	if ( Class'UBrowserInfoClientWindow'.Default.bClassicWindow )
	{
		VSplitter.HideWindow();
		Grid = UBrowserServerGrid(CreateWindow(C, 0, 0, WinWidth, WinHeight));
		bNowOnClassic = True;
	}
	else
	{
		Grid = UBrowserServerGrid(VSplitter.CreateWindow(C, 0, 0, WinWidth, WinHeight));
		InfoClient = UBrowserInfoClientWindow(VSplitter.CreateWindow(class'UBrowserInfoClientWindow', 0, 0, WinWidth, WinHeight));
		InfoClient.ListWin = Self;
		VSplitter.TopClientWindow = Grid;
		VSplitter.BottomClientWindow = InfoClient;
	}

	SubsetList = new class'UBrowserSubsetList';
	SubsetList.SetupSentinel();

	SupersetList = new class'UBrowserSupersetList';
	SupersetList.SetupSentinel();
}

function ToggleInfoWinType()
{
	bNowOnClassic = !bNowOnClassic;
	if ( InfoClient!=None )
	{
		InfoClient.SetStyle(bNowOnClassic);
		if ( InfoClient.bClassicWindow!=bNowOnClassic )
		{
			InfoClient.bClassicWindow = bNowOnClassic;
			InfoClient.SaveConfig();
		}
	}
	else if ( Class'UBrowserInfoClientWindow'.Default.bClassicWindow!=bNowOnClassic )
	{
		Class'UBrowserInfoClientWindow'.Default.bClassicWindow = bNowOnClassic;
		Class'UBrowserInfoClientWindow'.Static.StaticSaveConfig();
	}
	if ( bNowOnClassic )
	{
		Grid.SetParent(Self);
		InfoClient.SetParent(InfoClient.FramedWindowOwner);
		VSplitter.TopClientWindow = None;
		VSplitter.BottomClientWindow = None;
		VSplitter.HideWindow();
		if ( InfoClient.Server!=None )
			InfoClient.FramedWindowOwner.WindowTitle = "Info - "$List.HostName;
		else InfoClient.FramedWindowOwner.HideWindow();
		InfoClient.FramedWindowOwner.SetSize(350,250);
		Grid.SetSize(WinWidth,WinHeight);
	}
	else
	{
		Grid.SetParent(VSplitter);
		if ( InfoClient==None )
		{
			InfoClient = UBrowserInfoClientWindow(VSplitter.CreateWindow(class'UBrowserInfoClientWindow', 0, 0, WinWidth, WinHeight));
			InfoClient.ListWin = Self;
		}
		else
		{
			InfoClient.SetParent(VSplitter);
			InfoClient.ShowWindow();
		}
		VSplitter.TopClientWindow = Grid;
		VSplitter.BottomClientWindow = InfoClient;
		VSplitter.ShowWindow();
	}
}

function AutoInfo(UBrowserServerList I)
{
	if ( !bNowOnClassic )
		ShowInfo(I, True);
}

function ShowInfo(UBrowserServerList I, optional bool bAutoInfo)
{
	if (I == None) return;
	InfoItem = I;
	InfoClient.Server = InfoItem;
	I.ServerStatus();
}
function ShowInfoX(UBrowserServerList List)
{
	if ( InfoClient==None )
	{
		InfoClient = UBrowserInfoClientWindow(Root.CreateWindow(class'UBrowserInfoClientWindow', 0, 0, WinWidth, WinHeight));
		InfoClient.ListWin = Self;
	}
	else InfoClient.ShowWindow();
	InfoItem = List;
	InfoClient.BringToFront();
	InfoClient.Server = List;
	if ( InfoClient.FramedWindowOwner!=None )
	{
		InfoClient.FramedWindowOwner.WindowTitle = "Info - "$List.HostName;
		InfoClient.FramedWindowOwner.BringToFront();
	}
	List.ServerStatus();
}
function Resized()
{
	Super.Resized();
	VSplitter.SetSize(WinWidth, WinHeight);
	Grid.SetSize(WinWidth, WinHeight);
}

function AddSubset(UBrowserSubsetFact Subset)
{
	local UBrowserSubsetList l;

	for (l = UBrowserSubsetList(SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
		if (l.SubsetFactory == Subset)
			return;

	l = UBrowserSubsetList(SubsetList.Append(class'UBrowserSubsetList'));
	l.SubsetFactory = Subset;
}

function AddSuperSet(UBrowserServerListWindow Superset)
{
	local UBrowserSupersetList l;

	for (l = UBrowserSupersetList(SupersetList.Next); l != None; l = UBrowserSupersetList(l.Next))
		if (l.SupersetWindow == Superset)
			return;

	l = UBrowserSupersetList(SupersetList.Append(class'UBrowserSupersetList'));
	l.SupersetWindow = Superset;
}


function RemoveSubset(UBrowserSubsetFact Subset)
{
	local UBrowserSubsetList l;

	for (l = UBrowserSubsetList(SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
		if (l.SubsetFactory == Subset)
			l.Remove();
}

function RemoveSuperset(UBrowserServerListWindow Superset)
{
	local UBrowserSupersetList l;

	for (l = UBrowserSupersetList(SupersetList.Next); l != None; l = UBrowserSupersetList(l.Next))
		if (l.SupersetWindow == Superset)
			l.Remove();
}

function AddFavorite(UBrowserServerList Server)
{
	UBrowserServerListWindow(UBrowserMainClientWindow(GetParent(class'UBrowserMainClientWindow')).Favorites.Page).AddFavorite(Server);
}

function Refresh(optional bool bBySuperset, optional bool bInitial, optional bool bSaveExistingList, optional bool bInNoSort)
{
	if (!bSaveExistingList && List != None)
	{
		List.DestroyList();
		List = None;
		Grid.SelectedServer = None;
	}

	if (List == None)
	{
		List=New ServerListClass;
		List.Owner = Self;
		List.SetupSentinel();
	}
	else
	{
		TagServersAsOld();
	}

	PingState = PS_QueryServer;
	ShutdownFactories(bBySuperset);
	CreateFactories();
	Query(bBySuperset, bInitial, bInNoSort);

	if (!bInitial)
		RefreshSubsets();
}

function TagServersAsOld()
{
	local UBrowserServerList l;

	for (l = UBrowserServerList(List.Next); l != None; l = UBrowserServerList(l.Next))
		l.bOldServer = True;
}

function RemoveOldServers()
{
	local UBrowserServerList l, n;

	l = UBrowserServerList(List.Next);
	while (l != None)
	{
		n = UBrowserServerList(l.Next);

		if (l.bOldServer)
		{
			if (Grid.SelectedServer == l)
				Grid.SelectedServer = n;

			l.Remove();
		}
		l = n;
	}
}

function RefreshSubsets()
{
	local UBrowserSubsetList l, NextSubset;

	for (l = UBrowserSubsetList(SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
		l.bOldElement = True;

	l = UBrowserSubsetList(SubsetList.Next);
	while (l != None && l.bOldElement && L.SubsetFactory.Owner != none)
	{
		NextSubset = UBrowserSubsetList(l.Next);
		l.SubsetFactory.Owner.Owner.Refresh(True);
		l = NextSubset;
	}
}

function RePing()
{
	PingState = PS_RePinging;
	List.InvalidatePings();
	List.PingServers(True, False);
}

function QueryFinished(UBrowserServerListFactory Fact, bool bSuccess, optional string ErrorMsg)
{
	local int i;
	local bool bDone;

	bDone = True;
	for (i=0; i<NumFactories; i++)
	{
		if (FactoriesAr[i] == None) continue;
		if (FactoriesAr[i] == Fact)
			QueryDone[i] = 1;
		if (QueryDone[i] == 0)
			bDone = False;
	}

	if (!bSuccess)
	{
		PingState = PS_QueryFailed;
		ErrorString = ErrorMsg;

		// don't ping and report success if we have no servers.
		if (bDone && List.Count() == 0)
			return;
	}
	else
		ErrorString = "";

	// Log("QueryDone: NoSort is "$bNoSort);

	if (bDone)
	{
		if ( PingState==PS_RePinging )
			Return;
		else if ( PingState==PS_Done )
		{
			if ( !bNoSort )
				List.Sort();
			Return;
		}
		RemoveOldServers();

		PingState = PS_Pinging;
		if (!bNoSort && !Fact.bIncrementalPing)
			List.Sort();
		List.PingServers(True, bNoSort || Fact.bIncrementalPing);
	}
}

function PingFinished()
{
	PingState = PS_Done;
}

function CreateFactories()
{
	local int i;

	if( NumFactories==Array_Size(ListFactories) )
	{
		for (i=0; i<NumFactories; i++)
		{
			FactoriesAr[i].Owner = List;
			QueryDone[i] = 0;
		}
		return;
	}
	NumFactories = Array_Size(ListFactories);
	Array_Size(FactoriesAr,NumFactories);
	Array_Size(QueryDone,NumFactories);

	for (i=0; i<NumFactories; i++)
	{
		FactoriesAr[i] = UBrowserServerListFactory(BuildObjectWithProperties(ListFactories[i]));
		if( i<10 )
			Factories[i] = FactoriesAr[i]; // Old ver compatibility.
		FactoriesAr[i].Owner = List;
		QueryDone[i] = 0;
	}
}

function ShutdownFactories(optional bool bBySuperset)
{
	local int i;

	for (i=0; i<NumFactories; i++)
	{
		if (FactoriesAr[i] != None)
		{
			FactoriesAr[i].Shutdown(bBySuperset);
			if( i<10 )
				Factories[i] = None;
		}
	}
}

function Query(optional bool bBySuperset, optional bool bInitial, optional bool bInNoSort)
{
	local int i;

	bNoSort = bInNoSort;

	// Query all our factories
	for (i=0; i<NumFactories; i++)
	{
		if (FactoriesAr[i] != None)
			FactoriesAr[i].Query(bBySuperset, bInitial);
	}
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

function Tick(float Delta)
{
	if (List.bNeedUpdateCount)
	{
		List.UpdateServerCount();
		List.bNeedUpdateCount = False;
	}

	// AutoRefresh local servers
	if (AutoRefreshTime > 0)
	{
		TimeElapsed += Delta;

		if (TimeElapsed > AutoRefreshTime)
		{
			TimeElapsed = 0;
			Refresh(,,True, bNoAutoSort);
		}
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;
	local UBrowserSupersetList l;
	local EPingState P;
	local int PercentComplete;
	local string E;

	Super.BeforePaint(C, X, Y);

	W = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	l = UBrowserSupersetList(SupersetList.Next);

	if (l != None && PingState != PS_RePinging)
	{
		P = l.SupersetWindow.PingState;
		PingState = P;

		if (l.SupersetWindow.TotalServers > 0)
			PercentComplete = l.SupersetWindow.TotalPinged*100.0/l.SupersetWindow.TotalServers;
		E = l.SupersetWindow.ErrorString;
	}
	else
	{
		P = PingState;
		if (TotalServers > 0)
			PercentComplete = TotalPinged*100.0/TotalServers;
		E = ErrorString;
	}

	switch (P)
	{
	case PS_QueryServer:
		W.DefaultStatusBarText(QueryServerText);
		break;
	case PS_QueryFailed:
		W.DefaultStatusBarText(QueryFailedText$E);
		break;
	case PS_Pinging:
	case PS_RePinging:
		W.DefaultStatusBarText(PingingText$" "$PercentComplete$"% "$CompleteText$". "$List.TotalServers$" "$ServerCountName$", "$List.TotalPlayers$" "$PlayerCountName);
		break;
	case PS_Done:
		W.DefaultStatusBarText(List.TotalServers$" "$ServerCountName$", "$List.TotalPlayers$" "$PlayerCountName);
		break;
	}
}

defaultproperties
{
	ServerListClass=Class'UBrowser.UBrowserServerList'
	GridClass="UBrowser.UBrowserServerGrid"
	bSuspendPingOnClose=True
	PlayerCountName="Players"
	ServerCountName="Servers"
	QueryServerText="Querying Master Server"
	QueryFailedText="Master Server Failed: "
	PingingText="Pinging Servers"
	CompleteText="Complete"
	InfoName="Info"
}