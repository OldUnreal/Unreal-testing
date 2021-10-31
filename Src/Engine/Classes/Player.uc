//=============================================================================
// Player: Corresponds to a real player (a local camera or remote net player).
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Player extends Object
		native
			noexport;

//-----------------------------------------------------------------------------
// Player properties.

// Internal.
var pointer vfOut;
var pointer vfExec;

// The actor this player controls.
var transient const playerpawn Actor;
var transient const console Console;

// Window input variables
var transient const bool bWindowsMouseAvailable;
var bool bShowWindowsMouse;
var transient const float WindowsMouseX;
var transient const float WindowsMouseY;
var byte SelectedCursor;
var transient UnrealCursor CustomCursor; // This is set to None on mapchange by C++ codes.

const IDC_ARROW=0;
const IDC_SIZEALL=1;
const IDC_SIZENESW=2;
const IDC_SIZENS=3;
const IDC_SIZENWSE=4;
const IDC_SIZEWE=5;
const IDC_WAIT=6;

defaultproperties
{
}
