//=============================================================================
// UpgradeMenu
//=============================================================================
class UpgradeMenu extends YesNoMenu;

function ProcessResponse()
{
	//process based on state of bResponse
	if ( bResponse )
		PlayerOwner.ConsoleCommand("start http://www.oldunreal.com/oldunrealpatches.html");

	ExitMenu();
}

defaultproperties
{
	MenuList(1)="You need a newer version of Unreal to play on this server. Would you like to go to the Unreal web site for a newer version?"
}
