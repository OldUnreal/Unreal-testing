//=============================================================================
// UBrowserRulesGrid
//=============================================================================
class UBrowserRulesGrid extends UWindowGrid;

var localized string RuleText;
var localized string ValueText;

function Created()
{
	Super.Created();

	RowHeight = 12;

	AddColumn(RuleText, 100);
	AddColumn(ValueText, 100);
}
function InitColumns( int XSize )
{
	FirstColumn.WinWidth = XSize/2;
	FirstColumn.NextColumn.WinWidth = XSize/2;
}
function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local UBrowserServerList Server;
	local UBrowserRulesList RulesList, l;
	local int Visible;
	local int Count;
	local int Skipped;
	local int Y;
	local int TopMargin;
	local int BottomMargin;

	if (bShowHorizSB)
		BottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Server = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server;
	if (Server == None)
		return;
	RulesList = Server.RulesList;
	if (RulesList == None)
		return;

	Count = RulesList.Count();

	C.Font = Root.Fonts[F_Normal];
	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);

	VertSB.SetRange(0, Count+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;
	l = UBrowserRulesList(RulesList.Next);
	while ((Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && (l != None))
	{
		if (Skipped >= VertSB.Pos)
		{
			switch (Column.ColumnNum)
			{
			case 0:
				Column.ClipText( C, 2, Y + TopMargin, l.Rule );
				break;
			case 1:
				Column.ClipText( C, 2, Y + TopMargin, l.Value );
				break;
			}

			Y = Y + RowHeight;
		}
		Skipped ++;
		l = UBrowserRulesList(l.Next);
	}
}


function RightClickRow(int Row, float X, float Y)
{
	local UBrowserInfoMenu Menu;
	local float MenuX, MenuY;

	Menu = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Menu;

	WindowToGlobal(X, Y, MenuX, MenuY);
	Menu.WinLeft = MenuX;
	Menu.WinTop = MenuY;

	Menu.ShowWindow();
}

function SortColumn(UWindowGridColumn Column)
{
	UBrowserInfoClientWindow(GetParent(Class'UBrowserInfoClientWindow')).Server.RulesList.SortByColumn(Column.ColumnNum);
}

function SelectRow(int Row)
{
}

defaultproperties
{
	RuleText="Rule"
	ValueText="Value"
}