//=============================================================================
// UMenuRootWindow - root window subclass for Unreal Menu System
//=============================================================================
class UMenuRootWindow extends UWindowRootWindow;

#exec TEXTURE IMPORT NAME=Bg11 FILE=Textures\Bg-11.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg21 FILE=Textures\Bg-21.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg31 FILE=Textures\Bg-31.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg41 FILE=Textures\Bg-41.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg12 FILE=Textures\Bg-12.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg22 FILE=Textures\Bg-22.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg32 FILE=Textures\Bg-32.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg42 FILE=Textures\Bg-42.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg13 FILE=Textures\Bg-13.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg23 FILE=Textures\Bg-23.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg33 FILE=Textures\Bg-33.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=Bg43 FILE=Textures\Bg-43.pcx GROUP="Icons" MIPS=OFF VClampMode=VClamp UClampMode=UClamp
#exec TEXTURE IMPORT NAME=MenuBlack FILE=Textures\MenuBlack.bmp GROUP="Icons" MIPS=OFF

var	UMenuMenuBar MenuBar;
var	UMenuStatusBar StatusBar;
var Font BetaFont;

function Created()
{
	Super.Created();

	StatusBar = UMenuStatusBar(CreateWindow(class'UMenuStatusBar', 0, 0, 50, 16));
	StatusBar.HideWindow();

	MenuBar = UMenuMenuBar(CreateWindow(class'UMenuMenuBar', 50, 0, 500, 16));

	BetaFont = Font(DynamicLoadObject("UWindowFonts.UTFont40", class'Font'));
	Resized();
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local int XOffset, YOffset;
	local float W, H;

	if (Console.bNoDrawWorld)
	{
		DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MenuBlack');

		if (Console.bBlackOut)
			return;

		W = WinWidth / 4;
		H = W;

		if (H > WinHeight / 3)
		{
			H = WinHeight / 3;
			W = H;
		}

		XOffset = (WinWidth - (4 * (W-1))) / 2;
		YOffset = (WinHeight - (3 * (H-1))) / 2;

		C.bNoSmooth = False;

		DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'Bg43');
		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'Bg33');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'Bg23');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'Bg13');

		DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'Bg42');
		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'Bg32');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'Bg22');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'Bg12');

		DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'Bg41');
		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'Bg31');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'Bg21');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'Bg11');

		C.bNoSmooth = True;
	}
}

function Resized()
{
	Super.Resized();

	MenuBar.WinLeft = 0;;
	MenuBar.WinTop = 0;
	MenuBar.WinWidth = WinWidth;;
	MenuBar.WinHeight = 16;

	StatusBar.WinLeft = 0;
	StatusBar.WinTop = WinHeight - StatusBar.WinHeight;
	StatusBar.WinWidth = WinWidth;
}

function DoQuitGame()
{
	MenuBar.SaveConfig();
	if ( GetLevel().Game != None )
	{
		GetLevel().Game.SaveConfig();
		GetLevel().Game.GameReplicationInfo.SaveConfig();
	}
	Super.DoQuitGame();
}

function SetContextHelp(string Text)
{
	if (StatusBar != none)
		StatusBar.SetHelp(Text);
}

defaultproperties
{
	LookAndFeelClass="UMenu.UMenuGoldLookAndFeel"
}
