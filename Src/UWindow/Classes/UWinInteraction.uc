// UWindow Interaction - For modifing canvas rendering and input.
// Written by .:..: for Unreal 227.
// Note: this object does NOT receive "exec" function calls.
Class UWinInteraction extends Object
Abstract;

var Player Viewport;
var WindowConsole Console;

// Note: try to keep unused fuction calls on False to save CPU resources.
var() bool bRequestTick,bRequestInput,bRequestRender,bRequestMessages,bRemoveAfterMapchange;

function Initialized()
{
}

function Tick( float Delta )
{
}

function NotifyLevelChange()
{
}

// Input, return True to override.
function bool KeyType( byte Key )
{
	Return False;
}

function bool KeyEvent( byte Key, byte Action, FLOAT Delta )
{
	Return False;
}

function PostRender( Canvas Canvas )
{
}

function bool Message( PlayerReplicationInfo PRI, string Msg, name N )
{
	Return False; // Return True to prevent it from being reached by console.
}

defaultproperties
{
	bRemoveAfterMapchange=True
}
