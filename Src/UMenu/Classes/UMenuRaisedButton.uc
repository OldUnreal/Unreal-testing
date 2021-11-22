class UMenuRaisedButton extends UWindowButton;

var int Index;

function Created()
{
	Super.Created();

	TextX = 0;
	TextY = 0;
	Font = F_Normal;
	TextColor.R = 0;
	TextColor.G = 0;
	TextColor.B = 0;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	WinHeight = 18;

	TextSize(C, Text, W, H);

	TextY = (WinHeight - H) / 2;

	switch (Align)
	{
	case TA_Left:
		TextX = 3;
		break;
	case TA_Right:
		TextX = WinWidth - W - 3;
		break;
	case TA_Center:
		TextX = (WinWidth - W) / 2;
		break;
	}
}

function Paint(Canvas C, float X, float Y)
{
	if (bMouseDown)
	{
		DrawMiscBevel(C, 0, 0, WinWidth, WinHeight, LookAndFeel.Misc, 1);
	}
	else if (bDisabled)
	{
		DrawMiscBevel(C, 0, 0, WinWidth, WinHeight, LookAndFeel.Misc, 1);
	}
	else
	{
		DrawMiscBevel(C, 0, 0, WinWidth, WinHeight, LookAndFeel.Misc, 0);
	}

	Super.Paint(C, X, Y);
}

defaultproperties
{
}
