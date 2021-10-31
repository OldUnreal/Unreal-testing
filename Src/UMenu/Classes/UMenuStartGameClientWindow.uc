class UMenuStartGameClientWindow extends UMenuBotmatchClientWindow;

// Window
var UWindowSmallButton DedicatedButton;
var localized string DedicatedText;
var localized string DedicatedHelp;
var localized string ServerText;

var UWindowPageControlPage ServerTab;

function Created()
{
	Super.Created();

	// Dedicated
	DedicatedButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-156, WinHeight-24, 48, 16));
	DedicatedButton.SetText(DedicatedText);
	DedicatedButton.SetHelpText(DedicatedHelp);
	DedicatedButton.bDisabled = GameClass == none;

	ServerTab = Pages.AddPage(ServerText, class'UMenuServerSetupSC');
}

function Resized()
{
	Super.Resized();
	DedicatedButton.WinTop = WinHeight - 20;
}

function AlignButtons(Canvas C)
{
	super.AlignButtons(C);
	DedicatedButton.AutoWidth(C);
	DedicatedButton.WinLeft = StartButton.WinLeft - DedicatedButton.WinWidth - ButtonHOffset;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch (E)
	{
	case DE_Click:
		switch (C)
		{
		case DedicatedButton:
			if (!DedicatedButton.bDisabled)
				DedicatedPressed();
			return;
		default:
			Super.Notify(C, E);
			return;
		}
	default:
		Super.Notify(C, E);
		return;
	}
}

function DedicatedPressed()
{
	local string URL;
	local string LanPlay;
	local string Difficulty;

	if (class<GameInfo>(DynamicLoadObject(GameType, class'class', true)) == none)
	{
		Log("Rejected an attempt to start new game with an invalid game class '" $ GameType $ "'");
		return;
	}

	if (UMenuServerSetupPage(UMenuServerSetupSC(ServerTab.Page).ClientArea).bLanPlay)
		LanPlay = " -lanplay";

	if (bSetGameDifficulty)
	{
		Difficulty = "?Difficulty=" $ class'UMenuNewGameClientWindow'.default.LastSelectedSkill;
		class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
	}

	URL = Map $ "?Game=" $ GameType $ Difficulty $ "?Mutator=" $ Class'UMenuMutatorCW'.Default.MutatorList $ "?Listen";

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ConsoleCommand("RELAUNCH "$URL$LanPlay$" -server log="$GameClass.Default.ServerLogName);
}

// Override botmatch's start behavior
function StartPressed()
{
	local string Difficulty;

	if (class<GameInfo>(DynamicLoadObject(GameType, class'class', true)) == none)
	{
		Log("Rejected an attempt to start new game with an invalid game class '" $ GameType $ "'");
		return;
	}

	// Reset the game class.
	GameClass.Static.ResetGame();

	ParentWindow.Close();
	Root.Console.CloseUWindow();

	if (bSetGameDifficulty)
	{
		Difficulty = "?Difficulty=" $ class'UMenuNewGameClientWindow'.default.LastSelectedSkill;
		class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
	}

	GetPlayerOwner().ClientTravel(Map $ "?Game=" $ GameType $ Difficulty $ "?Mutator=" $ Class'UMenuMutatorCW'.Default.MutatorList $ "?Listen", TRAVEL_Absolute, false);
}

function bool CheckGameClass(string PackageName, string GameClassName)
{
	local name GameGroup;

	if (PackageName ~= "Engine")
		return false;
	if (PackageName ~= "UnrealI" ||
		PackageName ~= "UnrealShare" ||
		PackageName ~= "UPak")
	{
		GameGroup = ClassifyGameType(GameClassName);
		return GameGroup == 'CoopGame' || GameGroup == 'DeathMatchGame';
	}
	return true;
}

function EnableStart(bool bEnable)
{
	super.EnableStart(bEnable);
	if (DedicatedButton != none)
		DedicatedButton.bDisabled = !bEnable;
}

defaultproperties
{
	DedicatedText="Dedicated"
	DedicatedHelp="Press to launch a dedicated server."
	ServerText="Server"
	Map="Real_LavaGiant.unr"
	GameType="RealCTF.RealTeamGame"
	bNetworkGame=True
}
