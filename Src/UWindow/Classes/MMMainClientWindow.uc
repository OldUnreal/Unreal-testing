//=============================================================================
// Music Menu MainClientWindow
//=============================================================================
class MMMainClientWindow extends UWindowClientWindow;

var MMControlsClient ClientControls;
var MMMusicListGrid Grid;
var MMMusicFilesGrid FGrid;
var MMMainWindow MainWin;
var bool bMusicFBrowsOpen;
var float UdpTimer;

const ControlHeight=108;

function Created()
{
	Super.Created();

	ClientControls = MMControlsClient(CreateWindow(class'MMControlsClient', 0, 0, WinWidth, ControlHeight));
	Grid = MMMusicListGrid(CreateWindow(class'MMMusicListGrid', 0, ControlHeight, WinWidth, WinHeight-ControlHeight));
	ClientControls.MMClient = Self;
	Grid.MMClient = Self;
}
function Resized()
{
	ClientControls.SetSize(WinWidth, ControlHeight);
	if ( bMusicFBrowsOpen )
	{
		Grid.SetSize(WinWidth, (WinHeight-ControlHeight)/2);
		FGrid.WinTop = Grid.WinHeight+ControlHeight;
		FGrid.SetSize(WinWidth, Grid.WinHeight);
	}
	else Grid.SetSize(WinWidth, WinHeight-ControlHeight);
}
function SetStatus( string Status )
{
	if ( MainWin!=None )
		MainWin.StatusBarText = Status;
}
final function string CalcPlayTimePrct()
{
	local int V;

	V = int(GetPlayerOwner().ConsoleCommand("GetMusicOffset"));
	return Clamp(float(V) / float(Grid.MusicLength) * 100.f, 0, 100) @ "%";
}
function Paint(Canvas C, float X, float Y)
{
	local PlayerPawn PP;

	PP = C.Viewport.Actor;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	if (UdpTimer < PP.Level.TimeSeconds || UdpTimer > PP.Level.TimeSeconds + 1)
	{
		UdpTimer = PP.Level.TimeSeconds + 0.1;

		if (ClientControls.bWaitingForMusic)
		{
			// Hack, GalaxyAudioSubsystem won't return valid values until music is running some time, wait and update.
			///log("Waiting for music to be ready...");
			ClientControls.UpdateMusicScroll();
			Grid.bIsStream  = (GetPlayerOwner().ConsoleCommand("GetMusicType")~="STREAM");
		}

		if (ClientControls.LastPlayedSong != none)
		{
			if (Grid.MusicLength > 0)
			{
				if (Grid.bIsStream)
					MainWin.WindowTitle = MainWin.default.WindowTitle @ "-" @
						ClientControls.LastPlayedSong.Name @ "(" $ TimeToStr(int(PP.ConsoleCommand("GetMusicOffset"))) $ ")";
				else
					MainWin.WindowTitle = MainWin.default.WindowTitle @ "-" @
						ClientControls.LastPlayedSong.Name @ "(" $ CalcPlayTimePrct() $ ")";
			}
			else if (Grid.MusicLength < 0) // Audio renderer return -1 if not having valid value.
			{
				Grid.MusicLength = int(GetPlayerOwner().ConsoleCommand("GetMusicLen"));
				MainWin.WindowTitle = MainWin.default.WindowTitle @ "-" @ ClientControls.LastPlayedSong.Name;
			}
			else
				MainWin.WindowTitle = MainWin.default.WindowTitle @ "-" @
					ClientControls.LastPlayedSong.Name @ "(" $ TimeToStr(Grid.CurrentPlayTime) $ ")";
		}
		else if (PP.Song != none)
			MainWin.WindowTitle = MainWin.default.WindowTitle @ "-" @ PP.Song.Name;
		else
			MainWin.WindowTitle = MainWin.default.WindowTitle;
	}
}
function NotifyAfterLevelChange()
{
	Super.NotifyAfterLevelChange();
	UdpTimer = 0.f;
}
final function string TimeToStr( int InTime )
{
	local int Mins;

	Mins = InTime/60;
	InTime-=(Mins*60);
	if( InTime<10 )
		return string(Mins)$":0"$string(InTime);
	return string(Mins)$":"$string(InTime);
}
function CopyPropertiesFrom( MMMainClientWindow Other )
{
	ClientControls.LastPlayedSong = Other.ClientControls.LastPlayedSong;
	ClientControls.LastSongSection = Other.ClientControls.LastSongSection;
}
function AddMusicFileBrw()
{
	if ( bMusicFBrowsOpen )
	{
		bMusicFBrowsOpen = False;
		FGrid.HideWindow();
		ParentWindow.SetSize(ParentWindow.WinWidth, ParentWindow.WinHeight-120);
		Return;
	}
	bMusicFBrowsOpen = True;
	if ( FGrid==None )
	{
		FGrid = MMMusicFilesGrid(CreateWindow(class'MMMusicFilesGrid', 0, 180, WinWidth, WinHeight/2-80));
		FGrid.MMClient = Self;
	}
	else FGrid.ShowWindow();
	ParentWindow.SetSize(ParentWindow.WinWidth, ParentWindow.WinHeight+120);
}

defaultproperties
{
}
