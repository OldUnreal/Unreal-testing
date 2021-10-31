//=============================================================================
// CreditsGame.uc
//=============================================================================
class CreditsGame extends GameInfo;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;

	// Don't allow player to be a spectator
	if( !SpawnClass.Default.bCollideActors )
		SpawnClass = class'UPak.UPakMaleTwo';

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.bHidden = True;

	return NewPlayer;
}

function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv;

	// get rid of everything!
	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		Inv.Destroy();
	}
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

function float PlaySpawnEffect(inventory Inv)
{
	return 0;
}

function bool SetPause( BOOL bPause, PlayerPawn P )
{
	return False;
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return false;
}

defaultproperties
{
     bGameEnded=True
     HUDType=Class'Engine.HUD'
}
