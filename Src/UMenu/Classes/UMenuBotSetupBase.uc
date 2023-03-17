class UMenuBotSetupBase extends UMenuPlayerSetupClient;

var int ConfigureBot;

var UWindowComboControl BotCombo;
var localized string BotText;
var localized string BotHelp;
var localized string BotWord;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;

// Bot skills
var UWindowHSliderControl BotSkillSlider;
var localized string BotSkillText,BotSkillHelp;

var UWindowHSliderControl BotAccurSlider;
var localized string BotAccurText,BotAccurHelp;

var UWindowHSliderControl BotCombatStyleSlider;
var localized string BotCombatStyleText,BotCombatStyleHelp;

var UWindowHSliderControl BotAlertnessSlider;
var localized string BotAlertnessText,BotAlertnessHelp;

var UWindowHSliderControl BotCampingSlider;
var localized string BotCampingText,BotCampingHelp;

var UWindowComboControl FavoriteWeaponCombo;
var localized string FavoriteWeaponText,FavoriteWeaponHelp,NoFavoriteWeapon;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);

	BotCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotCombo.SetButtons(True);
	BotCombo.SetText(BotText);
	BotCombo.SetHelpText(BotHelp);
	BotCombo.SetFont(F_Normal);
	BotCombo.SetEditable(False);
	LoadBots();
	BotCombo.SetSelectedIndex(0);
	ConfigureBot = 0;
	ControlOffset += 25;

	Super.Created();
	SpectatorCheck.HideWindow();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Bot skills
	CenterWidth*=2.5;
	BotSkillSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotSkillSlider.SetRange(0, 9, 1);
	BotSkillSlider.SetText(BotSkillText);
	BotSkillSlider.SetHelpText(BotSkillHelp);
	BotSkillSlider.SetFont(F_Normal);

	ControlOffset += 25;
	BotAccurSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotAccurSlider.SetRange(0, 20, 2);
	BotAccurSlider.SetText(BotAccurText);
	BotAccurSlider.SetHelpText(BotAccurHelp);
	BotAccurSlider.SetFont(F_Normal);

	ControlOffset += 25;
	BotCombatStyleSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotCombatStyleSlider.SetRange(0, 20, 2);
	BotCombatStyleSlider.SetText(BotCombatStyleText);
	BotCombatStyleSlider.SetHelpText(BotCombatStyleHelp);
	BotCombatStyleSlider.SetFont(F_Normal);

	ControlOffset += 25;
	BotAlertnessSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotAlertnessSlider.SetRange(0, 20, 2);
	BotAlertnessSlider.SetText(BotAlertnessText);
	BotAlertnessSlider.SetHelpText(BotAlertnessHelp);
	BotAlertnessSlider.SetFont(F_Normal);

	ControlOffset += 25;
	BotCampingSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotCampingSlider.SetRange(0, 10, 1);
	BotCampingSlider.SetText(BotCampingText);
	BotCampingSlider.SetHelpText(BotCampingHelp);
	BotCampingSlider.SetFont(F_Normal);

	ControlOffset += 25;
	FavoriteWeaponCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FavoriteWeaponCombo.SetText(FavoriteWeaponText);
	FavoriteWeaponCombo.SetHelpText(FavoriteWeaponHelp);
	FavoriteWeaponCombo.SetFont(F_Normal);
	FavoriteWeaponCombo.SetEditable(False);
	LoadPossibleWeapons();
}

function LoadPossibleWeapons()
{
	local string WeaponClassName;
	local class<Weapon> WeaponClass;
	local int i;

	FavoriteWeaponCombo.AddItem(NoFavoriteWeapon,"None");
	foreach Class'Actor'.Static.IntDescIterator(Class'UMenuWeaponPriorityListBox'.Default.WeaponClassParent,WeaponClassName,,true)
	{
		i = FavoriteWeaponCombo.FindItemIndex2(WeaponClassName,true);
		if ( i==-1 )
		{
			WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
			if ( WeaponClass )
				FavoriteWeaponCombo.AddItem(WeaponClass.Default.ItemName,string(WeaponClass));
		}
	}
}

function LoadBots()
{
}
function ResetBots()
{
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	super.CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	BotCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	BotSkillSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	BotAccurSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	BotCombatStyleSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	BotAlertnessSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	BotCampingSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	FavoriteWeaponCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float ControlWidth, ControlLeft;

	if (!bUpdatedLabelTextAreaWidth)
	{
		LabelTextAreaWidth = 0;
		CalcLabelTextAreaWidth(C, LabelTextAreaWidth);
	}

	InitLayoutParams(ControlWidth, ControlLeft);

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = ControlLeft + ControlWidth - DefaultsButton.WinWidth;

	super.BeforePaint(C, X, Y);

	BotCombo.SetSize(ControlWidth, 1);
	BotCombo.WinLeft = ControlLeft;
	BotCombo.EditBoxWidth = EditAreaWidth;

	BotSkillSlider.SetSize(ControlWidth, 1);
	BotSkillSlider.WinLeft = ControlLeft;
	BotSkillSlider.SliderWidth = EditAreaWidth;

	BotAccurSlider.SetSize(ControlWidth, 1);
	BotAccurSlider.WinLeft = ControlLeft;
	BotAccurSlider.SliderWidth = EditAreaWidth;

	BotCombatStyleSlider.SetSize(ControlWidth, 1);
	BotCombatStyleSlider.WinLeft = ControlLeft;
	BotCombatStyleSlider.SliderWidth = EditAreaWidth;

	BotAlertnessSlider.SetSize(ControlWidth, 1);
	BotAlertnessSlider.WinLeft = ControlLeft;
	BotAlertnessSlider.SliderWidth = EditAreaWidth;

	BotCampingSlider.SetSize(ControlWidth, 1);
	BotCampingSlider.WinLeft = ControlLeft;
	BotCampingSlider.SliderWidth = EditAreaWidth;

	FavoriteWeaponCombo.SetSize(ControlWidth, 1);
	FavoriteWeaponCombo.WinLeft = ControlLeft;
	FavoriteWeaponCombo.EditBoxWidth = EditAreaWidth;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Click:
		switch (C)
		{
		case DefaultsButton:
			ResetBots();
			break;
		}
		break;
	case DE_Change:
		switch (C)
		{
		case BotCombo:
			BotChanged();
			break;
		}
		break;
	}
}

function BotChanged()
{
	if (Initialized)
	{
		UseSelected();
		Initialized = False;
		ConfigureBot = BotCombo.GetSelectedIndex();
		LoadCurrent();
		UseSelected();
		Initialized = True;
	}
}

defaultproperties
{
	BotText="Bot:"
	BotHelp="Select the bot you wish to configure."
	BotWord="Bot"
	DefaultsText="Reset"
	DefaultsHelp="Reset all bot configurations to their default settings."
	ControlOffset=35
	PlayerBaseClass="Bots"
	NameHelp="Set this bot's name."
	TeamText="Color:"
	TeamHelp="Select the team color for this bot."
	ClassHelp="Select this bot's class."
	SkinHelp="Choose a skin for this bot."
	FaceHelp="Choose a face for this bot."
	BotSkillText="Bot skill:"
	BotSkillHelp="Adjust the bot difficulty (easy-hard)."
	BotAccurText="Accuracy:"
	BotAccurHelp="Adjust the bot aiming skill (bad aiming-good aiming)."
	BotCombatStyleText="Combat style:"
	BotCombatStyleHelp="Adjust the bot combat style (stay far away attacking-aggressively approach their enemy)."
	BotAlertnessText="Alertness:"
	BotAlertnessHelp="The bot alertness (unaware of their surroundings-fully aware of their surroundings)."
	BotCampingText="Camping:"
	BotCampingHelp="Adjust how likely it is for the bot stay around camping (hunt at all time-camp a lot)."
	FavoriteWeaponText="Favorite Weapon:"
	FavoriteWeaponHelp="This bot's prefered weapon of choice."
	NoFavoriteWeapon="None prefered"
}
