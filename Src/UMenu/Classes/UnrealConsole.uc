class UnrealConsole extends WindowConsole;

// Show UMenu load game menu.
simulated function ShowLoadGameMenu()
{
	// Create load game dialog.
	Root.CreateWindow(class'UMenuLoadGameWindow', 100, 100, 200, 200, None, True);
}

defaultproperties
{
	RootWindow="UMenu.UMenuRootWindow"
	ConsoleClass=Class'UMenu.UMenuConsoleWindow'
	MouseScale=0.900000
}
