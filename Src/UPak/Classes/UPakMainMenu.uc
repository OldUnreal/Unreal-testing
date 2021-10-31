//=============================================================================
// UPakMainMenu.
//=============================================================================
class UPakMainMenu expands UnrealMainMenu;

// All long menus use this green background.
function DrawBackGround(canvas Canvas, bool bNoLogo)
{
	local int StartX, i, num;
	
	log( "****** Drawing UPakMainMenu background" );

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
function bool ProcessSelection()
{
	local Menu ChildMenu;

	ChildMenu = None;
	if ( ! bBegun )
	{
		PlayEnterSound();
		bBegun = true;
	}

	if ( Selection == 1 )
	{ 	
		ChildMenu = spawn(class'UPakGameMenu', owner);
	}
	else if ( Selection == 2 )
		ChildMenu = spawn(class'UnrealMultiPlayerMenu', owner);
	else if ( Selection == 3 )
		ChildMenu = spawn(class'UnrealOptionsMenu', owner);
	else if ( Selection == 4 )
		ChildMenu = spawn(class'UnrealVideoMenu', owner);
	else if( (Selection==5) && bShareware )
		ChildMenu = spawn(class<menu>(DynamicLoadObject("UnrealiOrder.UnrealOrderMenu",class'Class')), owner);		
	else	
		ChildMenu = spawn(class'UPakQuitMenu', owner);

	if ( ChildMenu != None )
	{
		HUD(Owner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
	}
	return true;
}

defaultproperties
{
}
