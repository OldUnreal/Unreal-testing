class UWindowComboArray expands UWindowComboList;

struct Item
{
	var string Value;
	var string Value2;
	var int SortWeight;
	var bool bIsRelevant;
};

var array<Item> AllItems; // all items that the control initially contains
var int RelevantItemsCount; // the number of items which are supposed to be relevant at the current moment'
var UWindowEditBox EditBox;
var bool bAutoSort;

var bool bIsSorted;
var bool bUseQuickFilter;
var string QuickFilter;
var int SelectedItemIndex;

function FilterItems(string Substring)
{
	local int i, n;

	QuickFilter = Caps(Substring);
	n = Array_Size(AllItems);

	if (Len(Substring) > 0)
	{
		for (i = 0; i < n; ++i)
			AllItems[i].bIsRelevant = ValueIsRelevant(AllItems[i].Value);
		UpdateRelevantItemsCount();
	}
	else
	{
		for (i = 0; i < n; ++i)
			AllItems[i].bIsRelevant = true;
		RelevantItemsCount = n;
	}
	VertSB.SetRange(0, RelevantItemsCount, MaxVisible);
}

function bool ValueIsRelevant(string Value)
{
	return InStr(Caps(Value), QuickFilter) >= 0;
}

function UpdateRelevantItemsCount()
{
	local int i, n;

	RelevantItemsCount = 0;
	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
		if (AllItems[i].bIsRelevant)
			RelevantItemsCount++;
}

function Sort()
{
	SortAllItems();
	bIsSorted = true;
}

function SortAllItems()
{
	// Using a non-recursive merge sort algorithm - stable, O(n * log n)
	local int i, n, size;
	local int idx1, idx2, end1, end2;
	local int merged_idx;
	local array<Item> merged;

	size = Array_Size(AllItems);
	if (size < 2)
		return;

	Array_Size(merged);

	for (n = 1; true; n *= 2)
	{
		for (i = 0; i < size; i += n * 2)
		{
			merged_idx = i;

			idx1 = i;
			if (size - idx1 > n)
				end1 = idx1 + n;
			else
				end1 = size;

			idx2 = end1;
			if (size - idx2 > n)
				end2 = idx2 + n;
			else
				end2 = size;

			while (idx1 < end1 && idx2 < end2)
			{
				if (CompareArrayItems(idx1, idx2))
					merged[merged_idx++] = AllItems[idx1++];
				else
					merged[merged_idx++] = AllItems[idx2++];
			}
			while (idx1 < end1)
				merged[merged_idx++] = AllItems[idx1++];
			while (idx2 < end2)
				merged[merged_idx++] = AllItems[idx2++];

			for (merged_idx = i; merged_idx < end2; ++merged_idx)
				AllItems[merged_idx] = merged[merged_idx];
		}

		if (size - n <= n)
			return;
	}
}

// Returns true iff AllItems[Index1] precedes AllItems[Index2]
function bool CompareArrayItems(int Index1, int Index2)
{
	if (AllItems[Index1].SortWeight == AllItems[Index2].SortWeight)
		return Caps(AllItems[Index1].Value) < Caps(AllItems[Index2].Value);
	return AllItems[Index1].SortWeight < AllItems[Index2].SortWeight;
}

// Returns true iff Item1 precedes Item2
function bool CompareItems(Item Item1, Item Item2)
{
	if (Item1.SortWeight == Item2.SortWeight)
		return Caps(Item1.Value) < Caps(Item2.Value);
	return Item1.SortWeight < Item2.SortWeight;
}

function WindowShown()
{
	local int i;

	Super.WindowShown();
	FocusWindow();
	bCanExecuteItem = false;
	bUseQuickFilter = false;
	FilterItems("");
	
	i = Owner.GetSelectedIndex();
	if( i>=0 && RelevantItemsCount>MaxVisible )
		VertSB.Pos = Min(i,RelevantItemsCount-MaxVisible);
}

function Clear()
{
	Array_Size(AllItems, 0);
	RelevantItemsCount = 0;
}

function Texture GetLookAndFeelTexture()
{
	return LookAndFeel.Active;
}

function int FindItemIndex(string Value, optional bool bIgnoreCase)
{
	local int i, n;

	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
	{
		if (bIgnoreCase && AllItems[i].Value ~= Value)
			return i;
		if (AllItems[i].Value == Value)
			return i;
	}

	return -1;
}

function int FindItemIndex2(string Value2, optional bool bIgnoreCase)
{
	local int i, n;

	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
	{
		if (bIgnoreCase && AllItems[i].Value2 ~= Value2 ||
			!bIgnoreCase && AllItems[i].Value2 == Value2)
		{
			return i;
		}
	}

	return -1;
}

function int FindExactItemIndex(string Value, string Value2, optional bool bIgnoreValueCase, optional bool bIgnoreValue2Case)
{
	local int i, n;

	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
	{
		if (bIgnoreValueCase && AllItems[i].Value ~= Value || !bIgnoreValueCase && AllItems[i].Value == Value)
		{
			if (bIgnoreValue2Case && AllItems[i].Value2 ~= Value2 || !bIgnoreValue2Case && AllItems[i].Value2 == Value2)
				return i;
		}
	}

	return -1;
}

function bool BinarySearch(string Value, int SortWeight, out int Index)
{
	local int i, lower_bound, upper_bound;
	local Item TmpItem;

	if (!bIsSorted)
	{
		Log(self $ ".BinarySearch is called for non-sorted array", 'Warning');
		Index = -1;
		return false;
	}

	lower_bound = 0;
	upper_bound = Array_Size(AllItems);
	TmpItem.Value = Value;
	TmpItem.SortWeight = SortWeight;

	while (lower_bound < upper_bound)
	{
		i = lower_bound + (upper_bound - lower_bound) / 2;
		if (CompareItems(AllItems[i], TmpItem))
			lower_bound = i + 1;
		else if (CompareItems(TmpItem, AllItems[i]))
			upper_bound = i;
		else
		{
			Index = i;
			return true;
		}
	}
	Index = lower_bound;
	return false;
}

function string GetItemValue(int Index)
{
	if (0 <= Index && Index < Array_Size(AllItems))
		return AllItems[Index].Value;
	return "";
}

function string GetItemValue2(int Index)
{
	if (0 <= Index && Index < Array_Size(AllItems))
		return AllItems[Index].Value2;
	return "";
}

function RemoveItem(int Index)
{
	if (0 <= Index && Index < Array_Size(AllItems))
	{
		if (AllItems[Index].bIsRelevant)
			RelevantItemsCount--;
		Array_Remove(AllItems, Index);
	}
}

function RemoveItems(string Value, string Value2)
{
	local int i, j, n;

	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
		if (AllItems[i].Value == Value && AllItems[i].Value2 == Value2)
		{
			for (j = i + 1; j < n; ++j)
				if (AllItems[j].Value != Value || AllItems[j].Value2 != Value2)
				{
					AllItems[i] = AllItems[j];
					++i;
				}
			Array_Remove(AllItems, i, n - i);
			UpdateRelevantItemsCount();
			return;
		}
}

function int AllItemsCount()
{
	return Array_Size(AllItems);
}

// If !bAutoSort, append new item
// If bAutoSort, call InsertItem(Value, Value2, SortWeight)
function AddItem(string Value, optional string Value2, optional int SortWeight)
{
	local int i;

	if (bAutoSort)
	{
		InsertItem(Value, Value2, SortWeight);
		return;
	}

	i = Array_Size(AllItems);
	AllItems[i].Value = Value;
	AllItems[i].Value2 = Value2;
	AllItems[i].SortWeight = SortWeight;
	AllItems[i].bIsRelevant = !bUseQuickFilter || ValueIsRelevant(Value);
	if (AllItems[i].bIsRelevant)
		RelevantItemsCount++;
}

// If !bAutoSort, insert new item into the front
// If bAutoSort, insert new item into the corresponding position, maintaining the order
function InsertItem(string Value, optional string Value2, optional int SortWeight)
{
	local int i;

	if (bAutoSort)
	{
		if (!bIsSorted)
			Sort();
		BinarySearch(Value, SortWeight, i);
		InsertItemAt(i, Value, Value2, SortWeight);
	}
	else
		InsertItemAt(0, Value, Value2, SortWeight);
}

// If !bAutoSort, append new item
// If bAutoSort, call InsertUniqueItem(Value, Value2, SortWeight)
function bool AddUniqueItem(string Value, optional string Value2, optional int SortWeight)
{
	if (bAutoSort)
		return InsertUniqueItem(Value, Value2, SortWeight);

	if (FindItemIndex(Value, true) >= 0)
		return false;

	AddItem(Value, Value2, SortWeight);
	return true;
}

// If !bAutoSort, insert new item into the front
// If bAutoSort, insert new item into the corresponding position, maintaining the order
function bool InsertUniqueItem(string Value, optional string Value2, optional int SortWeight)
{
	local int i;

	if (bAutoSort)
	{
		if (!bIsSorted)
			Sort();
		if (BinarySearch(Value, SortWeight, i))
			return false;
		InsertItemAt(i, Value, Value2, SortWeight);
		bIsSorted = true;
	}
	else
	{
		if (FindItemIndex(Value, true) >= 0)
			return false;
		InsertItemAt(0, Value, Value2, SortWeight);
	}

	return true;
}

function InsertItemAt(int Index, string Value, optional string Value2, optional int SortWeight)
{
	if (Index < 0 || Index > Array_Size(AllItems))
		return;
	Array_Insert(AllItems, Index);
	AllItems[Index].Value = Value;
	AllItems[Index].Value2 = Value2;
	AllItems[Index].SortWeight = SortWeight;
	AllItems[Index].bIsRelevant = !bUseQuickFilter || ValueIsRelevant(Value);
	if (AllItems[Index].bIsRelevant)
		RelevantItemsCount++;
	bIsSorted = false; // in general, insertion potentially may break the order
}

function SetSelected(float X, float Y)
{
	SelectedItemIndex = ClampRelevantItemIndex(Min((Y - VBorder) / ItemHeight + VertSB.Pos,VertSB.Pos+MaxVisible));
}

function LMouseUp(float X, float Y)
{
	if (bCanExecuteItem && Y >= 0 && Y <= WinHeight)
		ExecuteSelectedItem();
	Super.LMouseUp(X, Y);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, MaxWidth;
	local int i, n;
	local float ListX, ListY;
	local float ExtraWidth;

	C.Font = Root.Fonts[F_Normal];
	C.SetPos(0, 0);

	MaxWidth = Owner.EditBoxWidth;
	ExtraWidth = ((HBorder + TextBorder) * 2);

	if (RelevantItemsCount > MaxVisible)
	{
		ExtraWidth += LookAndFeel.Size_ScrollbarWidth;
		WinHeight = (ItemHeight * MaxVisible) + (VBorder * 2);
	}
	else
	{
		VertSB.Pos = 0;
		WinHeight = (ItemHeight * RelevantItemsCount) + (VBorder * 2);
	}

	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
		if (AllItems[i].bIsRelevant)
		{
			TextSize(C, RemoveAmpersand(AllItems[i].Value), W, H);
			if (W + ExtraWidth > MaxWidth)
				MaxWidth = W + ExtraWidth;
		}

	WinWidth = MaxWidth;

	ListX = Owner.EditAreaDrawX + Owner.EditBoxWidth - WinWidth;
	ListY = Owner.Button.WinTop + Owner.Button.WinHeight;

	if (RelevantItemsCount > MaxVisible || WinHeight > Root.WinHeight)
	{
		VertSB.ShowWindow();
		VertSB.SetRange(0, RelevantItemsCount, MaxVisible);
		VertSB.WinLeft = WinWidth - LookAndFeel.Size_ScrollbarWidth - HBorder;
		VertSB.WinTop = HBorder;
		VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
		VertSB.WinHeight = WinHeight - 2*VBorder;
	}
	else
	{
		VertSB.HideWindow();
	}

	Owner.WindowToGlobal(ListX, ListY, WinLeft, WinTop);

	if (WinTop >= Root.WinHeight - WinHeight)
	{
		ListY = Owner.Button.WinTop - WinHeight;
		Owner.WindowToGlobal(ListX, ListY, WinLeft, WinTop);
	}
	WinLeft = FMax(0, FMin(WinLeft, Root.WinWidth - WinWidth));
	WinTop = FMax(0, WinTop);
}

function Paint(Canvas C, float X, float Y)
{
	local int i, n, numvis;
	local int Offset;

	DrawMenuBackground(C);

	n = Array_Size(AllItems);

	for (i = 0; i < n; ++i)
		if (AllItems[i].bIsRelevant)
		{
			if (VertSB.bWindowVisible)
			{
				if (Offset >= VertSB.Pos)
				{
					DrawRelevantItem(C, i, Offset, HBorder, VBorder + (ItemHeight * (Offset - VertSB.Pos)), WinWidth - (2 * HBorder) - VertSB.WinWidth, ItemHeight);
					if( ++numvis>MaxVisible )
						break;
				}
			}
			else
				DrawRelevantItem(C, i, Offset, HBorder, VBorder + (ItemHeight * Offset), WinWidth - (2 * HBorder), ItemHeight);
			++Offset;
		}
}

function DrawMenuBackground(Canvas C)
{
	LookAndFeel.ComboList_DrawBackground(Self, C);
}

function DrawRelevantItem(Canvas C, int ItemIndex, int Offset, float X, float Y, float W, float H)
{
	LookAndFeel.ComboList_DrawItem(Self, C, X, Y, W, H, AllItems[ItemIndex].Value, Offset == SelectedItemIndex);
}

function ExecuteSelectedItem()
{
	local int i, n;
	local int RelevantItemIndex;

	if (SelectedItemIndex < 0 || SelectedItemIndex != ClampRelevantItemIndex(SelectedItemIndex))
		return;

	CloseUp();
	n = Array_Size(AllItems);
	for (i = 0; i < n; ++i)
		if (AllItems[i].bIsRelevant)
		{
			if (RelevantItemIndex == SelectedItemIndex)
			{
				Owner.EditBox.SetValue(AllItems[i].Value, AllItems[i].Value2);
				return;
			}
			++RelevantItemIndex;
		}
}

function Notify(byte E)
{
	super.Notify(E);

	if (E == DE_Change && EditBox != none)
		FilterItems(EditBox.GetValue());
}

singular function KeyDown(int Key, float X, float Y)
{
	super.KeyDown(Key, X, Y);
	HandleKeyboardScrolling(Key, X, Y);
	if (EditBox != none)
		EditBox.KeyDown(Key, X, Y);

	if (Key == IK_Enter)
		ExecuteSelectedItem();
}

singular function KeyUp(int Key, float X, float Y)
{
	super.KeyUp(Key, X, Y);
	if (EditBox != none)
		EditBox.KeyUp(Key, X, Y);
}

singular function KeyType(int Key, float MouseX, float MouseY)
{
	if (EditBox == none)
		return;
	if (!bUseQuickFilter)
	{
		bUseQuickFilter = true;
		EditBox.AssignValues("",, false);
		EditBox.OffsetSelectionType = 3;
		EditBox.CaretOffset = 0;
		EditBox.bHasKeyboardFocus = true;
	}
	EditBox.KeyType(Key, MouseX, MouseY);
	SelectedItemIndex = ClampRelevantItemIndex(0);
}

function FocusOtherWindow(UWindowWindow W)
{
	super(UWindowListControl).FocusOtherWindow(W);

	if (!bWindowVisible)
		return;
	if (W.ParentWindow == none ||
		W == EditBox ||
		W.ParentWindow.ParentWindow != self && W.ParentWindow != self && W.ParentWindow != Owner)
	{
		CloseUp();
	}
}

function KeyboardScrolling(int Direction, bool bPage, float X, float Y)
{
	if (bPage)
		Direction *= MaxVisible;
	if (SelectedItemIndex + Direction < VertSB.Pos ||
		SelectedItemIndex + Direction >= VertSB.Pos + MaxVisible)
	{
		VertSB.Scroll(Direction);
	}
	SelectedItemIndex = ClampRelevantItemIndex(SelectedItemIndex + Direction);
}

function int ClampRelevantItemIndex(int Index)
{
	local int MaxValue;

	// Note: MaxValue can be -1
	MaxValue = VertSB.Pos + Min(RelevantItemsCount, MaxVisible) - 1;
	if (Index >= MaxValue)
		return MaxValue;
	if (Index < VertSB.Pos)
		return VertSB.Pos;
	return Index;
}
