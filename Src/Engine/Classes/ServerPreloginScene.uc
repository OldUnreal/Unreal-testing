//=============================================================================
// ServerPreloginScene - Used to display some login scene for your server.
//=============================================================================
Class ServerPreloginScene extends Object
	native
	abstract;

var LevelInfo Level;
var GameInfo Game;

var() class<ClientPreloginScene> ClientScene; // Scene that client should display.

// Note: You can use serverside consolecommand 'CLEARPRELOADS' to empty this preloadlist.
native final function AddPreloginPackage( string S ); // Add a named package as pre-login package (ClientScene package is added automatically during init). NOTE: Referenced packages are NOT added automatically!
native final function SendClientMessage( NetConnection C, coerce string S ); // Send a prelogin message to a client.

event ClientMessage( NetConnection C, string S ); // Received a prelogin message from a client.
event ClientDisconnect( NetConnection C, string Reason ); // Client disconnected during prelogin.
event ClientConnect( NetConnection C ); // Client reached PostLogin (C.Actor is now valid).

event Init(); // Called during GameInfo.PostBeginPlay after this object has had its variables assigned.

event class<ClientPreloginScene> GetClientScene( NetConnection C ) // A new client is about to join.
{
	return ClientScene;
}
