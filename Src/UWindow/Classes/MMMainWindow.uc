//=============================================================================
// MusicMenu MainWindow - New menu in U227
//=============================================================================
class MMMainWindow extends UWindowFramedWindow;

function Created()
{
	bSizable = True;
	bStatusBar = True;
	Super.Created();
	MinWinWidth = 320;
	MinWinHeight = 166;
	MMMainClientWindow(ClientArea).MainWin = Self;
}
function CopyPropertiesFrom( MMMainWindow Other )
{
	MMMainClientWindow(ClientArea).CopyPropertiesFrom(MMMainClientWindow(Other.ClientArea));
}

defaultproperties
{
	ClientClass=Class'UWindow.MMMainClientWindow'
	WindowTitle="Music Menu"
	bLeaveOnscreen=True
}
