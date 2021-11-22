//=============================================================================
// LogHandler: Used to watch logging. Written by Marco.
// These hooks gets called before log suppression filtering.
//=============================================================================
Class LogHandler extends Object
	native
	abstract;

// If not enabled, this handler is not linked to listeners.
var const bool bEnabled;

// Link priority (highest gets called first).
var const int Priority;

// Types of logging to catch.
var const array<name> LogTypes;

native final function SetEnabled( bool bEnable );
native final function AddLogType( name N, optional bool bRemove );

// Output, return True to prevent it from being written to Log file.
event bool OnLogLine( name N, string S )
{
	return false;
}

defaultproperties
{
	bEnabled=true
}