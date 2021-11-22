//=============================================================================
// UBrowserInfoClientWindow - extra info on a specific server
//=============================================================================
class UBrowserInfoClientWindow extends UWindowClientWindow
			Config(User);

var UBrowserServerList Server;
var UWindowHSplitter Splitter;
var UWindowVSplitter VSplitter;
var float PrevSplitPos;
var bool bSplitterInit,bCurrentStyle;
var UBrowserInfoMenu Menu;
var() globalconfig bool bClassicWindow;
var UBrowserInfoWindow FramedWindowOwner;
var UBrowserPlayerGrid PLGrid;
var UBrowserRulesGrid RLGrid;
var UBrowserServerListWindow ListWin;

function Created()
{
	Super.Created();

	if ( bClassicWindow )
	{
		FramedWindowOwner = UBrowserInfoWindow(Root.CreateWindow(class'UBrowserInfoWindow', 50, 100, 350, 250));
		FramedWindowOwner.ClientArea = Self;
		FramedWindowOwner.BringToFront();
		FramedWindowOwner.Resized();
		SetParent(FramedWindowOwner);
		bCurrentStyle = True;
		Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
		Splitter.bRightGrow = True;
		Splitter.HideWindow();
		VSplitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));
		PLGrid = UBrowserPlayerGrid(VSplitter.CreateWindow(class'UBrowserPlayerGrid', 0, 0, 338, WinHeight));
		VSplitter.TopClientWindow = PLGrid;
		RLGrid = UBrowserRulesGrid(VSplitter.CreateWindow(class'UBrowserRulesGrid', 0, 0, WinWidth-352, WinHeight));
		VSplitter.BottomClientWindow = RLGrid;
	}
	else
	{
		Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
		Splitter.bRightGrow = True;
		PLGrid = UBrowserPlayerGrid(Splitter.CreateWindow(class'UBrowserPlayerGrid', 0, 0, 338, WinHeight));
		Splitter.LeftClientWindow = PLGrid;
		RLGrid = UBrowserRulesGrid(Splitter.CreateWindow(class'UBrowserRulesGrid', 0, 0, WinWidth-352, WinHeight));
		Splitter.RightClientWindow = RLGrid;
		VSplitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));
		VSplitter.HideWindow();
	}
	Menu = UBrowserInfoMenu(Root.CreateWindow(class'UBrowserInfoMenu', 0, 0, 100, 100));
	Menu.Info = Self;
	Menu.HideWindow();
}
function InitSplitter()
{
	local int Size;

	if ( bCurrentStyle )
	{
		VSplitter.SetSize(WinWidth, WinHeight);
		VSplitter.SplitPos = WinHeight/2;
		RLGrid.InitColumns(WinWidth-12);
	}
	else
	{
		WinLeft = 0;
		WinTop = 0;
		Size = WinWidth;
		Splitter.SplitPos = 345;
		Size-=Splitter.SplitPos;
		RLGrid.InitColumns(Size-19);
	}
}
function Resized()
{
	Splitter.SetSize(WinWidth, WinHeight);
	VSplitter.SetSize(WinWidth, WinHeight);
	bSplitterInit = False;
}

function Paint(Canvas C, float X, float Y)
{
	if ( !bSplitterInit )
	{
		bSplitterInit = True;
		InitSplitter();
	}
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

function SetStyle( bool bClassic )
{
	if ( bCurrentStyle==bClassic )
		Return;
	bSplitterInit = False;
	bCurrentStyle = bClassic;
	if ( bClassic )
	{
		if ( FramedWindowOwner==None )
		{
			FramedWindowOwner = UBrowserInfoWindow(Root.CreateWindow(class'UBrowserInfoWindow', 50, 100, 350, 250));
			FramedWindowOwner.ClientArea = Self;
			FramedWindowOwner.BringToFront();
			SetParent(FramedWindowOwner);
		}
		else
		{
			FramedWindowOwner.ShowWindow();
			FramedWindowOwner.BringToFront();
			SetParent(FramedWindowOwner);
		}
		RLGrid.SetParent(VSplitter);
		PLGrid.SetParent(VSplitter);
		Splitter.LeftClientWindow = None;
		Splitter.RightClientWindow = None;
		Splitter.HideWindow();
		VSplitter.TopClientWindow = PLGrid;
		VSplitter.BottomClientWindow = RLGrid;
		VSplitter.ShowWindow();
	}
	else
	{
		RLGrid.SetParent(Splitter);
		PLGrid.SetParent(Splitter);
		VSplitter.TopClientWindow = None;
		VSplitter.BottomClientWindow = None;
		VSplitter.HideWindow();
		Splitter.LeftClientWindow = PLGrid;
		Splitter.RightClientWindow = RLGrid;
		Splitter.ShowWindow();
		if ( FramedWindowOwner!=None )
		{
			FramedWindowOwner.HideWindow();
			SetParent(ListWin);
		}
	}
}

defaultproperties
{
}