class UMenuGameOptionsClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth; // Maximal width of a control that indicates a modifiable value

// language settings
var string Language;
var UWindowComboControl LanguageCombo;
var localized string LanguageText;
var localized string LanguageHelp;

var string Console;
var UWindowComboControl ConsoleCombo;
var localized string ConsoleText;
var localized string ConsoleHelp;

// Weapon Flash [unused, preserved for backward binary compatibility]
var UWindowCheckbox WeaponFlashCheck;
var localized string WeaponFlashText;
var localized string WeaponFlashHelp;

// Weapon Hand
var UWindowComboControl WeaponHandCombo;
var localized string WeaponHandText;
var localized string WeaponHandHelp;

var localized string LeftName;
var localized string CenterName;
var localized string RightName;
var localized string HiddenName;

// Dodging [unused, preserved for backward binary compatibility]
var UWindowCheckbox DodgingCheck;
var localized string DodgingText;
var localized string DodgingHelp;

// View Bob
var UWindowHSliderControl ViewBobSlider;
var localized string ViewBobText;
var localized string ViewBobHelp;

// Game Speed
var UWindowHSliderControl SpeedSlider;
var localized string SpeedText;
var int LastGameSpeed;

// Reduced Gore
var UWindowComboControl GoreCombo;
var localized string GoreText;
var localized string GoreHelp;
var localized string GoreLevels[3];

// Local Logging
var UWindowCheckbox LocalCheck;
var localized string LocalText;
var localized string LocalHelp;

var globalconfig bool bShowGoreControl;

var bool bInitialized;
var float ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft;

	local string NextDefault, NextDesc, CurrentLanguage, CurrentConsole;
	local string PackageName, ClassName;

	super.Created();

	ControlWidth = EditAreaWidth;
	ControlLeft = (WinWidth - ControlWidth)/2;

	LanguageCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	LanguageCombo.SetText(LanguageText);
	LanguageCombo.SetHelpText(LanguageHelp);
	LanguageCombo.SetFont(F_Normal);
	LanguageCombo.SetEditable(False);
	ControlOffset += 25;

	CurrentLanguage = class'Locale'.Static.GetLanguage();

	foreach GetPlayerOwner().IntDescIterator(string(class'Engine.Language'), NextDefault, NextDesc)
	{
		if (Len(NextDesc) == 0)
		{
			NextDesc = class'Locale'.Static.GetDisplayLanguage(NextDefault);
			if (Len(NextDesc) == 0)
			{
				Log(self $ ": Description of language '" $ NextDefault $ "' is missing");
				NextDesc = NextDefault;
			}
		}

		LanguageCombo.AddItem(NextDesc,NextDefault);

		if (NextDefault ~= CurrentLanguage)
			LanguageCombo.SetValue(NextDesc, NextDefault);
	}
	if (Len(LanguageCombo.GetValue2()) == 0 && Len(CurrentLanguage) > 0)
		LanguageCombo.SetValue(CurrentLanguage, CurrentLanguage);

	LanguageCombo.Sort();
    //----------------------------------

	ConsoleCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ConsoleCombo.SetText(ConsoleText);
	ConsoleCombo.SetHelpText(ConsoleHelp);
	ConsoleCombo.SetFont(F_Normal);
	ConsoleCombo.SetEditable(false);
	ControlOffset += 25;

	CurrentConsole = string(Root.Console.Class);

	foreach GetPlayerOwner().IntDescIterator("Engine.Console", NextDefault, NextDesc)
		if (Divide(NextDefault, ".", PackageName, ClassName))
		{
			NextDesc = Localize(ClassName, "ClassCaption", PackageName);
			if (StartsWith(NextDesc, "<?"))
				NextDesc = NextDefault;
			ConsoleCombo.AddItem(NextDesc, NextDefault);

			if (NextDefault ~= CurrentConsole)
				ConsoleCombo.SetValue(NextDesc, NextDefault);
		}
	if (Len(ConsoleCombo.GetValue2()) == 0)
		ConsoleCombo.SetValue(CurrentConsole, CurrentConsole);

	ConsoleCombo.Sort();

	// Weapon Hand
	WeaponHandCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	WeaponHandCombo.SetText(WeaponHandText);
	WeaponHandCombo.SetHelpText(WeaponHandHelp);
	WeaponHandCombo.SetFont(F_Normal);
	WeaponHandCombo.SetEditable(False);
	WeaponHandCombo.AddItem(LeftName, "Left");
	WeaponHandCombo.AddItem(CenterName, "Center");
	WeaponHandCombo.AddItem(RightName, "Right");
	WeaponHandCombo.AddItem(HiddenName, "Hidden");
	ControlOffset += 25;
	/*
	if ( class'GameInfo'.default.bAlternateMode ) // UGold - Smirftsch
		bShowGoreControl = false;
	*/

	if (bShowGoreControl)
	{
		// Reduced Gore
		GoreCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
		GoreCombo.SetText(GoreText);
		GoreCombo.SetHelpText(GoreHelp);
		GoreCombo.SetFont(F_Normal);
		GoreCombo.SetEditable(False);
		GoreCombo.AddItem(GoreLevels[0]);
		GoreCombo.AddItem(GoreLevels[1]);
		GoreCombo.AddItem(GoreLevels[2]);
		ControlOffset += 25;
	}

	// View Bob
	ViewBobSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ViewBobSlider.SetRange(0, 8, 1);
	ViewBobSlider.SetText(ViewBobText);
	ViewBobSlider.SetHelpText(ViewBobHelp);
	ViewBobSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Game Speed
	SpeedSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SpeedSlider.SetRange(50, 200, 5);
	SpeedSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Local Logging
	LocalCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	LocalCheck.SetText(LocalText);
	LocalCheck.SetHelpText(LocalHelp);
	LocalCheck.SetFont(F_Normal);
	LocalCheck.Align = TA_Left;
	ControlOffset += 25;

	LoadAvailableSettings();
}

function WindowShown()
{
	super.WindowShown();
	LoadAvailableSettings();
}

function LoadAvailableSettings()
{
	local PlayerPawn P;
	local GameInfo Game;

	P = GetPlayerOwner();
	bInitialized = false;

	if (-1 <= P.Handedness && P.Handedness <= 1)
		WeaponHandCombo.SetSelectedIndex(1 - P.Handedness);
	else if (P.Handedness == 2)
		WeaponHandCombo.SetSelectedIndex(3);
	else
		WeaponHandCombo.SetSelectedIndex(2);

	if (GoreCombo != none)
	{
		if (class'GameInfo'.default.bVeryLowGore)
			GoreCombo.SetSelectedIndex(2);
		else if (class'GameInfo'.default.bLowGore)
			GoreCombo.SetSelectedIndex(1);
		else
			GoreCombo.SetSelectedIndex(0);
	}

	ViewBobSlider.SetValue((GetPlayerOwner().Bob * 1000) / 4);

	Game = GetLevel().Game;
	if (Game != none && Game.Role == ROLE_Authority)
		LastGameSpeed = Game.GameSpeed * 100.0;
	else
		LastGameSpeed = FMax(0.1, GetLevel().TimeDilation) * 100.0;
	SpeedSlider.SetValue(LastGameSpeed);
	SpeedSlider.SetText(SpeedText @ "[" $ LastGameSpeed $ "%]:");

	LocalCheck.bChecked = class'GameInfo'.default.bLocalLog;

	bInitialized = true;
}

function AfterCreate()
{
	Super.AfterCreate();
	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	LanguageCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ConsoleCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	WeaponHandCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ViewBobSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SpeedSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SpeedSlider.GetMinStrWidth(C, SpeedText @ "[" $ SpeedSlider.GetWidestDigitSequence(C, 3) $ "%]:", LabelTextAreaWidth);
	if (GoreCombo != none)
		GoreCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	LocalCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft;
	local int LabelHSpacing, RightSpacing;
	local float LabelTextAreaWidth;

	LabelTextAreaWidth = 0;
	CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	ControlWidth = LabelTextAreaWidth + LabelHSpacing + EditAreaWidth;
	ControlLeft = LabelHSpacing;

	LanguageCombo.SetSize(ControlWidth, 1);
	LanguageCombo.WinLeft = ControlLeft;
	LanguageCombo.EditBoxWidth = EditAreaWidth;

	ConsoleCombo.SetSize(ControlWidth, 1);
	ConsoleCombo.WinLeft = ControlLeft;
	ConsoleCombo.EditBoxWidth = EditAreaWidth;

	LocalCheck.SetSize(ControlWidth - EditAreaWidth + 16, 1);
	LocalCheck.WinLeft = ControlLeft;

	WeaponHandCombo.SetSize(ControlWidth, 1);
	WeaponHandCombo.WinLeft = ControlLeft;
	WeaponHandCombo.EditBoxWidth = EditAreaWidth;

	ViewBobSlider.SetSize(ControlWidth, 1);
	ViewBobSlider.SliderWidth = EditAreaWidth;
	ViewBobSlider.WinLeft = ControlLeft;

	SpeedSlider.SetSize(ControlWidth, 1);
	SpeedSlider.SliderWidth = EditAreaWidth;
	SpeedSlider.WinLeft = ControlLeft;

	if (GoreCombo != None)
	{
		GoreCombo.SetSize(ControlWidth, 1);
		GoreCombo.WinLeft = ControlLeft;
		GoreCombo.EditBoxWidth = EditAreaWidth;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	switch (E)
	{
	case DE_Change:
		if (!bInitialized)
			break;
		switch (C)
		{
		case LanguageCombo:
		    LanguageComboChanged();
			break;
		case ConsoleCombo:
			ConsoleComboChanged();
			break;
		case WeaponHandCombo:
			WeaponHandChanged();
			break;
		case ViewBobSlider:
			ViewBobChanged();
			break;
		case SpeedSlider:
			SpeedChanged();
			break;
		case GoreCombo:
			GoreChanged();
			break;
		case LocalCheck:
			LocalChecked();
			break;
		}
	}
	Super.Notify(C, E);
}

function LanguageComboChanged()
{
	Language = LanguageCombo.GetValue2();
	class'UMenuGameOptionsClientWindow'.default.Language = Language;
}

function ConsoleComboChanged()
{
	if (class<Console>(DynamicLoadObject(ConsoleCombo.GetValue2(), class'class', true)) != none)
	{
		Console = ConsoleCombo.GetValue2();
		class'UMenuGameOptionsClientWindow'.default.Console = Console;
	}
	else
	{
		Log("Failed to load console class '" $ ConsoleCombo.GetValue2() $ "'");
		LoadAvailableSettings();
	}
}

// unused, preserved for backward binary compatibility
function WeaponFlashChecked();

// unused, preserved for backward binary compatibility
function DodgingChecked();

function WeaponHandChanged()
{
	GetPlayerOwner().ChangeSetHand(WeaponHandCombo.GetValue2());
}

function ViewBobChanged()
{
	GetPlayerOwner().UpdateBob((ViewBobSlider.Value * 4) / 1000);
}

function SpeedChanged()
{
	local GameInfo Game;
	local int GameSpeed;

	Game = GetLevel().Game;
	if (Game != none && Game.Role == ROLE_Authority)
	{
		GameSpeed = SpeedSlider.GetValue();
		SpeedSlider.SetText(SpeedText @ "[" $ GameSpeed $ "%]:");
		Game.SetGameSpeed(GameSpeed / 100.0);
	}
	else
	{
		bInitialized = false;
		SpeedSlider.SetValue(LastGameSpeed);
		bInitialized = true;
	}
}

function GoreChanged()
{
	local bool bLowGore, bVeryLowGore;

	switch (GoreCombo.GetSelectedIndex())
	{
	case 0:
		bLowGore = False;
		bVeryLowGore = False;
		break;
	case 1:
		bLowGore = True;
		bVeryLowGore = False;
		break;
	case 2:
		bLowGore = True;
		bVeryLowGore = True;
		break;
	}

	if (GetLevel().Game != None)
	{
		GetLevel().Game.bLowGore = bLowGore;
		GetLevel().Game.bVeryLowGore = bVeryLowGore;
	}

	class'GameInfo'.default.bLowGore = bLowGore;
	class'GameInfo'.default.bVeryLowGore = bVeryLowGore;
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	if ( GetLevel().Game != None )
	{
		GetLevel().Game.SaveConfig();
		GetLevel().Game.GameReplicationInfo.SaveConfig();
	}
	class'GameInfo'.static.StaticSaveConfig();
	Super.SaveConfigs();
}

function LocalChecked()
{
	class'GameInfo'.default.bLocalLog = LocalCheck.bChecked;
	if (GetLevel().Game != None)
	{
		GetLevel().Game.bLocalLog = LocalCheck.bChecked;
		GetLevel().Game.SaveConfig();
	}
}

defaultproperties
{
	EditAreaWidth=120
	LanguageText="Language"
	LanguageHelp="This is the current game language. Change it and press Restart button."
	ConsoleText="Console"
	ConsoleHelp="This option determines the look of console and menus. Press Restart button to apply the changes."
	WeaponFlashText="Weapon Flash"
	WeaponFlashHelp="If checked, your screen will flash when you fire your weapon."
	WeaponHandText="Weapon Hand"
	WeaponHandHelp="Select where your weapon will appear."
	LeftName="Left"
	CenterName="Center"
	RightName="Right"
	HiddenName="Hidden"
	DodgingText="Dodging"
	DodgingHelp="If checked, double tapping the movement keys (forward, back, and strafe left or right) will result in a fast dodge move."
	ViewBobText="View Bob"
	ViewBobHelp="Use the slider to adjust the amount your view will bob when moving."
	SpeedText="Game Speed"
	GoreText="Gore Level"
	GoreHelp="Choose the level of gore you wish to see in the game."
	GoreLevels(0)="Normal"
	GoreLevels(1)="Reduced"
	GoreLevels(2)="Ultra-Low"
	LocalText="ngStats Local Logging"
	LocalHelp="If checked, your system will log local botmatch and single player tournament games for stat compilation."
	bShowGoreControl=True
	ControlOffset=20.000000
}
