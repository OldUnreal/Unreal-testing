class UMenuHelpWindow extends UWindowFramedWindow;

function Created()
{
	Super.Created();
	bSizable = False;
	bStatusBar = False;

	WinLeft = ParentWindow.WinWidth - 220;
	WinTop = ParentWindow.WinHeight - 170;
	SetSize(200, 150);
}

defaultproperties
{
	ClientClass=Class'UMenu.UMenuHelpClientWindow'
	WindowTitle="Help"
}
