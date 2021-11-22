//=============================================================================
// Music Menu MusicListClientWindow
//=============================================================================
class MMMusClientWindow extends UWindowClientWindow;

var MMMusListGrid Grid;
var MMMusListWindow MainWin;

function Created()
{
	Super.Created();

	Grid = MMMusListGrid(CreateWindow(class'MMMusListGrid', 0, 0, WinWidth, WinHeight));
	Grid.MMClient = Self;
}
function Resized()
{
	Grid.SetSize(WinWidth,WinHeight);
}
function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

defaultproperties
{
}
