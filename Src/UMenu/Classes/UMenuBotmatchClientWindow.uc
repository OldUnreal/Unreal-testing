class UMenuBotmatchClientWindow extends UWindowDialogClientWindow;

// Game Information
var config string Map;
var config string GameType;
var config bool bFilterInvalidGameClasses;
var class<GameInfo> GameClass;

var bool bNetworkGame;
var bool bSetGameDifficulty;

// Window
var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;
var UWindowSmallButton StartButton;
var UMenuScreenshotCW ScreenshotWindow;
var UWindowHSplitter Splitter;

var localized string StartMatchTab, RulesTab, SettingsTab, BotConfigTab;
var localized string StartText;

var UWindowPageControlPage StartMatchPage, RulesPage, SettingsPage, BotConfigPage;

const ButtonHOffset = 2;

function Created()
{
	bSetGameDifficulty = false;

	if( !Class'UMenuMutatorCW'.Default.bKeepMutators )
		Class'UMenuMutatorCW'.Default.MutatorList = "";

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	Splitter.SplitPos = 280;
	Splitter.MaxSplitPos = 280;
	Splitter.bRightGrow = True;

	ScreenshotWindow = UMenuScreenshotCW(Splitter.CreateWindow(class'UMenuScreenshotCW', 0, 0, WinWidth, WinHeight));

	CreatePages();

	Splitter.LeftClientWindow = Pages;
	Splitter.RightClientWindow = ScreenshotWindow;

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
	StartButton.SetText(StartText);
	StartButton.bDisabled = GameClass == none;

	Super.Created();
}

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(Splitter.CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(true);
	StartMatchPage = Pages.AddPage(StartMatchTab, class'UMenuStartMatchScrollClient');

	if (GameClass == none)
		return;

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.default.RulesMenuType, class'class', true));
	if (PageClass != none)
		RulesPage = Pages.AddPage(RulesTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.default.SettingsMenuType, class'class', true));
	if (PageClass != none)
		SettingsPage = Pages.AddPage(SettingsTab, PageClass);

	if (Len(GameClass.default.BotMenuType) > 0)
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.default.BotMenuType, class'class', true));
		if (PageClass != none)
			BotConfigPage = Pages.AddPage(BotConfigTab, PageClass);
	}
}

function Resized()
{
	if (ParentWindow.WinWidth == 520)
	{
		Splitter.bSizable = False;
		Splitter.MinWinWidth = 0;
	}
	else
		Splitter.MinWinWidth = 100;

	Splitter.WinWidth = WinWidth;
	Splitter.WinHeight = WinHeight - 24;	// OK, Cancel area

	CloseButton.WinTop = WinHeight - 20;
	StartButton.WinTop = WinHeight - 20;
}

function AlignButtons(Canvas C)
{
	CloseButton.AutoWidth(C);
	CloseButton.WinLeft = WinWidth - CloseButton.WinWidth - ButtonHOffset - 2;
	StartButton.AutoWidth(C);
	StartButton.WinLeft = CloseButton.WinLeft - StartButton.WinWidth - ButtonHOffset;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
	AlignButtons(C);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Click:
		switch (C)
		{
		case StartButton:
			if (!StartButton.bDisabled)
				StartPressed();
			break;
		}
	}
}

function StartPressed()
{
	local string URL;
	local string Difficulty;

	if (class<GameInfo>(DynamicLoadObject(GameType, class'class', true)) == none)
	{
		Log("Rejected an attempt to start new game with an invalid game class '" $ GameType $ "'");
		return;
	}

	// Reset the game class.
	if( GameClass )
		GameClass.Static.ResetGame();

	if (bSetGameDifficulty)
	{
		Difficulty = "?Difficulty=" $ class'UMenuNewGameClientWindow'.default.LastSelectedSkill;
		class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
	}

	URL = Map $ "?Game=" $ GameType $ Difficulty $ "?Mutator=" $ Class'UMenuMutatorCW'.Default.MutatorList;

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

function PreGameChanged()
{
	if( RulesPage )
	{
		DeletePage(RulesPage);
		RulesPage = None;
	}
	if( SettingsPage )
	{
		DeletePage(SettingsPage);
		SettingsPage = None;
	}
	if( BotConfigPage )
	{
		DeletePage(BotConfigPage);
		BotConfigPage = None;
	}
	if( GameClass )
		GameClass.static.StaticSaveConfig();
}

function GameChanged()
{
	local class<UWindowPageWindow> PageClass;
	local UWindowPageControlPage InsertedPage;

	bSetGameDifficulty = false;
	InsertedPage = StartMatchPage;

	if( GameClass )
	{
		// Change out the rules page...
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class', true));
		if (PageClass != none)
		{
			RulesPage = Pages.InsertPageAfter(InsertedPage, RulesTab, PageClass);
			InsertedPage = RulesPage;
		}

		// Change out the settings page...
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class', true));
		if (PageClass != none)
		{
			SettingsPage = Pages.InsertPageAfter(InsertedPage, SettingsTab, PageClass);
			InsertedPage = SettingsPage;
		}

		// Change out the bots page...
		if (Len(GameClass.default.BotMenuType) > 0)
		{
			PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class', true));
			if (PageClass != none)
				BotConfigPage = Pages.InsertPageAfter(InsertedPage, BotConfigTab, PageClass);
		}
	}
}

function SaveConfigs()
{
	if (GameClass != None)
		GameClass.Static.StaticSaveConfig();
	Super.SaveConfigs();
}

function DeletePage(out UWindowPageControlPage Page)
{
	if (Page == none)
		return;
	Pages.DeletePage(Page);
	Page = none;
}

function name ClassifyGameType(string GameClassName)
{
	local class<GameInfo> GameInfoClass;

	if (GameClassName ~= "UnrealShare.CoopGame" ||
		GameClassName ~= "UPak.UPakCoopGame")
	{
		return 'CoopGame';
	}
	if (GameClassName ~= "UnrealI.DarkMatch" ||
		GameClassName ~= "UnrealI.KingOfTheHill" ||
		GameClassName ~= "UnrealShare.DeathMatchGame" ||
		GameClassName ~= "UnrealShare.TeamGame" ||
		GameClassName ~= "UPak.CloakGame" ||
		GameClassName ~= "UPak.CloakMatch" ||
		GameClassName ~= "UPak.GravityMatch" ||
		GameClassName ~= "UPak.MarineMatch" ||
		GameClassName ~= "UPak.TerranWeaponMatch" ||
		GameClassName ~= "UPak.UPakGame")
	{
		return 'DeathMatchGame';
	}
	if (GameClassName ~= "UnrealShare.SinglePlayer" ||
		GameClassName ~= "UnrealShare.VRikersGame" || // intentionally classified as SP game, even though this class is not derived from UnrealShare.SinglePlayer
		GameClassName ~= "UPak.CrashSiteGame" ||
		GameClassName ~= "UPak.DuskFallsGame" ||
		GameClassName ~= "UPak.UPakSinglePlayer") 
	{
		return 'SinglePlayer';
	}
	if (GameClassName ~= "UDSDemo.CSSinglePlayer" ||
		GameClassName ~= "UDSDemo.CSMovie" ||
		GameClassName ~= "UnrealI.EndGame" ||
		GameClassName ~= "UnrealI.Intro" ||
		GameClassName ~= "UnrealShare.EntryGameInfo" ||
		GameClassName ~= "UnrealShare.UnrealGameInfo" ||
		GameClassName ~= "UPak.TestGameInfo" ||
		GameClassName ~= "UPak.UPakIntro" ||
		GameClassName ~= "UPak.UPakTransitionInfo")
	{
		return 'UnrealGameInfo';
	}
	if (GameClassName ~= "UPak.CreditsGame")
		return 'GameInfo';

	GameInfoClass = class<GameInfo>(DynamicLoadObject(GameClassName, class'class', true));
	if (GameInfoClass == none)
		return '';
	if (ClassIsChildOf(GameInfoClass, class'UnrealShare.CoopGame'))
		return 'CoopGame';
	if (ClassIsChildOf(GameInfoClass, class'UnrealShare.DeathMatchGame'))
		return 'DeathMatchGame';
	if (ClassIsChildOf(GameInfoClass, class'UnrealShare.SinglePlayer') || ClassIsChildOf(GameInfoClass, class'UnrealShare.VRikersGame'))
		return 'SinglePlayer';
	if (ClassIsChildOf(GameInfoClass, class'UnrealShare.UnrealGameInfo'))
		return 'UnrealGameInfo';
	return 'GameInfo';
}

function bool CheckGameClass(string PackageName, string GameClassName)
{
	if (PackageName ~= "Engine")
		return false;
	if (PackageName ~= "UnrealI" ||
		PackageName ~= "UnrealShare" ||
		PackageName ~= "UPak")
	{
		return ClassifyGameType(GameClassName) == 'DeathMatchGame';
	}
	return true;
}

function string MapPrefix()
{
	if (GameClass != none)
		return GameClass.default.MapPrefix;
	return "";
}

function EnableStart(bool bEnable)
{
	if (StartButton != none)
		StartButton.bDisabled = !bEnable;
}

defaultproperties
{
	GameType="UnrealShare.DeathmatchGame"
	StartMatchTab="Match"
	RulesTab="Rules"
	SettingsTab="Settings"
	BotConfigTab="Bots"
	StartText="Start"
}
