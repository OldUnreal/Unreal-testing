//=============================================================================
// EndGame.
//=============================================================================
class EndGame extends UnrealGameInfo
	NoUserCreate;

event AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv;

	// accept no inventory
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
	for ( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		Inv.Destroy();
}


function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

defaultproperties
{
	DefaultWeapon=None
	HUDType=Class'UnrealI.EndgameHud'
}
