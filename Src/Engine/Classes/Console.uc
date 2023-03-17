//=============================================================================
// Console: A player console, associated with a viewport.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Console extends Object extends FOutputDevice
	native
	transient;

cpptext
{
	// Constructor.
	UConsole();

	// UConsole interface.
	virtual void _Init( UViewport* Viewport );
	virtual void PreRender( FSceneNode* Frame );
	virtual void PostRender( FSceneNode* Frame );
	virtual UBOOL GetDrawWorld();
	inline UBOOL GetbTyping() const
	{
		return bTyping;
	}
	inline BYTE GetConsoleKey() const
	{
		return GlobalConsoleKey;
	}
	inline BYTE GetWindowKey() const
	{
		return GlobalWindowKey;
	}
	
	// FOutputDevice interface.
	void Serialize( const TCHAR* Data, EName MsgType );
	UPlayer* GetUserContext() const;
}

// Imports.
#exec Texture Import NAME=ConsoleBack File=Textures\Console.pcx
#exec Texture Import NAME=Border File=Textures\Border.pcx

// Constants.
const MaxBorder=6;
const MaxLines=64;
const noexport MaxHistory=16;
const noexport TextMsgSize=128;

// Variables.
var viewport Viewport;
var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[MaxHistory];
var int Scrollback, NumLines, TopLine, TextLines;
var float MsgTime;
var string MsgText[MaxLines],MsgPRINames[MaxLines];
var name MsgType[MaxLines];
var PlayerReplicationInfo MsgPlayer[MaxLines];
var float MsgTick[MaxLines];
var int BorderSize;
var int ConsoleLines, BorderLines, BorderPixels;
var float ConsolePos, ConsoleDest;
var float FrameX, FrameY;
var texture ConBackground, Border;
var bool bNoStuff, bTyping, bTimeDemo;
var TimeDemo TimeDemo;
var bool bNoDrawWorld;
var int TypingOffset;					// Offset while typing string
var globalconfig byte GlobalConsoleKey;
var globalconfig byte GlobalWindowKey;
var transient const int LastInputKey;	// The Key code that can be retrieved from event function KeyType.
										// Unlike parameter Key of type EInputKey, LastInputKey can be greater than 255.

var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;
var bool bValidKeyEvent;
var globalconfig bool bConsoleCommandLog; // Should print results of consolecommands to client log.

//-----------------------------------------------------------------------------
// Input.

// Input system states.
enum EInputAction
{
	IST_None,    // Not performing special input processing.
	IST_Press,   // Handling a keypress or button press.
	IST_Hold,    // Handling holding a key or button.
	IST_Release, // Handling a key or button release.
	IST_Axis,    // Handling analog axis movement.
};

// Input keys.
enum EInputKey
{
	/*00*/	IK_None			,IK_LeftMouse	,IK_RightMouse	,IK_Cancel		,
	/*04*/	IK_MiddleMouse	,IK_Unknown05	,IK_Unknown06	,IK_Unknown07	,
	/*08*/	IK_Backspace	,IK_Tab         ,IK_Unknown0A	,IK_Unknown0B	,
	/*0C*/	IK_Unknown0C	,IK_Enter	    ,IK_Unknown0E	,IK_Unknown0F	,
	/*10*/	IK_Shift		,IK_Ctrl	    ,IK_Alt			,IK_Pause       ,
	/*14*/	IK_CapsLock		,IK_MouseButton4,IK_MouseButton5,IK_MouseButton6,
	/*18*/	IK_MouseButton7	,IK_MouseButton8,IK_Unknown1A	,IK_Escape		,
	/*1C*/	IK_Unknown1C	,IK_Unknown1D	,IK_Unknown1E	,IK_Unknown1F	,
	/*20*/	IK_Space		,IK_PageUp      ,IK_PageDown    ,IK_End         ,
	/*24*/	IK_Home			,IK_Left        ,IK_Up          ,IK_Right       ,
	/*28*/	IK_Down			,IK_Select      ,IK_Print       ,IK_Execute     ,
	/*2C*/	IK_PrintScrn	,IK_Insert      ,IK_Delete      ,IK_Help		,
	/*30*/	IK_0			,IK_1			,IK_2			,IK_3			,
	/*34*/	IK_4			,IK_5			,IK_6			,IK_7			,
	/*38*/	IK_8			,IK_9			,IK_Unknown3A	,IK_Unknown3B	,
	/*3C*/	IK_Unknown3C	,IK_Unknown3D	,IK_Unknown3E	,IK_Unknown3F	,
	/*40*/	IK_Unknown40	,IK_A			,IK_B			,IK_C			,
	/*44*/	IK_D			,IK_E			,IK_F			,IK_G			,
	/*48*/	IK_H			,IK_I			,IK_J			,IK_K			,
	/*4C*/	IK_L			,IK_M			,IK_N			,IK_O			,
	/*50*/	IK_P			,IK_Q			,IK_R			,IK_S			,
	/*54*/	IK_T			,IK_U			,IK_V			,IK_W			,
	/*58*/	IK_X			,IK_Y			,IK_Z			,IK_Unknown5B	,
	/*5C*/	IK_Unknown5C	,IK_Unknown5D	,IK_Unknown5E	,IK_Unknown5F	,
	/*60*/	IK_NumPad0		,IK_NumPad1     ,IK_NumPad2     ,IK_NumPad3     ,
	/*64*/	IK_NumPad4		,IK_NumPad5     ,IK_NumPad6     ,IK_NumPad7     ,
	/*68*/	IK_NumPad8		,IK_NumPad9     ,IK_GreyStar    ,IK_GreyPlus    ,
	/*6C*/	IK_Separator	,IK_GreyMinus	,IK_NumPadPeriod,IK_GreySlash   ,
	/*70*/	IK_F1			,IK_F2          ,IK_F3          ,IK_F4          ,
	/*74*/	IK_F5			,IK_F6          ,IK_F7          ,IK_F8          ,
	/*78*/	IK_F9           ,IK_F10         ,IK_F11         ,IK_F12         ,
	/*7C*/	IK_F13			,IK_F14         ,IK_F15         ,IK_F16         ,
	/*80*/	IK_F17			,IK_F18         ,IK_F19         ,IK_F20         ,
	/*84*/	IK_F21			,IK_F22         ,IK_F23         ,IK_F24         ,
	/*88*/	IK_Unknown88	,IK_Unknown89	,IK_Unknown8A	,IK_Unknown8B	,
	/*8C*/	IK_Unknown8C	,IK_Unknown8D	,IK_Unknown8E	,IK_Unknown8F	,
	/*90*/	IK_NumLock		,IK_ScrollLock  ,IK_Unknown92	,IK_Unknown93	,
	/*94*/	IK_Unknown94	,IK_Unknown95	,IK_Unknown96	,IK_Unknown97	,
	/*98*/	IK_Unknown98	,IK_Unknown99	,IK_Unknown9A	,IK_Unknown9B	,
	/*9C*/	IK_Unknown9C	,IK_Unknown9D	,IK_Unknown9E	,IK_Unknown9F	,
	/*A0*/	IK_LShift		,IK_RShift      ,IK_LControl    ,IK_RControl    ,
	/*A4*/	IK_UnknownA4	,IK_UnknownA5	,IK_UnknownA6	,IK_UnknownA7	,
	/*A8*/	IK_UnknownA8	,IK_UnknownA9	,IK_UnknownAA	,IK_UnknownAB	,
	/*AC*/	IK_UnknownAC	,IK_UnknownAD	,IK_UnknownAE	,IK_UnknownAF	,
	/*B0*/	IK_UnknownB0	,IK_UnknownB1	,IK_UnknownB2	,IK_UnknownB3	,
	/*B4*/	IK_UnknownB4	,IK_UnknownB5	,IK_UnknownB6	,IK_UnknownB7	,
	/*B8*/	IK_UnknownB8	,IK_UnknownB9	,IK_Semicolon	,IK_Equals		,
	/*BC*/	IK_Comma		,IK_Minus		,IK_Period		,IK_Slash		,
	/*C0*/	IK_Tilde		,IK_UnknownC1	,IK_UnknownC2	,IK_UnknownC3	,
	/*C4*/	IK_UnknownC4	,IK_UnknownC5	,IK_UnknownC6	,IK_UnknownC7	,
	/*C8*/	IK_Joy1	        ,IK_Joy2	    ,IK_Joy3	    ,IK_Joy4	    ,
	/*CC*/	IK_Joy5	        ,IK_Joy6	    ,IK_Joy7	    ,IK_Joy8	    ,
	/*D0*/	IK_Joy9	        ,IK_Joy10	    ,IK_Joy11	    ,IK_Joy12		,
	/*D4*/	IK_Joy13		,IK_Joy14	    ,IK_Joy15	    ,IK_Joy16	    ,
	/*D8*/	IK_UnknownD8	,IK_UnknownD9	,IK_UnknownDA	,IK_LeftBracket	,
	/*DC*/	IK_Backslash	,IK_RightBracket,IK_SingleQuote	,IK_UnknownDF	,
	/*E0*/  IK_JoyX			,IK_JoyY		,IK_JoyZ		,IK_JoyR		,
	/*E4*/	IK_MouseX		,IK_MouseY		,IK_MouseZ		,IK_MouseW		,
	/*E8*/	IK_JoyU			,IK_JoyV		,IK_UnknownEA	,IK_UnknownEB	,
	/*EC*/	IK_MouseWheelUp ,IK_MouseWheelDown,IK_Unknown10E,UK_Unknown10F  ,
	/*F0*/	IK_UnknownF0	,IK_UnknownF1	,IK_UnknownF2	,IK_UnknownF3	,
	/*F4*/	IK_UnknownF4	,IK_UnknownF5	,IK_Attn		,IK_CrSel		,
	/*F8*/	IK_ExSel		,IK_ErEof		,IK_Play		,IK_Zoom		,
	/*FC*/	IK_NoName		,IK_PA1			,IK_OEMClear
};

//-----------------------------------------------------------------------------
// natives.

// Execute a command on this console.
native function bool ConsoleCommand( coerce string S );

//-----------------------------------------------------------------------------
// Exec functions accessible from the console and key bindings.

// Begin typing a command on the console.
exec function Type()
{
	TypedStr="";
	GotoState( 'Typing' );
}

exec function Talk()
{
	TypedStr="Say ";
	bNoStuff = true;
	GotoState( 'Typing' );
}

exec function TeamTalk()
{
	TypedStr="TeamSay ";
	bNoStuff = true;
	GotoState( 'Typing' );
}

// Size the view up.
exec function ViewUp()
{
	BorderSize = Max( BorderSize-1, 0 );
}

// Size the view down.
exec function ViewDown()
{
	BorderSize = Min( BorderSize+1, MaxBorder );
}

//-----------------------------------------------------------------------------
// Member Access Functions.

function string GetMsgText( int Index )
{
	return MsgText[Index];
}
function SetMsgText( int Index, string NewMsgText )
{
	MsgText[Index] = NewMsgText;
}

function name GetMsgType(int Index)
{
	return MsgType[Index];
}
function SetMsgType(int Index, name NewMsgType)
{
	MsgType[Index] = NewMsgType;
}

function PlayerReplicationInfo GetMsgPlayer(int Index)
{
	if ( MsgPlayer[Index]!=None && MsgPlayer[Index].bDeleteMe )
		MsgPlayer[Index] = None;
	return MsgPlayer[Index];
}
function SetMsgPlayer(int Index, PlayerReplicationInfo NewMsgPlayer)
{
	MsgPlayer[Index] = NewMsgPlayer;
	if ( NewMsgPlayer!=None )
		MsgPRINames[Index] = NewMsgPlayer.PlayerName;
	else MsgPRINames[Index] = "???";
}

function float GetMsgTick(int Index)
{
	return MsgTick[Index];
}
function SetMsgTick(int Index, int NewMsgTick)
{
	MsgTick[Index] = NewMsgTick;
}

//-----------------------------------------------------------------------------
// Functions.

// Game has been booted up and is ready to play.
event Initialized();

// Clear messages.
function ClearMessages()
{
	local int i;

	for (i=0; i<MaxLines; i++)
	{
		MsgText[i] = "";
		MsgType[i] = '';
		MsgPlayer[i] = None;
		MsgTick[i] = 0.0;
	}
	MsgTime = 0.0;
}

// Write to console.
event Message( PlayerReplicationInfo PRI, coerce string Msg, name N )
{
	if ( Msg!="" )
	{
		TopLine		     = (TopLine+1) % MaxLines;
		NumLines	     = Min(NumLines+1,MaxLines-1);
		MsgType[TopLine] = N;
		MsgTime		     = 6.0;
		TextLines++;
		if ( PRI!=None )
			MsgPRINames[TopLine] = PRI.PlayerName;
		else MsgPRINames[TopLine] = "???";
		MsgText[TopLine] = Msg;
		MsgPlayer[TopLine] = PRI;
		MsgTick[TopLine] = MsgTime;
	}
}

// Called by the engine when a single key is typed.

event bool KeyType( EInputKey Key );


// Called by the engine when a key, mouse, or joystick button is pressed
// or released, or any analog axis movement is processed.
event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if ( Action!=IST_Press )
	{
		return false;
	}
	else if ( Key==IK_Tilde && !viewport.actor.bistyping)
	{
		if ( ConsoleDest==0.0 )
		{
			ConsoleDest=0.6;
			GotoState('Typing');
		}
		else GotoState('');
		return true;
	}
	else return false;
}

// Called each rendering iteration to update any time-based display.
event Tick( float Delta )
{
	local int I;

	if ( TimeDemo != None )
		TimeDemo.TickTimeDemo( Delta );
	else if ( bTimeDemo )
	{
		// restart TimeDemo after a level change
		TimeDemo = Viewport.Actor.Spawn(class'TimeDemo');
		TimeDemo.DoSetup(Self);
		bTimeDemo = False;
	}

	for (I = 0; I < MaxLines; I++)
	{
		if (MsgTick[I] > 0.0)
			MsgTick[I] -= Delta;
		if (MsgTick[I] < 0.0)
			MsgTick[I] = 0.0;
	}

	// Slide console up or down.
	if ( ConsolePos < ConsoleDest )
		ConsolePos = FMin(ConsolePos+Delta,ConsoleDest);
	else if ( ConsolePos > ConsoleDest )
		ConsolePos = FMax(ConsolePos-Delta,ConsoleDest);

	// Update status message.
	if ( ((MsgTime-=Delta) <= 0.0) && (TextLines > 0) )
		TextLines--;
}

// Called before rendering the world view.
event PreRender( canvas C );

event NotifyLevelChange()
{
	if ( TimeDemo != None )
	{
		// shutdown TimeDemo on level change
		TimeDemo.DoShutdown();
		TimeDemo = None;
		// Remember to restart it
		bTimeDemo = True;
	}
	ClearMessages();
}

function DrawLevelAction( canvas C )
{
	local string BigMessage;
	local font LargeFont;
	local float XL, YL;

	LargeFont = C.LargeFont;
	C.Style = 1;
	if ( Viewport.Actor.bShowMenu )
		BigMessage = "";
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Loading )
		BigMessage = LoadingMessage;
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Saving )
		BigMessage = SavingMessage;
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Connecting )
		BigMessage = ConnectingMessage;
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Precaching )
		BigMessage = PrecachingMessage;
	else if( Viewport.Actor.Level.bIsDemoPlayback )
	{
		if ( Viewport.Actor.Level.bPauseDemo )
		{
			LargeFont = C.MedFont;
			BigMessage = PausedMessage;
		}
	}
	else if ( Len(Viewport.Actor.Level.Pauser)>0 )
	{
		LargeFont = C.MedFont;
		BigMessage = PausedMessage; // Add pauser name?
	}

	if ( Len(BigMessage)>0 )
	{
		C.bCenter = false;
		C.Font = LargeFont;
		C.StrLen( BigMessage, XL, YL );
		C.SetPos(FrameX/2 - XL/2, FrameY/2 - YL/2);
		C.DrawText( BigMessage, false );
	}
}

// Add localization to hardcoded strings!!
// Called after rendering the world view.
event PostRender( canvas C )
{
	local int YStart, YEnd;

	if (bNoDrawWorld)
	{
		C.SetPos(0,0);
		C.DrawPattern( Texture'Border', C.ClipX, C.ClipY, 1.0 );
	}

	if ( TimeDemo != None )
		TimeDemo.PostRender( C );

	// call overridable "level action" rendering code to draw the "big message"
	DrawLevelAction( C );

	// If the console has changed since the previous frame, draw it.
	if ( ConsoleLines > 0 )
	{
		C.SetOrigin(0.0, ConsoleLines - FrameY*0.6);
		C.SetPos(0.0, 0.0);
		C.DrawTile(ConBackground,FrameX,FrameY*0.6,0,0,FrameX*0.6,ConBackground.VSize);
	}

	// Draw border.
	YStart 	= BorderLines;
	YEnd 	= FrameY - BorderLines;
	if ( BorderLines > 0 || BorderPixels > 0 )
	{
		YStart += ConsoleLines;
		if ( BorderLines > 0 )
		{
			C.SetOrigin(0.0, 0.0);
			C.SetPos(0.0, 0.0);
			C.DrawPattern( Border, FrameX, BorderLines, 1.0 );
			C.SetPos(0.0, YEnd);
			C.DrawPattern( Border, FrameX, BorderLines, 1.0 );
		}
		if ( BorderPixels > 0 )
		{
			C.SetOrigin(0.0, 0.0);
			C.SetPos(0.0, YStart);
			C.DrawPattern( Border, BorderPixels, YEnd - YStart, 1.0 );
			C.SetPos( FrameX - BorderPixels, YStart );
			C.DrawPattern( Border, BorderPixels, YEnd - YStart, 1.0 );
		}
	}

	// Draw console text.
	C.SetOrigin(0.0, 0.0);
	if ( ConsoleLines > 0 )
		DrawConsoleView( C );
	else
		DrawSingleView( C );
}

simulated function DrawConsoleView( Canvas C )
{
	local int Y, I, Line;
	local float XL, YL;

	// Console is visible; display console view.
	Y = ConsoleLines - 1;
	MsgText[(TopLine + 1 + MaxLines) % MaxLines] = "(>"@TypedStr;
	for ( I = Scrollback; I < (NumLines + 1); I++ )
	{
		// Display all text in the buffer.
		Line = (TopLine + MaxLines*2 - (I-1)) % MaxLines;

		C.Font = C.MedFont;

		if (( MsgType[Line] == 'Say' ) || ( MsgType[Line] == 'TeamSay' ))
			C.StrLen( MsgPRINames[Line]$":"@MsgText[Line], XL, YL );
		else
			C.StrLen( MsgText[Line], XL, YL );

		// Half-space blank lines.
		if ( YL == 0 )
			YL = 5;

		Y -= YL;
		if ( (Y + YL) < 0 )
			break;
		C.SetPos(4, Y);
		C.Font = C.MedFont;

		if (( MsgType[Line] == 'Say' ) || ( MsgType[Line] == 'TeamSay' ))
			C.DrawText( MsgPRINames[Line]$":"@MsgText[Line], false );
		else
			C.DrawText( MsgText[Line], false );
	}
}

simulated function DrawSingleView( Canvas C )
{
	local string TypingPrompt;
	local int I, J;
	local float XL, YL;
	local string ShortMessages[4];
	local int ExtraSpace;

	// Console is hidden; display single-line view.

	C.SetOrigin(0.0, 0.0);

	// Ask the HUD to deal with messages.
	if ( Viewport.Actor.myHUD )
	{
		XL = Class'HUD'.Default.HudScaler;
		if( XL!=1.f )
		{
			C.PushCanvasScale(XL,true);
			if ( Viewport.Actor.myHUD.DisplayMessages(C) )
			{
				C.PopCanvasScale();
				return;
			}
			C.PopCanvasScale();
		}
		else if ( Viewport.Actor.myHUD.DisplayMessages(C) )
			return;
	}

	// If the HUD doesn't deal with messages, use the default behavior
	if (!Viewport.Actor.bShowMenu)
	{
		if ( bTyping )
		{
			TypingPrompt = "(>"@TypedStr$"_";
			C.Font = C.MedFont;
			C.StrLen( TypingPrompt, XL, YL );
			C.SetPos( 2, FrameY - ConsoleLines - YL - 1 );
			C.DrawText( TypingPrompt, false );
		}
	}

	if ( TextLines > 0 && (!Viewport.Actor.bShowMenu || Viewport.Actor.bShowScores) )
	{
		J = TopLine;
		I = 0;
		while ((I < 4) && (J >= 0))
		{
			if ((Len(MsgText[J])>0) && (MsgTick[J] > 0.0))
			{
				if (MsgType[J] == 'Say')
					ShortMessages[I] = MsgPRINames[J]$":"@MsgText[J];
				else
					ShortMessages[I] = MsgText[J];
				I++;
			}
			J--;
		}

		J = 0;
		C.Font = C.MedFont;
		for ( I = 0; I < 4; I++ )
		{
			if (ShortMessages[3 - I] != "")
			{
				C.SetPos(4, 2 + (10 * J) + (10 * ExtraSpace));
				C.StrLen( ShortMessages[3 - I], XL, YL );
				C.DrawText( ShortMessages[3 - I], false );
				if ( YL == 18.0 )
					ExtraSpace++;
				J++;
			}
		}
	}
}

// Show ordinary menu.
simulated function ShowLoadGameMenu()
{
	Viewport.Actor.bSpecialMenu = true;
	Viewport.Actor.SpecialMenu = Class<Menu>(DynamicLoadObject("UnrealShare.UnrealLoadMenu",Class'Class'));
	Viewport.Actor.ShowMenu();
}

// Message history (227j)
function string PickNextHistory()
{
	History[HistoryCur % MaxHistory] = TypedStr;
	if ( HistoryCur < HistoryBot )
		return History[++HistoryCur % MaxHistory];
	else return "";
}
function string PickPrevHistory()
{
	if ( HistoryCur > HistoryTop )
	{
		History[HistoryCur % MaxHistory] = TypedStr;
		return History[--HistoryCur % MaxHistory];
	}
	return TypedStr;
}
function InsertHistory( string Txt )
{
	History[HistoryCur++ % MaxHistory] = Txt;
	if ( HistoryCur > HistoryBot )
		HistoryBot++;
	if ( HistoryCur - HistoryTop >= MaxHistory )
		HistoryTop = HistoryCur - MaxHistory + 1;
}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

state Typing
{
	exec function Type()
	{
		TypedStr="";
		gotoState( '' );
	}
	function bool KeyType( EInputKey Key )
	{
		if ( bNoStuff )
		{
			bNoStuff = false;
			return true;
		}
		if ( LastInputKey>=Asc(" ") && LastInputKey!=0x7F && LastInputKey!=Asc("~") && LastInputKey!=Asc("`") )
		{
			TypedStr = TypedStr $ Chr(LastInputKey);
			Scrollback=0;
			return true;
		}
		return false;
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;
		
		bNoStuff = false;
		if ( global.KeyEvent( Key, Action, Delta ) || Action!=IST_Press )
		{
			return true;
		}
		else if ( Key==IK_Escape )
		{
			if ( Scrollback!=0 )
			{
				Scrollback=0;
			}
			else if ( TypedStr!="" )
			{
				TypedStr="";
			}
			else
			{
				ConsoleDest=0.0;
				GotoState( '' );
			}
			Scrollback = 0;
		}
		else if ( Key==IK_Enter )
		{
			if ( Scrollback!=0 )
			{
				Scrollback = 0;
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
				Scrollback = 0;
			}
		}
		else if ( Key==IK_Up )
		{
			TypedStr = PickPrevHistory();
			Scrollback = 0;
		}
		else if ( Key==IK_Down )
		{
			TypedStr = PickNextHistory();
			Scrollback = 0;
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
		else if ( Key==IK_Backspace || Key==IK_Left )
		{
			if ( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
			Scrollback = 0;
		}
		return true;
	}
	function BeginState()
	{
		bTyping = true;
		Viewport.Actor.Typing(bTyping);
	}
	function EndState()
	{
		bTyping = false;
		Viewport.Actor.Typing(bTyping);
		log("Console leaving Typing");
		ConsoleDest=0.0;
	}
}

//-----------------------------------------------------------------------------
// State used while in a menu.

state Menuing
{
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		if ( Action != IST_Press )
			return false;
		if ( Viewport.Actor.myHUD == None || Viewport.Actor.myHUD.MainMenu == None )
			return false;

		Viewport.Actor.myHUD.MainMenu.MenuProcessInput(Key, Action);
		Scrollback=0;
		return true;
	}
	event NotifyLevelChange()
	{
		GoToState('');
	}
	function BeginState()
	{
		//log("Console entering Menuing");
	}
	function EndState()
	{
		//log("Console leaving Menuing");
	}
}

state EndMenuing
{
	// pass all key events, not just presses
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		if ( Viewport.Actor.myHUD == None || Viewport.Actor.myHUD.MainMenu == None )
			return false;

		Viewport.Actor.myHUD.MainMenu.MenuProcessInput(Key, Action);
		Scrollback=0;
		return true;
	}
}

//-----------------------------------------------------------------------------
// State used while typing in a menu.

state MenuTyping
{
	function bool KeyType( EInputKey Key )
	{
		if ( LastInputKey>=0x20 && LastInputKey!=0x7F )
		{
			TypedStr = TypedStr $ Chr(LastInputKey);
			Scrollback=0;
			if ( Viewport.Actor.myHUD && Viewport.Actor.myHUD.MainMenu )
				Viewport.Actor.myHUD.MainMenu.ProcessMenuUpdate( TypedStr );
			return true;
		}
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local Menu PlayerMenu;

		if ( Action != IST_Press )
			return false;

		if ( !Viewport.Actor.myHUD || !Viewport.Actor.myHUD.MainMenu )
			return false;

		PlayerMenu = Viewport.Actor.myHUD.MainMenu;

		if ( Key==IK_Escape )
		{
			if ( Scrollback!=0 )
				Scrollback = 0;
			else if ( TypedStr!="" )
				TypedStr="";
			else
				GotoState( 'Menuing' );
			PlayerMenu.ProcessMenuEscape();
			Scrollback=0;
		}
		else if ( Key==IK_Enter )
		{
			if ( Scrollback!=0 )
				Scrollback = 0;
			else
			{
				if ( TypedStr!="" )
					PlayerMenu.ProcessMenuInput( TypedStr );
				else PlayerMenu.ProcessMenuEscape();
				TypedStr="";
				GotoState( 'Menuing' );
				Scrollback = 0;
			}
		}
		else if ( Key==IK_Backspace || Key==IK_Left )
		{
			if ( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
			Scrollback = 0;
			PlayerMenu.ProcessMenuUpdate( TypedStr );
		}
		return true;
	}
	event NotifyLevelChange()
	{
		GoToState('');
	}
	function BeginState()
	{
		//log("Console entering MenuTyping");
	}
	function EndState()
	{
		//log("Console leaving MenuTyping");
	}
}

//-----------------------------------------------------------------------------
// State used while expecting single key input in a menu.

state KeyMenuing
{
	function bool KeyType( EInputKey Key )
	{
		if ( bValidKeyEvent )
		{
			ConsoleDest=0.0;
			if ( Viewport.Actor.myHUD!=None && Viewport.Actor.myHUD.MainMenu!=None )
				Viewport.Actor.myHUD.MainMenu.ProcessMenuKey( Key, Chr(LastInputKey) );
			Scrollback=0;
			GotoState( 'Menuing' );
		}
		Return False;
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		if ( bValidKeyEvent && Action==IST_Press )
		{
			ConsoleDest=0.0;
			if ( Viewport.Actor.myHUD!=None && Viewport.Actor.myHUD.MainMenu!=None )
				Viewport.Actor.myHUD.MainMenu.ProcessMenuKey( Key, mid(string(GetEnum(enum'EInputKey',Key)),3) );
			Scrollback=0;
			GotoState( 'Menuing' );
			return true;
		}
		Return False;
	}
	function Tick( float Delta )
	{
		Global.Tick(Delta);
		bValidKeyEvent = True;
	}
	function BeginState()
	{
		bValidKeyEvent = False;
		//log( "Console entering KeyMenuing" );
	}
	function EndState()
	{
		//log( "Console leaving KeyMenuing" );
	}
}

defaultproperties
{
	ConBackground=Texture'Engine.ConsoleBack'
	Border=Texture'Engine.Border'
	LoadingMessage="LOADING"
	SavingMessage="SAVING"
	ConnectingMessage="CONNECTING"
	PausedMessage="PAUSED"
	PrecachingMessage="PRECACHING"
	TypingOffset=-1
	GlobalConsoleKey=192
	GlobalWindowKey=27
	bConsoleCommandLog=true
}
