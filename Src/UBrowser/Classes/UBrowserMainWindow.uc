//=============================================================================
// UBrowserMainWindow - The main window
//=============================================================================
class UBrowserMainWindow extends UWindowFramedWindow;

var UBrowserBannerBar			BannerWindow;
var string						StatusBarDefaultText;
var bool						bStandaloneBrowser;

var localized string			WindowTitleString;

function DefaultStatusBarText(string Text)
{
	StatusBarDefaultText = Text;
	StatusBarText = Text;
}

function BeginPlay()
{
	Super.BeginPlay();

	WindowTitle = WindowTitleString;
	ClientClass = class'UBrowserMainClientWindow';
}

function Created()
{
	bSizable = True;
	bStatusBar = True;

	Super.Created();

	MinWinWidth = 300;
	MinWinHeight = 160;

	SetSizePos();
}

function BeforePaint(Canvas C, float X, float Y)
{
	if (StatusBarText == "")
		StatusBarText = StatusBarDefaultText;

	Super.BeforePaint(C, X, Y);
}

function Close(optional bool bByParent)
{
	if (bStandaloneBrowser)
		Root.Console.CloseUWindow();
	else
		Super.Close(bByParent);
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SetSizePos()
{
	SetSize(Min(680, Root.WinWidth - 10), Root.WinHeight-50);

	WinLeft = Int((Root.WinWidth - WinWidth) / 2);
	WinTop = Int((Root.WinHeight - WinHeight) / 2);
}

function SelectInternet()
{
	UBrowserMainClientWindow(ClientArea).SelectInternet();
}

function SelectLAN()
{
	UBrowserMainClientWindow(ClientArea).SelectLAN();
}

defaultproperties
{
	WindowTitleString="Unreal Server Browser"
}