//=============================================================================
// Admin GUI ClientWindow
//=============================================================================
class AdminGUIClientWindow extends UWindowClientWindow;

var AdminGUIMainWindow MainWin;
var UWindowPageControl PageControl;
var AdminGUIPlayersLPage PLPage;
var AdminGUIPlayersGrid PlayersListGrid;
var AdminGUIBanLPage BLPage;
var AdminGUIBanLGrid BanListGrid;
var AdminGUITBanLPage TBLPage;
var AdminGUIBanLGrid TempBanListGrid;
var() localized string PlayersListTxt,BanListTxt,TempBanListTxt;

function bool OverrideMessage( PlayerReplicationInfo PRI, coerce string Msg, name N )
{
	local string Char;

	if ( N=='Log' && Left(Msg,1)=="@" )
	{
		Char = Mid(Msg,1,1);
		if ( Char=="P" )
			PlayersListGrid.ProcessInput(Mid(Msg,2));
		else if ( Char=="B" )
			BanListGrid.ProcessInput(Mid(Msg,2));
		else if ( Char=="T" )
			TempBanListGrid.ProcessInput(Mid(Msg,2));
		Return True;
	}
	Return False;
}

function Created()
{
	Super.Created();
	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	Root.Console.MessageCatcher = Self;
	PLPage = AdminGUIPlayersLPage(PageControl.AddPage(PlayersListTxt, class'AdminGUIPlayersLPage').Page);
	PlayersListGrid = PLPage.Grid;
	PlayersListGrid.PageOwner = Self;
	BLPage = AdminGUIBanLPage(PageControl.AddPage(BanListTxt, class'AdminGUIBanLPage').Page);
	BanListGrid = BLPage.Grid;
	BanListGrid.PageOwner = Self;
	TBLPage = AdminGUITBanLPage(PageControl.AddPage(TempBanListTxt, class'AdminGUITBanLPage').Page);
	TempBanListGrid = TBLPage.Grid;
	TempBanListGrid.PageOwner = Self;
}
function InitControls()
{
	PlayersListGrid.RefreshPLList();
}
function SetStatus( string Status )
{
	if ( MainWin!=None )
		MainWin.StatusBarText = Status;
}
function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}
function Resized()
{
	PageControl.SetSize(WinWidth,WinHeight);
}

defaultproperties
{
	PlayersListTxt="Clients List"
	BanListTxt="Banned Clients"
	bLeaveOnscreen=True
	TempBanListTxt="Session Banned Clients"
}
