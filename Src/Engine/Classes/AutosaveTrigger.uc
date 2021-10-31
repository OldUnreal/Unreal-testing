//=============================================================================
// AutosaveTrigger: When triggered, perform an autosave.
//=============================================================================
Class AutosaveTrigger extends Triggers;

var localized string AutoSaveString;
var() bool bTriggerOnceOnly; // Only trigger once and then go dormant.

function Trigger( actor Other, pawn EventInstigator )
{
	if( Level.NetMode==NM_StandAlone && !Level.Game.bDeathMatch && GetLocalPlayerPawn().Health>0 )
	{
		GetLocalPlayerPawn().ClientMessage(AutoSaveString);
		GetLocalPlayerPawn().ConsoleCommand("SaveGame 0 AutoSave");
	}
	if( bTriggerOnceOnly )
		Disable('Trigger');
}

defaultproperties
{
	bTriggerOnceOnly=true
	Texture=Texture'S_SpecialEvent'
	AutoSaveString="Auto Saving"
	bCollideActors=false
	RemoteRole=ROLE_None
	CollisionRadius=16
	CollisionHeight=16
}