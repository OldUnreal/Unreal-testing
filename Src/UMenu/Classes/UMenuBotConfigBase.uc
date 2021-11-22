class UMenuBotConfigBase extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

var localized bool bSingleColumn;

// Base Skill
var UWindowComboControl BaseCombo;
var localized string BaseText;
var localized string BaseHelp;

// Taunt Label
var UMenuLabelControl TauntLabel;
var localized string Skills[8];
var localized string SkillTaunts[8];

// # of Bots
var UWindowEditControl NumBotsEdit;
var localized string NumBotsText;
var localized string NumBotsHelp;

// Auto Adjust
var UWindowCheckbox AutoAdjustCheck;
var localized string AutoAdjustText;
var localized string AutoAdjustHelp;

// Random Order
var UWindowCheckbox RandomCheck;
var localized string RandomText;
var localized string RandomHelp;

// Configure Indiv Bots
var UWindowSmallButton ConfigBots;
var localized string ConfigBotsText;
var localized string ConfigBotsHelp;

var localized string AtLeastOneBotTitle;
var localized string AtLeastOneBotText;

var float ControlOffset;

function Created()
{
	local int i;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	if (bSingleColumn)
		ControlRight = ControlLeft;
	else
		ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	SetBotmatchParent();

	// Base Skill
	BaseCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	BaseCombo.SetText(BaseText);
	BaseCombo.SetHelpText(BaseHelp);
	BaseCombo.SetFont(F_Normal);
	BaseCombo.SetEditable(False);
	for (i=0; i<8; i++)
	{
		if (Skills[i] != "")
			BaseCombo.AddItem(Skills[i]);
	}
	ControlOffset += 25;

	// Taunt Label
	TauntLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	TauntLabel.Align = TA_Center;
	ControlOffset += 25;
	if (bSingleColumn)
		ControlOffset += 25;

	// # of Bots
	NumBotsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	NumBotsEdit.SetText(NumBotsText);
	NumBotsEdit.SetHelpText(NumBotsHelp);
	NumBotsEdit.SetFont(F_Normal);
	NumBotsEdit.SetNumericOnly(True);
	NumBotsEdit.SetMaxLength(2);
	NumBotsEdit.Align = TA_Right;
	if (bSingleColumn)
		ControlOffset -= 25;

	ConfigBots = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlRight, ControlOffset, 48, 16));
	ConfigBots.SetText(ConfigBotsText);
	ConfigBots.SetFont(F_Normal);
	ConfigBots.SetHelpText(ConfigBotsHelp);
	ControlOffset += 25;
	if (bSingleColumn)
		ControlOffset += 25;

	// Auto Adjust
	AutoAdjustCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	AutoAdjustCheck.SetText(AutoAdjustText);
	AutoAdjustCheck.SetHelpText(AutoAdjustHelp);
	AutoAdjustCheck.SetFont(F_Normal);
	AutoAdjustCheck.Align = TA_Right;
	if (bSingleColumn)
		ControlOffset += 25;

	// Random Order
	RandomCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	RandomCheck.SetText(RandomText);
	RandomCheck.SetHelpText(RandomHelp);
	RandomCheck.SetFont(F_Normal);
	RandomCheck.Align = TA_Right;
	ControlOffset += 25;

}

function AfterCreate()
{
	Super.AfterCreate();
	LoadCurrentValues();
	Initialized = True;

	DesiredWidth = 270;
	DesiredHeight = ControlOffset;
}

function LoadCurrentValues()
{
}

function SetBotmatchParent()
{
	if (BotmatchParent != None)
		return;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, LeftColumnPos, RightColumnPos;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	LeftColumnPos = (WinWidth/2 - ControlWidth)/2 - 5;
	if (bSingleColumn)
		RightColumnPos = LeftColumnPos;
	else
		RightColumnPos = WinWidth/2 + LeftColumnPos;

	BaseCombo.EditBoxWidth = 120;
	BaseCombo.AutoWidth(C);
	BaseCombo.WinLeft = (WinWidth - BaseCombo.WinWidth) / 2;

	TauntLabel.SetSize(WinWidth - 20, 1);
	TauntLabel.WinLeft = 10;

	NumBotsEdit.EditBoxWidth = 20;
	NumBotsEdit.AutoWidth(C);
	NumBotsEdit.WinLeft = LeftColumnPos;

	ConfigBots.AutoWidth(C);
	if (bSingleColumn)
		ConfigBots.WinLeft = (WinWidth - ConfigBots.WinWidth) / 2;
	else
		ConfigBots.WinLeft = RightColumnPos;

	AutoAdjustCheck.AutoWidth(C);
	AutoAdjustCheck.WinLeft = LeftColumnPos;

	RandomCheck.AutoWidth(C);
	RandomCheck.WinLeft = RightColumnPos;
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
		case BaseCombo:
			BaseChanged();
			break;
		case NumBotsEdit:
			NumBotsChanged();
			break;
		case AutoAdjustCheck:
			AutoAdjustChecked();
			break;
		case RandomCheck:
			RandomChecked();
			break;
		}
	case DE_Click:
		switch (C)
		{
		case ConfigBots:
			ConfigureIndivBots();
			break;
		}
	}
}

function BaseChanged()
{
}

function NumBotsChanged()
{
}

function AutoAdjustChecked()
{
}

function RandomChecked()
{
}

function ConfigureIndivBots()
{
}

defaultproperties
{
	BaseText="Base Skill:"
	BaseHelp="This is the base skill level of the bots."
	Skills(0)="Novice"
	Skills(1)="Average"
	Skills(2)="Skilled"
	Skills(3)="Masterful"
	SkillTaunts(0)="They won't hurt you...much."
	SkillTaunts(1)="Don't get cocky."
	SkillTaunts(2)="You think you're tough?"
	SkillTaunts(3)="You're already dead."
	NumBotsText="Number of Bots"
	NumBotsHelp="This is the number of bots that you will play against."
	AutoAdjustText="Auto Adjust Skill"
	AutoAdjustHelp="If checked, bots will increase or decrease their skill to match your skill level."
	RandomText="Random Order"
	RandomHelp="If checked, bots will chosen at random from the list of bot configurations."
	ConfigBotsText="Configure"
	ConfigBotsHelp="Configure the names, appearance and other attributes of individual bots."
	AtLeastOneBotTitle="Configure Bots"
	AtLeastOneBotText="You must choose at least one bot in order to use the configure bots screen."
	ControlOffset=20.000000
}
