//=============================================================================
// Music Menu Music ListGrid
//=============================================================================
class MMMusListGrid extends UWindowGrid;

var MMMusClientWindow MMClient;

var UWindowGridColumn MusicName;

var int ListCount,SelectedRow;
var array<string> PackageSongs;

function Created()
{
	Super.Created();
	RowHeight = 12;
	MusicName = AddColumn(Class'MMMusicListGrid'.Default.MusicNameStr, WinWidth-LookAndFeel.Size_ScrollbarWidth);
}
function Resized()
{
	Super.Resized();
	MusicName.WinWidth = WinWidth-LookAndFeel.Size_ScrollbarWidth;
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
			if ( Column==MusicName )
				Column.ClipText( C, 2, Y + TopMargin, PackageSongs[Current] );

			Y = Y + RowHeight;
		}
		Skipped++;
		Current++;
	}
}

function SelectRow(int Row)
{
	SelectedRow = Clamp(Row,0,ListCount-1);
}

function DoubleClickRow(int Row)
{
	MMClient.MainWin.NotifyToWin.AddMusicEdit.SetValue(PackageSongs[Clamp(Row, 0, ListCount - 1)]);
	MMClient.MainWin.Close();
}

defaultproperties
{
	SelectedRow=-1
}
