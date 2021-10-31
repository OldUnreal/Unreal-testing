//=============================================================================
// UBrowserLibPageClientWin
//=============================================================================
class UBrowserLibPageClientWin extends UWindowClientWindow;

var UWindowLabelControl TextArea[2];
var UWindowHTMLTextArea HTMLTextArea;

function Created()
{
	Super.Created();
	TextArea[0] = UWindowLabelControl(CreateWindow(class'UWindowLabelControl', 3, 3, WinWidth-6, 16));
	TextArea[1] = UWindowLabelControl(CreateWindow(class'UWindowLabelControl', 3, 20, WinWidth-6, 16));
	HTMLTextArea = UBrowserHTMLArea(CreateWindow(Class'UBrowserHTMLArea',0,37,WinWidth,WinHeight-37));
}
function Resized()
{
	TextArea[0].SetSize(WinWidth-6, 16);
	TextArea[1].SetSize(WinWidth-6, 16);
	HTMLTextArea.SetSize(WinWidth, WinHeight-37);
}
function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, 0, WinWidth, 37, T);
}

defaultproperties
{
}