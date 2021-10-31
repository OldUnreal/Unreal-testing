//=============================================================================
// AdminGUIPlayersGrid.
//=============================================================================
class AdminGUIPlayersGrid extends UWindowGrid;

var() localized string PlayerID,PlayerName,PlayerIP,PlayerClientID,MaxLengthExceeded,IDMismatchedStr,ClientReceivedStr,GettingInfoStr;
var AdminGUIClientWindow PageOwner;
var int ReceiveID;
var int ListCount,LastSortedCol,SelectedRow;
var bool bOldReversed;
var struct PLFLList
{
	var int PLID;
	var string PLName,PLIP,CLID;
} PlayerListF[32];
var AdminGUIPLPullDown PulldownMenu;

function OpenedTab()
{
	if ( PageOwner!=None )
		RefreshPLList();
}
function ProcessInput( string S )
{
	local int i,j;

	if ( ListCount>=ArrayCount(PlayerListF) )
	{
		PageOwner.SetStatus(ReplaceStr(MaxLengthExceeded,"%i",string(ArrayCount(PlayerListF))));
		Return;
	}
	i = InStr(S,"|");
	if ( i==-1 )
		Return;
	j = int(Left(S,i));
	if ( j!=ReceiveID )
	{
		PageOwner.SetStatus(ReplaceStr(ReplaceStr(IDMismatchedStr,"%i",string(j)),"%j",string(ReceiveID)));
		Return;
	}
	S = Mid(S,i+1);
	i = InStr(S," ");
	PlayerListF[ListCount].PLID = int(Left(S,i));
	S = Mid(S,i+1);
	i = InStr(S," ");
	PlayerListF[ListCount].PLIP = Left(S,i);
	S = Mid(S,i+1);
	i = InStr(S," ");
	PlayerListF[ListCount].CLID = Left(S,i);
	PlayerListF[ListCount].PLName = Mid(S,i+1);
	PageOwner.SetStatus(ReplaceStr(ClientReceivedStr,"%ls",PlayerListF[ListCount].PLName));
	ListCount++;
}
function RefreshPLList()
{
	local PlayerPawn PP;

	PP = Root.Console.Viewport.Actor;
	ReceiveID = Rand(2500);
	PageOwner.SetStatus(GettingInfoStr);
	PP.Admin("UGetFullClientList P"$ReceiveID$"|");
	ListCount = 0;
}
function Created()
{
	Super.Created();

	RowHeight = 12;

	AddColumn(PlayerID, 32);
	AddColumn(PlayerName, 250);
	AddColumn(PlayerIP, 150);
	AddColumn(PlayerClientID, 210);
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
				Column.ClipText( C, 2, Y + TopMargin,string(PlayerListF[i].PLID));
				break;
			case 1:
				Column.ClipText( C, 2, Y + TopMargin,PlayerListF[i].PLName);
				break;
			case 2:
				Column.ClipText( C, 2, Y + TopMargin,PlayerListF[i].PLIP);
				break;
			case 3:
				Column.ClipText( C, 2, Y + TopMargin,PlayerListF[i].CLID);
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
		PulldownMenu = AdminGUIPLPullDown(Root.CreateWindow(class'AdminGUIPLPullDown', 0, 0, 100, 60));
	PulldownMenu.WinLeft = Root.MouseX;
	PulldownMenu.WinTop = Root.MouseY;
	PulldownMenu.ShowWindow();
	PulldownMenu.Manager = Self;
}

function SortColumn(UWindowGridColumn Column)
{
	local bool bReverseSort;
	local int I, J, Max;
	local PLFLList Tmp;

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
		for ( I=0; I<ListCount-1; I++ )
		{
			Max = I;
			for ( J=I+1; J<ListCount; J++ )
				if ( (!bReverseSort && PlayerListF[J].PLID>PlayerListF[Max].PLID)
						|| (bReverseSort && PlayerListF[J].PLID<PlayerListF[Max].PLID) )
					Max = J;
			Tmp = PlayerListF[Max];
			PlayerListF[Max] = PlayerListF[I];
			PlayerListF[I] = Tmp;
		}
		Break;
Case 1:
		for ( I=0; I<ListCount-1; I++ )
		{
			Max = I;
			for ( J=I+1; J<ListCount; J++ )
				if ( (!bReverseSort && PlayerListF[J].PLName<PlayerListF[Max].PLName)
						|| (bReverseSort && PlayerListF[J].PLName>PlayerListF[Max].PLName) )
					Max = J;
			Tmp = PlayerListF[Max];
			PlayerListF[Max] = PlayerListF[I];
			PlayerListF[I] = Tmp;
		}
		Break;
Case 2:
		for ( I=0; I<ListCount-1; I++ )
		{
			Max = I;
			for ( J=I+1; J<ListCount; J++ )
				if ( (!bReverseSort && PlayerListF[J].PLIP<PlayerListF[Max].PLIP)
						|| (bReverseSort && PlayerListF[J].PLIP>PlayerListF[Max].PLIP) )
					Max = J;
			Tmp = PlayerListF[Max];
			PlayerListF[Max] = PlayerListF[I];
			PlayerListF[I] = Tmp;
		}
		Break;
Default:
		for ( I=0; I<ListCount-1; I++ )
		{
			Max = I;
			for ( J=I+1; J<ListCount; J++ )
				if ( (!bReverseSort && PlayerListF[J].CLID<PlayerListF[Max].CLID)
						|| (bReverseSort && PlayerListF[J].CLID>PlayerListF[Max].CLID) )
					Max = J;
			Tmp = PlayerListF[Max];
			PlayerListF[Max] = PlayerListF[I];
			PlayerListF[I] = Tmp;
		}
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
function ProcessCmd( byte Code )
{
	local PlayerPawn PP;

	if ( SelectedRow>=ListCount )
		Return;
	PP = Root.Console.Viewport.Actor;
	if ( Code==0 )
		PP.Admin("UKnownNames"@PlayerListF[SelectedRow].PLID);
	else if ( Code==1 )
		PP.Admin("UKickID"@PlayerListF[SelectedRow].PLID);
	else if ( Code==2 )
		PP.Admin("UTempBanID"@PlayerListF[SelectedRow].PLID);
	else PP.Admin("UBanID"@PlayerListF[SelectedRow].PLID);
}

defaultproperties
{
	PlayerName="Player Name"
	PlayerID="ID#"
	PlayerIP="IP-Address"
	PlayerClientID="Client ID"
	MaxLengthExceeded="Maximum player list length exceeded '%i'"
	IDMismatchedStr="Response ID mismatched: %i/%j"
	ClientReceivedStr="Received client '%ls'."
	GettingInfoStr="Getting player list from server, if nothing happens you may not be logged in as admin."
}
