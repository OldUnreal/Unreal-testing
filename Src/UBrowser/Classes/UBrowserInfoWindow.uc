//=============================================================================
// UBrowserInfoWindow
//=============================================================================
class UBrowserInfoWindow extends UWindowFramedWindow;

function Created()
{
	bSizable = True;
	bStatusBar = True;
	Super(UWindowWindow).Created();
	MinWinHeight = 100;
	MinWinWidth = 50;
	CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));
}
function Resized()
{
	if ( ClientArea!=None )
	{
		ClientArea.WinTop = 16;
		ClientArea.WinLeft = 2;
		ClientArea.SetSize(WinWidth-4,WinHeight-30);
	}
}

defaultproperties
{
}