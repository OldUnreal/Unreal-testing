class UMenuMutatorFrameCW expands UMenuDialogClientWindow;

var UWindowControlFrame Frame;

function Created()
{
	Frame = UWindowControlFrame(CreateWindow(class'UWindowControlFrame', 0, 0, WinWidth, WinHeight));
	Super.Created();
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	Frame.WinLeft = 5;
	Frame.WinTop = 5;
	Frame.SetSize(WinWidth - 10, WinHeight - 10);
}

defaultproperties
{
}
