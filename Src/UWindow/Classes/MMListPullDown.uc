//=============================================================================
// Music Menu ListPullDown.
//=============================================================================
class MMListPullDown expands UWindowPulldownMenu;

var UWindowPulldownMenuItem PlaySongP, RemoveSongP, InsertCurrentSongP, ClearListP;
var MMMusicListGrid NotifyWin;

var() localized string PlaySongStr, RemoveSongStr, InsertCurrentSongStr, ClearPlaylistStr;

function Created()
{
	bTransient = true;
	Super.Created();
	PlaySongP = AddMenuItem(PlaySongStr, none);
	RemoveSongP = AddMenuItem(RemoveSongStr, none);
	AddMenuItem("-", none);
	InsertCurrentSongP = AddMenuItem(InsertCurrentSongStr, none);
	AddMenuItem("-", none);
	ClearListP = AddMenuItem(ClearPlaylistStr, none);
}

function WindowShown()
{
	local bool bHasSelectedItem;

	super.WindowShown();

	bHasSelectedItem = NotifyWin.HasSelectedRow();

	PlaySongP.bDisabled = !bHasSelectedItem;
	RemoveSongP.bDisabled = !bHasSelectedItem;
	InsertCurrentSongP.bDisabled = NotifyWin.GetPlayerOwner().Song == none;
	ClearListP.bDisabled = NotifyWin.ListCount == 0;
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case PlaySongP:
		NotifyWin.DoubleClickRow(NotifyWin.SelectedRow);
		break;
	case RemoveSongP:
		NotifyWin.RemoveSong(NotifyWin.SelectedRow);
		break;
	case InsertCurrentSongP:
		NotifyWin.AddSong(string(NotifyWin.GetPlayerOwner().Song));
		break;
	case ClearListP:
		NotifyWin.ClearTrackList();
		break;
	}

	Super.ExecuteItem(I);
}

function CloseUp()
{
	HideWindow();
}

defaultproperties
{
	PlaySongStr="&Play"
	RemoveSongStr="&Remove from playlist"
	InsertCurrentSongStr="&Insert currently playing track"
	ClearPlaylistStr="&Clear playlist"
	bLeaveOnscreen=True
	bQuiet=True
}
