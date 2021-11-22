//=============================================================================
// AdminGUIPLPullDown.
//=============================================================================
class AdminGUIPLPullDown expands UWindowPulldownMenu;

var UWindowPulldownMenuItem GetAliasMn,KickPLMn,KickTBNMn,KickBnPlMn,CloseMn,RefreshMn;
var AdminGUIPlayersGrid Manager;
var() localized string GetAliasesTxt,KickPlayerTxt,KickBanTempTxt,KickBanTxt,CloseMenuTxt,RefreshTxt;

function Created()
{
	Super.Created();
	RefreshMn = AddMenuItem(RefreshTxt, None);
	GetAliasMn = AddMenuItem(GetAliasesTxt, None);
	KickPLMn = AddMenuItem(KickPlayerTxt, None);
	KickTBNMn = AddMenuItem(KickBanTempTxt, None);
	KickBnPlMn = AddMenuItem(KickBanTxt, None);
	CloseMn = AddMenuItem(CloseMenuTxt, None);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case RefreshMn:
		Manager.RefreshPLList();
		break;
	case GetAliasMn:
		Manager.ProcessCmd(0);
		break;
	case KickPLMn:
		Manager.ProcessCmd(1);
		break;
	case KickTBNMn:
		Manager.ProcessCmd(2);
		break;
	case KickBnPlMn:
		Manager.ProcessCmd(3);
		break;
	case CloseMn:
		Manager.PageOwner.MainWin.Close();
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
	RefreshTxt="&Refresh players list"
	GetAliasesTxt="&Get player aliases"
	KickPlayerTxt="&Kick player"
	KickBanTempTxt="&Temporarily kick-ban player"
	KickBanTxt="Kick-&ban player"
	CloseMenuTxt="&Close this menu"
	bTransient=True
	bLeaveOnscreen=True
}
