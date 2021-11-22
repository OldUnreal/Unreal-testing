class UMenuHelpClientWindow extends UWindowClientWindow;

var UMenuHelpTextArea TextArea;

function Created()
{
	TextArea = UMenuHelpTextArea(CreateWindow(class'UMenuHelpTextArea', 20, 20, WinWidth-40, WinHeight-90));
}

function Paint(Canvas C, float X, float Y)
{
	Tile(C, Texture'Background');
}

function BeforePaint(Canvas C, float X, float Y)
{
	TextArea.WinWidth = WinWidth-40;
	TextArea.WinHeight = WinWidth-90;
}

defaultproperties
{
}
