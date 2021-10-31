//=============================================================================
// UnrealLoadMenu
//=============================================================================
class UnrealLoadMenu extends UnrealSlotMenu;

var() localized string RestartString;

function bool ProcessSelection()
{
	if ( Selection > Array_Size(Slots) )
	{
		GotoState('Restart');
		PlayerOwner.Player.Console.GotoState('EndMenuing');
		return true;
	}

	GotoState('LoadGame');
	PlayerOwner.Player.Console.GotoState('EndMenuing');
	return true;
}

function DrawMenu(canvas Canvas)
{
	DrawBackGround(Canvas, (Canvas.ClipY < 320));

	DrawTitle(Canvas);
	DrawSlots(Canvas);
}

function DrawSlots(canvas Canvas)
{
	Super.DrawSlots(Canvas);
}

state LoadGame
{
	function MenuProcessInput( byte KeyNum, byte ActionNum )
	{
		if (KeyNum == EInputKey.IK_Enter && ActionNum == EInputAction.IST_Release)
		{
			bExitAllMenus = true;
			PlayerOwner.ClientTravel( "?load=" $ Slots[Selection-1].Index, TRAVEL_Absolute, false);
			super.MenuProcessInput(KeyNum, ActionNum); // exit all menus
		}
		else if (KeyNum == EInputKey.IK_Escape)
		{
			PlayerOwner.Player.Console.GotoState('Menuing');
			super.MenuProcessInput(KeyNum, ActionNum);
		}
	}
}

state Restart
{
	function MenuProcessInput( byte KeyNum, byte ActionNum )
	{
		if (KeyNum == EInputKey.IK_Enter && ActionNum == EInputAction.IST_Release)
			PlayerOwner.RestartLevel();
		else if (KeyNum == EInputKey.IK_Escape)
		{
			PlayerOwner.Player.Console.GotoState('Menuing');
			super.MenuProcessInput(KeyNum, ActionNum);
		}
	}
}

defaultproperties
{
	RestartString="Restart "
	MenuLength=10
	MenuTitle="LOAD GAME"
}
