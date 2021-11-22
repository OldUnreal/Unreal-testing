class UBrowserInfoMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Refresh, CloseItem, AttachItem;

var localized string RefreshName,AttachName;
var localized string CloseName;

var UBrowserInfoClientWindow Info;

function Created()
{
	bTransient = True;
	Super.Created();

	Refresh = AddMenuItem(RefreshName, None);
	AddMenuItem("-", None);
	AttachItem = AddMenuItem(AttachName, None);
	AttachItem.bChecked = !Class'UBrowserInfoClientWindow'.Default.bClassicWindow;
	CloseItem = AddMenuItem(CloseName, None);
	CloseItem.bDisabled = AttachItem.bChecked;
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Refresh:
		Info.Server.ServerStatus();
		break;
	case AttachItem:
		Info.ListWin.ToggleInfoWinType();
		break;
	case CloseItem:
		Info.FramedWindowOwner.Close();
		break;
	}

	Super.ExecuteItem(I);
}
function ShowWindow()
{
	AttachItem.bChecked = !Class'UBrowserInfoClientWindow'.Default.bClassicWindow;
	CloseItem.bDisabled = AttachItem.bChecked;
	Super.ShowWindow();
}
function RMouseDown(float X, float Y)
{
	LMouseDown(X, Y);
}

function RMouseUp(float X, float Y)
{
	LMouseUp(X, Y);
}

function CloseUp()
{
	HideWindow();
}

defaultproperties
{
	RefreshName="&Refresh Info"
	AttachName="&Attach window"
	CloseName="&Close window"
}