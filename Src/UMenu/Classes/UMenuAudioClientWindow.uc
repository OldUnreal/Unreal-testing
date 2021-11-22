class UMenuAudioClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth; // Maximal width of a control that indicates a modifiable value

// Driver
var bool bInitialized;
var UWindowComboControl AudioCombo;
var string Driver;
var localized string DriverText;
var localized string DriverHelp;
var localized string ConfirmDriverTitle;
var localized string ConfirmDriverText;

// Sound Quality
var UWindowComboControl SoundQualityCombo;
var localized string SoundQualityText;
var localized string SoundQualityHelp;
var localized string Details[2];

// Music Volume
var UWindowHSliderControl MusicVolumeSlider;
var localized string MusicVolumeText;
var localized string MusicVolumeHelp;

// Sound Volume
var UWindowHSliderControl SoundVolumeSlider;
var localized string SoundVolumeText;
var localized string SoundVolumeHelp;

// Voice Volume
var UWindowHSliderControl VoiceVolumeSlider;
var localized string VoiceVolumeText;
var localized string VoiceVolumeHelp;

// Voice Messages
var UWindowCheckbox VoiceMessagesCheck;
var localized string VoiceMessagesText;
var localized string VoiceMessagesHelp;

// Message Beep
var UWindowCheckbox MessageBeepCheck;
var localized string MessageBeepText;
var localized string MessageBeepHelp;

var localized string NotAvailableText;

var float ControlOffset;
var string CurrentDriver;
var bool bCanAccessDriverSettings;

function Created()
{
	local int ControlWidth, ControlLeft;
	local string NextDefault, NextDesc, ClassLeft, ClassRight;

	Super.Created();

	ControlWidth = EditAreaWidth;
	ControlLeft = (WinWidth - ControlWidth) / 2;

	AudioCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	AudioCombo.SetText(DriverText);
	AudioCombo.SetHelpText(DriverHelp);
	AudioCombo.SetFont(F_Normal);
	AudioCombo.SetEditable(False);
	ControlOffset += 25;

	foreach GetPlayerOwner().IntDescIterator(string(class'Engine.AudioSubsystem'), NextDefault, NextDesc, true)
	{
		if (Len(NextDesc) == 0)
		{
			ClassLeft = Left(NextDefault, InStr(NextDefault, "."));
			ClassRight = Mid(NextDefault, InStr(NextDefault, ".") + 1);
			NextDesc = Localize(ClassRight, "ClassCaption", ClassLeft);
		}

		AudioCombo.AddItem(NextDesc, NextDefault);
	}

	AudioCombo.Sort();

	// Voice Messages
	VoiceMessagesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	VoiceMessagesCheck.SetText(VoiceMessagesText);
	VoiceMessagesCheck.SetHelpText(VoiceMessagesHelp);
	VoiceMessagesCheck.SetFont(F_Normal);
	VoiceMessagesCheck.Align = TA_Left;
	ControlOffset += 25;

	// Message Beep
	MessageBeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	MessageBeepCheck.SetText(MessageBeepText);
	MessageBeepCheck.SetHelpText(MessageBeepHelp);
	MessageBeepCheck.SetFont(F_Normal);
	MessageBeepCheck.Align = TA_Left;
	ControlOffset += 25;

	ExtraMessageOptions();

	// Sound Quality
	SoundQualityCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SoundQualityCombo.SetText(SoundQualityText);
	SoundQualityCombo.SetHelpText(SoundQualityHelp);
	SoundQualityCombo.SetFont(F_Normal);
	SoundQualityCombo.SetEditable(False);
	SoundQualityCombo.AddItem(Details[0]);
	SoundQualityCombo.AddItem(Details[1]);
	ControlOffset += 25;

	// Music Volume
	MusicVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	MusicVolumeSlider.SetRange(0, 255, 16);
	MusicVolumeSlider.SetText(MusicVolumeText);
	MusicVolumeSlider.SetHelpText(MusicVolumeHelp);
	MusicVolumeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Sound Volume
	SoundVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SoundVolumeSlider.SetRange(0, 255, 16);
	SoundVolumeSlider.SetText(SoundVolumeText);
	SoundVolumeSlider.SetHelpText(SoundVolumeHelp);
	SoundVolumeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Voice Volume
	VoiceVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	VoiceVolumeSlider.SetRange(0, 255, 16);
	VoiceVolumeSlider.SetText(VoiceVolumeText);
	VoiceVolumeSlider.SetHelpText(VoiceVolumeHelp);
	VoiceVolumeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	LoadAvailableSettings();
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset;

	bInitialized = true;
}

function WindowShown()
{
	super.WindowShown();
	ReloadAvailableSettings();
}

function string GetAudioDriverClassName()
{
	local string S;

	CurrentDriver = GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice Class");
	// Get class name from class'...'
	if (Divide(CurrentDriver, "'", S, CurrentDriver) && Divide(CurrentDriver, "'", CurrentDriver, S))
	{
		bCanAccessDriverSettings = true;
		return CurrentDriver;
	}

	bCanAccessDriverSettings = false;
	return "";
}

function LoadAudioDriverSettings()
{
	local string CurrentDriver, S;
	local AudioSubsystem Subsystem;
	local int i;

	CurrentDriver = GetAudioDriverClassName();
	if (Len(CurrentDriver) == 0)
		foreach AllObjects(class'Engine.AudioSubsystem', Subsystem)
		{
			CurrentDriver = string(Subsystem.Class);
			break;
		}

	if (Len(CurrentDriver) > 0)
	{
		i = AudioCombo.FindItemIndex2(CurrentDriver);
		if (i >= 0)
		{
			AudioCombo.SetSelectedIndex(i);
			if (!bCanAccessDriverSettings)
				AudioCombo.SetValue("*" @ AudioCombo.GetValue());
		}
		else
		{
			while (Divide(CurrentDriver, ".", S, CurrentDriver)) {}
			AudioCombo.SetValue("*" @ CurrentDriver);
		}
	}
	else
		AudioCombo.SetValue("");
}

function ReloadAvailableSettings()
{
	bInitialized = false;
	LoadAvailableSettings();
	bInitialized = true;
}

function LoadAvailableSettings()
{
	local PlayerPawn P;
	local bool bLowSoundQuality;
	local int MusicVolume, SoundVolume, VoiceVolume;

	P = GetPlayerOwner();
	LoadAudioDriverSettings();

	VoiceMessagesCheck.bChecked = !P.bNoVoices;
	MessageBeepCheck.bChecked = P.bMessageBeep;

	if (bCanAccessDriverSettings)
	{
		bLowSoundQuality = bool(P.ConsoleCommand("get ini:Engine.Engine.AudioDevice LowSoundQuality"));
		SoundQualityCombo.SetDisabled(false);
		SoundQualityCombo.SetSelectedIndex(int(!bLowSoundQuality));

		MusicVolume = Clamp(int(P.ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume")), 0, 255);
		MusicVolumeSlider.bDisabled = false;
		MusicVolumeSlider.bIndeterminate = false;
		MusicVolumeSlider.SetText(MusicVolumeText @ "[" $ MusicVolume $ "]");
		MusicVolumeSlider.SetValue(MusicVolume, true);

		SoundVolume = Clamp(int(P.ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume")), 0, 255);
		SoundVolumeSlider.bDisabled = false;
		SoundVolumeSlider.bIndeterminate = false;
		SoundVolumeSlider.SetText(SoundVolumeText @ "[" $ SoundVolume $ "]");
		SoundVolumeSlider.SetValue(SoundVolume, true);

		VoiceVolumeSlider.bIndeterminate = Property(FindObj(class'Property', CurrentDriver $ ".SpeechVolume")) == none;
		VoiceVolumeSlider.bDisabled = VoiceVolumeSlider.bIndeterminate;
		if (!VoiceVolumeSlider.bIndeterminate)
		{
			VoiceVolume = Clamp(int(P.ConsoleCommand("get ini:Engine.Engine.AudioDevice SpeechVolume")), 0, 255);
			VoiceVolumeSlider.SetText(VoiceVolumeText @ "[" $ VoiceVolume $ "]");
			VoiceVolumeSlider.SetValue(VoiceVolume, true);
		}
	}
	else
	{
		SoundQualityCombo.SetDisabled(true);
		SoundQualityCombo.SetValue(NotAvailableText);

		MusicVolumeSlider.SetText(MusicVolumeText);
		MusicVolumeSlider.bIndeterminate = true;
		MusicVolumeSlider.bDisabled = true;

		SoundVolumeSlider.SetText(SoundVolumeText);
		SoundVolumeSlider.bIndeterminate = true;
		SoundVolumeSlider.bDisabled = true;

		VoiceVolumeSlider.SetText(VoiceVolumeText);
		VoiceVolumeSlider.bIndeterminate = true;
		VoiceVolumeSlider.bDisabled = true;
	}
}

function ExtraMessageOptions()
{
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	AudioCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	VoiceMessagesCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	MessageBeepCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SoundQualityCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	MusicVolumeSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	MusicVolumeSlider.GetMinStrWidth(C, MusicVolumeText @ "[" $ MusicVolumeSlider.GetWidestDigitSequence(C, 3) $ "]", LabelTextAreaWidth);
	SoundVolumeSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SoundVolumeSlider.GetMinStrWidth(C, SoundVolumeText @ "[" $ SoundVolumeSlider.GetWidestDigitSequence(C, 3) $ "]", LabelTextAreaWidth);
	VoiceVolumeSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	VoiceVolumeSlider.GetMinStrWidth(C, VoiceVolumeText @ "[" $ VoiceVolumeSlider.GetWidestDigitSequence(C, 3) $ "]", LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, CheckboxWidth;
	local int LabelHSpacing, RightSpacing;
	local float LabelTextAreaWidth;

	Super.BeforePaint(C, X, Y);

	LabelTextAreaWidth = 0;
	CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	ControlWidth = LabelTextAreaWidth + LabelHSpacing + EditAreaWidth;
	CheckboxWidth = ControlWidth - EditAreaWidth + 16;
	ControlLeft = LabelHSpacing;

	AudioCombo.SetSize(ControlWidth, 1);
	AudioCombo.WinLeft = ControlLeft;
	AudioCombo.EditBoxWidth = EditAreaWidth;

	VoiceMessagesCheck.SetSize(CheckboxWidth, 1);
	VoiceMessagesCheck.WinLeft = ControlLeft;

	MessageBeepCheck.SetSize(CheckboxWidth, 1);
	MessageBeepCheck.WinLeft = ControlLeft;

	SoundQualityCombo.SetSize(ControlWidth, 1);
	SoundQualityCombo.WinLeft = ControlLeft;
	SoundQualityCombo.EditBoxWidth = EditAreaWidth;

	MusicVolumeSlider.SetSize(ControlWidth, 1);
	MusicVolumeSlider.SliderWidth = EditAreaWidth;
	MusicVolumeSlider.WinLeft = ControlLeft;

	SoundVolumeSlider.SetSize(ControlWidth, 1);
	SoundVolumeSlider.SliderWidth = EditAreaWidth;
	SoundVolumeSlider.WinLeft = ControlLeft;

	VoiceVolumeSlider.SetSize(ControlWidth, 1);
	VoiceVolumeSlider.SliderWidth = EditAreaWidth;
	VoiceVolumeSlider.WinLeft = ControlLeft;
}

function Notify(UWindowDialogControl C, byte E)
{
	super.Notify(C, E);
	
	switch (E)
	{
	case DE_Change:
		if (!bInitialized)
			break;
		switch (C)
		{
		case AudioCombo:
			AudioComboChanged();
			break;
		case VoiceMessagesCheck:
			VoiceMessagesChecked();
			break;
		case MessageBeepCheck:
			MessageBeepChecked();
			break;
		case SoundQualityCombo:
			SoundQualityChanged();
			break;
		case MusicVolumeSlider:
			MusicVolumeChanged();
			break;
		case SoundVolumeSlider:
			SoundVolumeChanged();
			break;
		case VoiceVolumeSlider:
			VoiceVolumeChanged();
			break;
		}
	}
}

function AudioComboChanged()
{
	Driver = AudioCombo.GetValue2();
	class'UMenuAudioClientWindow'.default.Driver = Driver;
}

function SoundQualityChanged()
{
	local int SelectedIndex;
	local bool bLowSoundQuality;

	SelectedIndex = SoundQualityCombo.GetSelectedIndex();
	bInitialized = false;
	LoadAvailableSettings();
	if (bCanAccessDriverSettings && SelectedIndex >= 0)
	{
		bLowSoundQuality = SelectedIndex == 0;
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality" @ bLowSoundQuality);
		SoundQualityCombo.SetSelectedIndex(SelectedIndex);
	}
	bInitialized = true;
}

function VoiceMessagesChecked()
{
	GetPlayerOwner().bNoVoices = !VoiceMessagesCheck.bChecked;
}

function MessageBeepChecked()
{
	GetPlayerOwner().bMessageBeep = MessageBeepCheck.bChecked;
}

function MusicVolumeChanged()
{
	if (Len(GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume" @ MusicVolumeSlider.Value)) > 0)
		ReloadAvailableSettings();
	else
		MusicVolumeSlider.SetText(MusicVolumeText @ "[" $ int(MusicVolumeSlider.Value) $ "]");
}

function SoundVolumeChanged()
{
	if (Len(GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume" @ SoundVolumeSlider.Value)) > 0)
		ReloadAvailableSettings();
	else
		SoundVolumeSlider.SetText(SoundVolumeText @ "[" $ int(SoundVolumeSlider.Value) $ "]");
}

function VoiceVolumeChanged()
{
	if (Len(GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice SpeechVolume" @ VoiceVolumeSlider.Value)) > 0)
		ReloadAvailableSettings();
	else
		VoiceVolumeSlider.SetText(VoiceVolumeText @ "[" $ int(VoiceVolumeSlider.Value) $ "]");
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	EditAreaWidth=110
	DriverText="Audio Driver"
	DriverHelp="This is the current audio driver. Press the Restart button to apply changes."
	ConfirmDriverTitle="Change Audio Driver..."
	ConfirmDriverText="Do you want to restart Unreal with the selected audio driver?"
	SoundQualityText="Sound Quality"
	SoundQualityHelp="Use low sound quality to improve game performance on machines with less than 32 Mb memory."
	Details(0)="Low"
	Details(1)="High"
	MusicVolumeText="Music Volume"
	MusicVolumeHelp="Increase or decrease music volume."
	SoundVolumeText="Sound Volume"
	SoundVolumeHelp="Increase or decrease sound effects volume."
	VoiceVolumeText="Voice Volume"
	VoiceVolumeHelp="Increase or decrease speech, taunt and grunt effects volume."
	VoiceMessagesText="Voice Messages"
	VoiceMessagesHelp="If checked, you will hear voice messages and commands from other players."
	MessageBeepText="Message Beep"
	MessageBeepHelp="If checked, you will hear a beep sound when chat message received."
	NotAvailableText="Not available"
	ControlOffset=20.000000
}
