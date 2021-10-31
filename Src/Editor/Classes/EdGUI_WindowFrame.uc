Class EdGUI_WindowFrame extends EdGUI_Base
	native
	abstract
	config(UnrealEd);
	
cpptext
{
	static TArray<UEdGUI_WindowFrame*> ActiveWindows;
	UEdGUI_WindowFrame() {}
	void Destroy();
	void Init();
	void Close(UBOOL bRemoved = 0);
	virtual void OnCallback(class UEdGUI_Base* Component, ESignalType Type);
	void DoClose();
	void SetCaption(const TCHAR* NewCaption);
}
	
var const EdGUI_WindowFrame DialogMaster; // Master window for a dialogue frame (if None, its main editor frame or not a dialogue window).
var const EdGUI_Base ComponentList;
var pointer Canvas;

var() const string Caption; // Window title bar.
var() int MinX,MinY; // Minimum window size.
var() config int X,Y,XSize,YSize; // Window coordinates and size (X/Y offset -1 means centered on screen).

var() bool bCanResize,
			bIsDialogue; // If True, this window stays same level as editor main frame, if False, this window will receive own title in windows menubar.
var bool bNeedsPaint; // If true, call OnPaint.
var transient bool bShouldRepaint; // Call repaint on next tick.

// Timer:
var transient float TimerCounter,TimerRate;
var transient bool bTimerLoop;

enum ESignalType
{
	SG_LeftClick,
	SG_RightClick,
	SG_DblClick,
	SG_ValueChange,
	SG_HitEnter,
};

// Create a new window
// @bUnique - Only allow one instance of this window class to excist, that will bring that window to front and return it.
// @DialogOwner - If bIsDialogue, this is the owner window, if owner window is closed, so is this window.
// Window class is the class this function is being called on: ABC = class'ABC'.CreateWindow();
static native final function EdGUI_WindowFrame CreateWindow( optional bool bUnique /*=true*/, optional EdGUI_WindowFrame DialogOwner );

// Find a window without interacting with it nor creating it.
static native final function EdGUI_WindowFrame FindWindow();

// Paint functions.
// Draw a single colored rect from U -> UL/V -> VL.
native final function DrawRect( color Color, int U, int V, int UL, int VL );

// Draw text
// PivotX/Y: 0 = pivot is left/top, 1 = center, 2 = right/bottom.
native final function DrawText( string Text, int X, int Y, optional byte PivotX, optional byte PivotY, optional color Color /*=black*/ );

event OnClosed()
{
	SaveConfig();
}

// A callback signal from a component.
event OnCallback( EdGUI_Base Component, ESignalType Type );

// Called if bNeedsPaint and only when some elements are changed (components added or removed, window resized etc).
event OnPaint();

final function SetTimer( optional float Rate, optional bool bLoop )
{
	TimerCounter = Rate;
	TimerRate = Rate;
	bTimerLoop = bLoop;
}

event Timer();

defaultproperties
{
	Caption="Window Frame"
	X=-1
	Y=-1
	MinX=200
	MinY=100
	XSize=200
	YSize=100
	bIsDialogue=true
}