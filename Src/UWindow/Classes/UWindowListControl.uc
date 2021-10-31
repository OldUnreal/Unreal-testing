//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class UWindowListControl extends UWindowDialogControl;

var class<UWindowList>	ListClass;
var UWindowList			Items;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	// Declared in Subclass
}

function Created()
{
	Super.Created();

	Items = New ListClass;
	Items.Last = Items;
	Items.Next = None;
	Items.Prev = None;
	Items.Sentinel = Items;
}

defaultproperties
{
}
