//=============================================================================
// WindowConsole - console replacer to implement UWindow UI System
//=============================================================================
class WindowConsole extends Console;

#exec Texture Import File=Textures\Warningsign.pcx Name=I_Warning Mips=Off Flags=2

var UWindowRootWindow	Root;
var() config string		RootWindow;

var float				OldClipX;
var float				OldClipY;
var bool				bCreatedRoot;
var float				MouseX;
var float				MouseY;

var class<UWindowConsoleWindow> ConsoleClass;
var config float		MouseScale;
var config bool			ShowDesktop;
var config bool			bShowConsole;
var bool				bBlackout;
var bool				bUWindowType;

var bool				bUWindowActive;
var bool				bQuickKeyEnable;
var bool				bLocked;
var bool				bLevelChange;
var bool				bHoldingCtrlKey;
var string				OldLevel;
var globalconfig int	ConsoleKeyChar;
var UWindowConsoleWindow ConsoleWindow;
var byte	            ConsoleKey; // Dummy for compatibility. Don't use, check Console.uc for GlobalConsoleKey !!!
var EInputKey	        UWindowKey; // Dummy for compatibility. Don't use, check Console.uc for GlobalWindowKey !!!

// New in 227:
var class<UWindowFramedWindow> CustomUMenu;
var MMMainWindow MusicMenu;
var MMMusicListGrid MusicMenuTimer;
var float TimerCounter;
var AdminGUIMainWindow AdminGUIMenu;

var UWindowEditBoxHistory CurrentHistory;
var string FirstTxtLine,Unicodes;
var globalconfig bool bConsoleShowColors,bConsoleLogChatOnly,bLogChatMessages,bLogScriptWarnings;
var bool bTypingUnicode,bPendingOpenConsole;
var UWindowWindow MessageCatcher;			// For special handling.
var UWindowNetErrorWindow NetworkErrorWindow;
var bool bDisplayWarning;
var float WarningTimer;
var localized string WarningMessage;

var array<UWinInteraction> Interactions;		// List of console interactions.
var array<UWindowWindow> TempNewWindowList;	// Newly generated windows list (cleared after mapchange).

var UWindowLogHandler LogHandler;

function Initialized()
{
	Super.Initialized();
	
	LogHandler.Console = Self;
	if( bLogScriptWarnings )
		LogHandler.SetEnabled(true);
}

function ResetUWindow()
{
	local int i;

	// Cleanup list.
	for( i=(TempNewWindowList.Size()-1); i>=0; --i )
		TempNewWindowList[i].NotifyWindowRemoved();
	TempNewWindowList.Empty();

	if( Root )
		Root.Close();
	Root = None;
	bCreatedRoot = False;
	ConsoleWindow = None;
	bShowConsole = False;
	CloseUWindow();
}

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local byte k;
	local UWinInteraction I;

	foreach Interactions(I)
		if ( I.bRequestInput && I.KeyEvent(Key,Action,Delta) )
			Return True;
	k = Key;
	switch (Action)
	{
	case IST_Press:
		switch (k)
		{
		case EInputKey.IK_Escape:
			if (bLocked)
				return true;
			bQuickKeyEnable = False;
			LaunchUWindow();
			return true;
		case GlobalConsoleKey:
			if (GlobalConsoleKey != 0)
			{
				if (bLocked)
					return true;
				bQuickKeyEnable = True;
				LaunchUWindow();
				if (!bShowConsole)
					ShowConsole();
				return true;
			}
		}
		break;
	}
	return False;
}
event bool KeyType( EInputKey Key )
{
	local UWinInteraction I;

	if (!bLocked && GlobalConsoleKey == 0 && LastInputKey != 0 && LastInputKey == ConsoleKeyChar)
	{
		bQuickKeyEnable = True;
		LaunchUWindow();
		if (!bShowConsole)
			ShowConsole();
	}

	foreach Interactions(I)
		if ( I.bRequestInput && I.KeyType(Min(LastInputKey, 255)) );
			Return True;
	return False;
}

function ShowConsole()
{
	bShowConsole = true;
	if (bCreatedRoot)
		ConsoleWindow.ShowWindow();
}

function HideConsole()
{
	ConsoleLines = 0;
	bShowConsole = false;
	if (ConsoleWindow != None)
		ConsoleWindow.HideWindow();
}

event Tick( float Delta )
{
	local UWinInteraction I;

	if (MusicMenuTimer != none)
	{
		TimerCounter += Delta;
		if (TimerCounter >= 1.f)
		{
			MusicMenuTimer.MusicTimer();
			TimerCounter -= int(TimerCounter);
			if (TimerCounter >= 1.f)
				TimerCounter = 0;
		}
	}
	foreach Interactions(I)
		if ( I.bRequestTick )
			I.Tick(Delta);
	Super.Tick(Delta);

	if (bLevelChange && Root != None && string(Viewport.Actor.Level) != OldLevel)
	{
		OldLevel = string(Viewport.Actor.Level);
		// if this is Entry, we could be falling through to another level...
		if (Viewport.Actor.Level != Viewport.Actor.GetEntryLevel())
			bLevelChange = False;
		Root.NotifyAfterLevelChange();
		if ( MusicMenu!=None )
			MusicMenu.NotifyAfterLevelChange();
	}
	else if ( bPendingOpenConsole )
	{
		bPendingOpenConsole = False;
		if ( Root!=None && Root.HasActiveWindow() )
		{
			bQuickKeyEnable = True;
			LaunchUWindow();
		}
	}
	if( bDisplayWarning && (WarningTimer-=Delta)<0.f )
		bDisplayWarning = false;
}

state UWindow
{
	event Tick( float Delta )
	{
		if ( bPendingOpenConsole )
			bPendingOpenConsole = False;
		Global.Tick(Delta);
		if (Root != None)
			Root.DoTick(Delta);
	}

	event PostRender( canvas Canvas )
	{
		local UWinInteraction I;

		if( Viewport.Actor.Level.LevelAction==LEVACT_SaveScreenshot ) return;
	
		DrawSingleView(Canvas);
		if( TimeDemo )
			TimeDemo.PostRender( Canvas );
		foreach Interactions(I)
			if( I.bRequestRender )
				I.PostRender(Canvas);
		if( Root )
			Root.bUWindowActive = True;
		RenderUWindow( Canvas );
		if( bDisplayWarning )
			DrawWarning(Canvas);
	}

	event bool KeyType( EInputKey Key )
	{
		//log(LastInputKey);
		if( !GlobalConsoleKey && LastInputKey && LastInputKey==ConsoleKeyChar )
		{
			if (bShowConsole)
				HideConsole();
			else if (Root != none)
			{
				if (Root.bAllowConsole)
					ShowConsole();
				else
					Root.WindowEvent(WM_KeyType, None, MouseX, MouseY, LastInputKey);
			}
			return true;
		}

		if (Root != None)
			Root.WindowEvent(WM_KeyType, None, MouseX, MouseY, LastInputKey);
		return True;
	}

	event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		switch (Action)
		{
		case IST_Release:
			switch (Key)
			{
			case IK_LeftMouse:
				if( Root )
					Root.WindowEvent(WM_LMouseUp, None, MouseX, MouseY, Key);
				break;
			case IK_RightMouse:
				if( Root )
					Root.WindowEvent(WM_RMouseUp, None, MouseX, MouseY, Key);
				break;
			case IK_MiddleMouse:
				if( Root )
					Root.WindowEvent(WM_MMouseUp, None, MouseX, MouseY, Key);
				break;
			default:
				if( Root )
					Root.WindowEvent(WM_KeyUp, None, MouseX, MouseY, Key);
				break;
			}
			break;

		case IST_Press:
			switch (Key)
			{
			case IK_F9:	// Screenshot
				return Global.KeyEvent(Key, Action, Delta);
				break;
			case IK_Escape:
				if( Root )
					Root.CloseActiveWindow();
				break;
			case IK_LeftMouse:
				if( Root )
					Root.WindowEvent(WM_LMouseDown, None, MouseX, MouseY, Key);
				break;
			case IK_RightMouse:
				if( Root )
					Root.WindowEvent(WM_RMouseDown, None, MouseX, MouseY, Key);
				break;
			case IK_MiddleMouse:
				if( Root )
					Root.WindowEvent(WM_MMouseDown, None, MouseX, MouseY, Key);
				break;
			default:
				if( GlobalConsoleKey && Key==GlobalConsoleKey )
				{
					if (bShowConsole)
						HideConsole();
					else if( Root )
					{
						if (Root.bAllowConsole)
							ShowConsole();
						else
							Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, Key);
					}
				}
				else if( Root )
					Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, Key);
				break;
			}
			break;
		case IST_Axis:
			switch (Key)
			{
			case IK_MouseX:
				MouseX = MouseX + (MouseScale * Delta);
				break;
			case IK_MouseY:
				MouseY = MouseY - (MouseScale * Delta);
				break;
			}
		default:
			break;
		}

		return true;
	}
	exec function UShowMusicMenu()
	{
		ShowUMusicMenu();
	}
	exec function UShowAdminMenu()
	{
		ShowUAdminMenu();
	}
	function HandleNetworkError( string Reason )
	{
		local GameReplicationInfo G;

		if ( Left(Reason,2)=="DC" ) // Disconnect!
		{
			Viewport.Actor.bDelayedCommand = True;
			Viewport.Actor.DelayedCommand = "Disconnect";
			Reason = Mid(Reason,2);
		}
		if ( Root==None )
			Return;
		if ( Reason=="NE_Ban" )
		{
			foreach ViewPort.Actor.AllActors(Class'GameReplicationInfo',G)
			{
				Reason = Reason@G.AdminEMail;
				Break;
			}
		}
		if ( NetworkErrorWindow==None )
			NetworkErrorWindow = UWindowNetErrorWindow(Root.CreateWindow(class'UWindowNetErrorWindow', Root.RealWidth/2-200, Root.RealHeight/2-100, 300, 150,,True));
		else NetworkErrorWindow.ShowWindow();
		UWindowNetErrorClientWindow(NetworkErrorWindow.ClientArea).SetNetworkMessage(Reason);
	}
}

function ToggleUWindow()
{
}

function LaunchUWindow()
{
	bUWindowActive = !bQuickKeyEnable;
	Viewport.bShowWindowsMouse = True;

	if (bQuickKeyEnable)
		bNoDrawWorld = False;
	else
	{
		if ( Viewport.Actor.Level.NetMode==NM_Standalone && CustomUMenu==None )
			Viewport.Actor.SetPause( True );
		bNoDrawWorld = ShowDesktop;
	}
	if (Root != None)
	{
		Root.bWindowVisible = True;
		if ( !bQuickKeyEnable && CustomUMenu!=None )
		{
			bNoDrawWorld = False;
			bUWindowActive = False;
			Root.bUWindowActive = False;
			Root.CreateWindow(CustomUMenu,10,10,200,200,,True).ShowWindow();
			bQuickKeyEnable = True;
		}
	}
	GotoState('UWindow');
}

function CloseUWindow()
{
	if (Viewport.Actor.Level.NetMode==NM_Standalone && !bQuickKeyEnable)
		Viewport.Actor.SetPause( False );

	bNoDrawWorld = False;
	bQuickKeyEnable = False;
	bUWindowActive = False;
	Viewport.bShowWindowsMouse = False;

	if (Root != None)
		Root.bWindowVisible = False;
	GotoState('');
}

function CreateRootWindow(Canvas Canvas)
{
	local int i;
	local string OutText;
	local class<UWindowRootWindow> RootClass;

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

	RootClass = class<UWindowRootWindow>(DynamicLoadObject(RootWindow, class'Class'));
	if ( RootClass==None )
		RootClass = Class'UWindowRootWindow';
	Log("Creating root window: "$RootWindow);

	Root = New(None) RootClass;

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
	if ( !bShowConsole )
		HideConsole();

	UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(" ");
	for (I=0; (i<ArrayCount(MsgText)); I++)
	{
		if ( MsgText[i]!="" )
		{
			if (( MsgType[i] == 'Say' ) || ( MsgType[i] == 'TeamSay' ))
				OutText = MsgPlayer[i].PlayerName$": "$MsgText[i];
			else
				OutText = MsgText[i];
			if (ConsoleWindow != None)
				UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(OutText);
		}
		//UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(MsgText[I]);
	}
}

function RenderUWindow( canvas Canvas )
{
	local UWindowWindow NewFocusWindow;

	Canvas.bNoSmooth = True;
	Canvas.Z = 1;
	Canvas.Style = 1;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;

	if (Viewport.bWindowsMouseAvailable && Root != None)
	{
		MouseX = Viewport.WindowsMouseX/Root.GUIScale;
		MouseY = Viewport.WindowsMouseY/Root.GUIScale;
	}

	if (!bCreatedRoot)
		CreateRootWindow(Canvas);

	Root.bWindowVisible = True;
	Root.bUWindowActive = bUWindowActive;
	Root.bQuickKeyEnable = bQuickKeyEnable;

	if (Canvas.ClipX != OldClipX || Canvas.ClipY != OldClipY)
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;

		Root.WinTop = 0;
		Root.WinLeft = 0;
		Root.WinWidth = Canvas.ClipX / Root.GUIScale;
		Root.WinHeight = Canvas.ClipY / Root.GUIScale;

		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;

		Root.ClippingRegion.X = 0;
		Root.ClippingRegion.Y = 0;
		Root.ClippingRegion.W = Root.WinWidth;
		Root.ClippingRegion.H = Root.WinHeight;

		Root.Resized();
	}

	if (MouseX > Root.WinWidth) MouseX = Root.WinWidth;
	if (MouseY > Root.WinHeight) MouseY = Root.WinHeight;
	if (MouseX < 0) MouseX = 0;
	if (MouseY < 0) MouseY = 0;


	// Check for keyboard focus
	NewFocusWindow = Root.CheckKeyFocusWindow();

	if (NewFocusWindow != Root.KeyFocusWindow)
	{
		Root.KeyFocusWindow.KeyFocusExit();
		Root.KeyFocusWindow = NewFocusWindow;
		Root.KeyFocusWindow.KeyFocusEnter();
	}


	Root.MoveMouse(MouseX, MouseY);
	Root.WindowEvent(WM_Paint, Canvas, MouseX, MouseY, 0);
	if (bUWindowActive || bQuickKeyEnable)
		Root.DrawMouse(Canvas);
}

function Message( PlayerReplicationInfo PRI, coerce string Msg, name N )
{
	local string OutText;
	local color MsgC;
	local UWinInteraction I;
	
	foreach Interactions(I)
		if ( I.bRequestMessages && I.Message(PRI,Msg,N) )
			Return;
	if ( MessageCatcher!=None && MessageCatcher.OverrideMessage(PRI,Msg,N) )
		Return;
	if ( N=='Networking' )
	{
		HandleNetworkError(Msg);
		Return;
	}
	Super.Message( PRI, Msg, N );

	if ( Viewport.Actor == None )
		return;

	if ( Msg!="" )
	{
		if ( N=='Say' || N=='TeamSay' )
		{
			if ( PRI==None || PRI.bDeleteMe )
				OutText = "???:"@Msg;
			else OutText = PRI.PlayerName$":"@Msg;
			if ( bLogChatMessages )
				Log(OutText,'ChatLog');
		}
		else if ( bConsoleLogChatOnly )
			Return;
		else OutText = Msg;
		if ( bConsoleShowColors && Viewport.Actor.myHUD!=None )
			Viewport.Actor.myHUD.GetMessageColor(N,MsgC);
		if (ConsoleWindow != None)
			UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(OutText,MsgC);
	}
}

// Obsolete! But left in for mod compatibility.
function UpdateHistory()
{
	// Update history buffer.
	InsertHistory(TypedStr);
}
function HistoryUp()
{
	TypedStr = PickPrevHistory();
}
function HistoryDown()
{
	TypedStr = PickNextHistory();
}

function NotifyLevelChange()
{
	local int i;

	// Notify Interactions & remove all desired interactions.
	for( i=(Interactions.Size()-1); i>=0; --i )
	{
		Interactions[i].NotifyLevelChange();
		if ( Interactions[i].bRemoveAfterMapchange )
			Interactions.Remove(i);
	}

	Super.NotifyLevelChange();
	bLevelChange = True;

	// Cleanup list.
	for( i=(TempNewWindowList.Size()-1); i>=0; --i )
		TempNewWindowList[i].NotifyWindowRemoved();
	TempNewWindowList.Empty();

	if (Root != None)
		Root.NotifyBeforeLevelChange();
	CustomUMenu = None;
}

// Added clipboard support:
state Typing
{
	function bool KeyType( EInputKey Key )
	{
		if ( bNoStuff )
		{
			bNoStuff = false;
			return true;
		}
		if (LastInputKey>=Asc(" ") && LastInputKey != 0x7F)
		{
			if( TypingOffset>=0 && TypingOffset<Len(TypedStr) )
			{
				TypedStr = Left(TypedStr,TypingOffset) $ Chr(LastInputKey) $ Mid(TypedStr,TypingOffset);
				++TypingOffset;
			}
			else TypedStr = TypedStr $ Chr(LastInputKey);
			Scrollback=0;
			return true;
		}
		return false;
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;

		bNoStuff = false;
		if ( Root )
		{
			if ( Key==IK_Ctrl )
			{
				bHoldingCtrlKey = (Action==IST_Press || Action==IST_Hold);
				return true;
			}
			else if ( bHoldingCtrlKey && Action==IST_Press )
			{
				if ( Key==IK_C )
				{
					Class'PlayerPawn'.Static.CopyToClipboard(TypedStr);
					return true;
				}
				else if ( Key==IK_V )
				{
					Temp = Class'PlayerPawn'.Static.PasteFromClipboard();
					if( TypingOffset==-1 || TypingOffset>=Len(TypedStr) )
						TypedStr = TypedStr$Temp;
					else
					{
						TypedStr = Left(TypedStr,TypingOffset)$Temp$Mid(TypedStr,TypingOffset);
						TypingOffset+=Len(Temp);
					}
					return true;
				}
				else if ( Key==IK_X )
				{
					Class'PlayerPawn'.Static.CopyToClipboard(TypedStr);
					TypedStr = "";
					TypingOffset = -1;
					return true;
				}
			}
		}
		else if ( Key==IK_Alt )
		{
			if ( !bTypingUnicode && Action==IST_Press )
			{
				bTypingUnicode = True;
				Unicodes = "";
			}
			else if ( bTypingUnicode && Action==IST_Release )
			{
				bTypingUnicode = False;
				if( TypingOffset>=0 && TypingOffset<Len(TypedStr) )
				{
					TypedStr = Left(TypedStr,TypingOffset)$Chr(int(Unicodes))$Mid(TypedStr,TypingOffset);
					++TypingOffset;
				}
				else TypedStr = TypedStr$Chr(int(Unicodes));
			}
			return true;
		}
		else if ( bTypingUnicode )
		{
			if ( Key>=48 && Key<=57 ) //0-9 number keys.
				Unicodes = Unicodes$Chr(Key);
			return true;
		}
		bLocked = True;
		if ( Key!=IK_Escape && (global.KeyEvent( Key, Action, Delta ) || Action!=IST_Press) )
		{
			bLocked = False;
			return true;
		}
		else if ( Key==IK_Escape && Action==IST_Press )
		{
			if ( Scrollback!=0 )
			{
				Scrollback=0;
			}
			else if ( TypedStr!="" )
			{
				TypingOffset = -1;
				TypedStr="";
			}
			else
			{
				ConsoleDest=0.0;
				GotoState( '' );
			}
			Scrollback=0;
		}
		else if ( Key==IK_Enter )
		{
			if ( Scrollback!=0 )
			{
				Scrollback=0;
			}
			else
			{
				if ( TypedStr!="" )
				{
					// Print to console.
					if ( ConsoleLines!=0 )
						Message( None, "(>" @ TypedStr, 'Console' );

					// Update history buffer.
					InsertHistory(TypedStr);

					// Make a local copy of the string.
					Temp=TypedStr;
					TypedStr="";
					if ( !ConsoleCommand( Temp ) )
						Message( None, Localize("Errors","Exec","Core"), 'Console' );
					Message( None, "", 'Console' );
				}
				if ( ConsoleDest==0.0 )
					GotoState('');
				Scrollback=0;
			}
		}
		else if ( Key==IK_Up )
		{
			TypedStr = PickNextHistory();
			Scrollback=0;
			TypingOffset = -1;
		}
		else if ( Key==IK_Down )
		{
			TypedStr = PickPrevHistory();
			Scrollback=0;
			TypingOffset = -1;
		}
		else if ( Key==IK_PageUp )
		{
			if ( ++Scrollback >= MaxLines )
				Scrollback = MaxLines-1;
		}
		else if ( Key==IK_PageDown )
		{
			if ( --Scrollback < 0 )
				Scrollback = 0;
		}
		else if ( Key==IK_Backspace )
		{
			if( TypingOffset>0 && TypingOffset<Len(TypedStr) )
			{
				TypedStr = Left(TypedStr,TypingOffset-1)$Mid(TypedStr,TypingOffset);
				--TypingOffset;
			}
			else if ( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
			Scrollback = 0;
		}
		else if ( Key==IK_Delete )
		{
			if( TypingOffset>=0 && TypingOffset<Len(TypedStr) )
			{
				TypedStr = Left(TypedStr,TypingOffset)$Mid(TypedStr,TypingOffset+1);
				Scrollback = 0;
			}
		}
		else if ( Key==IK_Left )
		{
			if( TypingOffset==-1 )
				TypingOffset = Len(TypedStr)-1;
			else TypingOffset = Max(TypingOffset-1,0);
		}
		else if ( Key==IK_Right )
		{
			if( TypingOffset==-1 || (TypingOffset+1)>=Len(TypedStr) )
				TypingOffset = -1;
			else ++TypingOffset;
		}
		bLocked = False;
		return true;
	}
	function BeginState()
	{
		bTyping = true;
		Viewport.Actor.Typing(true);
		CurrentHistory = None;
		bTypingUnicode = False;
		bHoldingCtrlKey = false;
	}
	function EndState()
	{
		bTyping = false;
		Viewport.Actor.Typing(false);
		ConsoleDest=0.0;
		TypingOffset = -1;
	}
}

state Menuing
{
	Ignores BeginState,EndState;
}
state MenuTyping
{
	Ignores BeginState,EndState;
}
state KeyMenuing
{
	Ignores EndState;
	function BeginState()
	{
		bValidKeyEvent = False;
		bTypingUnicode = False;
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		if ( !bValidKeyEvent )
			return false;
		if ( Key==IK_Alt )
		{
			if ( !bTypingUnicode && Action==IST_Press )
			{
				bTypingUnicode = True;
				Unicodes = "";
			}
			else if ( bTypingUnicode && Action==IST_Release )
			{
				bTypingUnicode = False;
				Viewport.Actor.myHUD.MainMenu.ProcessMenuKey( Key, Chr(int(Unicodes)) );
				Scrollback=0;
				GotoState( 'Menuing' );
			}
			return true;
		}
		else if ( bTypingUnicode )
		{
			if ( Key>=48 && Key<=57 ) //0-9 number keys.
				Unicodes = Unicodes$Chr(Key);
			return true;
		}
		if ( Action==IST_Press )
		{
			ConsoleDest=0.0;
			if ( Viewport.Actor.myHUD!=None && Viewport.Actor.myHUD.MainMenu!=None )
				Viewport.Actor.myHUD.MainMenu.ProcessMenuKey( Key, mid(string(GetEnum(enum'EInputKey',Key)),3) );
			Scrollback=0;
			GotoState( 'Menuing' );
			return true;
		}
	}
}

function string PickNextHistory()
{
	local UWindowEditBox E;

	if( !ConsoleWindow )
		Return Super.PickNextHistory();

	E = UWindowConsoleClientWindow(ConsoleWindow.ClientArea).EditControl.EditBox;
	if( !E )
		Return ""; // Error?
	if( !CurrentHistory )
	{
		FirstTxtLine = TypedStr;
		CurrentHistory = E.HistoryList;
		if ( CurrentHistory && CurrentHistory.HistoryText=="" )
			CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Next);
		if( !CurrentHistory )
			Return TypedStr;
		Return CurrentHistory.HistoryText;
	}
	if( CurrentHistory.Next )
	{
		CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Next);
		Return CurrentHistory.HistoryText;
	}
	return TypedStr;
}
function string PickPrevHistory()
{
	if( !ConsoleWindow )
		return Super.PickPrevHistory();

	if( !CurrentHistory )
		return TypedStr;
	if( CurrentHistory.Prev )
	{
		CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Prev);
		if( CurrentHistory.HistoryText=="" )
			CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Prev);
		if( CurrentHistory )
			return CurrentHistory.HistoryText;
	}
	CurrentHistory = None;
	return FirstTxtLine;
}
function InsertHistory( string Txt )
{
	local UWindowEditBox E;

	if( !Len(Txt) )
		return;
	if( !ConsoleWindow )
	{
		Super.InsertHistory(Txt);
		return;
	}
	E = UWindowConsoleClientWindow(ConsoleWindow.ClientArea).EditControl.EditBox;
	if ( E )
		E.SaveToHistory(Txt);
}
function ListUWindowMenu( UWindowWindow Menu )
{
	TempNewWindowList.Add(Menu);
}
function UWindowWindow FindOldMenu( class<UWindowWindow> WinClass, UWindowWindow ParentWindow )
{
	local UWindowWindow W;

	foreach TempNewWindowList(W)
	{
		if ( W.Class==WinClass && W.ParentWindow==ParentWindow )
			return W;
	}
	return None;
}

exec function UShowMusicMenu()
{
	ShowUMusicMenu();

	bQuickKeyEnable = True;
	LaunchUWindow();
}
exec function UShowAdminMenu()
{
	ShowUAdminMenu();

	bQuickKeyEnable = True;
	LaunchUWindow();
}

function ShowUMusicMenu()
{
	const UMusicMenuWinWidth = 320;
	const UMusicMenuWinHeight = 264;
	local MMMainWindow OldMM;

	if (Root == none)
		return;
	OldMM = MusicMenu;
	if (MusicMenu == none || MusicMenu.Root != Root)
	{
		MusicMenu = MMMainWindow(Root.CreateWindow(
			class'MMMainWindow',
			Root.WinWidth/2 - UMusicMenuWinWidth/2,
			FMax(20, Root.WinHeight/2 - UMusicMenuWinHeight * 3 / 4),
			UMusicMenuWinWidth, UMusicMenuWinHeight,, true));
		if (OldMM != none)
			MusicMenu.CopyPropertiesFrom(OldMM);
	}
	else
	{
		MusicMenu.ShowWindow();
		MusicMenu.BringToFront();
	}
}

function ShowUAdminMenu()
{
	local float Height;

	if (Root == none)
		return;
	if (AdminGUIMenu == none || AdminGUIMenu.Root != Root)
	{
		Height = Root.RealHeight/5*4/Root.GUIScale;
		AdminGUIMenu = AdminGUIMainWindow(Root.CreateWindow(class'AdminGUIMainWindow', Root.WinWidth/2-330, Root.WinHeight/2-Height/2, 660, Height,,True));
	}
	else
	{
		AdminGUIMenu.ShowWindow();
		AdminGUIMenu.BringToFront();
	}
}

exec function UWindowShowDebug()
{
	if ( Root!=None )
		Root.bDisplayDebugMouse = !Root.bDisplayDebugMouse;
}

// Initilize UWindow on game startup
event PostRender( canvas Canvas )
{
	local UWinInteraction I;

	if ( !bCreatedRoot )
	{
		bShowConsole = False;
		CreateRootWindow(Canvas);
	}
	Super.PostRender(Canvas);
	foreach Interactions(I)
		if ( I.bRequestRender )
			I.PostRender(Canvas);
	if( bDisplayWarning )
		DrawWarning(Canvas);
}

function DrawWarning( Canvas Canvas )
{
	local float Scale;
	local byte A;
	
	Scale = FClamp(Canvas.ClipY*0.0005f,0.1f,1.f);
	Canvas.SetPos(Scale*10.f,Scale*32.f);
	if( WarningTimer>1.f )
	{
		Canvas.DrawColor = MakeColor(255,255,255);
		Canvas.Style = Viewport.Actor.ERenderStyle.STY_Masked;
	}
	else
	{
		A = WarningTimer*255.f;
		if( A==0 )
			return;
		Canvas.DrawColor = MakeColor(A,A,A);
		Canvas.Style = Viewport.Actor.ERenderStyle.STY_Translucent;
	}
	Canvas.DrawIcon(Texture'I_Warning',Scale);
	Canvas.Font = Font'SmallFont';
	Canvas.SetPos(Scale*10.f,Scale*{32+128-8});
	Canvas.DrawColor.G = 0;
	Canvas.DrawColor.B = 0;
	Canvas.DrawText(WarningMessage);
	Canvas.DrawColor = MakeColor(255,255,255);
	Canvas.Style = Viewport.Actor.ERenderStyle.STY_Normal;
}

/* ***************** Third party mods interface *************************** */

// Can be used by custom gametype authors to set up a custom UWindow "main menu"
exec function SetCustomUMenu( class<UWindowFramedWindow> NewMainMenu )
{
	CustomUMenu = NewMainMenu;
}

// Display network error message
function HandleNetworkError( string Reason )
{
	local GameReplicationInfo G;

	if ( Root==None )
		Return;
	if ( Reason=="NE_Ban" )
	{
		foreach ViewPort.Actor.AllActors(Class'GameReplicationInfo',G)
		{
			Reason = Reason@G.AdminEMail;
			Break;
		}
	}
	if ( NetworkErrorWindow==None )
		NetworkErrorWindow = UWindowNetErrorWindow(Root.CreateWindow(class'UWindowNetErrorWindow', Root.RealWidth/2-200, Root.RealHeight/2-100, 300, 150,,True));
	else NetworkErrorWindow.ShowWindow();
	bQuickKeyEnable = True;
	LaunchUWindow();
	UWindowNetErrorClientWindow(NetworkErrorWindow.ClientArea).SetNetworkMessage(Reason);
}

// Interaction functions.
final function UWinInteraction CreateInteraction( Class<UWinInteraction> InterClass )
{
	local UWinInteraction I;

	I = New InterClass;
	I.Viewport = Viewport;
	I.Console = Self;
	Interactions.Add(I);
	I.Initialized();
	Return I;
}
final function UWinInteraction FindInteraction( Class<UWinInteraction> InterClass, optional bool bCreateOne )
{
	local UWinInteraction I;

	foreach Interactions(I)
	{
		if ( I.Class==InterClass )
			return I;
	}
	if ( bCreateOne )
		Return CreateInteraction(InterClass);
	Return None;
}
final function bool RemoveInteraction( Class<UWinInteraction> InterClass )
{
	local int i;

	for ( i=(Interactions.Size()-1); i>=0; i-- )
	{
		if ( Interactions[i].Class==InterClass )
		{
			Interactions.Remove(i);
			return true;
		}
	}
	return false;
}

// Open up some custom UWindow menu.
function UWindowWindow OpenUWindowMenu( Class<UWindowWindow> WindClass, float XL, float YL, float XSize, float YSize )
{
	if ( Root==None )
		return None;
	return Root.CreateWindow(WindClass,XL*Root.WinWidth,YL*Root.WinHeight,XSize*Root.WinWidth,YSize*Root.WinHeight,,True);
}

defaultproperties
{
	RootWindow="UWindow.UWindowRootWindow"
	ConsoleClass=Class'UWindow.UWindowConsoleWindow'
	MouseScale=0.600000
	ConsoleKeyChar=96
	bLogChatMessages=True
	WarningMessage="Something is creating script warnings..."
	
	Begin Object Class=UWindowLogHandler Name=UWindowLogHandle
	End Object
	LogHandler=UWindowLogHandle
}