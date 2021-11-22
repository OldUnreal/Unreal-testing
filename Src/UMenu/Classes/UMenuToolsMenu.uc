class UMenuToolsMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Console, TimeDemo, ShowLog, MusicMBut, AdminMBut, DebugMode;

var localized string ConsoleName;
var localized string ConsoleHelp;
var localized string TimeDemoName;
var localized string TimeDemoHelp;
var localized string LogName;
var localized string LogHelp;
var localized string MusicMName;
var localized string MusicMHelp;
var localized string AdminMName;
var localized string AdminMHelp;
var localized string DebugModeName;
var localized string DebugModeHelp;

function Created()
{
	Super.Created();

	// Add menu items.
	Console = AddMenuItem(ConsoleName, None);
	Console.bChecked = Root.Console.bShowConsole;
	TimeDemo = AddMenuItem(TimeDemoName, None);
	TimeDemo.bChecked = Root.Console.bTimeDemo;
	ShowLog = AddMenuItem(LogName, None);
	AddMenuItem("-", None);
	MusicMBut = AddMenuItem(MusicMName, None);
	AdminMBut = AddMenuItem(AdminMName, None);
	DebugMode = AddMenuItem(DebugModeName, None);
	DebugMode.bChecked = Root.bDisplayDebugMouse;
}

function ShowWindow()
{
	Super.ShowWindow();

	Console.bChecked = Root.Console.bShowConsole;
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Console:
		Console.bChecked = !Console.bChecked;
		if (Console.bChecked)
			Root.Console.ShowConsole();
		else
			Root.Console.HideConsole();
		break;
	case TimeDemo:
		TimeDemo.bChecked = !TimeDemo.bChecked;
		if (TimeDemo.bChecked)
			GetPlayerOwner().ConsoleCommand("TIMEDEMO 1");
		else 
			GetPlayerOwner().ConsoleCommand("TIMEDEMO 0");
		break;
	case ShowLog:
		GetPlayerOwner().ConsoleCommand("SHOWLOG");
		break;
	case MusicMBut:
		GetPlayerOwner().ConsoleCommand("UShowMusicMenu");
		break;
	case AdminMBut:
		GetPlayerOwner().ConsoleCommand("UShowAdminMenu");
		break;
	case DebugMode:
		Root.bDisplayDebugMouse = !Root.bDisplayDebugMouse;
		DebugMode.bChecked = Root.bDisplayDebugMouse;
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Console:
		UMenuMenuBar(GetMenuBar()).SetHelp(ConsoleHelp);
		break;
	case TimeDemo:
		UMenuMenuBar(GetMenuBar()).SetHelp(TimeDemoHelp);
		break;
	case ShowLog:
		UMenuMenuBar(GetMenuBar()).SetHelp(LogHelp);
		break;
	case MusicMBut:
		UMenuMenuBar(GetMenuBar()).SetHelp(MusicMHelp);
		break;
	case AdminMBut:
		UMenuMenuBar(GetMenuBar()).SetHelp(AdminMHelp);
		break;
	case DebugMode:
		UMenuMenuBar(GetMenuBar()).SetHelp(DebugModeHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
	ConsoleName="System &Console"
	ConsoleHelp="This option brings up the Unreal Console.  You can use the console to enter advanced commands and cheats."
	TimeDemoName="T&imeDemo Statistics"
	TimeDemoHelp="Enable the TimeDemo statistic to measure your frame rate."
	LogName="Show &Log"
	LogHelp="Show the Unreal log window."
	MusicMName="&Music Menu"
	MusicMHelp="Music menu: Allows you to play a custom music during game (Warning: many anti-cheat mods may not like the custom musics)."
	AdminMName="&Admin Menu"
	AdminMHelp="Admin menu: Allows you to do various things, such as kicking/banning/unbanning clients (note: only works on 227 servers and when youre logged in as administrator)."
	DebugModeName="&Debug mode"
	DebugModeHelp="Enable UWindow debug mode for debugging."
}
