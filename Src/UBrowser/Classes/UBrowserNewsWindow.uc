class UBrowserNewsWindow extends UWindowPageWindow
			Config;

var() config string RequestingURL,RequestingAddress;
var() config int RequestingURLPort;

var enum EnHTMLReceiveStatus
{
	HRS_None,
	HRS_HasStatus,
	HRS_Done,
	HRS_Failed
} HTMLReceiveStatus;

var	string				FailedString;

var	UBrowserHTMLArea			HTMLTextArea;
var	UBrowserMainWindow		MainWindow;
var	Player				ViewPortOwner;
var	UBrowserNewsHTTPLink		ActiveLink;

function Created()
{
	Super.Created();
	HTMLTextArea = UBrowserHTMLArea(CreateWindow(Class'UBrowserHTMLArea',0,0,WinWidth,WinHeight));
	HTMLTextArea.NewsWin = Self;
	HTMLTextArea.SetHTML("Requesting page from <a href="$RequestingAddress$">"$RequestingAddress$"</a>...<br>Hit <a href=httpunr://"$RequestingAddress$">*Refresh*</a> if nothing happens.");
	ViewPortOwner = GetPlayerOwner().Player;
	if ( ActiveLink==None )
		ActiveLink = ViewPortOwner.Actor.GetEntryLevel().Spawn(class'UBrowserNewsHTTPLink');
	ActiveLink.FeedbackObj = Self;
	ActiveLink.Start(RequestingAddress,RequestingURL,RequestingURLPort);
}
function WindowShown()
{
	Super.WindowShown();
	Switch( HTMLReceiveStatus )
	{
Case HRS_HasStatus:
		SetStatusTxt(FailedString);
		Break;
Case HRS_Failed:
		SetStatusTxt(FailedString);
		if ( ActiveLink==None )
			ActiveLink = ViewPortOwner.Actor.GetEntryLevel().Spawn(class'UBrowserNewsHTTPLink');
		ActiveLink.FeedbackObj = Self;
		ActiveLink.Start(RequestingAddress,RequestingURL,RequestingURLPort);
		Break;
	}
}
function WindowHidden()
{
	Super.WindowHidden();
}
function Resized()
{
	Super.Resized();
	HTMLTextArea.SetSize(WinWidth,WinHeight);
}

function ReceivedError( string ErrorStr, UBrowserNewsHTTPLink Sender )
{
	if ( Sender!=ActiveLink )
		Return;
	FailedString = ErrorStr;
	HTMLReceiveStatus = HRS_Failed;
	SetStatusTxt(ErrorStr);
	if ( ViewPortOwner.Actor.GetEntryLevel().XLevel==ActiveLink.XLevel || ViewPortOwner.Actor.XLevel==ActiveLink.XLevel )
		ActiveLink.Destroy();
	ActiveLink = None;
}

function ReceivedStatus( string Status, UBrowserNewsHTTPLink Sender )
{
	if ( Sender!=ActiveLink )
		Return;
	FailedString = Status;
	HTMLReceiveStatus = HRS_HasStatus;
	SetStatusTxt(Status);
}

function ReceivedSuccess( out string HTMLCode, UBrowserNewsHTTPLink Sender )
{
	if ( Sender!=ActiveLink )
		Return;
	HTMLReceiveStatus = HRS_Done;
	HTMLTextArea.SetHTML(HTMLCode);
	SetStatusTxt("Successfully received the HTML page.");
	if ( ViewPortOwner.Actor.GetEntryLevel().XLevel==ActiveLink.XLevel || ViewPortOwner.Actor.XLevel==ActiveLink.XLevel )
		ActiveLink.Destroy();
	ActiveLink = None;
}

function SetStatusTxt( string Status )
{
	Status = "HTTPLink:"@Status;
	if ( MainWindow==None )
		MainWindow = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	MainWindow.DefaultStatusBarText(Status);
}

function Refresh( string URL, string SubURL, int URLPort )
{
	if ( ActiveLink!=None && (ViewPortOwner.Actor.GetEntryLevel().XLevel==ActiveLink.XLevel || ViewPortOwner.Actor.XLevel==ActiveLink.XLevel) )
		ActiveLink.Destroy();
	ActiveLink = ViewPortOwner.Actor.GetEntryLevel().Spawn(class'UBrowserNewsHTTPLink');
	ActiveLink.FeedbackObj = Self;
	ActiveLink.Start(URL,SubURL,URLPort);
}

function OpenUpLink( string NewURL )
{
	local int i;
	local string SubURL;

	i = InStr(NewURL,"/");
	if ( i!=-1 )
	{
		SubURL = Mid(NewURL,i);
		NewURL = Left(NewURL,i);
	}
	Refresh(NewURL,SubURL,80);
}

defaultproperties
{
	RequestingURL="/news.html"
	RequestingAddress="www.oldunreal.com"
	RequestingURLPort=80
}