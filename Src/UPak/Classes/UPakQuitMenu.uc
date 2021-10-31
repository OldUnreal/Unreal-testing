//=============================================================================
// UPakQuitMenu.
//=============================================================================
class UPakQuitMenu expands UnrealQuitMenu;

// All long menus use this green background.
function DrawBackGround(canvas Canvas, bool bNoLogo)
{
	local int StartX, i, num;

	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;	
	Canvas.bNoSmooth = True;	

	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.Style = 1;
	Canvas.SetPos(StartX,0);
	Canvas.DrawIcon(texture'Menu2', 1.0);
	
	num = int(Canvas.ClipY/256) + 1;
	StartX = 0.5 * Canvas.ClipX - 128;
	for ( i=1; i<=num; i++ )
	{
		Canvas.SetPos(StartX,256*i);
		Canvas.DrawIcon(texture'Menu2', 1.0);
	}
	
	if ( bNoLogo )
		Return;
	
	Canvas.Style = 3;	
	StartX = 0.5 * Canvas.ClipX - 128;	
	Canvas.SetPos(StartX,Canvas.ClipY-58);	
	Canvas.DrawTile( Texture'MenuBarrier', 256, 64, 0, 0, 256, 64 );
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.Style = 2;	
	Canvas.SetPos(StartX,Canvas.ClipY-52);
	Canvas.DrawIcon(texture'Return', 1.0);	
	Canvas.Style = 1;
}


function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, SecSpace;
	
	DrawBackGround(Canvas, (Canvas.ClipY < 320));
	
	StartX = 0.5 * Canvas.ClipX - 120;
	StartY = 2;
	Spacing = 2;
	Canvas.Font = Canvas.MedFont;
	
	Canvas.SetPos(StartX, StartY );
	Canvas.DrawText(MenuList[0], False);	
	Canvas.SetPos(StartX+72, StartY+10 );	
	Canvas.DrawText(MenuList[1], False);	
	StartX = Max(8, 0.5 * Canvas.ClipX - 116);	
	Spacing = Clamp(0.04 * Canvas.ClipY, 7, 40);
	StartY = 16 + Spacing;
	SecSpace =  Spacing/10;
	Canvas.Font = Canvas.SmallFont;
	
	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 30;
		
	Canvas.SetPos(StartX, StartY);
	Canvas.DrawText(MenuList[2], false);
	Canvas.SetPos(StartX+4, StartY+Spacing);
	Canvas.DrawText(MenuList[3], false);
	Canvas.SetPos(StartX, StartY+Spacing*2+SecSpace);

	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 30;
	
	Canvas.DrawText(MenuList[4], false);	
	Canvas.SetPos(StartX+4, StartY+Spacing*3+SecSpace);
	Canvas.DrawText(MenuList[5],  false);	

	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 30;

	Canvas.SetPos(StartX+4, StartY+Spacing*4+SecSpace);
	Canvas.DrawText(MenuList[6],  false);		

	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 30;

	Canvas.SetPos(StartX+4, StartY+Spacing*5+SecSpace);
	Canvas.DrawText(MenuList[7],  false);

	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 30;
	
	Canvas.SetPos(StartX, StartY+Spacing*6+SecSpace*2);
	Canvas.DrawText(MenuList[8],  false);
	
	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 30;

	Canvas.SetPos(StartX, StartY+Spacing*7+SecSpace*3);
	Canvas.DrawText(MenuList[9],  false);

	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 30;

	Canvas.SetPos(StartX+4, StartY+Spacing*8+SecSpace*3);
	Canvas.DrawText(MenuList[10],  false);	

	Canvas.SetPos(StartX, StartY+Spacing*9+SecSpace*4);
	Canvas.DrawText(MenuList[11],  false);
	Canvas.SetPos(StartX+4, StartY+Spacing*10+SecSpace*4);
	Canvas.DrawText(MenuList[12],  false);
	Canvas.SetPos(StartX+4, StartY+Spacing*11+SecSpace*4);
	Canvas.DrawText(MenuList[13],  false);		

	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 30;
	Canvas.SetPos(StartX, StartY+Spacing*12+SecSpace*5);
	Canvas.DrawText(MenuList[14],  false);	
	Canvas.SetPos(StartX+4, StartY+Spacing*13+SecSpace*5);
	Canvas.DrawText(MenuList[15],  false);
	
	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 90;
	Canvas.DrawColor.B = 30;

	Canvas.SetPos(StartX, StartY+Spacing*14+SecSpace*6);
	Canvas.DrawText(MenuList[16],  false);	

	Canvas.DrawColor.R = 40;
	Canvas.DrawColor.G = 60;
	Canvas.DrawColor.B = 20;
	
	Canvas.SetPos(StartX, StartY+Spacing*15+SecSpace*7);
	Canvas.DrawText(MenuList[17],  false);	
	
	Canvas.DrawColor.R = 30;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 30;

	Canvas.SetPos(StartX, StartY+Spacing*16+SecSpace*8);
	Canvas.DrawText(MenuList[18],  false);
	Canvas.SetPos(StartX, StartY+Spacing*17+SecSpace*9);
	Canvas.DrawText(MenuList[19],  false);
	Canvas.SetPos(StartX, StartY+Spacing*18+SecSpace*10);
	Canvas.DrawText(MenuList[20],  false);
	Canvas.SetPos(StartX, StartY+Spacing*19+SecSpace*11);
	Canvas.DrawText(MenuList[21],  false);

			
	// draw text
	Canvas.Font = Canvas.MedFont;	
	SetFontBrightness(Canvas, true);
	StartY = Clamp(StartY+Spacing*17+SecSpace*9, Canvas.ClipY - 66, Canvas.ClipY - 12);
	Canvas.bCenter = true;
	Canvas.SetPos(0, StartY );
	if ( bResponse )
		Canvas.DrawText(MenuTitle$YesSelString, False);
	else
		Canvas.DrawText(MenuTitle$NoSelString, False);
	Canvas.DrawColor = Canvas.Default.DrawColor;
	Canvas.bCenter = false;

	// Draw help panel
//	DrawHelpPanel(Canvas, 0.5 * Canvas.ClipY + 16, 228);
}

defaultproperties
{
}
