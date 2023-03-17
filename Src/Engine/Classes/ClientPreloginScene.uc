//=============================================================================
// ClientPreloginScene - Used to display some login scene when entering a server.
// ObjectDeleted event is called when client no longer needs this object (successfully connected or connection failure).
//=============================================================================
Class ClientPreloginScene extends Object
	native
	abstract;

// Use GetLocalPlayerPawn() to grab current player.
var pointer<class UNetConnection*> NetConnection;
var const string ServerAddress; // Server IP:Port
var const string ServerMap; // Map filename were about to enter.
var const string ConnectionURL; // URL we're using to enter the server.
var const array<string> PendingDownload; // List of files yet to download (formatted as: <filename>.<ext>:<filesize>).

native final function SendMessage( coerce string S ); // Transmit message to server.

event Init(); // Called once when connection has been established and variables has been assigned.
event PostRender( Canvas C );
event ServerMessage( string S ); // Response from server.

event StartDownload( string File, int Size ); // Start a new download from server.
event DownloadProgress( int Progress ); // Update download progress.
event DownloadFailed( string Reason ); // Download failed.
event ConnectionFailed( string Reason ); // Connection rejected by server or failed by client side.

// Spawn client spectator before reciving a playerpawn when entered server level.
event PlayerPawn SpawnClientCamera( LevelInfo NewLevel )
{
	return NewLevel.SpawnClientCamera();
}
