class UMenuRecGrid extends UWindowGrid;

var UMenuRecPlay ParentHandle;

var UWindowGridColumn FileName;

var int ListCount,SelectedRow;
var array<string> Files;
var() localized string FileNameText;

function Created()
{
	Super.Created();
	RowHeight = 12;
	FileName = AddColumn(FileNameText, WinWidth-LookAndFeel.Size_ScrollbarWidth);
	UpdateDemoList();
}
function ShowWindow()
{
	Super.ShowWindow();
	UpdateDemoList();
}

function Resized()
{
	Super.Resized();
	FileName.WinWidth = WinWidth-LookAndFeel.Size_ScrollbarWidth;
}

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local float Y;
	local int Visible;
	local int Skipped;
	local int TopMargin;
	local int BottomMargin,Current;

	C.Font = Root.Fonts[F_Normal];

	if (bShowHorizSB)
		BottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);

	VertSB.SetRange(0, ListCount+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;

	while ( (Y<RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && Current<ListCount )
	{
		if ( Skipped >= VertSB.Pos )
		{
			// Draw highlight
			if ( Current==SelectedRow )
				Column.DrawStretchedTexture( C, 0, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'MenuHighlight');
			if ( Column==FileName )
				Column.ClipText( C, 2, Y + TopMargin, Files[Current] );

			Y = Y + RowHeight;
		}
		Skipped++;
		Current++;
	}
}
function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

function SelectRow(int Row)
{
	if( ListCount==0 )
		return;
	SelectedRow = Clamp(Row,0,ListCount-1);
	ParentHandle.SelectedFile = Files[SelectedRow];
}

function DoubleClickRow(int Row)
{
	ParentHandle.PlayDemo();
}

final function UpdateDemoList()
{
	local string S;
	local int i;

	Array_Size(Files,0);
	ListCount = 0;
	S = GetPlayerOwner().ConsoleCommand("DEMOLIST");
	while( Len(S)>0 )
	{
		S = Mid(S,1);
		i = InStr(S,"'");
		if( i==-1 )
			break;
		Files[ListCount++] = Left(S,i);
		S = Mid(S,i+1);
	}
}

defaultproperties
{
	SelectedRow=-1
	FileNameText="File name"
}