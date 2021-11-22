//=============================================================================
// UPakChooseGameMenu.
//=============================================================================
class UPakChooseGameMenu expands UnrealChooseGameMenu;

var() nowarn config string StartMaps[20];
var() nowarn config string GameNames[20];

function PostBeginPlay()
{
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	ChildMenu = spawn(class'UnrealNewGameMenu', owner);

	HUD(Owner).MainMenu = ChildMenu;
	ChildMenu.PlayerOwner = PlayerOwner;
	PlayerOwner.UpdateURL("Game","", false);
	UnrealNewGameMenu(ChildMenu).StartMap = StartMaps[Selection];

	if ( MenuLength == 1 )
	{
		ChildMenu.ParentMenu = ParentMenu;
		Destroy();
	}
	else
		ChildMenu.ParentMenu = self;
		
	return true;
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;

	if ( MenuLength == 1 )
	{
		DrawBackGround(Canvas, false);
		Selection = 1;
		ProcessSelection();
		return;
	}

	DrawBackGround(Canvas, false);
	DrawTitle(Canvas);

	Canvas.Style = 3;
	Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	for ( i=0; i<20; i++ )
	{
		MenuList[i] = GameNames[i];
	}
	DrawList(Canvas, false, Spacing, StartX, StartY); 

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing + 8, 228);
}

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

defaultproperties
{
     StartMaps(0)="Intro2.unr"
     StartMaps(1)="Intro2.unr"
     StartMaps(2)="Vortex2.unr"
     GameNames(1)="Unreal: Return to Na Pali"
     GameNames(2)="Unreal"
     MenuLength=3
     MenuList(0)="Return to Na Pali"
     MenuList(1)="Unreal"
}
