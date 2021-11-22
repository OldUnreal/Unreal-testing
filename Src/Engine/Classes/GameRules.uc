//=============================================================================
// 227 GameRules, modify certain game rules.
// Should be added to rules list by a mutator.
// Note: Do *not* use this class if you want your mod backwards compatible.
//=============================================================================
class GameRules extends Info
	abstract
	DependsOn(Pawn);

var GameRules NextRules;

/* Note: Try to enable only those flags you really need in order to save server resources */
var() bool bNotifyLogin; // Handle login releated stuff (ModifyPlayerSpawnClass/OverridePrelogin/AllowDownload)
var() bool bNotifySpawnPoint; // Call ModifyPlayerStart/ModifyPlayer
var() bool bNotifyRules; // Modify serverinfo rules (ModifyRules)
var() bool bNotifyMessages; // Handle message functions (AllowBroadcast/AllowChat)
var() bool bModifyDamage; // Call PreventDamage and ModifyDamage on me.
var() bool bHandleDeaths; // Handle death functions (NotifyKilled/PreventDeath)
var() bool bModifyAI; // Call ModifyThreat
var() bool bHandleMapEvents; // Call map switching functions (CanCoopTravel/CanRestartGame/CanRestartPlayer/AllowServerTravel)
var() bool bHandleInventory; // Call CanPickupInventory
var() bool bHandleGrab; // Call can handle grabbing

function AddSelfToGame()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}

/* To add to gamerules list:
G = Spawn(Your rules class);
if( Level.Game.GameRules==None )
	Level.Game.GameRules = G;
else Level.Game.GameRules.AddRules(G);
*/
function AddRules( GameRules Add )
{
	local GameRules G;
	for ( G=Self; G.NextRules!=None; G=G.NextRules ) {}
	G.NextRules = Add;
}

// Called whenever a Player uses 'Admin' command (always called)
function string ExecAdminCmd( PlayerPawn Other, string Cmd )
{
	if ( NextRules!=None )
		Return NextRules.ExecAdminCmd(Other,Cmd);
	if ( !Other.bAdmin )
		Return "";
	Return Other.ConsoleCommand(Cmd);
}

function PreBeginPlay(); // Don't call actor PreBeginPlay.

// Called whenever a pawn has Died.
function NotifyKilled( Pawn Killed, Pawn Killer, name DamageType );

// Called whenever a pawn takes damage.
function ModifyDamage( Pawn Injured, Pawn EventInstigator, out int Damage, vector HitLocation, name DamageType, out vector Momentum );

// Return true iff damage should be ignored entirely.
// This function should not produce any valuable side effects; its internal evaluations should be done only to compute the resulting value.
function bool PreventDamage( Pawn Injured, Pawn DamageInstigator, int Damage, vector HitLocation, name DamageType, vector Momentum )
{
	return false;
}

// Prevent a pawn from dying.
function bool PreventDeath( Pawn Dying, Pawn Killer, name DamageType )
{
	Return False;
}

// Modify a Pawn's threat to an another pawn. (227j: changed third parm byte to Pawn.EAttitude)
function ModifyThreat( Pawn Other, Pawn Hated, out Pawn.EAttitude Attitude );

// Allow an actor to use BroadcastMessage
function bool AllowBroadcast( Actor Broadcasting, string Msg )
{
	Return True;
}

// Allow a player to talk a chat message
function bool AllowChat( PlayerPawn Chatting, out string Msg )
{
	Return True;
}

// Modify a spawnpoint for a pawn
function ModifyPlayerStart( Pawn Respawning, out NavigationPoint SpawningPoint, byte Team );

// Coop server travel
function bool CanCoopTravel( Pawn Ender, out string NextURL )
{
	Return True;
}

// Modify a newly respawned pawn
function ModifyPlayer( Pawn Other );

// A Pawn can pick up inventory
function bool CanPickupInventory( Pawn Other, Inventory Inv )
{
	Return True;
}

// Modify a playerpawn class to spawn with
function ModifyPlayerSpawnClass( string Options, out Class<PlayerPawn> AClass );

// Player can restart himself (called by ServerRestartPlayer).
function bool CanRestartPlayer( PlayerPawn Other )
{
	Return True;
}

// Player can restart game (called by ServerRestartGame).
function bool CanRestartGame( PlayerPawn Other )
{
	Return True;
}

// Modify server query rules
function ModifyRules( out string Rules );

// Modify prelogin for whatsoever reason.
function OverridePrelogin( string Options, string PlayerName, out string Error);

/* Check if allowed to download a file off server, return false to give client downloading not allowed error */
function bool AllowDownload( NetConnection Conn, string PLName, string PLIP, string FileName, int FileSize )
{
	return true;
}

// ServerTravel was attempted:
function bool AllowServerTravel( out string URL, bool bItems )
{
	return true;
}

// Pawn can grab (decoration)
function bool CanGrab(Pawn P)
{
	return true;
} 

defaultproperties
{
	RemoteRole=ROLE_None
}
