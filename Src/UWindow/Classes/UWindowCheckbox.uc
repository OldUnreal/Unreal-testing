//=============================================================================
// UWindowCheckbox - a checkbox
//=============================================================================
class UWindowCheckbox extends UWindowButton;

var bool bChecked;
var int DesiredTextOffset; // horizontal text offset from the left window bound

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Checkbox_SetupSizes(Self, C);
	Super.BeforePaint(C, X, Y);
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Checkbox_Draw(Self, C);
	Super.Paint(C, X, Y);
}


function LMouseUp(float X, float Y)
{
	if (!bDisabled)
	{
		bChecked = !bChecked;
		Notify(DE_Change);
	}

	Super.LMouseUp(X, Y);
}

function AutoWidth(Canvas C, optional out float MinWidth)
{
	local float TextWidth, TextHeight;

	C.Font = Root.Fonts[Font];
	TextSize(C, Text, TextWidth, TextHeight);
	if( IsValid(MinWidth) )
	{
		WinWidth = FMax(MinWidth, DesiredTextOffset + TextWidth);
		if (MinWidth < WinWidth)
			MinWidth = WinWidth;
	}
	else WinWidth = DesiredTextOffset + TextWidth;
}

defaultproperties
{
	DesiredTextOffset=20
}
