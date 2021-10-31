//=============================================================================
// AdminGUIPlayersLPage.
//=============================================================================
class AdminGUIPlayersLPage expands UWindowPageWindow;

var AdminGUIPlayersGrid Grid;

function Created()
{
	Grid = AdminGUIPlayersGrid(CreateWindow(Class'AdminGUIPlayersGrid', 0, 0, WinWidth, WinHeight));
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
