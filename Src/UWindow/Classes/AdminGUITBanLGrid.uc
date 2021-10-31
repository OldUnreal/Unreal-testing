//=============================================================================
// AdminGUITBanLGrid.
//=============================================================================
class AdminGUITBanLGrid extends AdminGUIBanLGrid;

function RefreshBLList()
{
	local PlayerPawn PP;

	PP = Root.Console.Viewport.Actor;
	ReceiveID = Rand(2500);
	PageOwner.SetStatus(GettingBanListText);
	PP.Admin("UGetTBanList T"$ReceiveID$"|");
	ListCount = 0;
}
function ProcessUnban()
{
	local PlayerPawn PP;

	if ( SelectedRow>=ListCount )
		Return;
	PP = Root.Console.Viewport.Actor;
	PP.Admin("UTempUnBan"@BanPlListF[SelectedRow].IDx);
	RefreshBLList();
}
function ProcessManualBan();

defaultproperties
{
	GettingBanListText="Getting temp-banlist from server, if nothing happens you may not be logged in as admin (or there are no temp-bans on server)."
}
