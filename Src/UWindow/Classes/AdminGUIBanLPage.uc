//=============================================================================
// AdminGUIBanLPage.
//=============================================================================
class AdminGUIBanLPage expands UWindowPageWindow;

var AdminGUIBanLGrid Grid;

function Created()
{
	Grid = AdminGUIBanLGrid(CreateWindow(Class'AdminGUIBanLGrid', 0, 0, WinWidth, WinHeight));
}
function Resized()
{
	Grid.WinTop = 0;
	Grid.SetSize(WinWidth, WinHeight);
}
function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}
function ShowWindow()
{
	if ( Grid!=None )
		Grid.OpenedTab();
	Super.ShowWindow();
}

defaultproperties
{
}
