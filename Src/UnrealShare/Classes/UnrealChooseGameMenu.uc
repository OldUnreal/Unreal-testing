//=============================================================================
// UnrealChooseGameMenu
// finds all the single player game types (using the .int files)
// then allows the player to choose one (if there is only one, this menu never displays)
//=============================================================================
class UnrealChooseGameMenu extends UnrealLongMenu;

struct FGameEntry
{
	var string StartMap, GameName, GameClass, TextureName;
	var Texture ScreenShot;
};
var FGameEntry GameList[19];

function PostBeginPlay()
{
	local string Ent,Des;
	local int i,j;

	Super.PostBeginPlay();
	MenuLength = 0;
	GetNextIntDesc("UnrealShare.SinglePlayer",i++,Ent,Des);
	while ( (Ent!= "") && (MenuLength < 20) )
	{
		if ( Des!="" )
		{
			j = InStr(Des,";");
			if ( j!=-1 )
			{
				GameList[MenuLength].StartMap = Left(Des,j);
				Des = Mid(Des,j+1);
				j = InStr(Des,";");
				if ( j!=-1 )
				{
					GameList[MenuLength].TextureName = Left(Des,j);
					GameList[MenuLength].GameName = Mid(Des,j+1);
				}
				else GameList[MenuLength].GameName = Des;
				GameList[MenuLength].GameClass = Ent;
				MenuList[MenuLength+1] = GameList[MenuLength].GameName;
				MenuLength++;
				if( MenuLength>1 )
					HelpMessage[MenuLength] = Default.HelpMessage[1];
			}
		}
		GetNextIntDesc("UnrealShare.SinglePlayer",i++,Ent,Des);
	}
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	ChildMenu = spawn(class'UnrealNewGameMenu', owner);
	HUD(Owner).MainMenu = ChildMenu;
	ChildMenu.PlayerOwner = PlayerOwner;
	if ( GameList[Selection-1].GameClass=="Game.Game" )
		PlayerOwner.UpdateURL("Game","", false);
	else PlayerOwner.UpdateURL("Game",GameList[Selection-1].GameClass, false);
	UnrealNewGameMenu(ChildMenu).StartMap = GameList[Selection-1].StartMap;

	if ( MenuLength == 1 )
	{
		ChildMenu.ParentMenu = ParentMenu;
		Destroy();
		return false;
	}
	else
	{
		ChildMenu.ParentMenu = self;
		return true;
	}
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;
	local Texture T;

	if ( MenuLength == 1 )
	{
		DrawBackGround(Canvas, false);
		Selection = 1;
		ProcessSelection();
		return;
	}

	DrawBackGround(Canvas, true);
	DrawTitle(Canvas);

	Canvas.Style = 3;
	Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing + 8, 228);
	
	// Draw campaign screenshot.
	i = Selection-1;
	T = GameList[i].ScreenShot;
	if( !T )
	{
		if( Len(GameList[i].TextureName) )
		{
			T = Texture(DynamicLoadObject(GameList[i].TextureName,Class'Texture'));
			GameList[i].TextureName = "";
			GameList[i].ScreenShot = T;
		}
	}
	
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.SetPos(0.5 * Canvas.ClipX - 128, Canvas.ClipY-58);
	Canvas.DrawTile( Texture'MenuBarrier', 256, 64, 0, 0, 256, 64 );
	Canvas.Style = ERenderStyle.STY_Normal;

	if( T )
	{
		Canvas.SetPos((Canvas.ClipX-T.USize)*0.5f,Canvas.ClipY-T.VSize);
		Canvas.DrawIcon(T, 1.0);
		Canvas.Style = 1;
	}
}

defaultproperties
{
	HelpMessage(1)="Choose which game to play."
	MenuTitle="CHOOSE GAME"
}