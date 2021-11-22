Class UMenuDemoRecMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem RecordNow, Playback, StopDemo;

var localized string RecordName;
var localized string RecordHelp;
var localized string PlaybackName;
var localized string PlaybackHelp;
var localized string StopDemoName;
var localized string StopDemoHelp;

function Created()
{
	Super.Created();

	RecordNow = AddMenuItem(RecordName, None);
	Playback = AddMenuItem(PlaybackName, None);
	StopDemo = AddMenuItem(StopDemoName, None);
	CheckRecording();
}

function ShowWindow()
{
	Super.ShowWindow();
	CheckRecording();
}

final function CheckRecording()
{
	local LevelInfo L;
	
	L = GetLevel();
	RecordNow.bChecked = L.bIsDemoRecording;
	RecordNow.bDisabled = L.bIsDemoPlayback;
	Playback.bDisabled = (L.bIsDemoRecording || L.bIsDemoPlayback);
	StopDemo.bDisabled = (!L.bIsDemoRecording && !L.bIsDemoPlayback);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	local UMenuMenuBar MenuBar;

	MenuBar = UMenuMenuBar(GetMenuBar());

	switch (I)
	{
	case RecordNow:
		if( GetLevel().bIsDemoRecording )
		{
			GetPlayerOwner().bConsoleCommandMessage = true;
			GetPlayerOwner().ConsoleCommand("STOPDEMO");
			GetPlayerOwner().bConsoleCommandMessage = false;
			HideWindow();
			Root.Console.CloseUWindow();
		}
		else if( !GetLevel().bIsDemoPlayback )
		{
			Root.CreateWindow(Class'UMenuStartRecWindow', Root.WinWidth/2-100, Root.WinHeight/2.5-40, 200, 80, Self, True);
			HideWindow();
		}
		break;
	case Playback:
		if( !GetLevel().bIsDemoRecording && !GetLevel().bIsDemoPlayback )
		{
			Root.CreateWindow(Class'UMenuRecPlayWindow', Root.WinWidth/2-100, Root.WinHeight/2.5-140, 200, 400, Self, True);
			HideWindow();
		}
		break;
	case StopDemo:
		GetPlayerOwner().ConsoleCommand("STOPDEMO");
		break;
	}
	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case RecordNow:
		UMenuMenuBar(GetMenuBar()).SetHelp(RecordHelp);
		break;
	case Playback:
		UMenuMenuBar(GetMenuBar()).SetHelp(PlaybackHelp);
		break;
	case StopDemo:
		UMenuMenuBar(GetMenuBar()).SetHelp(StopDemoHelp);
		break;
	}
	Super.Select(I);
}

defaultproperties
{
	RecordName="&Record game"
	RecordHelp="Start and end a recording."
	PlaybackName="&Play demo"
	PlaybackHelp="Play a recorded demo."
	StopDemoName="&Stop demo"
	StopDemoHelp="Stop the current demo."
}