class UMenuTeamGameRulesCWindow extends UMenuGameRulesCWindow;

// Friendly Fire Scale
var UWindowHSliderControl FFSlider;
var localized string FFText;
var localized string FFHelp;

function Created()
{
	local int FFS;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	DesiredWidth = 220;
	DesiredHeight = 245;

	// Friendly Fire Scale
	FFSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	FFSlider.SetRange(0, 10, 1);
	FFS = Class<TeamGame>(BotmatchParent.GameClass).Default.FriendlyFireScale * 10;
	FFSlider.SetValue(FFS);
	FFSlider.SetText(FFText$" ["$FFS*10$"%]:");
	FFSlider.SetHelpText(FFHelp);
	FFSlider.SetFont(F_Normal);
}

function BeforePaint(Canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);

	FFSlider.SliderWidth = 90;
	FFSlider.AutoWidth(C);
	FFSlider.WinLeft = (WinWidth - FFSlider.WinWidth) / 2;
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
		case FFSlider:
			FFChanged();
			break;
		}
	}
}

function FFChanged()
{
	class<TeamGame>(BotmatchParent.GameClass).Default.FriendlyFireScale = FFSlider.GetValue() / 10;
	FFSlider.SetText(FFText$" ["$int(FFSlider.GetValue()*10)$"%]:");
}

defaultproperties
{
	FFText="Friendly Fire:"
	FFHelp="Slide to adjust the amount of damage friendly fire imparts to other teammates."
}
