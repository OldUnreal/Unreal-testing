// Descend from this class to add an item to the Mod menu.
// Be sure to put a line in your Mod's .int file to specify this class
// eg:
// Object=(Name=MyModPkg.MyModMenuItem,Class=Class,MetaClass=UMenu.UMenuModMenuItem,Description="&My Mod,This text goes on the status bar")

class UMenuModMenuItem expands UWindowList;

var localized string MenuCaption;
var localized string MenuHelp;

var UWindowPulldownMenuItem MenuItem;	// Used internally

function Setup()
{
	/// Called when the menu item is created
}

function Execute()
{
	// Called when the menu item is chosen
}

defaultproperties
{
	MenuCaption="&My Mod"
	MenuHelp="This text goes on the status bar"
}
