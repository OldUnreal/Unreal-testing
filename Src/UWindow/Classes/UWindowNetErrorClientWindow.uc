class UWindowNetErrorClientWindow extends UWindowDialogClientWindow;

var UWindowDynamicTextArea TextArea;
var UWindowSmallCloseButton CloseB;
var() localized string KickNetworkText,BanNetworkText,TempBanNetworkText;

function Created()
{
	TextArea = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 4, 4, WinWidth, WinHeight-26));
	TextArea.MaxLines = 15;
	CloseB = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-60, WinHeight-22, 48, 22));
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	TextArea.WinWidth = WinWidth-8;
	TextArea.WinHeight = WinHeight-30;
	CloseB.WinTop = WinHeight-24;
	CloseB.WinLeft = WinWidth-60;
}
function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.DrawClientArea(Self, C);
	DrawStretchedTexture(C, TextArea.WinLeft, TextArea.WinTop, TextArea.WinWidth, TextArea.WinHeight, Texture'BlackTexture');
}
function SetNetworkMessage( String Msg )
{
	local int i;
	local UWindowNetErrorWindow WT;

	// Check for short names.
	if ( Msg=="NE_Kick" )
		Msg = KickNetworkText;
	else if ( Left(Msg,6)=="NE_Ban" )
		Msg = BanNetworkText@Mid(Msg,7);
	else if ( Msg=="NE_TBan" )
		Msg = TempBanNetworkText;

	// Check for window title name
	WT = UWindowNetErrorWindow(ParentWindow);
	i = InStr(Msg,"|");
	if ( i==-1 )
		WT.WindowTitle = WT.Default.WindowTitle;
	else
	{
		WT.WindowTitle = Left(Msg,i);
		Msg = Mid(Msg,i+1);
	}

	// Check message lines
	TextArea.Clear();
	i = InStr(Msg,"\\");
	while ( i!=-1 )
	{
		TextArea.AddText(Left(Msg,i));
		Msg = Mid(Msg,i+1);
		i = InStr(Msg,"\\");
	}
	TextArea.AddText(Msg);
}

defaultproperties
{
	KickNetworkText="KICKED!|You have been kicked from this server by an administrator for remainder of the game.\\"
	BanNetworkText="BANNED!|You have been banned from this server by an administrator for bad behaviour.\\\\If you feel like you dont deserve this ban, contact the administrator at: "
	TempBanNetworkText="SESSION BANNED!|You have been temporarily banned from this server for remainder of the map.\\"
}
