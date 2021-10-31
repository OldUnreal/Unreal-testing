//=============================================================================
// UBrowserLibPageWindow
//=============================================================================
class UBrowserLibPageWindow extends UWindowFramedWindow;

var localized string DLLTitleStr,DLLVerTitleStr,InfoText[2];
var UBrowserLibPageClientWin ClientUInfo;
var UBrowserLibHTTPLink Link;

function Created()
{
	Super.Created();
	ClientUInfo = UBrowserLibPageClientWin(ClientArea);
	MinWinWidth = 250;
	MinWinHeight = 250;
}
final function SetDLLInfo( string DLLName, string DLLURL, bool bMismatch )
{
	local int i;
	local string S;

	i = InStr(DLLURL,"/");
	if( i==-1 )
		S = DLLURL;
	else
	{
		S = Left(DLLURL,i);
		DLLURL = Mid(DLLURL,i);
	}

	if( bMismatch )
		WindowTitle = DLLVerTitleStr;
	else WindowTitle = DLLTitleStr;
	WindowTitle = ReplaceStr(WindowTitle,"%ls",DLLName);
	ClientUInfo.TextArea[0].SetText(ReplaceStr(InfoText[0],"%ls",DLLName));
	ClientUInfo.TextArea[1].SetText(ReplaceStr(InfoText[1],"%ls",S));
	ClientUInfo.HTMLTextArea.SetHTML("Requesting page from <a href="$S$DLLURL$">"$S$"</a>.<br>Please wait...");

	if( Link!=None )
		Link.Destroy();
	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserLibHTTPLink');
	Link.OwnerPageWin = Self;
	Link.OutputPage = ClientUInfo.HTMLTextArea;
	Link.Start(S,DLLURL,80);
}

defaultproperties
{
	DLLTitleStr="Can't connect: Missing Dynamic Link Libary '%ls'."
	DLLVerTitleStr="Can't connect: Dynamic Link Libary version mismatched '%ls'."
	InfoText(0)="To connect this server you will need additional C++ libary '%ls',"
	InfoText(1)="for more info view the external info from below (hosted by %ls):"
	ClientClass=Class'UBrowser.UBrowserLibPageClientWin'
	bLeaveOnscreen=True
}
