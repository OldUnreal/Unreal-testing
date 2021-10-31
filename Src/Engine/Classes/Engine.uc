//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
	native
	transient
	abstract;

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
var int TickCycles, GameCycles, ClientCycles;
var(Settings) config int CacheSizeMegs;
var(Settings) config bool UseSound;

var(Settings) float CurrentTickRate;

static native final function Engine GetEngine();

// Send a consolecommand to engine (functions the same as Actor.ConsoleCommand).
static native final function string ConsoleCommand(string Command, optional bool bPrintToLog /*=true*/ );

defaultproperties
{
	CacheSizeMegs=8
	UseSound=True
}
