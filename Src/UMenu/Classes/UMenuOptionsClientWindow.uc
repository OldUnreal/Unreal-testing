class UMenuOptionsClientWindow extends UWindowDialogClientWindow
			config;

var bool bInitialized;
var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;
var UWindowSmallRestartButton RestartButton;
var localized string RestartButtonText;
var localized string RestartButtonHelp;
var localized string ConfirmText;
var localized string ConfirmTitle;
var UWindowMessageBox Confirm;

var localized string GamePlayTab, InputTab, ControlsTab, AudioTab, VideoTab, NetworkTab, HUDTab;
var UWindowPageControlPage Network;

const ButtonHOffset = 2;

function Created()
{
	super.Created();

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight - 48));
	Pages.SetMultiLine(True);
	Pages.AddPage(VideoTab, class'UMenuVideoScrollClient');
	Pages.AddPage(AudioTab, class'UMenuAudioScrollClient');
	Pages.AddPage(GamePlayTab, class'UMenuGameOptionsScrollClient');
	Pages.AddPage(ControlsTab, class'UMenuCustomizeScrollClient');
	Pages.AddPage(InputTab, class'UMenuInputOptionsScrollClient');
	Pages.AddPage(HUDTab, class'UMenuHUDConfigScrollClient');
	Network = Pages.AddPage(NetworkTab, class'UMenuNetworkScrollClient');
	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	RestartButton = UWindowSmallRestartButton(CreateControl(class'UWindowSmallRestartButton', WinWidth-56, WinHeight-24, 48, 16));
	RestartButton.SetText(RestartButtonText);
	RestartButton.SetFont(F_Normal);
	RestartButton.SetHelpText(RestartButtonHelp);

	bInitialized = true;
}

function ShowNetworkTab()
{
	Pages.GotoTab(Network, True);
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.WinHeight = WinHeight - 24;	// OK, Cancel area
	CloseButton.WinTop = WinHeight - 20;
	RestartButton.WinTop = WinHeight - 20;
}

function AlignButtons(Canvas C)
{
	CloseButton.AutoWidth(C);
	CloseButton.WinLeft = WinWidth - CloseButton.WinWidth - ButtonHOffset - 2;
	RestartButton.AutoWidth(C);
	RestartButton.WinLeft = CloseButton.WinLeft - RestartButton.WinWidth - ButtonHOffset;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
	AlignButtons(C);
}

function GetDesiredDimensions(out float W, out float H)
{
	Super(UWindowWindow).GetDesiredDimensions(W, H);
	H += 30;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Click:
		switch (C)
		{
		case RestartButton:
			if(!RestartButton.bDisabled)
				RestartButtonChange();
			break;
		}
		break;
	}
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	local string SelectedLanguage, SelectedConsole, SelectedAudioDevice, SelectedVideoDevice;

	if (W == Confirm)
	{
		Confirm = none;
		if (Result == MR_Yes)
		{
			SelectedAudioDevice = class'UMenuAudioClientWindow'.default.Driver;
			if (SelectedAudioDevice != "")
			{
				GetPlayerOwner().ConsoleCommand("SETAUDIODEVICE" @ SelectedAudioDevice);
				Log("...setting Engine.Engine.AudioDevice:" @ SelectedAudioDevice);
			}

			SelectedVideoDevice = class'UMenuVideoClientWindow'.default.Driver;
            if (SelectedVideoDevice != "")
			{
				GetPlayerOwner().ConsoleCommand("SETGAMERENDERDEVICE" @ SelectedVideoDevice);
				Log("...setting Engine.Engine.GameRenderDevice:" @ SelectedVideoDevice);
			}

			SelectedLanguage = class'UMenuGameOptionsClientWindow'.default.Language;
            if (SelectedLanguage != "")
			{
				class'Locale'.Static.SetLanguage(SelectedLanguage);
				Log("...setting Engine.Engine.Language:" @ SelectedLanguage);
				Log("...get language after save:" @ class'Locale'.Static.GetLanguage());
			}

			SelectedConsole = class'UMenuGameOptionsClientWindow'.default.Console;
			if (SelectedConsole != "")
			{
				GetPlayerOwner().ConsoleCommand("SetGameConsole" @ SelectedConsole);
				Log("...setting Engine.Engine.Console:" @ SelectedConsole);
			}

			GetParent(class'UWindowFramedWindow').Close();
			Root.Console.CloseUWindow();
			GetPlayerOwner().ConsoleCommand("RELAUNCH");
		}
	}
}

function RestartButtonChange()
{
	Confirm = MessageBox(ConfirmTitle, ConfirmText, MB_YesNo, MR_No);
}

defaultproperties
{
	ConfirmTitle="Save Settings and Restart..."
	ConfirmText="This option will restart Unreal now and will run with selected settings. do you want to do this?"
	RestartButtonText="Restart"
	RestartButtonHelp="Press this button to restart the game with current settings."
	GamePlayTab="Game"
	InputTab="Input"
	ControlsTab="Controls"
	AudioTab="Audio"
	VideoTab="Video"
	NetworkTab="Network"
	HUDTab="HUD"
}
