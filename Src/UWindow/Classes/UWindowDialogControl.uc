//=============================================================================
// UWindowDialogControl - a control which notifies a dialog control group
//=============================================================================
class UWindowDialogControl extends UWindowWindow;

var UWindowDialogClientWindow	NotifyWindow;
var string Text;
var int Font;
var color TextColor;
var TextAlign Align;
var float TextX, TextY;		// changed by BeforePaint functions
var bool bHasKeyboardFocus;
var bool bNoKeyboard;
var bool bAcceptExternalDragDrop;
var bool bNotifyMouseClicks;
var string HelpText;
var float MinWidth, MinHeight;	// minimum heights for layout control

var UWindowDialogControl	TabNext;
var UWindowDialogControl	TabPrev;


function Created()
{
	if (!bNoKeyboard)
		SetAcceptsFocus();
}

function KeyFocusEnter()
{
	Super.KeyFocusEnter();
	bHasKeyboardFocus = True;
}

function KeyFocusExit()
{
	Super.KeyFocusExit();
	bHasKeyboardFocus = False;
}

function SetHelpText(string NewHelpText)
{
	HelpText = NewHelpText;
}

function SetText(string NewText)
{
	Text = NewText;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	C.Font = Root.Fonts[Font];
}

function SetFont(int NewFont)
{
	Font = NewFont;
}

function SetTextColor(color NewColor)
{
	TextColor = NewColor;
}


function Register(UWindowDialogClientWindow	W)
{
	NotifyWindow = W;
	Notify(DE_Created);
}

function Notify(byte E)
{
	if (NotifyWindow != None)
	{
		NotifyWindow.Notify(Self, E);
	}
}

function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	return False;
}

function UWindowDialogControl CheckExternalDrag(float X, float Y)
{
	local float RootX, RootY;
	local float ExtX, ExtY;
	local UWindowWindow W;
	local UWindowDialogControl C;

	WindowToGlobal(X, Y, RootX, RootY);
	W = Root.FindWindowUnder(RootX, RootY);
	C = UWindowDialogControl(W);

	if (W != Self && C != None && C.bAcceptExternalDragDrop)
	{
		W.GlobalToWindow(RootX, RootY, ExtX, ExtY);
		if (C.ExternalDragOver(Self, ExtX, ExtY))
			return C;
	}

	return None;
}

function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;
	local UWindowDialogControl N;

	P = Root.GetPlayerOwner();

	switch (Key)
	{
	case P.EInputKey.IK_Tab:

		if (TabNext != None)
		{
			N = TabNext;
			while (N != Self && !N.bWindowVisible)
				N = N.TabNext;

			N.ActivateWindow(0, False);
		}
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}

}

function MouseMove(float X, float Y)
{
	Super.MouseMove(X, Y);
	Notify(DE_MouseMove);
}

function MouseEnter()
{
	Super.MouseEnter();
	Notify(DE_MouseEnter);
}

function MouseLeave()
{
	Super.MouseLeave();
	Notify(DE_MouseLeave);
}

function Click(float X, float Y)
{
	if (bNotifyMouseClicks)
		Notify(DE_Click);
}

function MClick(float X, float Y)
{
	if (bNotifyMouseClicks)
		Notify(DE_MClick);
}

function RClick(float X, float Y)
{
	if (bNotifyMouseClicks)
		Notify(DE_RClick);
}

function DoubleClick(float X, float Y)
{
	if (bNotifyMouseClicks)
		Notify(DE_DoubleClick);
}

function HandleMouseWheelScrolling(int Key, float X, float Y)
{
	if (Key == IK_MouseWheelUp)
		MouseWheelScrolling(-1, X, Y);
	else if (Key == IK_MouseWheelDown)
		MouseWheelScrolling(1, X, Y);

	if (Root != none)
		Root.bHandledWindowEvent = true;
}

function HandleKeyboardScrolling(int Key, float X, float Y)
{
	if (Key == IK_Up)
		KeyboardScrolling(-1, false, X, Y);
	else if (Key == IK_Down)
		KeyboardScrolling(1, false, X, Y);
	else if (Key == IK_PageUp)
		KeyboardScrolling(-1, true, X, Y);
	else if (Key == IK_PageDown)
		KeyboardScrolling(1, true, X, Y);
}

function GetMinTextAreaWidth(Canvas C, out float MinWidth)
{
	GetMinStrWidth(C, Text, MinWidth);
}

function GetMinStrWidth(Canvas C, coerce string Str, out float MinWidth)
{
	local float TextWidth, TextHeight;

	C.Font = Root.Fonts[Font];
	TextSize(C, Str, TextWidth, TextHeight);
	if (MinWidth < TextWidth)
		MinWidth = TextWidth;
}

function string GetWidestDigitSequence(Canvas C, int DigitsNum)
{
	local float TextWidth, TextHeight;
	local float MinWidth;
	local int i, n;
	local string Result;

	if (DigitsNum <= 0)
		return "";

	C.Font = Root.Fonts[Font];
	if (C.Font == none || StartsWith(C.Font.Name, "Tahoma", false))
		n = 0;
	else
	{
		for (i = 0; i <= 9; ++i)
		{
			TextSize(C, string(i), TextWidth, TextHeight);
			if (MinWidth < TextWidth)
			{
				MinWidth = TextWidth;
				n = i;
			}
		}
	}
	while (DigitsNum-- > 0)
		Result $= n;
	return Result;
}

defaultproperties
{
}
