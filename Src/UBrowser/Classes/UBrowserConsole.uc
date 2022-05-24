class UBrowserConsole expands WindowConsole;

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local UWinInteraction I;

	if ( Key!=IK_Escape )
		return Super.KeyEvent( Key, Action, Delta );
	else
	{
		foreach Interactions(I)
			if ( I.bRequestInput && I.KeyEvent(Key,Action,Delta) )
				Return True;
		return Super(Console).KeyEvent( Key, Action, Delta );
	}
}

exec function ShowUBrowser()
{
	LaunchUWindow();
}


function LaunchUWindow()
{
	bUWindowActive = !bQuickKeyEnable;
	Viewport.bShowWindowsMouse = True;

	bNoDrawWorld = False;
	if ( !bQuickKeyEnable && Viewport.Actor.Level.NetMode==NM_Standalone )
		Viewport.Actor.SetPause( True );
	if (Root != None)
		Root.bWindowVisible = True;
	GotoState('UWindow');
}
function CreateRootWindow(Canvas Canvas)
{
	local int i;
	local string OutText;

	if (Canvas != None)
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
	}
	else
	{
		OldClipX = 0;
		OldClipY = 0;
	}

	Log("Creating root window: "$RootWindow);

	Root = New(None) class<UWindowRootWindow>(DynamicLoadObject(RootWindow, class'Class'));

	Root.BeginPlay();
	Root.WinTop = 0;
	Root.WinLeft = 0;

	if (Canvas != None)
	{
		Root.WinWidth = Canvas.ClipX / Root.GUIScale;
		Root.WinHeight = Canvas.ClipY / Root.GUIScale;
		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;
	}
	else
	{
		Root.WinWidth = 0;
		Root.WinHeight = 0;
		Root.RealWidth = 0;
		Root.RealHeight = 0;
	}

	Root.ClippingRegion.X = 0;
	Root.ClippingRegion.Y = 0;
	Root.ClippingRegion.W = Root.WinWidth;
	Root.ClippingRegion.H = Root.WinHeight;

	Root.Console = Self;
	Root.bUWindowActive = bUWindowActive;

	Root.Created();
	bCreatedRoot = True;

	// Create the console window.
	ConsoleWindow = UWindowConsoleWindow(Root.CreateWindow(ConsoleClass, 100, 100, 200, 200));
	if (!bShowConsole)
		HideConsole();

	UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(" ");
	for (I=0; (i<ArrayCount(MsgText)); I++)
	{
		if ( MsgText[i]!="" )
		{
			if (( MsgType[i] == 'Say' ) || ( MsgType[i] == 'TeamSay' ))
				OutText = MsgPlayer[i].PlayerName$": "$MsgText[i];
			else OutText = MsgText[i];
			if (ConsoleWindow != None)
				UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(OutText);
		}
	}
}

defaultproperties
{
	RootWindow="UBrowser.UBrowserRootWindow"
	bShowConsole=True
}