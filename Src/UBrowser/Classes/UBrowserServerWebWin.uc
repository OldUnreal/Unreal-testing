//=============================================================================
// UBrowserServerWebWin
//=============================================================================
class UBrowserServerWebWin extends UWindowFramedWindow;

var UBrowserServerWebCW ClientUInfo;
var UBrowserServerWebLink Link;
var string CurrentURL[2];
var string URLHistory[10];
var byte HistoryCount;
var int HistoryOffset;

function Created()
{
	Super.Created();
	ClientUInfo = UBrowserServerWebCW(ClientArea);
	ClientUInfo.HTMLTextArea.PageOwner = Self;
	ClientUInfo.PageOwner = Self;
	MinWinWidth = 250;
	MinWinHeight = 250;
}
final function OpenChildURL( string URL )
{
	OpenWebsite(CurrentURL[0]$"/"$URL);
}
final function OpenWebsite( string URL, optional bool bNewSession, optional bool bHistoryExplore )
{
	local int i;

	i = InStr(URL,"://");
	if( i>=0 )
		URL = Mid(URL,i+3);

	i = InStr(URL,"/");
	if( i==-1 )
	{
		CurrentURL[0] = URL;
		CurrentURL[1] = "/index.html";
	}
	else
	{
		CurrentURL[0] = Left(URL,i);
		CurrentURL[1] = Mid(URL,i);
	}

	if( bNewSession )
	{
		URLHistory[0] = URL;
		HistoryOffset = 0;
		HistoryCount = 1;
		ClientUInfo.HTMLTextArea.SetHTML("Requesting page from <a href=\"httpunr://"$CurrentURL[0]$CurrentURL[1]$"\">"$CurrentURL[0]$"</a>.<br>Please wait...");
	}
	else if( !bHistoryExplore )
	{
		if( URLHistory[HistoryOffset]==URL )
		{}
		else if( HistoryOffset==(ArrayCount(URLHistory)-1) )
		{
			for( i=0; i<ArrayCount(URLHistory); ++i )
				URLHistory[i] = URLHistory[i+1];
			URLHistory[ArrayCount(URLHistory)-1] = URL;
		}
		else if( HistoryOffset>=0 )
		{
			URLHistory[++HistoryOffset] = URL;
			HistoryCount = (HistoryOffset+1);
		}
	}

	if( Link==None )
	{
		Link = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserServerWebLink');
		Link.FeedbackObj = Self;
	}
	ToolTip("Opening page"@CurrentURL[0]$CurrentURL[1]);
	Link.Start(CurrentURL[0],CurrentURL[1],80);
}
final function ReceivedError( string S )
{
	ClientUInfo.HTMLTextArea.SetHTML("Page couldn't open:"$S$"<br>Please try to <a href=\"httpunr://"$CurrentURL[0]$CurrentURL[1]$"\">refresh</a>.");
	ToolTip(S$".");
}
final function ReceivedSuccess( string S )
{
	ClientUInfo.HTMLTextArea.SetHTML(S);
	ToolTip("");
}
final function LinkDestroyed( UBrowserServerWebLink Other )
{
	if( Link==Other )
		Link = None;
}
final function HistoryPrevious()
{
	if( HistoryOffset>0 )
		OpenWebsite(URLHistory[--HistoryOffset],,true);
}
final function HistoryNext()
{
	if( HistoryOffset<(HistoryCount-1) )
		OpenWebsite(URLHistory[++HistoryOffset],,true);
}
final function ReloadPage()
{
	OpenWebsite(URLHistory[HistoryOffset],,true);
}

defaultproperties
{
	ClientClass=Class'UBrowser.UBrowserServerWebCW'
	WindowTitle="Unreal Web Explorer"
	bSizable=True
	bStatusBar=True
	bLeaveOnscreen=True
}