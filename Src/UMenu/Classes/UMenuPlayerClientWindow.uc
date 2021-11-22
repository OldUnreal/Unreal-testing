class UMenuPlayerClientWindow extends UMenuDialogClientWindow;

var UWindowHSplitter Splitter;
var class<UWindowWindow> PlayerSetupClass;

function Created()
{
	Super.Created();

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

	Splitter.RightClientWindow = UMenuPlayerMeshClient(Splitter.CreateWindow(class'UMenuPlayerMeshClient', 0, 0, 100, 100));
	Splitter.LeftClientWindow = Splitter.CreateWindow(PlayerSetupClass, 0, 0, 100, 100, OwnerWindow);

	Splitter.bRightGrow = True;
	Splitter.SplitPos = 240;
//	Splitter.MinWinWidth = 300;
}

function Resized()
{
	Super.Resized();
	Splitter.SetSize(WinWidth, WinHeight);
}

defaultproperties
{
	PlayerSetupClass=Class'UMenu.UMenuPlayerSetupScrollClient'
}
