// UWindowEditBox - simple edit box, for use in other controls such as
// UWindowComboxBoxControl, UWindowEditBoxControl etc.

class UWindowEditBox extends UWindowDialogControl;

var string		Value;
var string		Value2;
var int			CaretOffset;
var int			MaxLength;
var float		LastDrawTime;
var bool		bShowCaret;
var float		Offset;
var UWindowDialogControl	NotifyOwner;
var bool		bNumericOnly;
var bool		bNumericFloat;
var bool		bCanEdit;
var bool		bAllSelected;
var bool		bSelectOnFocus;
var bool		bDelayedNotify;
var bool		bChangePending;
var bool		bControlDown;
var bool		bShiftDown;
var bool		bHistory;
var bool		bKeyDown;
var bool		bHasValue2;
var UWindowEditBoxHistory	HistoryList;
var UWindowEditBoxHistory	CurrentHistory;

// New 227 vars (written by .:..:):
var byte OffsetSelectionType;
var int XClickPos,RangeSelection[2];
var bool bHasRangeSelection;
var UWindowEditBoxHistoryFile SaveFile;

function Created()
{
	Super.Created();
	bCanEdit = True;
	bControlDown = False;
	bShiftDown = False;

	MaxLength = 255;
	CaretOffset = 0;
	Offset = 0;
	LastDrawTime = GetLevel().TimeSeconds;
}

function SetHistory(bool bInHistory)
{
	bHistory = bInHistory;

	if (bHistory && HistoryList==None)
	{
		HistoryList = new(None) class'UWindowEditBoxHistory';
		HistoryList.SetupSentinel();
		CurrentHistory = None;
	}
	else if (!bHistory && HistoryList!=None)
	{
		HistoryList = None;
		CurrentHistory = None;
	}
}

final function SetHistorySave( name F )
{
	if( !SaveFile )
	{
		SetHistory(true);
		SaveFile = new (None, F) class'UWindowEditBoxHistoryFile';
		SaveFile.LoadHistory(HistoryList);
	}
}

function SetEditable(bool bEditable)
{
	bCanEdit = bEditable;
	if ( !bEditable )
		bHasRangeSelection = False;
}

function SetValue(string NewValue, optional string NewValue2)
{
	bHasRangeSelection = False;
	bHasValue2 = Len(NewValue2) > 0;
	Value = NewValue;
	Value2 = NewValue2;

	if (CaretOffset > Len(Value))
		CaretOffset = Len(Value);
	Notify(DE_Change);
}

function AssignValues(string NewValue, optional string NewValue2, optional bool bNoNotify)
{
	bHasRangeSelection = False;
	bHasValue2 = Len(NewValue2) > 0;
	bNoNotify = bNoNotify || NewValue == Value && NewValue2 == Value2;
	Value = NewValue;
	Value2 = NewValue2;

	if (CaretOffset > Len(Value))
		CaretOffset = Len(Value);
	if (!bNoNotify)
		Notify(DE_Change);
}

function Clear()
{
	bHasRangeSelection = False;
	bHasValue2 = False;
	CaretOffset = 0;
	Value="";
	Value2="";
	bAllSelected = False;
	if (bDelayedNotify)
		bChangePending = True;
	else
		Notify(DE_Change);
}

function SelectAll()
{
	if (bCanEdit && Value != "")
	{
		bHasRangeSelection = False;
		CaretOffset = Len(Value);
		bAllSelected = True;
		OffsetSelectionType = 1;
	}
}

function string GetValue()
{
	return Value;
}

function string GetValue2()
{
	return Value2;
}

function Notify(byte E)
{
	if (NotifyOwner != None)
	{
		NotifyOwner.Notify(E);
	}
	else
	{
		Super.Notify(E);
	}
}

function InsertText(string Text)
{
	local int i,l;

	l = Len(Text);
	for (i=0; i<l; i++)
	{
		InsertUnicode(Asc(Text, i));
		bHasRangeSelection = False;
	}
}

// Inserts a character at the current caret position
function bool Insert(byte C)
{
	local string	NewValue;

	if ( bHasRangeSelection )
		NewValue = Left(Value, RangeSelection[0]) $ Chr(C) $ Mid(Value, RangeSelection[1]);
	else NewValue = Left(Value, CaretOffset) $ Chr(C) $ Mid(Value, CaretOffset);

	if (Len(NewValue) > MaxLength)
		return False;

	if ( bHasRangeSelection )
		CaretOffset = RangeSelection[0]+1;
	else CaretOffset++;

	Value = NewValue;
	bHasValue2 = false;
	if (bDelayedNotify)
		bChangePending = True;
	else
		Notify(DE_Change);
	return True;
}

// Inserts a unicode at the current caret position
function bool InsertUnicode( int C )
{
	local string	NewValue;

	if ( bHasRangeSelection )
		NewValue = Left(Value, RangeSelection[0]) $ Chr(C) $ Mid(Value, RangeSelection[1]);
	else NewValue = Left(Value, CaretOffset) $ Chr(C) $ Mid(Value, CaretOffset);

	if (Len(NewValue) > MaxLength)
		return False;

	if ( bHasRangeSelection )
		CaretOffset = RangeSelection[0]+1;
	else CaretOffset++;

	Value = NewValue;
	bHasValue2 = false;
	if (bDelayedNotify)
		bChangePending = True;
	else
		Notify(DE_Change);
	return True;
}

function PasteAdjustedText(string Text)
{
	local int i, c, TextSize;
	local bool bPointInserted;
	local string LeftStr, RightStr;

	if (bNumericOnly)
	{
		TextSize = Len(Text);
		for (i = 0; i < TextSize; ++i)
		{
			c = Asc(Text, i);
			if (c >= 0x30 && c <= 0x39)
				continue;
			else if (bNumericFloat && !bPointInserted && (c == Asc(".") || c == Asc(",")))
			{
				bPointInserted = true;
				continue;
			}
			else
				break;
		}
		if (i == 0)
			return;
		if (i < TextSize)
			Text = Left(Text, i);
		Text = ReplaceStr(Text, ",", ".");
	}
	if (bAllSelected)
	{
		Clear();
		InsertText(Text);
	}
	else
	{
		InsertText(Text);
		if (bNumericOnly && bPointInserted && Divide(Value, ".", LeftStr, RightStr))
		{
			Value = LeftStr $ "." $ ReplaceStr(RightStr, ".", "");
			if (CaretOffset > Len(Value))
				CaretOffset = Len(Value);
		}
	}
}

function bool Backspace()
{
	local string	NewValue;

	if ( !bHasRangeSelection && CaretOffset==0 ) return False;

	if ( bHasRangeSelection )
	{
		NewValue = Left(Value, RangeSelection[0]) $ Mid(Value, RangeSelection[1]);
		CaretOffset = RangeSelection[0];
	}
	else
	{
		NewValue = Left(Value, CaretOffset - 1) $ Mid(Value, CaretOffset);
		CaretOffset--;
	}

	Value = NewValue;
	bHasValue2 = false;
	if (bDelayedNotify)
		bChangePending = True;
	else
		Notify(DE_Change);
	bHasRangeSelection = False;
	return True;
}

function bool DeleteSelection()
{
	local string	NewValue;

	if ( !bHasRangeSelection && CaretOffset==Len(Value) ) return False;

	if ( bHasRangeSelection )
	{
		NewValue = Left(Value, RangeSelection[0]) $ Mid(Value, RangeSelection[1]);
		CaretOffset = RangeSelection[0];
	}
	else NewValue = Left(Value, CaretOffset) $ Mid(Value, CaretOffset + 1);

	Value = NewValue;
	bHasValue2 = false;
	Notify(DE_Change);
	bHasRangeSelection = False;
	return True;
}

function bool WordLeft()
{
	while (CaretOffset > 0 && Mid(Value, CaretOffset - 1, 1) == " ")
		CaretOffset--;
	while (CaretOffset > 0 && Mid(Value, CaretOffset - 1, 1) != " ")
		CaretOffset--;
	bHasRangeSelection = False;

	LastDrawTime = GetLevel().TimeSeconds;
	bShowCaret = True;

	return True;
}

function bool MoveLeft()
{
	if (CaretOffset == 0) return False;
	CaretOffset--;
	bHasRangeSelection = False;

	LastDrawTime = GetLevel().TimeSeconds;
	bShowCaret = True;

	return True;
}

function bool MoveRight()
{
	if (CaretOffset == Len(Value)) return False;
	CaretOffset++;
	bHasRangeSelection = False;

	LastDrawTime = GetLevel().TimeSeconds;
	bShowCaret = True;

	return True;
}

function bool WordRight()
{
	while (CaretOffset < Len(Value) && Mid(Value, CaretOffset, 1) != " ")
		CaretOffset++;
	while (CaretOffset < Len(Value) && Mid(Value, CaretOffset, 1) == " ")
		CaretOffset++;
	bHasRangeSelection = False;

	LastDrawTime = GetLevel().TimeSeconds;
	bShowCaret = True;

	return True;
}

function bool MoveHome()
{
	CaretOffset = 0;
	bHasRangeSelection = False;

	LastDrawTime = GetLevel().TimeSeconds;
	bShowCaret = True;

	return True;
}

function bool MoveEnd()
{
	CaretOffset = Len(Value);
	bHasRangeSelection = False;

	LastDrawTime = GetLevel().TimeSeconds;
	bShowCaret = True;

	return True;
}

function EditCopy()
{
	if ( Root==None )
		Return;
	if ( bAllSelected || !bCanEdit )
		Root.CopyText(Value);
	else if ( bHasRangeSelection )
		Root.CopyText(Mid(Value,RangeSelection[0],RangeSelection[1]-RangeSelection[0]));
}

function EditPaste()
{
	if ( bCanEdit && Root!=None )
		PasteAdjustedText(Root.PasteText());
}

function EditCut()
{
	if ( bCanEdit && Root!=None )
	{
		if ( bAllSelected )
		{
			Root.CopyText(Value);
			bAllSelected = False;
			Clear();
		}
		else if ( bHasRangeSelection )
		{
			Root.CopyText(Mid(Value,RangeSelection[0],RangeSelection[1]-RangeSelection[0]));
			DeleteSelection();
		}
	}
	else
		EditCopy();
}

function KeyType( int Key, float MouseX, float MouseY )
{
		if (bCanEdit && bKeyDown)
		{
				if ( !bControlDown )
				{
						if (bAllSelected)
								Clear();
 
						bAllSelected = False;
 
						if (bNumericOnly)
						{
								if ( Key>=0x30 && Key<=0x39 )
										Insert(Key);
						}
						else if ( Key>=0x20 && Key!=0x7F )
								InsertUnicode(Key);
						bHasRangeSelection = False;
				}
		}
}

function KeyUp(int Key, float X, float Y)
{
	local PlayerPawn P;
	bKeyDown = False;
	P = GetPlayerOwner();
	switch (Key)
	{
	case P.EInputKey.IK_Ctrl:
		bControlDown = False;
		break;
	case P.EInputKey.IK_Shift:
		bShiftDown = False;
		break;
	}
}
function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;

	bKeyDown = True;
	P = GetPlayerOwner();

	switch (Key)
	{
	case P.EInputKey.IK_Ctrl:
		bControlDown = True;
		break;
	case P.EInputKey.IK_Shift:
		bShiftDown = True;
		break;
	case P.EInputKey.IK_Escape:
		break;
	case P.EInputKey.IK_Enter:
		if (bCanEdit)
		{
			if (bHistory)
			{
				AddValueToHistory();
				CurrentHistory = HistoryList;
			}
			Notify(DE_EnterPressed);
		}
		break;
	case P.EInputKey.IK_MouseWheelUp:
		if (bCanEdit)
			Notify(DE_WheelUpPressed);
		break;
	case P.EInputKey.IK_MouseWheelDown:
		if (bCanEdit)
			Notify(DE_WheelDownPressed);
		break;

	case P.EInputKey.IK_Right:
		if (bCanEdit)
		{
			if (bControlDown)
				WordRight();
			else
				MoveRight();
		}
		bAllSelected = False;
		break;
	case P.EInputKey.IK_Left:
		if (bCanEdit)
		{
			if (bControlDown)
				WordLeft();
			else
				MoveLeft();
		}
		bAllSelected = False;
		break;
	case P.EInputKey.IK_Up:
		if (bCanEdit && bHistory)
		{
			bAllSelected = False;
			if ( CurrentHistory==None && HistoryList!=None )
				CurrentHistory = HistoryList;
			if (CurrentHistory != None && CurrentHistory.Next != None)
			{
				CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Next);
				SetValue(CurrentHistory.HistoryText);
				MoveEnd();
			}
		}
		break;
	case P.EInputKey.IK_Down:
		if (bCanEdit && bHistory)
		{
			bAllSelected = False;
			if (CurrentHistory != None && CurrentHistory.Prev != None)
			{
				CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Prev);
				SetValue(CurrentHistory.HistoryText);
				MoveEnd();
			}
		}
		break;
	case P.EInputKey.IK_Home:
		if (bCanEdit)
			MoveHome();
		bAllSelected = False;
		break;
	case P.EInputKey.IK_End:
		if (bCanEdit)
			MoveEnd();
		bAllSelected = False;
		break;
	case P.EInputKey.IK_Backspace:
		if (bCanEdit)
		{
			if (bAllSelected)
				Clear();
			else
				Backspace();
		}
		bAllSelected = False;
		break;
	case P.EInputKey.IK_Delete:
		if (bCanEdit)
		{
			if (bAllSelected)
				Clear();
			else
				DeleteSelection();
		}
		bAllSelected = False;
		break;
	case P.EInputKey.IK_Period:
	case P.EInputKey.IK_NumPadPeriod:
		if (bNumericFloat)
		{
			if (InStr(Value, ".") >= 0)
				Value = ReplaceStr(Value, ".", "");
			Insert(Asc("."));
		}
		break;
	default:
		if ( bControlDown )
		{
			if ( Key == Asc("c") || Key == Asc("C"))
				EditCopy();

			if ( Key == Asc("v") || Key == Asc("V"))
				EditPaste();

			if ( Key == Asc("x") || Key == Asc("X"))
				EditCut();
		}
		else
		{
			if (NotifyOwner != None)
				NotifyOwner.KeyDown(Key, X, Y);
			else
				Super.KeyDown(Key, X, Y);
		}
		break;
	}
}

function Click(float X, float Y)
{
	OffsetSelectionType = 0;
	Notify(DE_Click);
}

function LMouseDown(float X, float Y)
{
	bHasRangeSelection = False;
	bAllSelected = False;
	if (bCanEdit)
	{
		OffsetSelectionType = 2;
		XClickPos = X;
	}
	Super.LMouseDown(X, Y);
	Notify(DE_LMouseDown);
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, XL, YL, XS;
	local float TextY;
	local int NewC;
	local string S;

	C.Font = Root.Fonts[Font];

	if ( OffsetSelectionType==1 )
		OffsetSelectionType = 0;
	else if ( OffsetSelectionType==2 )
	{
		OffsetSelectionType = 3;
		CaretOffset = PickStringOffset(XClickPos,C);
	}
	else if ( OffsetSelectionType==3 )
	{
		GetMouseXY(W,H);
		NewC = PickStringOffset(W,C);
		if ( H<-1 || H>WinHeight || W<-1 || W>WinWidth )
			OffsetSelectionType = 0;
		else if ( NewC!=CaretOffset )
		{
			if ( NewC<CaretOffset )
			{
				RangeSelection[0] = NewC;
				RangeSelection[1] = CaretOffset;
				bHasRangeSelection = True;
			}
			else
			{
				RangeSelection[0] = CaretOffset;
				RangeSelection[1] = NewC;
				bHasRangeSelection = True;
			}
		}
	}
	else if ( bAllSelected )
		CaretOffset = Len(Value);

	TextSize(C, "A", W, H);
	TextY = (WinHeight - H) / 2;

	if ( CaretOffset==0 )
	{
		TextSize(C, "A", W, H);
		W = 0;
	}
	else TextSize(C, Left(Value, CaretOffset), W, H);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	if (W + Offset < 0)
		Offset = -W;

	if (W + Offset > (WinWidth - 2))
	{
		Offset = (WinWidth - 2) - W;
		if (Offset > 0) Offset = 0;
	}

	C.DrawColor = TextColor;

	if (bAllSelected)
	{
		DrawStretchedTexture(C, Offset + 1, TextY, W, H, Texture'UWindow.WhiteTexture');

		// Invert Colors
		C.DrawColor.R = 255 ^ C.DrawColor.R;
		C.DrawColor.G = 255 ^ C.DrawColor.G;
		C.DrawColor.B = 255 ^ C.DrawColor.B;
	}
	else if ( bHasRangeSelection )
	{
		if ( RangeSelection[0]>0 )
		{
			S = Left(Value,RangeSelection[0]);
			C.TextSize(S,XL,YL);
			ClipText(C, Offset + 1, TextY,  S);
		}
		else XL = 0;
		XL/=Root.GUIScale;
		S = Mid(Value,RangeSelection[0],RangeSelection[1]-RangeSelection[0]);
		C.TextSize(S,XS,YL);
		XS/=Root.GUIScale;
		DrawStretchedTexture(C, Offset+1+XL, TextY, XS, H, Texture'UWindow.WhiteTexture');
		C.DrawColor.R = 255 ^ C.DrawColor.R;
		C.DrawColor.G = 255 ^ C.DrawColor.G;
		C.DrawColor.B = 255 ^ C.DrawColor.B;
		ClipText(C, Offset+1+XL,TextY,S);
		S = Mid(Value,RangeSelection[1]);
		C.DrawColor = TextColor;
		ClipText(C, Offset+1+XL+XS,TextY,S);
		Return;
	}
	ClipText(C, Offset + 1, TextY,  Value);

	if ((!bHasKeyboardFocus) || (!bCanEdit))
		bShowCaret = False;
	else
	{
		if ((GetLevel().TimeSeconds > LastDrawTime + 0.3) || (GetLevel().TimeSeconds < LastDrawTime))
		{
			LastDrawTime = GetLevel().TimeSeconds;
			bShowCaret = !bShowCaret;
		}
	}

	if (bShowCaret)
		ClipText(C, Offset + W - 1, TextY, "|");
}

function Close(optional bool bByParent)
{
	if (bChangePending)
	{
		bChangePending = False;
		Notify(DE_Change);
	}
	bKeyDown = False;
	Super.Close(bByParent);
}

function FocusOtherWindow(UWindowWindow W)
{
	if (bChangePending)
	{
		bChangePending = False;
		Notify(DE_Change);
	}

	if (NotifyOwner != None)
		NotifyOwner.FocusOtherWindow(W);
	else
		Super.FocusOtherWindow(W);
}

function KeyFocusEnter()
{
	if (bSelectOnFocus && !bHasKeyboardFocus)
		SelectAll();

	Super.KeyFocusEnter();
}

function DoubleClick(float X, float Y)
{
	Super.DoubleClick(X, Y);
	SelectAll();
}

function KeyFocusExit()
{
	bAllSelected = False;
	bHasRangeSelection = False;
	OffsetSelectionType = 0;
	Super.KeyFocusExit();
}

// New in 227:
function int PickStringOffset( int XPos, Canvas C )
{
	local int i,l;
	local float XL,YL,LastXL;

	XPos-=Offset;
	XPos*=Root.GUIScale;
	l = Len(Value);
	if ( l==0 )
		Return 0;
	For( i=1; i<=l; i++ )
	{
		C.TextSize(Left(Value,i),XL,YL);
		if ( XL>XPos )
		{
			if ( i==1 )
			{
				if ( (XL/2.f)<XPos )
					Return 1;
				Return 0;
			}
			XL-=XPos;
			LastXL-=XPos;
			if ( Abs(LastXL)>XL )
				Return i;
			else Return i-1;
		}
		else LastXL = XL;
	}
	Return l;
}

function AddValueToHistory()
{
	if( Len(Value) )
		SaveToHistory(Value);
}

final function SaveToHistory( string Val )
{
	local int i;

	if( SaveFile )
		SaveFile.SaveNewHistory(Val);

	for ( CurrentHistory = UWindowEditBoxHistory(HistoryList.Next); CurrentHistory != none && i < 1024; CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Next))
	{
		if (CurrentHistory.HistoryText == Val)
		{
			CurrentHistory.Remove();
			HistoryList.InsertItem(CurrentHistory);
			return;
		}
		++i;
	}

	CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(class'UWindowEditBoxHistory'));
	CurrentHistory.HistoryText = Val;
}

defaultproperties
{
}
