//=============================================================================
// GameEngine
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
Class GameEngine extends Engine
	native
	transient;

const VALID_IPV4 = 1;
const VALID_HOSTNAME = 1;
const VALID_IPV6 = 3;

struct URL
{
	// URL components.
	var string Protocol;	// Protocol, i.e. "unreal" or "http".
	var string Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int Port;       // Optional host port.
	var string Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string> Op;	// Options.
	var string Portal;		// Portal to enter through, default is "".
	var int Valid;		// Whether parsed successfully.
};

var Level								GLevel;
var Level								GEntry;
var PendingLevel						GPendingLevel;
var URL									LastURL;
var(Settings) config array<string>		ServerActors; // Actors that should spawn along with starting up a server.
var(Settings) config array<string>		ServerPackages; // Packages that will be forced to be downloaded by clients and should remain network syncronized on the server.
var(Settings) config bool				bServerSaveInventory, // Save client inventory on ini file for server.
										bDeleteTravelInvOnLoad; // Delete client inventory data upon connection.
var transient bool						bIsFirstBoot;
