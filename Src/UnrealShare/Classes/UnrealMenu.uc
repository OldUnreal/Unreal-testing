//=============================================================================
// UnrealMenu
//
// Master class of all UnrealI menus.  Contains nonstyle specific utilities
// for all menu types (Info/Long/Short).
//=============================================================================
class UnrealMenu extends Menu;

#exec TEXTURE IMPORT NAME=IconSkull FILE=Textures\Hud\i_skull.pcx GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=TranslatorHUD3 FILE=Models\TRANHUD3.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

#exec Font Import File=Textures\TinyFont.pcx Name=TinyFont
#exec Font Import File=Textures\TinyFon3.pcx Name=TinyWhiteFont
#exec Font Import File=Textures\TinyFon2.pcx Name=TinyRedFont

#exec Texture Import File=Textures\dot.pcx Name=Dot MIPS=OFF FLAGS=2
#exec Texture Import File=Textures\Slide1.pcx Name=Slide1 MIPS=OFF VClampMode=VClamp UClampMode=UClamp FLAGS=2
#exec Texture Import File=Textures\Slide2.pcx Name=Slide2 MIPS=OFF VClampMode=VClamp
#exec Texture Import File=Textures\Slide3.pcx Name=Slide3 MIPS=OFF VClampMode=VClamp UClampMode=UClamp FLAGS=2
#exec Texture Import File=Textures\Slide4.pcx Name=Slide4 MIPS=OFF VClampMode=VClamp
#exec Texture Import File=Textures\ex.pcx Name=ex MIPS=OFF FLAGS=2
#exec Texture Import File=Textures\check.pcx Name=Check MIPS=OFF FLAGS=2

#exec OBJ LOAD FILE=Textures\menugr.utx PACKAGE=UnrealShare.MenuGfx

#exec Texture Import File=Textures\HD_Icons\HDlogo2.dds Name=HDlogo2 Group="HD" Mips=Off Flags=131074
#exec TEXTURE IMPORT NAME=logo2 FILE=Textures\Hud\logo2.pcx GROUP="MenuGfx" FLAGS=2 MIPS=OFF HD=HDlogo2

#exec AUDIO IMPORT FILE="Sounds\Menu\Select4.wav" NAME="Select4" GROUP="Menu"
#exec AUDIO IMPORT FILE="Sounds\Menu\updown3.wav" NAME="Updown3" GROUP="Menu"
#exec AUDIO IMPORT FILE="Sounds\Menu\side1b.wav" NAME="side1b" GROUP="Menu"

simulated function PlaySelectSound()
{
	PlayerOwner.PlaySound(sound'updown3');
}

simulated function PlayModifySound()
{
	PlayerOwner.PlaySound(sound'Select4',,2.0);
}

simulated function PlayEnterSound()
{
	PlayerOwner.PlaySound(sound'Select4',,2.0);
}

function DrawTitle(canvas Canvas)
{
	if ( Canvas.ClipY < 300 )
	{
		Canvas.Font = Canvas.BigFont;
		Canvas.SetPos(Max(8, 0.5 * Canvas.ClipX - 4 * Len(MenuTitle)), 4 );
	}
	else
	{
		Canvas.Font = Canvas.LargeFont;
		Canvas.SetPos(Max(8, 0.5 * Canvas.ClipX - 8 * Len(MenuTitle)), 4 );
	}
	Canvas.DrawText(MenuTitle, False);
}

function DrawList(canvas Canvas, bool bLargeFont, int Spacing, int StartX, int StartY)
{
	local int i;

	if ( bLargeFont )
	{
		if ( Spacing < 30 )
		{
			StartX += 0.5 * ( 0.5 * Canvas.ClipX - StartX);
			Canvas.Font = Canvas.BigFont;
		}
		else
			Canvas.Font = Canvas.LargeFont;
	}
	else
		Canvas.Font = Canvas.MedFont;

	for (i=0; i< (MenuLength); i++ )
	{
		SetFontBrightness(Canvas, (i == Selection - 1) );
		Canvas.SetPos(StartX, StartY + Spacing * i);
		Canvas.DrawText(MenuList[i + 1], false);
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

function DrawSlider( canvas Canvas, int StartX, int StartY, int Value, int sMin, int StepSize )
{
	local int i;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(StartX, StartY);
	Canvas.DrawIcon(Texture'Slide1',1.0);
	Canvas.SetPos(StartX+8, StartY);
	Canvas.DrawRect(Texture'Slide4',64.f,8.f);
	Canvas.SetPos(StartX+64.f+8.f, StartY);
	Canvas.DrawIcon(Texture'Slide3',1.0);
	i = int(FClamp(float(Value-sMin) / (StepSize*8.f),0.f,1.f) * (5.f + 64.f - 6.f));
	Canvas.SetPos(StartX+5+i, StartY);
	Canvas.DrawIcon(Texture'Dot',1.0);
}

defaultproperties
{
}
