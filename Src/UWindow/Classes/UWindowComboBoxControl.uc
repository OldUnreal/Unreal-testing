class UWindowComboBoxControl expands UWindowComboControl;

var class<UWindowComboArray> ListWindowClass;
var UWindowComboArray ListWindow;
var string Value, Value2;
var bool bHasValue2;

function Created()
{
	Super(UWindowDialogControl).Created();

	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, WinWidth-12, WinHeight));
	EditBox.NotifyOwner = Self;
	EditBoxWidth = WinWidth / 2;
	EditBox.bTransient = True;
	EditBox.SetEditable(False);

	Button = UWindowComboButton(CreateWindow(class'UWindowComboButton', WinWidth-12, 0, 12, 10));
	Button.Owner = Self;

	ListWindow = UWindowComboArray(Root.CreateWindow(ListWindowClass, 0, 0, 100, 100));
	ListWindow.LookAndFeel = LookAndFeel;
	ListWindow.Owner = Self;
	ListWindow.Setup();

	ListWindow.HideWindow();
	bListVisible = False;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function int FindItemIndex(string V, optional bool bIgnoreCase)
{
	return ListWindow.FindItemIndex(V, bIgnoreCase);
}

function RemoveItem(int Index)
{
	ListWindow.RemoveItem(Index);
}

function RemoveSelectedItems()
{
	ListWindow.RemoveItems(Value, Value2);
}

function int FindItemIndex2(string V2, optional bool bIgnoreCase)
{
	return ListWindow.FindItemIndex2(V2, bIgnoreCase);
}

function int GetSelectedIndex()
{
	return ListWindow.FindItemIndex(Value);
}

function int GetSelectedItemIndex()
{
	return ListWindow.FindExactItemIndex(Value, Value2);
}

function SetSelectedIndex(int Index)
{
	SetValue(ListWindow.GetItemValue(Index), ListWindow.GetItemValue2(Index));
}

function string GetValue()
{
	return Value;
}

function string GetValue2()
{
	return Value2;
}

function bool HasValue2()
{
	return bHasValue2;
}

function SetValue(string NewValue, optional string NewValue2)
{
	Value = NewValue;
	Value2 = NewValue2;
	if (!bListVisible)
		EditBox.SetValue(NewValue, NewValue2);
}

function AssignValues(string NewValue, optional string NewValue2, optional bool bNoNotify)
{
	Value = NewValue;
	Value2 = NewValue2;
	if (!bListVisible)
		EditBox.AssignValues(NewValue, NewValue2, bNoNotify);
}

function string GetItemValue(int Index)
{
	return ListWindow.GetItemValue(Index);
}

function string GetItemValue2(int Index)
{
	return ListWindow.GetItemValue2(Index);
}

function SetAutoSort(bool bEnable)
{
	ListWindow.bAutoSort = bEnable;
}

function SetEditable(bool bNewCanEdit)
{
	bCanEdit = bNewCanEdit;
}

function EnableQuickFilter(bool bEnable)
{
	if (bEnable)
		ListWindow.EditBox = EditBox;
	else
		ListWindow.EditBox = none;
}

function AddItem(string S, optional string S2, optional int SortWeight)
{
	ListWindow.AddItem(S, S2, SortWeight);
}

function InsertItem(string S, optional string S2, optional int SortWeight)
{
	ListWindow.InsertItem(S, S2, SortWeight);
}

function AddUniqueItem(string S, optional string S2, optional int SortWeight)
{
	ListWindow.AddUniqueItem(S, S2, SortWeight);
}

function InsertUniqueItem(string S, optional string S2, optional int SortWeight)
{
	ListWindow.InsertUniqueItem(S, S2, SortWeight);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super(UWindowDialogControl).BeforePaint(C, X, Y);
	LookAndFeel.Combo_SetupSizes(Self, C);
	ListWindow.bLeaveOnscreen = bListVisible && bLeaveOnscreen;
}

function CloseUp()
{
	bListVisible = False;
	EditBox.NotifyOwner = self;
	EditBox.SetEditable(false);
	EditBox.AssignValues(Value, Value2, true);
	ListWindow.HideWindow();
	Button.FocusWindow();
}

function DropDown()
{
	bListVisible = True;
	EditBox.NotifyOwner = none; // prevent calling FocusOtherWindow on this UWindowComboBoxControl
	EditBox.SetEditable(ListWindow.EditBox == EditBox);
	ListWindow.ShowWindow();
	if (ListWindow.EditBox == EditBox)
		EditBox.NotifyOwner = ListWindow; // temporarily makes the edit box a field that represents the quick filter
	else
		EditBox.NotifyOwner = self;
}

function Sort()
{
	ListWindow.Sort();
}

function ClearValue()
{
	Value = "";
	Value2 = "";
	EditBox.Clear();
}

function Clear()
{
	ListWindow.Clear();
	ClearValue();
}

function FocusOtherWindow(UWindowWindow W)
{
	super.FocusOtherWindow(W);
	if (W != EditBox && EditBox.bCanEdit)
		EditBox.SetEditable(false);
}

function int ItemsCount()
{
	return ListWindow.AllItemsCount();
}

function Notify(byte E)
{
	if (E == DE_Change)
	{
		Value = EditBox.Value;
		Value2 = EditBox.Value2;
		bHasValue2 = EditBox.bHasValue2;
	}
	else if (E == DE_LMouseDown && !bDisabled)
	{
		if (!bListVisible)
		{
			if (bCanEdit)
				EditBox.SetEditable(true);
			else if (ItemsCount() > 0)
			{
				DropDown();
				Root.CaptureMouse(ListWindow);
			}
		}
		else
			CloseUp();
	}

	super(UWindowDialogControl).Notify(E);
}

defaultproperties
{
	ListWindowClass=Class'UWindow.UWindowComboArray'
}
