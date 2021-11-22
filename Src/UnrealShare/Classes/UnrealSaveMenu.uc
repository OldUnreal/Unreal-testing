//=============================================================================
// UnrealSaveMenu
//=============================================================================
class UnrealSaveMenu extends UnrealSlotMenu;

var localized string CantSave;

function BeginPlay()
{
	Super.BeginPlay();
}

function bool ProcessSelection()
{
	if ( PlayerOwner.Health <= 0 )
		return true;

	bExitAllMenus = true;
	PlayerOwner.bDelayedCommand = true;
	PlayerOwner.DelayedCommand = "SaveGame "$Slots[Selection-1].Index;
	return true;
}

function DrawMenu(canvas Canvas)
{
	if ( PlayerOwner.Health <= 0 )
	{
		MenuTitle = CantSave;
		DrawTitle(Canvas);
		return;
	}
	DrawBackGround(Canvas, (Canvas.ClipY < 320));
	DrawTitle(Canvas);
	DrawSlots(Canvas);
}

defaultproperties
{
	CantSave="CAN'T SAVE WHEN DEAD"
	MenuTitle="SAVE GAME"
	bSaveGame=true
}
