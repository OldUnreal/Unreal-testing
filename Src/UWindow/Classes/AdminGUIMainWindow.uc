//=============================================================================
// Admin GUI Main Window - New menu in U227
//=============================================================================
class AdminGUIMainWindow extends UWindowFramedWindow;

function Created()
{
	bSizable = True;
	bStatusBar = True;
	Super.Created();
	MinWinWidth = 300;
	MinWinHeight = 360;
	AdminGUIClientWindow(ClientArea).MainWin = Self;
	AdminGUIClientWindow(ClientArea).InitControls();
}
function ShowWindow()
{
	Root.Console.MessageCatcher = ClientArea;
	Super.ShowWindow();
	AdminGUIClientWindow(ClientArea).InitControls();
}

defaultproperties
{
	ClientClass=Class'AdminGUIClientWindow'
	WindowTitle="Admin Menu"
	bTransient=False
	bLeaveOnscreen=True
}
