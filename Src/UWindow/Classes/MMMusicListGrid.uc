//=============================================================================
// Music Menu MusicListGrid
//=============================================================================
class MMMusicListGrid extends UWindowGrid
	Config(User);

var MMMainClientWindow MMClient;
var MMListPullDown PullDown;

var UWindowGridColumn MusicPackage,MusicName;
var() localized string
	MusicNameStr,
	MusicPackStr,
	FailedToPlayStr,
	StartedPlayStr,
	NullErrorStr,
	FailedLoadStr,
	ConfirmInsertDuplicateTitle,
	ConfirmInsertDuplicateText,
	AddedStr,
	RemoveSongStr,
	ClearListStr,
	AddAllStr,
	ConfirmClearListTitle,
	ConfirmClearListText,
	BadIndexStr;

var int ListCount, SelectedRow;
var() globalconfig array<string> SavedMusics;
var() globalconfig int MusicPlayTime;
var() globalconfig bool bShuffleMusic;
struct MMTextLineType
{
	var string SongPackage, SongName;
};
var array<int> RandPlayList;
var int RandPlayOffset;

var array<MMTextLineType> LoadedMusicList;
var int CurrentTrackIndex, CurrentPlayTime, MusicLength;
var bool bIsStream;
var UWindowMessageBox InsertDuplicatePrompt;
var UWindowMessageBox ClearListPrompt;
var int DraggingTrack;
var Music DuplicatedMusic;

function MusicTimer()
{
	if (MMClient.ClientControls.LastPlayedSong == none)
		return;
	CurrentPlayTime++;
	if (MusicPlayTime > 0 && CurrentPlayTime >= MusicPlayTime)
		PlayNextTrack();
}
function Created()
{
	Super.Created();

	RowHeight = 12;
	CreateColumns();
	InitMusicList();
	PullDown = MMListPullDown(Root.CreateWindow(class'MMListPullDown', 0, 0, 100, 100));
	PullDown.HideWindow();
	PullDown.NotifyWin = Self;
	Root.Console.MusicMenuTimer = Self;
	SelectedRow = -1;
	CurrentTrackIndex = -1;
	DraggingTrack = -1;
}

function CreateColumns()
{
	MusicPackage	= AddColumn(MusicPackStr, WinWidth/2);
	MusicName		= AddColumn(MusicNameStr, WinWidth/2-LookAndFeel.Size_ScrollbarWidth);
}

function Resized()
{
	Super.Resized();
	MusicName.WinWidth = WinWidth-MusicPackage.WinWidth-LookAndFeel.Size_ScrollbarWidth;
}

function InitMusicList()
{
	local int i;

	ListCount = Array_Size(SavedMusics);
	Array_Size(LoadedMusicList, ListCount);
	for (i = 0; i < ListCount; ++i)
		if (!Divide(SavedMusics[i], ".", LoadedMusicList[i].SongPackage, LoadedMusicList[i].SongName))
		{
			LoadedMusicList[i].SongPackage = SavedMusics[i];
			LoadedMusicList[i].SongName = SavedMusics[i];
		}
}

function UpdateMusicList()
{
	local int i;

	ListCount = LoadedMusicList.Size();
	SavedMusics.SetSize(ListCount);
	for (i = 0; i < ListCount; ++i)
	{
		if (LoadedMusicList[i].SongPackage ~= LoadedMusicList[i].SongName)
			SavedMusics[i] = LoadedMusicList[i].SongPackage;
		else
			SavedMusics[i] = LoadedMusicList[i].SongPackage $ "." $ LoadedMusicList[i].SongName;
	}
	SaveConfig();
}

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local float Y;
	local int Visible;
	local int Skipped;
	local int TopMargin;
	local int BottomMargin, i;
	local Color MainDrawColor;

	MainDrawColor = C.DrawColor;
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

	while ( (Y<RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && i < ListCount )
	{
		C.DrawColor = MainDrawColor;
		if (Skipped >= VertSB.Pos)
		{
			// Draw highlight
			if (i == SelectedRow)
				Column.DrawStretchedTexture( C, 0, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'MenuHighlight');

			if (i == CurrentTrackIndex)
			{
				C.DrawColor.R = 0;
				C.DrawColor.B = 0;
			}

			switch (Column)
			{
			case MusicPackage:
				Column.ClipText( C, 2, Y + TopMargin, LoadedMusicList[i].SongPackage );
				break;
			case MusicName:
				Column.ClipText( C, 2, Y + TopMargin, LoadedMusicList[i].SongName );
				break;
			}

			Y = Y + RowHeight;
		}
		++Skipped;
		++i;
	}
	C.DrawColor = MainDrawColor;
}

function SelectRow(int Row)
{
	if (Row >= ListCount)
		Row = -1;
	SelectedRow = Row;
}

final function StartRandomSong()
{
	local int i,c;

	if( ListCount==0 )
		return;
	if( ListCount==1 )
		DoubleClickRow(0);
	else
	{
		i = Rand(ListCount);
		while( i==SelectedRow && ++c<10 )
			i = Rand(ListCount);
		SelectedRow = i;
		DoubleClickRow(i);
	}
}
function DoubleClickRow(int Row)
{
	PlayTrack(Row);
}

private function int PickUnlistedTrack()
{
	local int i,c;

	while( ++c<16 )
	{
		i = Rand(ListCount);
		if( RandPlayList.Find(i)==-1 )
			return i;
	}
	return i;
}
final function int GetRandomTrack( int Dir )
{
	local int MaxListSize,i;
	
	// Special cases for small playlists.
	if( ListCount<=1 )
		return 0;
	if( ListCount==2 )
		return (CurrentTrackIndex==0) ? 1 : 0;

	MaxListSize = (ListCount>>1);
	RandPlayOffset+=Dir;
	
	if( RandPlayOffset<0 )
	{
		RandPlayOffset = 0;
		RandPlayList.Insert(0);
		i = PickUnlistedTrack();
		RandPlayList[0] = i;
		if( RandPlayList.Size()>MaxListSize )
			RandPlayList.SetSize(MaxListSize);
	}
	else if( RandPlayOffset>=RandPlayList.Size() )
	{
		if( RandPlayList.Size()>=MaxListSize )
			RandPlayList.Remove(0, (RandPlayList.Size()-MaxListSize+1));
		i = PickUnlistedTrack();
		RandPlayList.Add(i);
		RandPlayOffset = RandPlayList.Size()-1;
	}
	else i = RandPlayList[RandPlayOffset];
	
	if( RandPlayList.Size()>MaxListSize )
		RandPlayList.SetSize(MaxListSize);
	return i;
}

final function PlayNextTrack()
{
	if (ListCount == 0)
		return;
	if( bShuffleMusic )
		CurrentTrackIndex = GetRandomTrack(1);
	else if (CurrentTrackIndex>=0 && CurrentTrackIndex < (ListCount - 1))
		CurrentTrackIndex++;
	else CurrentTrackIndex = 0;

	ScrollToRow(CurrentTrackIndex);
	PlayTrack(CurrentTrackIndex);
}
final function PlayPrevTrack()
{
	if (ListCount == 0)
		return;
	if( bShuffleMusic )
		CurrentTrackIndex = GetRandomTrack(-1);
	else if (HasCurrentTrack())
	{
		if (--CurrentTrackIndex < 0)
			CurrentTrackIndex = ListCount - 1;
	}
	else CurrentTrackIndex = 0;

	ScrollToRow(CurrentTrackIndex);
	PlayTrack(CurrentTrackIndex);
}
final function PlayTrack( int Index )
{
	MMClient.ClientControls.PlayTrack(Index, true);
}

function RightClickRow(int Row, float X, float Y)
{
	if (Row >= ListCount)
		Row = -1;
	SelectedRow = Row;
	PullDown.WinLeft = Root.MouseX;
	PullDown.WinTop = Root.MouseY;
	PullDown.ShowWindow();
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (W == InsertDuplicatePrompt)
	{
		InsertDuplicatePrompt = none;
		if (Result == MR_Yes)
			InsertMusic(DuplicatedMusic);
	}
	else if (W == ClearListPrompt)
	{
		ClearListPrompt = none;
		if (Result == MR_Yes)
			ClearList();
	}
}

function AddSong(string SngName)
{
	local Music MusicObject;

	if (SngName ~= "None" || Len(SngName) == 0)
	{
		MMClient.SetStatus(NullErrorStr);
		return;
	}
	if (InStr(SngName, ".") == -1)
		SngName = SngName $ "." $ SngName;

	MusicObject = Music(DynamicLoadObject(SngName, Class'Music', true));
	if (MusicObject == none)
	{
		MMClient.SetStatus(ReplaceStr(FailedLoadStr, "%ls", SngName));
		return;
	}

	if (IsInTrackList(SngName))
	{
		DuplicatedMusic = MusicObject;
		InsertDuplicatePrompt = MessageBox(ConfirmInsertDuplicateTitle, ConfirmInsertDuplicateText, MB_YesNo, MR_No, MR_None, 10);
	}
	else
		InsertMusic(MusicObject);
}

function InsertMusic(Music MusicObject)
{
	local Object OuterMusicObject;
	local int Index;

	OuterMusicObject = MusicObject.Outer;
	while (OuterMusicObject.Outer != none)
		OuterMusicObject = OuterMusicObject.Outer;

	if (HasSelectedRow())
	{
		Index = SelectedRow;
		if (SelectedRow <= CurrentTrackIndex)
			CurrentTrackIndex++;
	}
	else
	{
		Index = ListCount;
		SelectedRow = -1;
	}

	RandPlayList.Empty();
	LoadedMusicList.Insert(Index);
	LoadedMusicList[Index].SongName = string(MusicObject.Name);
	LoadedMusicList[Index].SongPackage = string(OuterMusicObject.Name);

	if ((CurrentTrackIndex < 0 || CurrentTrackIndex >= ListCount) &&
		MMClient.ClientControls.LastPlayedSong != none &&
		MMClient.ClientControls.LastPlayedSong == MusicObject)
	{
		CurrentTrackIndex = Index;
	}

	MMClient.SetStatus(ReplaceStr(ReplaceStr(AddedStr, "%ls", string(MusicObject)), "%i", string(Index + 1)));
	UpdateMusicList();
	VertSB.SetRange(0, ListCount + 1, VertSB.MaxVisible);
	ScrollToRow(Index);
}

function RemoveSong(int RowNum)
{
	if (RowNum < 0 || RowNum >= ListCount)
	{
		MMClient.SetStatus(BadIndexStr);
		return;
	}
	RandPlayList.Empty();
	LoadedMusicList.Remove(RowNum);
	UpdateMusicList();
	MMClient.SetStatus(ReplaceStr(RemoveSongStr, "%i", string(RowNum)));
	SelectedRow = -1;
	if (RowNum == CurrentTrackIndex)
		CurrentTrackIndex = -1;
	else if (RowNum < CurrentTrackIndex)
		CurrentTrackIndex--;
}

function ClearTrackList()
{
	ClearListPrompt = MessageBox(ConfirmClearListTitle, ConfirmClearListText, MB_YesNo, MR_No, MR_None, 10);
}

function ClearList()
{
	RandPlayList.Empty();
	LoadedMusicList.Empty();
	UpdateMusicList();
	MMClient.SetStatus(ClearListStr);
	SelectedRow = -1;
	CurrentTrackIndex = -1;
}

function bool IsInTrackList(string TrackName)
{
	local int i;

	if (InStr(TrackName, ".") < 0)
		TrackName = TrackName $ "." $ TrackName;
	for (i = 0; i < ListCount; ++i)
		if (TrackName ~= (LoadedMusicList[i].SongPackage $ "." $ LoadedMusicList[i].SongName))
			return true;
	return false;
}

function bool HasSelectedRow()
{
	return 0 <= SelectedRow && SelectedRow < ListCount;
}

function bool HasCurrentTrack()
{
	return 0 <= CurrentTrackIndex && CurrentTrackIndex < ListCount;
}

function LeftClickRowDown(int Row, float X, float Y)
{
	SelectRow(Row);
	if (0 <= Row && Row < ListCount)
		DraggingTrack = Row;
}

function LeftClickRow(int Row, float X, float Y)
{
	DraggingTrack = -1;
}

function MouseMoveRow(int Row, float X, float Y, bool bMouseDown)
{
	local MMTextLineType TrackInfo;

	if (!bMouseDown || DraggingTrack < 0 || DraggingTrack >= ListCount || DraggingTrack == Row)
		return;
	RandPlayList.Empty();
	Row = Clamp(Row, 0, ListCount - 1);
	TrackInfo = LoadedMusicList[DraggingTrack];
	if (Row < DraggingTrack)
	{
		LoadedMusicList.Remove(DraggingTrack);
		LoadedMusicList.Insert(Row);
		LoadedMusicList[Row] = TrackInfo;

		if (CurrentTrackIndex == DraggingTrack)
			CurrentTrackIndex = Row;
		else if (Row <= CurrentTrackIndex && CurrentTrackIndex < DraggingTrack)
			CurrentTrackIndex++;
	}
	else
	{
		LoadedMusicList.Insert(Row + 1);
		LoadedMusicList[Row + 1] = TrackInfo;
		LoadedMusicList.Remove(DraggingTrack);

		if (CurrentTrackIndex == DraggingTrack)
			CurrentTrackIndex = Row;
		else if (DraggingTrack < CurrentTrackIndex && CurrentTrackIndex <= Row)
			CurrentTrackIndex--;
	}
	DraggingTrack = Row;
	SelectedRow = Row;
	UpdateMusicList();
}

function ScrollToRow(int Row)
{
	if (DraggingTrack >= 0)
		return;
	if (Row < ListCount - 1)
		VertSB.Show(Row);
	else
		VertSB.Scroll(ListCount);
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if ( PullDown!=None )
		PullDown.Close();
}

final function bool SongInOrder( Music A, Music B )
{
	return Caps(A)>Caps(B);
}

function FullListSongs()
{
	local string MN;
	local Music M;
	local Object Obj;
	local array<Music> AddedList;
	local array<Object> ObjL;
	local int i,j;
	
	RandPlayList.Empty();
	LoadedMusicList.Empty();
	CurrentTrackIndex = -1;
	
	foreach AllFiles("umx", "", MN)
	{
		if ( LoadPackageContents(MN,Class'Music',ObjL) )
		{
			for( i=(ObjL.Size()-1); i>=0; --i )
			{
				M = Music(ObjL[i]);
				if( M )
					AddedList.AddUnique(M);
			}
		}
	}
	
	AddedList.Sort(SongInOrder);
	foreach AddedList(M)
	{
		Obj = M;
		while( Obj.Outer )
			Obj = Obj.Outer;
		
		LoadedMusicList[j].SongName = string(M.Name);
		LoadedMusicList[j].SongPackage = string(Obj.Name);
		if( MMClient.ClientControls.LastPlayedSong && MMClient.ClientControls.LastPlayedSong==M )
			CurrentTrackIndex = j;
		++j;
	}
	
	UpdateMusicList();
	MMClient.SetStatus(AddAllStr);
	SelectedRow = -1;
}

defaultproperties
{
	MusicNameStr="Music name"
	MusicPackStr="Music package"
	FailedToPlayStr="Failed to play: Music '%ls' was not found or failed to load."
	StartedPlayStr="Started playing music '%ls' with section %i."
	NullErrorStr="Failed to add: NULL is not a valid song."
	FailedLoadStr="Failed to add: Music '%ls' file could not be found or loaded."
	ConfirmInsertDuplicateTitle="Adding an already listed track"
	ConfirmInsertDuplicateText="Such a track is already included in the playlist. Insert it anyway?"
	AddedStr="Added music '%ls' (%i)."
	AddAllStr="Added all musics to the list."
	RemoveSongStr="Removed song #%i."
	ClearListStr="Removed all tracks from the list."
	ConfirmClearListTitle="Confirm clearing the playlist"
	ConfirmClearListText="Do you want to clear the playlist?"
	BadIndexStr="Failed to remove: Bad remove index."
	SavedMusics=("Isotoxin","K_Vision")
}
