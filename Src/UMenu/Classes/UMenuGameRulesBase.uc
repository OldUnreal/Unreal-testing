class UMenuGameRulesBase extends UMenuPageWindow;

var localized bool bSingleColumn;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

// Frag Limit
var UWindowEditControl FragEdit;
var localized string FragText;
var localized string FragHelp;

// Time Limit
var UWindowEditControl TimeEdit;
var localized string TimeText;
var localized string TimeHelp;

// Max Players
var UWindowEditControl MaxPlayersEdit;
var localized string MaxPlayersText;
var localized string MaxPlayersHelp;

var UWindowEditControl MaxSpectatorsEdit;
var localized string MaxSpectatorsText;
var localized string MaxSpectatorsHelp;

// Weapons Stay
var UWindowCheckbox WeaponsCheck;
var localized string WeaponsText;
var localized string WeaponsHelp;

// Humans Only
var UWindowCheckbox HumansOnlyCheck;
var localized string HumansOnlyText;
var localized string HumansOnlyHelp;

var float ControlOffset;
var bool bControlRight;

function Created()
{
	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");
	else
	{
		if (BotmatchParent.bNetworkGame)
			SetupNetworkOptions();
		if (class<DeathMatchGame>(BotmatchParent.GameClass) != none)
			SetupDeathMatchOptions();
		SetupGeneralOptions();
	}
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 270;
	DesiredHeight = ControlOffset;

	LoadCurrentValues();
	Initialized = True;
}

function WindowShown()
{
	super.WindowShown();

	Initialized = false;
	LoadCurrentValues();
	Initialized = true;
}

function InitLayoutParams(out float ControlWidth, out float ControlLeft, out float ControlRight)
{
	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	if (bSingleColumn)
		ControlRight = ControlLeft;
	else
		ControlRight = WinWidth/2 + ControlLeft;
}

function SetupDeathMatchOptions()
{
	local float ControlWidth, ControlLeft, ControlRight;

	InitLayoutParams(ControlWidth, ControlLeft, ControlRight);

	// Frag Limit
	FragEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	FragEdit.SetText(FragText);
	FragEdit.SetHelpText(FragHelp);
	FragEdit.SetFont(F_Normal);
	FragEdit.SetNumericOnly(True);
	FragEdit.SetMaxLength(3);
	FragEdit.Align = TA_Right;
	if (bSingleColumn)
		ControlOffset += 25;

	// Time Limit
	TimeEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	TimeEdit.SetText(TimeText);
	TimeEdit.SetHelpText(TimeHelp);
	TimeEdit.SetFont(F_Normal);
	TimeEdit.SetNumericOnly(True);
	TimeEdit.SetMaxLength(3);
	TimeEdit.Align = TA_Right;
	ControlOffset += 25;
}

function SetupGeneralOptions()
{
	local float ControlWidth, ControlLeft, ControlRight;

	InitLayoutParams(ControlWidth, ControlLeft, ControlRight);

	// WeaponsStay
	WeaponsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	WeaponsCheck.SetText(WeaponsText);
	WeaponsCheck.SetHelpText(WeaponsHelp);
	WeaponsCheck.SetFont(F_Normal);
	WeaponsCheck.bChecked = BotmatchParent.GameClass.default.bCoopWeaponMode;
	WeaponsCheck.Align = TA_Right;
	ControlOffset += 25;

	HumansOnlyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	HumansOnlyCheck.SetText(HumansOnlyText);
	HumansOnlyCheck.SetHelpText(HumansOnlyHelp);
	HumansOnlyCheck.SetFont(F_Normal);
	HumansOnlyCheck.bChecked = BotmatchParent.GameClass.default.bHumansOnly;
	HumansOnlyCheck.Align = TA_Right;
	ControlOffset += 25;
}

function SetupNetworkOptions()
{
	local float ControlWidth, ControlLeft, ControlRight;

	InitLayoutParams(ControlWidth, ControlLeft, ControlRight);

	// Max Players
	MaxPlayersEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	MaxPlayersEdit.SetText(MaxPlayersText);
	MaxPlayersEdit.SetHelpText(MaxPlayersHelp);
	MaxPlayersEdit.SetFont(F_Normal);
	MaxPlayersEdit.SetNumericOnly(True);
	MaxPlayersEdit.SetMaxLength(2);
	MaxPlayersEdit.Align = TA_Right;
	MaxPlayersEdit.SetDelayedNotify(True);
	if (bSingleColumn)
		ControlOffset += 25;

	// Max Spectators
	MaxSpectatorsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	MaxSpectatorsEdit.SetText(MaxSpectatorsText);
	MaxSpectatorsEdit.SetHelpText(MaxSpectatorsHelp);
	MaxSpectatorsEdit.SetFont(F_Normal);
	MaxSpectatorsEdit.SetNumericOnly(True);
	MaxSpectatorsEdit.SetMaxLength(2);
	MaxSpectatorsEdit.Align = TA_Right;
	MaxSpectatorsEdit.SetDelayedNotify(True);
	ControlOffset += 25;
}


function LoadCurrentValues()
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float ControlWidth, ControlLeft, ControlRight;

	Super.BeforePaint(C, X, Y);

	InitLayoutParams(ControlWidth, ControlLeft, ControlRight);

	if (FragEdit != None)
	{
		FragEdit.WinLeft = ControlLeft;
		FragEdit.EditBoxWidth = 25;
		FragEdit.AutoWidth(C);
	}

	if (TimeEdit != None)
	{
		TimeEdit.WinLeft = ControlRight;
		TimeEdit.EditBoxWidth = 25;
		TimeEdit.AutoWidth(C);
	}

	if (MaxPlayersEdit != None)
	{
		MaxPlayersEdit.WinLeft = ControlLeft;
		MaxPlayersEdit.EditBoxWidth = 25;
		MaxPlayersEdit.AutoWidth(C);
	}

	if (MaxSpectatorsEdit != None)
	{
		MaxSpectatorsEdit.WinLeft = ControlRight;
		MaxSpectatorsEdit.EditBoxWidth = 25;
		MaxSpectatorsEdit.AutoWidth(C);
	}

	WeaponsCheck.WinLeft = ControlLeft;
	WeaponsCheck.AutoWidth(C);

	HumansOnlyCheck.WinLeft = ControlLeft;
	HumansOnlyCheck.AutoWidth(C);
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case FragEdit:
			FragChanged();
			break;
		case TimeEdit:
			TimeChanged();
			break;
		case MaxPlayersEdit:
			MaxPlayersChanged();
			break;
		case MaxSpectatorsEdit:
			MaxSpectatorsChanged();
			break;
		case WeaponsCheck:
			WeaponsChecked();
			break;
		case HumansOnlyCheck:
			HumansOnlyChecked();
			break;
		}
	}
}

function FragChanged()
{
}

function TimeChanged()
{
}

function MaxPlayersChanged()
{
}

function MaxSpectatorsChanged()
{
}

function WeaponsChecked()
{
}

function HumansOnlyChecked()
{
}

defaultproperties
{
	FragText="Frag Limit"
	FragHelp="The game will end if a player achieves this many frags. A value of 0 sets no frag limit."
	TimeText="Time Limit"
	TimeHelp="The game will end if after this many minutes. A value of 0 sets no time limit."
	MaxPlayersText="Max Connections"
	MaxPlayersHelp="Maximum number of human players allowed to connect to the game."
	MaxSpectatorsText="Max Spectators"
	MaxSpectatorsHelp="Maximum number of spectators allowed to connect to the game."
	WeaponsText="Weapons Stay"
	WeaponsHelp="If checked, weapons will stay at their pickup location after being picked up, instead of respawning."
	HumansOnlyText="Humans only"
	HumansOnlyHelp="If checked, only human player classes are allowed"
	ControlOffset=20.000000
}
