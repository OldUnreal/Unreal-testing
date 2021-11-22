class UMenuOptionsMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Preferences, Prioritize, Desktop, Advanced, Player, AdvPreferences;

var localized string PreferencesName;
var localized string PreferencesHelp;
var localized string PrioritizeName;
var localized string PrioritizeHelp;
var localized string DesktopName;
var localized string DesktopHelp;
var localized string PlayerMenuName;
var localized string PlayerMenuHelp;
var localized string AdvancedOptionsName,AdvancedOptionsHelp;

var Class<UWindowWindow> PlayerWindowClass;
var class<UWindowWindow> WeaponPriorityWindowClass;

function Created()
{
	Super.Created();

	Preferences = AddMenuItem(PreferencesName, None);
	Player = AddMenuItem(PlayerMenuName, None);
	Prioritize = AddMenuItem(PrioritizeName, None);
	AdvPreferences = AddMenuItem(AdvancedOptionsName, None);

	AddMenuItem("-", None);

	Desktop = AddMenuItem(DesktopName, None);
	Desktop.bChecked = Root.Console.ShowDesktop;
}

function UWindowWindow PlayerSetup()
{
	return Root.CreateWindow(PlayerWindowClass, 100, 100, 200, 200, Self, True);
}

function ShowPreferences(optional bool bNetworkSettings)
{
	local UMenuOptionsWindow O;

	O = UMenuOptionsWindow(Root.CreateWindow(Class'UMenuOptionsWindow', 100, 100, 200, 200, Self, True));
	if (bNetworkSettings)
		UMenuOptionsClientWindow(O.ClientArea).ShowNetworkTab();
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Preferences:
		ShowPreferences();
		break;
	case AdvPreferences:
		GetPlayerOwner().ConsoleCommand("Preferences");
		break;
	case Prioritize:
		// Create prioritize weapons dialog.
		Root.CreateWindow(WeaponPriorityWindowClass, 100, 100, 200, 200, Self, True);
		break;
	case Desktop:
		// Toggle show desktop.
		Desktop.bChecked = !Desktop.bChecked;
		Root.Console.ShowDesktop = !Root.Console.ShowDesktop;
		Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
		Root.Console.SaveConfig();
		break;
	case Player:
		// Create player dialog.
		PlayerSetup();
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Preferences:
		UMenuMenuBar(GetMenuBar()).SetHelp(PreferencesHelp);
		break;
	case Prioritize:
		UMenuMenuBar(GetMenuBar()).SetHelp(PrioritizeHelp);
		break;
	case Desktop:
		UMenuMenuBar(GetMenuBar()).SetHelp(DesktopHelp);
		break;
	case Player:
		UMenuMenuBar(GetMenuBar()).SetHelp(PlayerMenuHelp);
		break;
	case AdvPreferences:
		UMenuMenuBar(GetMenuBar()).SetHelp(AdvancedOptionsHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
	PreferencesName="P&references"
	PreferencesHelp="Change your game options, audio and video setup, HUD configuration, controls and other options."
	PrioritizeName="&Weapons"
	PrioritizeHelp="Change your weapon priority, view and set weapon options."
	DesktopName="Show &Desktop"
	DesktopHelp="Toggle between showing your game behind the menus, or the desktop logo."
	PlayerMenuName="&Player Setup"
	PlayerMenuHelp="Configure your player setup for multiplayer and botmatch gaming."
	AdvancedOptionsName="&Advanced Options"
	AdvancedOptionsHelp="Bring up the Advanced Options menu, where you can configure most of the custom mods."
	PlayerWindowClass=Class'UMenu.UMenuPlayerWindow'
	WeaponPriorityWindowClass=Class'UMenu.UMenuWeaponPriorityWindow'
}
