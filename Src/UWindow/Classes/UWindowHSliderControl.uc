class UWindowHSliderControl extends UWindowDialogControl;


var	float   MinValue;
var	float   MaxValue;
var	float   Value;
var	int     Step;           // 0 = continuous
var bool    bIndeterminate; // whether the value is supposed to be indeterminate
var bool    bDisabled;
var int     DesiredTextOffset;

var	float   SliderWidth;
var	float   SliderDrawX, SliderDrawY;
var float   TrackStart;
var float   TrackWidth;
var bool    bSliding;
var bool    bNoSlidingNotify;


function Created()
{
	Super.Created();
	SliderWidth = WinWidth / 2;
	TrackWidth = 4;
}

function SetRange(float Min, float Max, int NewStep)
{
	MinValue = Min;
	MaxValue = Max;
	Step = NewStep;
	Value = CheckValue(Value);
}

function float GetValue()
{
	return Value;
}

function SetValue(float NewValue, optional bool bNoNotify)
{
	local float OldValue;

	OldValue = Value;
	Value = CheckValue(NewValue);

	if (Value != OldValue && !bNoNotify && !bIndeterminate && !bDisabled)
	{
		// Notify
		Notify(DE_Change);
	}
}


function float CheckValue(float Test)
{
	local float TempF;
	local float NewValue;

	NewValue = Test;

	if (Step != 0)
	{
		TempF = NewValue / Step;
		NewValue = int((TempF >= 0) ? (TempF + 0.5) : (TempF - 0.5)) * Step;
	}

	if (NewValue < MinValue) NewValue = MinValue;
	if (NewValue > MaxValue) NewValue = MaxValue;

	return NewValue;
}


function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	TextSize(C, Text, W, H);
	WinHeight = H+1;

	switch (Align)
	{
	case TA_Left:
		SliderDrawX = WinWidth - SliderWidth;
		TextX = 0;
		break;
	case TA_Right:
		SliderDrawX = 0;
		TextX = WinWidth - W;
		break;
	case TA_Center:
		SliderDrawX = (WinWidth - SliderWidth) / 2;
		TextX = (WinWidth - W) / 2;
		break;
	}

	SliderDrawY = (WinHeight - 2) / 2;
	TextY = (WinHeight - H) / 2;

	TrackStart = SliderDrawX + (SliderWidth - TrackWidth) * ((Value - MinValue)/(MaxValue - MinValue));
}


function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	local Region R;
	local int CanvasStyle;

	T = GetLookAndFeelTexture();

	if (Text != "")
	{
		C.DrawColor = TextColor;
		ClipText(C, TextX, TextY, Text);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}

	R = LookAndFeel.HLine;
	CanvasStyle = C.Style;
	if (bDisabled)
		C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
	DrawStretchedTextureSegment( C, SliderDrawX, SliderDrawY, SliderWidth, R.H, R.X, R.Y, R.W, R.H, T);

	if (!bIndeterminate)
		DrawUpBevel(C, TrackStart, SliderDrawY-4, TrackWidth, 10, T);
	C.Style = CanvasStyle;
}

function LMouseUp(float X, float Y)
{
	Super.LMouseUp(X, Y);

	if (bNoSlidingNotify && !bIndeterminate && !bDisabled)
		Notify(DE_Change);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if (bIndeterminate || bDisabled)
		return;

	if ((X >= TrackStart) && (X <= TrackStart + TrackWidth))
	{
		bSliding = True;
		Root.CaptureMouse();
	}

	if (X < TrackStart && X > SliderDrawX)
	{
		if (Step != 0)
			SetValue(Value - Step);
		else
			SetValue(Value - 1);
	}

	if (X > TrackStart + TrackWidth && X < SliderDrawX + SliderWidth)
	{
		if (Step != 0)
			SetValue(Value + Step);
		else
			SetValue(Value + 1);
	}

}

function MouseMove(float X, float Y)
{
	Super.MouseMove(X, Y);
	if (bSliding && bMouseDown && !bIndeterminate && !bDisabled)
	{
		SetValue((((X - SliderDrawX) / (SliderWidth - TrackWidth)) * (MaxValue - MinValue)) + MinValue, bNoSlidingNotify);
	}
	else
		bSliding = False;
}


function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;

	if (bIndeterminate || bDisabled)
	{
		super.KeyDown(Key, X, Y);
		return;
	}

	P = GetPlayerOwner();

	switch (Key)
	{
	case P.EInputKey.IK_Left:
		if (Step != 0)
			SetValue(Value - Step);
		else
			SetValue(Value - 1);

		break;
	case P.EInputKey.IK_Right:
		if (Step != 0)
			SetValue(Value + Step);
		else
			SetValue(Value + 1);

		break;
	case P.EInputKey.IK_Home:
		SetValue(MinValue);
		break;
	case P.EInputKey.IK_End:
		SetValue(MaxValue);
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}
}

function AutoWidth(Canvas C, optional out float MinWidth)
{
	local float TextWidth, TextHeight;

	C.Font = Root.Fonts[Font];
	TextSize(C, Text, TextWidth, TextHeight);
	if( IsValid(MinWidth) )
	{
		WinWidth = FMax(MinWidth, SliderWidth + DesiredTextOffset + TextWidth);
		if (MinWidth < WinWidth)
			MinWidth = WinWidth;
	}
	else WinWidth = SliderWidth + DesiredTextOffset + TextWidth;
}

defaultproperties
{
	DesiredTextOffset=7
}
