//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
	native
	transient
	abstract;

struct export CreditsInfo
{
	var string Credits,Website;
	var Texture Logo;
};

// Drivers.
var(Drivers) config class<RenderDevice>   GameRenderDevice;
var(Drivers) config class<AudioSubsystem> AudioDevice;
var(Drivers) config class<Console>        Console;
var(Drivers) config class<NetDriver>      NetworkDevice;
var(Drivers) config class<Language>       Language;
var(Drivers) config class<PhysicsEngine>  PhysicsEngine;

// Variables.
var const primitive Cylinder;
var const client Client;
var const renderbase Render;
var const audiosubsystem Audio;
var const PhysicsEngine Physics;
var const array<CreditsInfo> DriverCredits;
var int TickCycles, GameCycles, ClientCycles;
var(Settings) config int CacheSizeMegs;
var(Settings) config bool UseSound;

var(Settings) float CurrentTickRate;

static invariant native final function Engine GetEngine();

// Send a consolecommand to engine (functions the same as Actor.ConsoleCommand).
static native final function string ConsoleCommand(string Command, optional bool bPrintToLog /*=true*/ );

// Game has currently RigidBodies enabled.
static invariant final function bool IsPhysicsEnabled()
{
	return bool(GetEngine().Physics);
}

// Store a login password for a server, will be automatically appended when trying to login to said remote address.
// (not accessible in UnrealScript for security reasons)
static native final function StorePassword( string Addr, string Password );

defaultproperties
{
	CacheSizeMegs=8
	UseSound=True
}
