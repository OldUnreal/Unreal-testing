//=============================================================================
// DarkMatch.
//=============================================================================
class DarkMatch extends DeathMatchGame
	NoUserCreate;

function AddDefaultInventory(Pawn Player)
{
	if (Player.IsA('Spectator'))
		return;
	super.AddDefaultInventory(Player);
	AddPlayerDefaultPickup(Player, class'SearchLight', true);
}

defaultproperties
{
				MapListType=Class'UnrealI.DKmaplist'
				MapPrefix="DK"
				GameName="DarkMatch"
}