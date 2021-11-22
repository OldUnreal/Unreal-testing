class UMenuGameMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem NewGame, Load, Save, GameOptions, Botmatch, Quit;

var localized string NewGameName;
var localized string NewGameHelp;
var localized string LoadName;
var localized string LoadHelp;
var localized string SaveName;
var localized string SaveHelp;
var localized string BotmatchName;
var localized string BotmatchHelp;
var localized string QuitName;
var localized string QuitHelp;
var localized string QuitTitle;
var localized string QuitText;

var UWindowMessageBox ConfirmQuit;

function Created()
{
	Super.Created();

	// Add menu items.
	NewGame = AddMenuItem(NewGameName, None);
	Load = AddMenuItem(LoadName, None);
	Save = AddMenuItem(SaveName, None);
	AddMenuItem("-", None);
	Botmatch = AddMenuItem(BotmatchName, None);
	AddMenuItem("-", None);
	Quit = AddMenuItem(QuitName, None);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (W == ConfirmQuit && Result == MR_Yes)
		Root.QuitGame();
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case NewGame:
		// Create new game dialog.
		Root.CreateWindow(class'UMenuNewGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Load:
		// Create load game dialog.
		Root.CreateWindow(class'UMenuLoadGameWindow', 100, 100, 300, 660, Self, True);
		break;
	case Save:
		// Create save game dialog.
		Root.CreateWindow(class'UMenuSaveGameWindow', 100, 100, 300, 660, Self, True);
		break;
	case Botmatch:
		// Create botmatch dialog.
		Root.CreateWindow(class'UMenuBotmatchWindow', 100, 100, 200, 200, Self, True);
		break;
	case Quit:
		ConfirmQuit = MessageBox(QuitTitle, QuitText, MB_YesNo, MR_No, MR_Yes);
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case NewGame:
		UMenuMenuBar(GetMenuBar()).SetHelp(NewGameHelp);
		return;
	case Load:
		UMenuMenuBar(GetMenuBar()).SetHelp(LoadHelp);
		break;
	case Save:
		UMenuMenuBar(GetMenuBar()).SetHelp(SaveHelp);
		break;
	case Botmatch:
		UMenuMenuBar(GetMenuBar()).SetHelp(BotmatchHelp);
		break;
	case Quit:
		UMenuMenuBar(GetMenuBar()).SetHelp(QuitHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
	NewGameName="&New"
	NewGameHelp="Select to setup a new single player game of Unreal."
	LoadName="&Load"
	LoadHelp="Select to load a previously saved game."
	SaveName="&Save"
	SaveHelp="Select to save your current game."
	BotmatchName="&Botmatch"
	BotmatchHelp="Select to begin a game of Botmatch: Deathmatch with Bots!"
	QuitName="&Quit"
	QuitHelp="Select to save preferences and exit Unreal."
	QuitTitle="Confirm Quit"
	QuitText="Are you sure you want to Quit?"
}
