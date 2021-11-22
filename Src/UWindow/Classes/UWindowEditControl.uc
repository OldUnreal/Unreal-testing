class UWindowEditControl extends UWindowDialogControl;

var	float			EditBoxWidth;
var float			EditAreaDrawX, EditAreaDrawY;
var UWindowEditBox	EditBox;
var bool			bDisabled;
var int				DesiredTextOffset;

function Created()
{
	Super.Created();

	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, WinWidth, WinHeight));
	EditBox.NotifyOwner = Self;
	EditBox.bSelectOnFocus = True;

	EditBoxWidth = WinWidth / 2;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function SetNumericOnly(bool bNumericOnly)
{
	EditBox.bNumericOnly = bNumericOnly;
}

function SetNumericFloat(bool bNumericFloat)
{
	EditBox.bNumericFloat = bNumericFloat;
}

function SetFont(int NewFont)
{
	Super.SetFont(NewFont);
	EditBox.SetFont(NewFont);
}

function SetHistory(bool bInHistory)
{
	EditBox.SetHistory(bInHistory);
}

final function SetHistorySave( name F )
{
	EditBox.SetHistorySave(F);
}

function SetEditTextColor(Color NewColor)
{
	EditBox.SetTextColor(NewColor);
}

function SetDisabled(bool bDisabled)
{
	self.bDisabled = bDisabled;
	EditBox.SetEditable(!bDisabled);

	if (bDisabled)
		SetEditTextColor(LookAndFeel.EditBoxDisabledTextColor);
	else
		SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function Clear()
{
	EditBox.Clear();
}

function string GetValue()
{
	return EditBox.GetValue();
}

function SetValue(string NewValue)
{
	EditBox.SetValue(NewValue);
}

function SetMaxLength(int MaxLength)
{
	EditBox.MaxLength = MaxLength;
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Editbox_Draw(Self, C);
	Super.Paint(C, X, Y);
}


function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	LookAndFeel.Editbox_SetupSizes(Self, C);
}

function SetDelayedNotify(bool bDelayedNotify)
{
	Editbox.bDelayedNotify = bDelayedNotify;
}

function AutoWidth(Canvas C, optional out float MinWidth)
{
	local float TextWidth, TextHeight;

	C.Font = Root.Fonts[Font];
	TextSize(C, Text, TextWidth, TextHeight);
	if( IsValid(MinWidth) )
	{
		WinWidth = FMax(MinWidth, EditBoxWidth + DesiredTextOffset + TextWidth);
		if (MinWidth < WinWidth)
			MinWidth = WinWidth;
	}
	else WinWidth = EditBoxWidth + DesiredTextOffset + TextWidth;
}

defaultproperties
{
	DesiredTextOffset=7
}
