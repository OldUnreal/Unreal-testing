//=============================================================================
// MusicMenu MusicList Window - New menu in U227
//=============================================================================
class MMMusListWindow extends UWindowFramedWindow;

var MMMusClientWindow ClientW;
var MMControlsClient NotifyToWin;

function Created()
{
	Super.Created();
	ClientW = MMMusClientWindow(ClientArea);
	MMMusClientWindow(ClientArea).MainWin = Self;
}
function AddSongToList( string MusName )
{
	ClientW.Grid.PackageSongs[ClientW.Grid.ListCount++] = MusName;
}
function EmptySongList()
{
	if ( ClientW.Grid.ListCount==0 )
		return;
	Array_Size(ClientW.Grid.PackageSongs,0);
	ClientW.Grid.ListCount = 0;
	ClientW.Grid.SelectedRow = -1;
}

defaultproperties
{
	ClientClass=Class'MMMusClientWindow'
	WindowTitle="Multiple musics found:"
	bTransient=False
	bLeaveOnscreen=True
	bSizable=false
	bStatusBar=false
	MinWinWidth=300
	MinWinHeight=120
}
