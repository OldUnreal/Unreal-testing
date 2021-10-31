//=============================================================================
// Admin GUI Manual ban Window - New menu in U227
//=============================================================================
class AdminGUIManualBanWnd extends UWindowFramedWindow;

function Created()
{
	Super.Created();
	MinWinWidth = Default.MinWinWidth;
	MinWinHeight = Default.MinWinHeight;
	AdminGUIManBanClientW(ClientArea).MainWin = Self;
}

defaultproperties
{
	ClientClass=Class'AdminGUIManBanClientW'
	WindowTitle="Insert manual ban"
	bTransient=False
	bLeaveOnscreen=True
	MinWinWidth=240
	MinWinHeight=180
	bSizable=True
	bStatusBar=True
}
