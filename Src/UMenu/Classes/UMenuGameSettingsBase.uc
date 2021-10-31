class UMenuGameSettingsBase extends UMenuPageWindow;

const EditAreaWidth = 110;
const EditAreaOffset = 10;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;
var float ControlOffset;

// Game Style
var UWindowComboControl StyleCombo;
var localized string StyleText;
var localized string Styles[3];
var localized string StyleHelp;

// Game Speed
var UWindowHSliderControl SpeedSlider;
var localized string SpeedText;
var localized string SpeedHelp;

function Created()
{
	local int CenterWidth, CenterPos;

	Super.Created();

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuGameSettingsCWindow without UMenuBotmatchClientWindow parent.");

	// Game Style
	StyleCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	StyleCombo.SetText(StyleText);
	StyleCombo.SetHelpText(StyleHelp);
	StyleCombo.SetFont(F_Normal);
	StyleCombo.SetEditable(False);
	StyleCombo.AddItem(Styles[0]);
	StyleCombo.AddItem(Styles[1]);
	StyleCombo.AddItem(Styles[2]);
	ControlOffset += 25;

	// Game Speed
	SpeedSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	SpeedSlider.SetRange(50, 200, 5);
	SpeedSlider.SetHelpText(SpeedHelp);
	SpeedSlider.SetFont(F_Normal);
	ControlOffset += 25;
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

function LoadCurrentValues()
{
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	StyleCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SpeedSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SpeedSlider.GetMinStrWidth(C, SpeedText $ " [" $ SpeedSlider.GetWidestDigitSequence(C, 3) $ "%]:", LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft;
	local float LabelTextAreaWidth;

	Super.BeforePaint(C, X, Y);

	LabelTextAreaWidth = 0;
	CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	ControlLeft = (WinWidth - LabelTextAreaWidth - EditAreaOffset - EditAreaWidth) / 2;
	ControlWidth = LabelTextAreaWidth + EditAreaOffset + EditAreaWidth;

	StyleCombo.SetSize(ControlWidth, 1);
	StyleCombo.WinLeft = ControlLeft;
	StyleCombo.EditBoxWidth = EditAreaWidth;

	SpeedSlider.SetSize(ControlWidth, 1);
	SpeedSlider.SliderWidth = EditAreaWidth;
	SpeedSlider.WinLeft = ControlLeft;
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
		case StyleCombo:
			StyleChanged();
			break;
		case SpeedSlider:
			SpeedChanged();
			break;
		}
	}
}

function StyleChanged()
{
}

function SpeedChanged()
{
}

defaultproperties
{
	ControlOffset=20.000000
	StyleText="Game Style:"
	Styles(0)="Classic"
	Styles(1)="Hardcore"
	Styles(2)="Turbo"
	StyleHelp="Choose your game style. Hardcore is 10% faster with a 50% damage increase. Turbo also adds ultra fast player movement."
	SpeedText="Game Speed"
	SpeedHelp="Adjust the speed of the game."
}
