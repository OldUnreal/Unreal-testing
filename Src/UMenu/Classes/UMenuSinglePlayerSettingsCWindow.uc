class UMenuSinglePlayerSettingsCWindow extends UMenuPageWindow;

var bool Initialized;
var float ControlOffset;

// Skill Level
var UWindowComboControl SkillCombo;
var localized string SkillText;
var localized string SkillHelp;
var localized int EditAreaWidth;

function Created()
{
	local int i;

	Super.Created();

	// Skill Level
	SkillCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', WinWidth / 2, ControlOffset, 100, 1));
	SkillCombo.SetText(SkillText);
	SkillCombo.SetHelpText(SkillHelp);
	SkillCombo.SetFont(F_Normal);
	SkillCombo.SetEditable(false);
	for (i = 0; i < ArrayCount(class'UMenuNewGameClientWindow'.default.Skills); ++i)
		SkillCombo.AddItem(class'UMenuNewGameClientWindow'.default.Skills[i]);
	SkillCombo.SetSelectedIndex(Clamp(class'UMenuNewGameClientWindow'.default.LastSelectedSkill,0,ArrayCount(class'UMenuNewGameClientWindow'.default.Skills)));
	ControlOffset += 25;

	EnableGameDifficulty();
}

function EnableGameDifficulty()
{
	if (UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow')) != none)
		UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow')).bSetGameDifficulty = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	SkillCombo.EditBoxWidth = EditAreaWidth;
	SkillCombo.AutoWidth(C);
	SkillCombo.WinLeft = (WinWidth - SkillCombo.WinWidth) / 2;
}

function AfterCreate()
{
	Super.AfterCreate();
	
	DesiredWidth = 220;
	DesiredHeight = ControlOffset;

	Initialized = true;
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
		case SkillCombo:
			SkillChanged();
			break;
		}
	}
}

function SkillChanged()
{
	class'UMenuNewGameClientWindow'.default.LastSelectedSkill = SkillCombo.GetSelectedIndex();
}

defaultproperties
{
	ControlOffset=20.000000
	SkillText="Difficulty:"
	SkillHelp="Select the difficulty you wish to play at."
	EditAreaWidth=90
}
