//=============================================================================
// MMControlsClient.
//=============================================================================
class MMControlsClient expands UWindowDialogClientWindow;

#exec TEXTURE IMPORT NAME=MultimediaButtons FILE=Textures\MultimediaButtons.pcx FLAGS=2 GROUP="Icons" MIPS=0

var MMMainClientWindow MMClient;

var MOffsetScrollbar MusicOffsetScroll;
var UWindowMultimediaButton PlayButton, StopButton, PriorButton, NextButton;
var UWindowHSliderControl MusicVolumeSlider;
var UWindowSmallButton AddMusicButton, BrowseButton, AddAllButton;
var UWindowEditControl AddMusicEdit, SectionEdit, TimeLimitEdit;
var UWindowCheckbox MusicShuffleCBox;

var float MinButtonWidth;

var Music LastPlayedSong;
var byte LastSongSection;
var bool bWaitingForMusic;

var() localized string
	MusicVolumeText,
	BrowseText,
	BrowseHint,
	AddAllText,
	AddAllHint,
	AddAllWinHdr,
	AddAllWarningText,
	AddMusicText,
	AddMusicHint,
	TimeLimitText,
	TimeLimitHint,
	SectionText,
	SectionHint,
	MusicStoppedText,
	PlayTrackHint,
	StopTrackHint,
	PriorTrackHint,
	NextTrackHint,
	ShuffleText,
	ShuffleHint;

const ControlHSpacing = 6;
const ControlVSpacing = 6;
const MaxPlayableMusicSection = 254; // 255 corresponds to silence

function WindowShown()
{
	Super.WindowShown();
	if( MusicVolumeSlider!=None )
		MusicVolumeSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume")));
}
function Created()
{
	local float ControlDistY, ButtonDistY;
	local float MultimediaButtonWidth;
	local float ControlOffsetX, ControlOffsetY;
	local float SliderWidth, PlaybackEditBoxWidth;

	Super.Created();

	ControlDistY = 18;
	ButtonDistY = 20;
	MinButtonWidth = 68;
	MultimediaButtonWidth = 16;
	SliderWidth = 100;
	PlaybackEditBoxWidth = 30;

	ControlOffsetY = ControlVSpacing;

	// Scroller
	MusicOffsetScroll = MOffsetScrollbar(CreateWindow(class'MOffsetScrollbar', ControlHSpacing, ControlVSpacing, WinWidth - ControlHSpacing * 2, 12));
	MusicOffsetScroll.Controller = Self;
	UpdateMusicScroll();

	ControlOffsetX = ControlHSpacing;
	ControlOffsetY += ControlDistY;

	// Multimedia buttons
	PlayButton = UWindowMultimediaButton(CreateWindow(class'UWindowMultimediaButton', ControlHSpacing, ControlOffsetY, MultimediaButtonWidth * 2, 16));
	PlayButton.UpTexture = Texture'UWindow.Icons.MultimediaButtons';
	PlayButton.Register(self);
	PlayButton.SetHelpText(PlayTrackHint);
	ControlOffsetX += MultimediaButtonWidth * 2 + 2;

	StopButton = UWindowMultimediaButton(CreateWindow(class'UWindowMultimediaButton', ControlOffsetX, ControlOffsetY, MultimediaButtonWidth, 16));
	StopButton.UpTexture = Texture'UWindow.Icons.MultimediaButtons';
	StopButton.MultimediaButtonIdx = 1;
	StopButton.Register(self);
	StopButton.SetHelpText(StopTrackHint);
	ControlOffsetX += MultimediaButtonWidth + 2;

	PriorButton = UWindowMultimediaButton(CreateWindow(class'UWindowMultimediaButton', ControlOffsetX, ControlOffsetY, MultimediaButtonWidth, 16));
	PriorButton.UpTexture = Texture'UWindow.Icons.MultimediaButtons';
	PriorButton.MultimediaButtonIdx = 2;
	PriorButton.Register(self);
	PriorButton.SetHelpText(PriorTrackHint);
	ControlOffsetX += MultimediaButtonWidth + 2;

	NextButton = UWindowMultimediaButton(CreateWindow(class'UWindowMultimediaButton', ControlOffsetX, ControlOffsetY, MultimediaButtonWidth, 16));
	NextButton.UpTexture = Texture'UWindow.Icons.MultimediaButtons';
	NextButton.MultimediaButtonIdx = 3;
	NextButton.Register(self);
	NextButton.SetHelpText(NextTrackHint);

	// Music Volume
	MusicVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', WinWidth - SliderWidth, ControlOffsetY, 180, 1));
	MusicVolumeSlider.SetRange(0, 255, 4);
	MusicVolumeSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume")));
	MusicVolumeSlider.SetText(MusicVolumeText);
	MusicVolumeSlider.SetFont(F_Normal);
	MusicVolumeSlider.SliderWidth = SliderWidth;
	MusicVolumeSlider.Register(self);

	// Music Section
	ControlOffsetY += ButtonDistY;
	SectionEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', WinWidth - PlaybackEditBoxWidth - ControlHSpacing, ControlOffsetY, PlaybackEditBoxWidth, 10));
	SectionEdit.EditBoxWidth = SectionEdit.WinWidth;
	SectionEdit.SetFont(F_Normal);
	SectionEdit.SetNumericOnly(true);
	SectionEdit.SetMaxLength(3);
	SectionEdit.SetHistory(False);
	SectionEdit.SetText(SectionText);
	SectionEdit.SetHelpText(SectionHint);
	SectionEdit.SetValue("0");

	// Time Limit
	ControlOffsetY += ButtonDistY;
	TimeLimitEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', WinWidth - PlaybackEditBoxWidth - ControlHSpacing, ControlOffsetY, PlaybackEditBoxWidth, 10));
	TimeLimitEdit.EditBoxWidth = TimeLimitEdit.WinWidth;
	TimeLimitEdit.SetFont(F_Normal);
	TimeLimitEdit.SetNumericOnly(true);
	TimeLimitEdit.SetMaxLength(5);
	TimeLimitEdit.SetHistory(false);
	TimeLimitEdit.SetText(TimeLimitText);
	TimeLimitEdit.SetHelpText(TimeLimitHint);
	TimeLimitEdit.SetValue(string(Class'MMMusicListGrid'.default.MusicPlayTime/60));

	ControlOffsetX = ControlHSpacing;
	ControlOffsetY = WinHeight - ControlVSpacing - 16;

	// Adding Music
	AddMusicButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', ControlOffsetX, ControlOffsetY, MinButtonWidth, 16));
	AddMusicButton.SetText(AddMusicText);
	AddMusicButton.SetHelpText(AddMusicHint);
	AddMusicButton.Register(self);

	ControlOffsetX += MinButtonWidth + ControlHSpacing;
	AddMusicEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlOffsetX, ControlOffsetY, WinWidth - ControlOffsetX - ControlHSpacing, 10));
	AddMusicEdit.EditBoxWidth = AddMusicEdit.WinWidth;
	AddMusicEdit.SetFont(F_Normal);
	AddMusicEdit.SetHelpText(AddMusicHint);
	AddMusicEdit.SetNumericOnly(False);
	AddMusicEdit.SetMaxLength(150);
	AddMusicEdit.SetHistory(True);

	ControlOffsetX = ControlHSpacing;
	ControlOffsetY -= ButtonDistY;

	BrowseButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', ControlOffsetX, ControlOffsetY, MinButtonWidth, 16));
	BrowseButton.SetText(BrowseText);
	BrowseButton.SetHelpText(BrowseHint);
	BrowseButton.Register(self);
	
	ControlOffsetX += MinButtonWidth + ControlHSpacing;
	
	AddAllButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', ControlOffsetX, ControlOffsetY, MinButtonWidth, 16));
	AddAllButton.SetText(AddAllText);
	AddAllButton.SetHelpText(AddAllHint);
	AddAllButton.Register(self);
	
	ControlOffsetX = ControlHSpacing;
	ControlOffsetY -= ButtonDistY;
	
	// Shuffle music
	MusicShuffleCBox = UWindowCheckbox(CreateWindow(class'UWindowCheckbox', ControlOffsetX, ControlOffsetY, 16, 16));
	MusicShuffleCBox.bChecked = class'MMMusicListGrid'.Default.bShuffleMusic;
	MusicShuffleCBox.NotifyWindow = Self;
	MusicShuffleCBox.SetText(ShuffleText);
	MusicShuffleCBox.Align = TA_Right;
	MusicShuffleCBox.SetHelpText(ShuffleHint);
}

function BeforePaint(Canvas C, float X, float Y)
{
	MusicOffsetScroll.SetSize(WinWidth - ControlHSpacing * 2, 12);

	MusicVolumeSlider.AutoWidth(C);
	MusicVolumeSlider.WinLeft = WinWidth - MusicVolumeSlider.WinWidth - ControlHSpacing;

	SectionEdit.AutoWidth(C);
	SectionEdit.WinLeft = WinWidth - SectionEdit.WinWidth - ControlHSpacing;

	TimeLimitEdit.AutoWidth(C);
	TimeLimitEdit.WinLeft = WinWidth - TimeLimitEdit.WinWidth - ControlHSpacing;

	AddMusicButton.AutoWidthBy(C, MinButtonWidth);
	BrowseButton.AutoWidthBy(C, MinButtonWidth);
	AddAllButton.AutoWidthBy(C, MinButtonWidth);

	AddMusicEdit.WinLeft = 2 * ControlHSpacing + AddMusicButton.WinWidth;
	AddMusicEdit.SetSize(WinWidth - AddMusicButton.WinWidth - 3 * ControlHSpacing, 1);
	AddMusicEdit.EditBoxWidth = AddMusicEdit.WinWidth;
	
	MusicShuffleCBox.AutoWidth(C);
}

final function UpdateMusicScroll()
{
	local float R;

	MusicOffsetScroll.bDisabled = (LastPlayedSong == none);
	if( !MusicOffsetScroll.bDisabled )
	{
		R = float(GetPlayerOwner().ConsoleCommand("GetMusicLen"));
		if (R == -1.f) // Waiting for Music to be started.
		{
			bWaitingForMusic = true;
			return;
		}
		else if( R>0 )
			MusicOffsetScroll.SetRange(0,R*1.05f,R*0.05f,0.f);
		else
			MusicOffsetScroll.bDisabled = true;

		bWaitingForMusic = false;
	}
	if( MusicOffsetScroll.bDisabled )
		MusicOffsetScroll.SetRange(0,0.f,0.f,0.f);
}
final function ChangeMusicOffset( int Result )
{
	GetPlayerOwner().ConsoleCommand("SetMusicOffset"@Result);
}
function Notify(UWindowDialogControl C, byte E)
{
	super.Notify(C, E);
	if (E == DE_Click)
	{
		switch(C)
		{
			case PlayButton:
				if (MMClient.Grid.HasSelectedRow())
					PlayTrack(MMClient.Grid.SelectedRow, false);
				else
					RestartCurrentTrack();
				break;
			case StopButton:
				StopMusic();
				break;
			case PriorButton:
				MMClient.Grid.PlayPrevTrack();
				break;
			case NextButton:
				MMClient.Grid.PlayNextTrack();
				break;
			case BrowseButton:
				MMClient.AddMusicFileBrw();
				break;
			case AddMusicButton:
				AddTrack(AddMusicEdit.GetValue());
				break;
			case AddAllButton:
				MessageBox(AddAllWinHdr, AddAllWarningText, MB_OKCancel, MR_No);
				break;
		}
	}
	else if (E == DE_RClick)
	{
		switch(C)
		{
			case PlayButton:
				RestartCurrentTrack();
				break;
			case StopButton:
				SilenceCurrentTrack();
				break;
			case PriorButton:
				if (SelectPriorMusicSection())
					RestartCurrentTrack();
				break;
			case NextButton:
				if (SelectNextMusicSection())
					RestartCurrentTrack();
				break;
		}
	}
	else if (E == DE_MouseMove)
	{
		if (Root != none)
			Root.SetContextHelp(C.HelpText);
	}
	else if (E == DE_MouseLeave)
	{
		if (Root != none)
			Root.SetContextHelp("");
	}
	else if (E == DE_Change && C == MusicVolumeSlider)
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$MusicVolumeSlider.Value);
	else if( C==MusicShuffleCBox )
	{
		MMClient.Grid.bShuffleMusic = MusicShuffleCBox.bChecked;
		MMClient.Grid.SaveConfig();
	}
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if( Result==MR_OK )
		MMClient.Grid.FullListSongs();
}

function AddTrack(string MName)
{
	MMClient.Grid.AddSong(MName);
}

function PlayTrack(int Index, bool bResetSection)
{
	local int TimeLimit;
	local Music MusicObject;
	local int MusicSection;
	local string MusicName;

	if (Index < 0 || Index >= MMClient.Grid.ListCount)
		return;

	TimeLimit = int(TimeLimitEdit.GetValue());
	if (TimeLimit < 0 || TimeLimit > MaxInt / 60)
	{
		TimeLimit = 0;
		TimeLimitEdit.SetValue("0");
	}
	else
		TimeLimit *= 60;
	if (TimeLimit != MMClient.Grid.MusicPlayTime)
	{
		MMClient.Grid.MusicPlayTime = TimeLimit;
		MMClient.Grid.SaveConfig();
	}

	MusicName = MMClient.Grid.LoadedMusicList[Index].SongPackage $ "." $ MMClient.Grid.LoadedMusicList[Index].SongName;
	MusicObject = Music(DynamicLoadObject(MusicName, Class'Music'));
	if (MusicObject == none)
		MMClient.SetStatus(ReplaceStr(MMClient.Grid.FailedToPlayStr, "%ls", MusicName));
	else
	{
		if (bResetSection)
			SectionEdit.SetValue("0");
		MusicSection = Clamp(int(SectionEdit.GetValue()), 0, 254);
		LastPlayedSong = MusicObject;
		LastSongSection = MusicSection;
		GetPlayerOwner().bIgnoreMusicChange = false;
		GetPlayerOwner().ClientSetMusic(MusicObject, MusicSection, 255, MTRAN_Instant);
		GetPlayerOwner().bIgnoreMusicChange = true;
		MMClient.Grid.MusicLength = int(GetPlayerOwner().ConsoleCommand("GetMusicLen"));
		MMClient.Grid.bIsStream = (GetPlayerOwner().ConsoleCommand("GetMusicType") ~= "STREAM");
		MMClient.SetStatus(ReplaceStr(ReplaceStr(MMClient.Grid.StartedPlayStr, "%ls", string(MusicObject)), "%i", string(MusicSection)));
		MMClient.Grid.CurrentTrackIndex = Index;
		MMClient.Grid.CurrentPlayTime = 0;
		UpdateMusicScroll();
	}
}

function RestartCurrentTrack()
{
	if (LastPlayedSong != none)
	{
		LastSongSection = Clamp(int(SectionEdit.GetValue()), 0, 254);
		GetPlayerOwner().bIgnoreMusicChange = false;
		GetPlayerOwner().ClientSetMusic(LastPlayedSong, LastSongSection, 255, MTRAN_Instant);
		GetPlayerOwner().bIgnoreMusicChange = true;
		MMClient.SetStatus(ReplaceStr(ReplaceStr(MMClient.Grid.StartedPlayStr, "%ls", string(LastPlayedSong)), "%i", string(LastSongSection)));
		MMClient.Grid.CurrentPlayTime = 0;
		UpdateMusicScroll();
	}
	else if (GetPlayerOwner().Song != none)
		GetPlayerOwner().ClientSetMusic(
			GetPlayerOwner().Song,
			Clamp(int(SectionEdit.GetValue()), 0, 254),
			255,
			MTRAN_Instant);
}

function StopMusic()
{
	LastPlayedSong = none;
	GetPlayerOwner().bIgnoreMusicChange = false;
	GetPlayerOwner().ClientSetMusic(none, 0, 255, MTRAN_Instant);
	MMClient.SetStatus(MusicStoppedText);
	UpdateMusicScroll();
	MMClient.Grid.CurrentTrackIndex = -1;
}

function SilenceCurrentTrack()
{
	LastSongSection = 255;
	GetPlayerOwner().bIgnoreMusicChange = false;
	GetPlayerOwner().ClientSetMusic(GetPlayerOwner().Song, LastSongSection, 255, MTRAN_Instant);
	if (LastPlayedSong != none)
		GetPlayerOwner().bIgnoreMusicChange = true;
	MMClient.SetStatus(MusicStoppedText);
	UpdateMusicScroll();
}

function bool SelectPriorMusicSection()
{
	local int MusicSection;

	MusicSection = Clamp(int(SectionEdit.GetValue()), 0, MaxPlayableMusicSection + 1);
	if (MusicSection > 0)
	{
		SectionEdit.SetValue(string(--MusicSection));
		return true;
	}
	SectionEdit.SetValue(string(MusicSection));
	return false;
}

function bool SelectNextMusicSection()
{
	local int MusicSection;

	MusicSection = Clamp(int(SectionEdit.GetValue()), 0, MaxPlayableMusicSection);
	if (MusicSection < MaxPlayableMusicSection)
	{
		SectionEdit.SetValue(string(++MusicSection));
		return true;
	}
	SectionEdit.SetValue(string(MusicSection));
	return false;
}

function NotifyAfterLevelChange()
{
	Super.NotifyAfterLevelChange();
	if ( LastPlayedSong!=None )
	{
		GetPlayerOwner().ClientSetMusic(LastPlayedSong, LastSongSection, 255, MTRAN_FastFade);
		GetPlayerOwner().bIgnoreMusicChange = True;
		UpdateMusicScroll();
	}
}

defaultproperties
{
	MusicVolumeText="Music Volume"
	BrowseText="Browse"
	BrowseHint="Browse music files"
	AddMusicText="Add Music"
	AddMusicHint="Add music with the specified name"
	TimeLimitText="Time Limit"
	TimeLimitHint="Select music playtime in minutes (0 = no time limit)"
	SectionText="Song Section"
	SectionHint="Set initial music section (0 - 254)"
	MusicStoppedText="Music player was stopped."
	PlayTrackHint="Play track"
	StopTrackHint="Stop track"
	PriorTrackHint="Prior track"
	NextTrackHint="Next track"
	AddAllText="Add All"
	AddAllHint="This will search through entire music directory and add all audio tracks to playlist."
	AddAllWinHdr="WARNING: Add all songs?"
	AddAllWarningText="This operation will be slow and will add every possible song to your playlist, proceed?"
	ShuffleText="Shuffle playlist"
	ShuffleHint="Next track is always selected at random."
	bWaitingForMusic=false
}
