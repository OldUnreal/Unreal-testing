//=============================================================================
// AdminGUIBanLGrid.
//=============================================================================
class AdminGUIBanLGrid extends UWindowGrid;

var AdminGUIClientWindow PageOwner;
var int ReceiveID;
var int ListCount,LastSortedCol,SelectedRow;
var bool bOldReversed,bReverseSort;
var struct BPLFLList
{
	var int IDx;
	var string PLName,PLIP,CLID;
} BanPlListF[512];
var AdminGUIBanLPullDown PulldownMenu;
var() localized string LengthExceeded,ResponseMismatch,ReceiveBanText,GettingBanListText;

function OpenedTab()
{
	if ( PageOwner!=None )
		RefreshBLList();
}
function ProcessInput( string S )
{
	local int i,j;

	if ( ListCount>=ArrayCount(BanPlListF) )
	{
		PageOwner.SetStatus(ReplaceStr(LengthExceeded,"%i",string(ArrayCount(BanPlListF))));
		Return;
	}
	i = InStr(S,"|");
	if ( i==-1 )
		Return;
	j = int(Left(S,i));
	if ( j!=ReceiveID )
	{
		PageOwner.SetStatus(ReplaceStr(ReplaceStr(ResponseMismatch,"%i",string(j)),"%j",string(ReceiveID)));
		Return;
	}
	S = Mid(S,i+1);
	i = InStr(S," ");
	BanPlListF[ListCount].IDx = int(Left(S,i));
	S = Mid(S,i+1);
	i = InStr(S," ");
	BanPlListF[ListCount].PLIP = Left(S,i);
	S = Mid(S,i+1);
	i = InStr(S," ");
	BanPlListF[ListCount].CLID = Left(S,i);
	BanPlListF[ListCount].PLName = Mid(S,i+1);
	PageOwner.SetStatus(ReplaceStr(ReceiveBanText,"%ls",BanPlListF[ListCount].PLName));
	ListCount++;
}
function RefreshBLList()
{
	local PlayerPawn PP;

	PP = Root.Console.Viewport.Actor;
	ReceiveID = Rand(2500);
	PageOwner.SetStatus(GettingBanListText);
	PP.Admin("UGetBanList B"$ReceiveID$"|");
	ListCount = 0;
}
function Created()
{
	Super.Created();

	RowHeight = 12;

	AddColumn(Class'AdminGUIPlayersGrid'.Default.PlayerName, 260);
	AddColumn(Class'AdminGUIPlayersGrid'.Default.PlayerIP, 150);
	AddColumn(Class'AdminGUIPlayersGrid'.Default.PlayerClientID, 210);
}
function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local int Visible;
	local int Skipped;
	local int Y,i;
	local int TopMargin;
	local int BottomMargin;

	if (bShowHorizSB)
		BottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	C.Font = Root.Fonts[F_Normal];
	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);

	VertSB.SetRange(0, ListCount+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;
	i = 0;
	while ((Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && i<ListCount )
	{
		if (Skipped >= VertSB.Pos)
		{
			// Draw highlight
			if ( i==SelectedRow )
				Column.DrawStretchedTexture( C, 0, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'MenuHighlight');
			switch (Column.ColumnNum)
			{
			case 0:
				Column.ClipText( C, 2, Y + TopMargin,BanPlListF[i].PLName);
				break;
			case 1:
				Column.ClipText( C, 2, Y + TopMargin,BanPlListF[i].PLIP);
				break;
			case 2:
				Column.ClipText( C, 2, Y + TopMargin,BanPlListF[i].CLID);
				break;
			}
			Y = Y + RowHeight;
		}
		Skipped ++;
		i++;
	}
}

function RightClickRow(int Row, float X, float Y)
{
	if ( PulldownMenu==None )
		PulldownMenu = AdminGUIBanLPullDown(Root.CreateWindow(class'AdminGUIBanLPullDown', 0, 0, 100, 60));
	PulldownMenu.WinLeft = Root.MouseX;
	PulldownMenu.WinTop = Root.MouseY;
	PulldownMenu.ShowWindow();
	PulldownMenu.Manager = Self;
	if ( Class==Class'AdminGUIBanLGrid' )
		PulldownMenu.AddManualItem();
}

final function bool SortByBanNames( BPLFLList A, BPLFLList B )
{
	return ((!bReverseSort && A.PLName<B.PLName) || (bReverseSort && A.PLName>B.PLName));
}
final function bool SortByBanIPs( BPLFLList A, BPLFLList B )
{
	return ((!bReverseSort && A.PLIP<B.PLIP) || (bReverseSort && A.PLIP>B.PLIP));
}
final function bool SortByBanIDs( BPLFLList A, BPLFLList B )
{
	return ((!bReverseSort && A.CLID<B.CLID) || (bReverseSort && A.CLID>B.CLID));
}
function SortColumn(UWindowGridColumn Column)
{
	bReverseSort = ((Column.ColumnNum+1)==LastSortedCol);
	if ( !bReverseSort )
		bOldReversed = True;
	else
	{
		bReverseSort = bOldReversed;
		bOldReversed = !bOldReversed;
	}
	Switch(Column.ColumnNum)
	{
Case 0:
		SortStaticArray(Property'BanPlListF',Function'UWindow.AdminGUIBanLGrid.SortByBanNames',ListCount);
		Break;
Case 1:
		SortStaticArray(Property'BanPlListF',Function'UWindow.AdminGUIBanLGrid.SortByBanIPs',ListCount);
		Break;
Default:
		SortStaticArray(Property'BanPlListF',Function'UWindow.AdminGUIBanLGrid.SortByBanIDs',ListCount);
		Break;
	}
	LastSortedCol = Column.ColumnNum+1;
}

function SelectRow(int Row)
{
	SelectedRow = Row;
}
function DoubleClickRow(int Row)
{
	RightClickRow(Row,0,0);
}
function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if ( PulldownMenu!=None )
		PulldownMenu.Close();
}
function ProcessUnban()
{
	local PlayerPawn PP;

	if ( SelectedRow>=ListCount )
		Return;
	PP = Root.Console.Viewport.Actor;
	PP.Admin("UUnBan"@BanPlListF[SelectedRow].IDx);
	RefreshBLList();
}
function ProcessManualBan()
{
	local AdminGUIManualBanWnd W;

	W = AdminGUIManualBanWnd(Root.CreateWindow(class'AdminGUIManualBanWnd', 200, 150, Class'AdminGUIManualBanWnd'.Default.MinWinWidth,
							 Class'AdminGUIManualBanWnd'.Default.MinWinHeight,, True));
}

defaultproperties
{
	LengthExceeded="Maximum player list length exceeded '%i'"
	ResponseMismatch="Response ID mismatched: %i/%j"
	ReceiveBanText="Received ban '%ls'."
	GettingBanListText="Getting banlist from server, if nothing happens you may not be logged in as admin (or there are no bans on server)."
}
