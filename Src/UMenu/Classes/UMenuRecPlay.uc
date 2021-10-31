class UMenuRecPlay expands UMenuPageWindow;

var UMenuRecGrid Grid;
var UWindowSmallButton PlayDemoButton;
var UWindowSmallCloseButton CancelButton;
var float ButtonWidth;
var() localized string PlayDemoText;
var string SelectedFile;

const ButtonXSpacing = 10;

function Created()
{
	Super.Created();

	PlayDemoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ButtonXSpacing, WinHeight - 24, 75, 16));
	PlayDemoButton.SetText(PlayDemoText);
	CancelButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth - 75 - ButtonXSpacing, WinHeight - 24, 75, 16));

	Grid = UMenuRecGrid(CreateWindow(class'UMenuRecGrid', 0, 0, WinWidth, WinHeight - 30));
	Grid.ParentHandle = Self;
}

function Resized()
{
	Super.Resized();
	Grid.WinWidth = WinWidth;
	Grid.WinHeight = WinHeight - 30;
	Grid.Resized();
	PlayDemoButton.WinTop = WinHeight - 24;
	CancelButton.WinTop = WinHeight - 24;
}

function BeforePaint(Canvas C, float X, float Y)
{
	PlayDemoButton.AutoWidthBy(C, ButtonWidth);
	CancelButton.AutoWidthBy(C, ButtonWidth);
	CancelButton.WinLeft = WinWidth - CancelButton.WinWidth - ButtonXSpacing;
}

final function PlayDemo()
{
	GetPlayerOwner().bDelayedCommand = true;
	GetPlayerOwner().DelayedCommand = "DEMOPLAY"@SelectedFile;
	ParentWindow.HideWindow();
	Root.Console.CloseUWindow();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	if ( E==DE_Click && C==PlayDemoButton )
		PlayDemo();
}

defaultproperties
{
	PlayDemoText="Play demo"
}