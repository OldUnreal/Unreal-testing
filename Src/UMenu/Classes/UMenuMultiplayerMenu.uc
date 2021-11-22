class UMenuMultiplayerMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Start, Browser, LAN, Patch, Disconnect, Reconnect, OpenLocation;
var UBrowserMainWindow BrowserWindow;

var localized string StartName;
var localized string StartHelp;
var localized string BrowserName;
var localized string BrowserHelp;
var localized string LANName;
var localized string LANHelp;
var localized string OpenLocationName;
var localized string OpenLocationHelp;
var localized string PatchName;
var localized string PatchHelp;
var localized string DisconnectName;
var localized string DisconnectHelp;
var localized string ReconnectName;
var localized string ReconnectHelp;
var localized string SuggestPlayerSetupTitle;
var localized string SuggestPlayerSetupText;
var localized string SuggestNetspeedTitle;
var localized string SuggestNetspeedText;

var config string UBrowserClassName;
var config string StartGameClassName;

var UWindowMessageBox SuggestPlayerSetup, SuggestNetspeed;
var bool bOpenLocation;
var bool bOpenLAN;

function Created()
{
	Super.Created();

	Browser = AddMenuItem(BrowserName, None);
	Start = AddMenuItem(StartName, None);
	LAN = AddMenuItem(LanName, None);
	OpenLocation = AddMenuItem(OpenLocationName, None);
	AddMenuItem("-", None);
	Disconnect = AddMenuItem(DisconnectName, None);
	Reconnect = AddMenuItem(ReconnectName, None);
	AddMenuItem("-", None);
	Patch = AddMenuItem(PatchName, None);
}

function WindowShown()
{
	Super.WindowShown();

	if (GetLevel().NetMode == NM_Client)
	{
		Disconnect.bDisabled = False;
		Reconnect.bDisabled = False;
	}
	else
	{
		Disconnect.bDisabled = True;
		Reconnect.bDisabled = GetLevel() != GetEntryLevel();
	}
}

function ResolutionChanged(float W, float H)
{
	if (BrowserWindow != None)
		BrowserWindow.ResolutionChanged(W, H);
	Super.ResolutionChanged(W, H);
}

function NotifyQuitUnreal()
{
	if (BrowserWindow != None && !BrowserWindow.bWindowVisible)
		BrowserWindow.NotifyQuitUnreal();
	Super.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	if (BrowserWindow != None && !BrowserWindow.bWindowVisible)
		BrowserWindow.NotifyBeforeLevelChange();
	Super.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
	if (BrowserWindow != None && !BrowserWindow.bWindowVisible)
		BrowserWindow.NotifyAfterLevelChange();
	Super.NotifyAfterLevelChange();
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Start:
		UMenuMenuBar(GetMenuBar()).SetHelp(StartHelp);
		break;
	case Browser:
		UMenuMenuBar(GetMenuBar()).SetHelp(BrowserHelp);
		break;
	case LAN:
		UMenuMenuBar(GetMenuBar()).SetHelp(LANHelp);
		break;
	case OpenLocation:
		UMenuMenuBar(GetMenuBar()).SetHelp(OpenLocationHelp);
		break;
	case Patch:
		UMenuMenuBar(GetMenuBar()).SetHelp(PatchHelp);
		break;
	case Disconnect:
		UMenuMenuBar(GetMenuBar()).SetHelp(DisconnectHelp);
		break;
	case Reconnect:
		UMenuMenuBar(GetMenuBar()).SetHelp(ReconnectHelp);
		break;
	}

	Super.Select(I);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	local class<UMenuStartGameWindow> StartGameClass;

	switch (I)
	{
	case Start:
		// Create start network game dialog.
		StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject(StartGameClassName, class'Class'));
		Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True);
		break;
	case OpenLocation:
	case Browser:
	case LAN:
		bOpenLAN = (I == LAN);
		bOpenLocation = (I == OpenLocation);

		if (GetPlayerOwner().PlayerReplicationInfo.PlayerName ~= "Player")
			SuggestPlayerSetup = MessageBox(SuggestPlayerSetupTitle, SuggestPlayerSetupText, MB_YesNo, MR_None, MR_None);
		else if (!class'UMenuNetworkClientWindow'.default.bShownWindow && !bOpenLAN)
			SuggestNetspeed = MessageBox(SuggestNetspeedTitle, SuggestNetspeedText, MB_YesNo, MR_None, MR_None);
		else
			LoadUBrowser();
		break;
	case Patch:
		GetPlayerOwner().ConsoleCommand("start http://www.oldunreal.com/");
		break;
	case Disconnect:
		GetPlayerOwner().ConsoleCommand("disconnect");
		Root.Console.CloseUWindow();
		break;
	case Reconnect:
		if (GetLevel().NetMode == NM_Client)
			GetPlayerOwner().ConsoleCommand("disconnect");
		GetPlayerOwner().ConsoleCommand("reconnect");
		Root.Console.CloseUWindow();
		break;
	}

	Super.ExecuteItem(I);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	switch (W)
	{
	case SuggestPlayerSetup:
		switch (Result)
		{
		case MR_Yes:
			UMenuMenuBar(GetMenuBar()).Options.PlayerSetup();
			break;
		case MR_No:
			LoadUBrowser();
			break;
		}
		break;
	case SuggestNetspeed:
		switch (Result)
		{
		case MR_Yes:
			UMenuMenuBar(GetMenuBar()).Options.ShowPreferences(True);
			break;
		case MR_No:
			LoadUBrowser();
			break;
		}
		break;
	}
}

function LoadUBrowser()
{
	local class<UBrowserMainWindow> UBrowserClass;

	if (BrowserWindow == None)
	{
		UBrowserClass = class<UBrowserMainWindow>(DynamicLoadObject(UBrowserClassName, class'Class'));
		BrowserWindow = UBrowserMainWindow(Root.CreateWindow(UBrowserClass, 50, 30, 500, 300));
	}
	else
	{
		BrowserWindow.ShowWindow();
		BrowserWindow.BringToFront();
	}
	/*
	if(bOpenLocation)
		BrowserWindow.ShowOpenWindow(); // not in UGold either, maybe need to check later - Smirftsch
	*/

	if (bOpenLAN)
		BrowserWindow.SelectLAN();
	else
		BrowserWindow.SelectInternet();

	bOpenLocation = False;
}

defaultproperties
{
	StartName="&Start New Multiplayer Game"
	StartHelp="Start your own network game which others can join."
	BrowserName="&Find Internet Games"
	BrowserHelp="Search for games currently in progress on the Internet."
	LANName="Find &LAN Games"
	LANHelp="Search for games of your local LAN."
	OpenLocationName="Open &Location"
	OpenLocationHelp="Connect to a server using its IP address or unreal:// URL."
	PatchName="Download Latest &Update"
	PatchHelp="Find the latest update to Unreal on the web!"
	DisconnectName="&Disconnect from Server"
	DisconnectHelp="Disconnect from the current server."
	ReconnectName="&Reconnect to Server"
	ReconnectHelp="Attempt to reconnect to the last server you were connected to."
	SuggestPlayerSetupTitle="Check Player Name"
	SuggestPlayerSetupText="Your name is currently set to Player.  It is recommended that you go to Player Setup and give yourself another name before playing a multiplayer game."
	SuggestNetspeedTitle="Check Internet Speed"
	SuggestNetspeedText="You haven't yet configured the type of Internet connection you will be playing with. It is recommended that you go to the Network Settings screen to ensure you have the best online gaming experience."
	UBrowserClassName="UBrowser.UBrowserMainWindow"
	StartGameClassName="UMenu.UMenuStartGameWindow"
}
