//=============================================================================
// AdminGUITBanLPage.
//=============================================================================
class AdminGUITBanLPage expands AdminGUIBanLPage;

function Created()
{
	Grid = AdminGUIBanLGrid(CreateWindow(Class'AdminGUITBanLGrid', 0, 0, WinWidth, WinHeight));
}

defaultproperties
{
}
