//=============================================================================
// UnrealHelpMenu
//=============================================================================
class UnrealHelpMenu extends UnrealLongMenu;

function bool ProcessSelection()
{
	if ( Selection == 1 )
		PlayerOwner.ConsoleCommand("START ..\\help\\trouble.htm");
	else
		return false;

	return true;
}

function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, HelpPanelX;

	DrawBackGround(Canvas, (Canvas.ClipY < 250));

	HelpPanelX = 228;

	Spacing = Clamp(0.06 * Canvas.ClipY, 12, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);

	DrawTitle(Canvas);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing, HelpPanelX);
}

defaultproperties
{
	MenuLength=1
	HelpMessage(1)="Open the troubleshooting document."
	MenuList(1)="TroubleShooting"
	MenuTitle="HELP"
}
