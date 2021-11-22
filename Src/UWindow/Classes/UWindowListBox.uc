//=============================================================================
// UWindowListBox - a listbox
//=============================================================================
class UWindowListBox extends UWindowListControl;

var float				ItemHeight;
var UWindowVScrollbar	VertSB;
var UWindowListBoxItem	SelectedItem;

var bool				bCanDrag;
var bool				bCanDragExternal;
var string				DefaultHelpText;
var bool				bDragging;
var float				DragY;
var UWindowListBox		DoubleClickList;	// list to send items to on double-click

function Created()
{
	Super.Created();
	VertSB = UWindowVScrollbar(CreateWindow(class'UWindowVScrollbar', WinWidth-12, 0, 12, WinHeight));
}

function BeforePaint(Canvas C, float MouseX, float MouseY)
{
	local UWindowListBoxItem OverItem;
	local string NewHelpText;

	VertSB.SetRange(0, Items.CountShown(), int(WinHeight/ItemHeight));

	NewHelpText = DefaultHelpText;
	if (SelectedItem != None)
	{
		OverItem = GetItemAt(MouseX, MouseY);
		if (OverItem == SelectedItem && OverItem.HelpText != "")
			NewHelpText = OverItem.HelpText;
	}

	if (NewHelpText != HelpText)
	{
		HelpText = NewHelpText;
		Notify(DE_HelpChanged);
	}
}

function SetHelpText(string T)
{
	Super.SetHelpText(T);
	DefaultHelpText = T;
}

function Sort()
{
	Items.Sort();
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float y;
	local UWindowList CurItem;
	local int i;

	CurItem = Items.Next;
	i = 0;

	while ((CurItem != None) && (i < VertSB.Pos))
	{
		if (CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for (y=0; (y < WinHeight) && (CurItem != None); CurItem = CurItem.Next)
	{
		if (CurItem.ShowThisItem())
		{
			DrawItem(C, CurItem, 0, y, WinWidth - 12, ItemHeight);
			y = y + ItemHeight;
		}
	}
}

function Resized()
{
	Super.Resized();

	VertSB.WinLeft = WinWidth-12;
	VertSB.WinTop = 0;
	VertSB.SetSize(12, WinHeight);
}

function UWindowListBoxItem GetItemAt(float MouseX, float MouseY)
{
	local float y;
	local UWindowList CurItem;
	local int i;

	if (MouseX < 0 || MouseX > WinWidth)
		return None;

	CurItem = Items.Next;
	i = 0;

	while ((CurItem != None) && (i < VertSB.Pos))
	{
		if (CurItem.ShowThisItem())
			i++;
		CurItem = CurItem.Next;
	}

	for (y=0; (y < WinHeight) && (CurItem != None); CurItem = CurItem.Next)
	{
		if (CurItem.ShowThisItem())
		{
			if (MouseY >= y && MouseY <= y+ItemHeight)
				return UWindowListBoxItem(CurItem);
			y = y + ItemHeight;
		}
	}

	return None;
}

function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local int i;

	VertSB.SetRange(0, Items.CountShown(), int(WinHeight/ItemHeight));

	if (SelectedItem == None)
		return;

	i = 0;
	for (CurItem=Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
		if (CurItem == SelectedItem)
			break;
		if (CurItem.ShowThisItem())
			i++;
	}

	VertSB.Show(i);
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	if (NewSelected != None && SelectedItem != NewSelected)
	{
		if (SelectedItem != None)
			SelectedItem.bSelected = False;

		SelectedItem = NewSelected;

		if (SelectedItem != None)
			SelectedItem.bSelected = True;

		Notify(DE_Click);
	}
}

function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	SetSelectedItem(NewSelected);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	SetSelected(X, Y);

	if (bCanDrag || bCanDragExternal)
	{
		bDragging = True;
		Root.CaptureMouse();
		DragY = Y;
	}
}

function DoubleClick(float X, float Y)
{
	Super.DoubleClick(X, Y);

	if (GetItemAt(X, Y) == SelectedItem)
	{
		DoubleClickItem(SelectedItem);
	}
}

function ReceiveDoubleClickItem(UWindowListBox L, UWindowListBoxItem I)
{
	I.Remove();
	Items.AppendItem(I);
	SetSelectedItem(I);
	L.SelectedItem = None;
	L.Notify(DE_Change);
	Notify(DE_Change);
}

function DoubleClickItem(UWindowListBoxItem I)
{
	if (DoubleClickList != None && I != None)
		DoubleClickList.ReceiveDoubleClickItem(Self, I);
}

function MouseMove(float X, float Y)
{
	local UWindowListBoxItem OverItem;
	Super.MouseMove(X, Y);

	if (bDragging && bMouseDown)
	{
		OverItem = GetItemAt(X, Y);
		if (bCanDrag && OverItem != SelectedItem && OverItem != None && SelectedItem != None)
		{
			SelectedItem.Remove();
			if (Y < DragY)
				OverItem.InsertItemBefore(SelectedItem);
			else
				OverItem.InsertItemAfter(SelectedItem, True);

			Notify(DE_Change);

			DragY = Y;
		}
		else
		{
			if (bCanDragExternal && CheckExternalDrag(X, Y) != None)
				bDragging = False;
		}
	}
	else
		bDragging = False;
}

function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	local UWindowListBox B;
	local UWindowListBoxItem OverItem;

	// Subclass should return false and not call this version if this external
	// drag should be denied.

	B = UWindowListBox(ExternalControl);
	if (B != None && B.SelectedItem != None)
	{
		OverItem = GetItemAt(X, Y);

		B.SelectedItem.Remove();
		if (OverItem != None)
			OverItem.InsertItemBefore(B.SelectedItem);
		else
			Items.AppendItem(B.SelectedItem);

		SetSelectedItem(B.SelectedItem);
		B.SelectedItem = None;
		B.Notify(DE_Change);
		Notify(DE_Change);

		if (bCanDrag || bCanDragExternal)
		{
			Root.CancelCapture();
			bDragging = True;
			bMouseDown = True;
			Root.CaptureMouse(Self);
			DragY = Y;
		}

		return True;
	}

	return False;
}

function KeyDown(int Key, float X, float Y)
{
	super.KeyDown(Key, X, Y);
	HandleMouseWheelScrolling(Key, X, Y);
}

function MouseWheelScrolling(int Direction, float X, float Y)
{
	VertSB.Scroll(Direction);
}

defaultproperties
{
	ItemHeight=10.000000
}
