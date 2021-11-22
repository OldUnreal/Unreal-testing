class UMenuWeaponPriorityCW extends UMenuDialogClientWindow;

var localized int ListAreaWidth;
var string ListAreaClass;
var UWindowHSplitter HSplitter;

function Created()
{
	Super.Created();

	HSplitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

	HSplitter.RightClientWindow = HSplitter.CreateWindow(class'UMenuWeaponPriorityMesh', 0, 0, 100, 100);
	HSplitter.LeftClientWindow = HSplitter.CreateWindow(class<UWindowWindow>(DynamicLoadObject(ListAreaClass, class'Class')), 0, 0, 100, 100, OwnerWindow);

	ListAreaWidth = Max(140, ListAreaWidth);
	HSplitter.bRightGrow = True;
	HSplitter.SplitPos = ListAreaWidth;
	HSplitter.MinWinWidth = ListAreaWidth;
}

function Resized()
{
	Super.Resized();
	HSplitter.SetSize(WinWidth, WinHeight);
}

defaultproperties
{
	ListAreaClass="UMenu.UMenuWeaponPriorityListArea"
	ListAreaWidth=150
}
