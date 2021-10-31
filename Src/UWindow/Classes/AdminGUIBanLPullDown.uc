//=============================================================================
// AdminGUIBanLPullDown.
//=============================================================================
class AdminGUIBanLPullDown expands UWindowPulldownMenu;

var UWindowPulldownMenuItem UnbanMn,CloseMn,RefreshMn,ManualBtn;
var AdminGUIBanLGrid Manager;
var() localized string RemoveBanTxt,CloseMenuTxt,RefreshTxt,ManualBanTxt;
var bool bAddedManual;

function Created()
{
	Super.Created();
	RefreshMn = AddMenuItem(RefreshTxt, None);
	UnbanMn = AddMenuItem(RemoveBanTxt, None);
	CloseMn = AddMenuItem(CloseMenuTxt, None);
}
function AddManualItem()
{
	if ( bAddedManual )
		return;
	bAddedManual = true;
	ManualBtn = AddMenuItem(ManualBanTxt, None);
}
function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case RefreshMn:
		Manager.RefreshBLList();
		break;
	case UnbanMn:
		Manager.ProcessUnban();
		break;
	case CloseMn:
		Manager.PageOwner.MainWin.Close();
		break;
	case ManualBtn:
		Manager.ProcessManualBan();
		break;
	}
	Super.ExecuteItem(I);
}
function CloseUp()
{
	HideWindow();
}

defaultproperties
{
	RefreshTxt="&Refresh banlist"
	RemoveBanTxt="&Remove ban"
	CloseMenuTxt="&Close this menu"
	ManualBanTxt="&Manually insert ban entry"
	bTransient=True
	bLeaveOnscreen=True
}
