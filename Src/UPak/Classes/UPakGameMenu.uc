//=============================================================================
// UPakGameMenu.
//=============================================================================
class UPakGameMenu expands UnrealGameMenu;

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( (Selection == 1) && (Level.NetMode == NM_Standalone)
				&& !Level.Game.IsA('DeathMatchGame') )
		ChildMenu = spawn(class'UnrealSaveMenu', owner);
	else if ( Selection == 2 ) 
		ChildMenu = spawn(class'UnrealLoadMenu', owner);
	else if ( Selection == 3 )
		ChildMenu = spawn(class'UPakChooseGameMenu', owner);
	else if ( Selection == 4 )
	{
		if ( (Level.Game != None) && (Level.Game.GameMenuType != None) )
			ChildMenu = spawn(Level.Game.GameMenuType, owner);
	}
	else if ( Selection == 5 )
	{
		ChildMenu = spawn(class'UnrealServerMenu', owner);
		UnrealServerMenu(ChildMenu).bStandAlone = true;
	}
	else 
		return false;

	if ( ChildMenu != None )
	{
		HUD(Owner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
	}
	return true;
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
}
