class UMenuNewGameWindow extends UMenuFramedWindow;

function Created()
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	SetSize(260, 180);

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	ClientClass=Class'UMenu.UMenuNewGameClientWindow'
	WindowTitle="New Game"
}
