//=============================================================================
// UnrealLongMenu
//
// The long "green" UnrealI menus.
//=============================================================================
class UnrealLongMenu extends UnrealMenu;

// All long menus use this green background.
function DrawBackGround(canvas Canvas, bool bNoLogo)
{
	local int StartX;

	Canvas.DrawColor = MakeColor(255,255,255,255);
	Canvas.bNoSmooth = False;

	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(StartX,0);
	Canvas.DrawTile(texture'Menu2', 256.f, Canvas.ClipY, 0, 0, 256.f, Canvas.ClipY);

	if ( bNoLogo )
		Return;

	Canvas.Style = ERenderStyle.STY_Translucent;
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.SetPos(StartX,Canvas.ClipY-58);
	Canvas.DrawTile( Texture'MenuBarrier', 256, 64, 0, 0, 256, 64 );
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(StartX,Canvas.ClipY-52);
	Canvas.DrawIcon(texture'Logo2', 1.0);
}

// All long menus use this "help panel."  A small area at the bottom
// of the menu describing the currently selected option.
function DrawHelpPanel(canvas Canvas, int MinStartY, int XClip)
{
	local int OldXClip, OldYClip;
	local int StartX, StartY;
	local float XL, YL;

	if ( Canvas.ClipY < 92 + MinStartY )
		return;

	StartX = 0.5 * Canvas.ClipX - 128;
	StartY = Canvas.ClipY - 92;
	OldXClip = Canvas.ClipX;
	OldYClip = Canvas.ClipY;

	Canvas.bCenter = false;
	Canvas.Font = Canvas.MedFont;
	Canvas.SetOrigin(StartX + 18, StartY);
	Canvas.SetClip(XClip,128);
	Canvas.SetPos(0,0);
	Canvas.Style = 1;
	SetFontBrightness(Canvas, true);
	if ( Selection < 20 )
	{
		Canvas.StrLen(HelpMessage[Selection], XL, YL);
		if (YL <= Canvas.ClipY && MinStartY + YL <= OldYClip)
		{
			if (StartY + YL > OldYClip)
				Canvas.OrgY = OldYClip - YL;
			Canvas.DrawText(HelpMessage[Selection], false);
		}
	}
	SetFontBrightness(Canvas, false);
	Canvas.SetOrigin(0, 0);
	Canvas.SetClip(OldXClip,OldYClip);
}

// Each menu provides its own implementation of DrawMenu.
function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing;

	Spacing = Clamp(0.1 * Canvas.ClipY, 32, 48);
	StartX = Max(8, 0.5 * Canvas.ClipX - 160);
	StartY = Max(4, 0.5 * (Canvas.ClipY - 5 * Spacing - 128));
	Canvas.Font = Canvas.LargeFont;

	// draw text
	Canvas.SetPos(StartX, StartY );
	Canvas.DrawText("NOT YET IMPLEMENTED", False);

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + 5 * Spacing, 228);
}

defaultproperties
{
}
