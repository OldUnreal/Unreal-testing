//=============================================================================
// Music Menu Music Files list Grid
//=============================================================================
class MMMusicFilesGrid extends UWindowGrid;

var UWindowGridColumn MainColomn;
var MMMainClientWindow MMClient;
var int ListCount,SelectedRow;
var array<string> MSList;
var() localized string ErrorLoadPackage,ErrorNoMusics;

function Created()
{
	Super.Created();

	RowHeight = 12;
	MainColomn = AddColumn(Class'MMMusicListGrid'.Default.MusicPackStr, WinWidth-LookAndFeel.Size_ScrollbarWidth);
	UpdateMusicList();
}

function Resized()
{
	Super.Resized();
	MainColomn.WinWidth = WinWidth-LookAndFeel.Size_ScrollbarWidth;
}

final function bool SortMusicList( string A, string B )
{
	return Caps(A) > Caps(B);
}

function UpdateMusicList()
{
	local string MN;
	local int i;

	Array_Size(MSList, 0);
	foreach AllFiles("umx", "", MN)
	{
		MN = Left(MN, Len(MN) - 4);
		if (!SearchMusicFileName(MN, i))
		{
			Array_Insert(MSList, i);
			MSList[i] = MN;
		}
	}
	ListCount = Array_Size(MSList);
	///SortArray(ArrayProperty'MSList',Function'SortMusicList');
}

function bool SearchMusicFileName(string FileName, out int Index)
{
	local int i, lower_bound, upper_bound;

	lower_bound = 0;
	upper_bound = Array_Size(MSList);
	FileName = Caps(FileName);

	while (lower_bound < upper_bound)
	{
		i = lower_bound + (upper_bound - lower_bound) / 2;
		if (Caps(MSList[i]) < FileName)
			lower_bound = i + 1;
		else if (FileName < Caps(MSList[i]))
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
			Column.ClipText( C, 2, Y + TopMargin, MSList[Current]);
			Y = Y + RowHeight;
		}
		Skipped++;
		Current++;
	}
}

function SelectRow(int Row)
{
	if ( ListCount<=Row )
		Row = ListCount-1;
	SelectedRow = Row;
}

function DoubleClickRow(int Row)
{
	local array<Object> ObjL;
	local int c,i;

	if ( Row!=SelectedRow )
		Return;
	if ( !LoadPackageContents(MSList[Row],Class'Music',ObjL) )
	{
		MMClient.SetStatus(ErrorLoadPackage);
		return;
	}
	c = Array_Size(ObjL);
	if ( c==0 )
	{
		MMClient.SetStatus(ErrorNoMusics);
		return;
	}
	for( i=0; i<c; ++i )
		MMClient.ClientControls.AddTrack(string(ObjL[i]));
}

function RightClickRow(int Row, float X, float Y);

defaultproperties
{
	ErrorLoadPackage="Error: Failed to load music package."
	ErrorNoMusics="Error: Failed to find any musics in this package."
}
