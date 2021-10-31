class UMenuLoadGameWindow extends UMenuFramedWindow;

function Created()
{
	bStatusBar = false;
	bSizable = true;

	super.Created();

	UpdateMinSize();
	SetSize(MinWinWidth, MinWinHeight);

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

function WindowShown()
{
	Super.WindowShown();
	UpdateMinSize();
	SetSize(MinWinWidth, MinWinHeight);
	if ( ClientArea!=None )
		ClientArea.ShowWindow();
}

function Resized()
{
	UpdateMinSize();
	if (WinHeight != MinWinHeight)
		WinHeight = MinWinHeight;
	super.Resized();
}

function UpdateMinSize()
{
	MinWinWidth = FMin(400, Root.WinWidth - 20);
	MinWinHeight = FMin(740, Root.WinHeight - 40);
}

defaultproperties
{
	ClientClass=Class'UMenuLoadGameClientWindow'
	WindowTitle="Load Game"
	bLeaveOnscreen=True
}
