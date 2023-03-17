//=============================================================================
// UnrealChooseGameMenu
// finds all the single player game types (using the .int files)
// then allows the player to choose one (if there is only one, this menu never displays)
//=============================================================================
class UnrealChooseGameMenu extends UnrealLongMenu
	config(User);

struct FGameEntry
{
	var string StartMap, GameName, GameClass, TextureName, SaveInfo;
	var Texture ScreenShot;
};
var array<FGameEntry> GameList;
var config string LastSelectedGame;
var config byte LastSelectedSkill;

function PostBeginPlay()
{
	local string Ent,Des;
	local int j;

	Super.PostBeginPlay();
	MenuLength = 0;
	foreach IntDescIterator(string(Class'SinglePlayer'),Ent,Des)
	{
		if ( Len(Des) )
		{
			j = InStr(Des,";");
			if ( j!=-1 )
			{
				GameList[MenuLength].SaveInfo = Ent@Left(Des,j);
				if( Default.LastSelectedGame~=GameList[MenuLength].SaveInfo )
					Selection = MenuLength+1;
				
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
				if( MenuLength>=20 )
					break;
			}
		}
	}
}

function bool ProcessSelection()
{
	local Menu ChildMenu;
	local string S;

	ChildMenu = spawn(class'UnrealNewGameMenu', owner);
	HUD(Owner).MainMenu = ChildMenu;
	ChildMenu.PlayerOwner = PlayerOwner;
	S = GameList[Selection-1].StartMap;
	if ( !(GameList[Selection-1].GameClass~="Game.Game") )
		S = S$"?Game="$GameList[Selection-1].GameClass;
	if( Default.LastSelectedGame!=GameList[Selection-1].SaveInfo )
	{
		Default.LastSelectedGame = GameList[Selection-1].SaveInfo;
		StaticSaveConfig();
	}
	UnrealNewGameMenu(ChildMenu).StartMap = S;

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
	LastSelectedGame="Game.Game Vortex2"
	LastSelectedSkill=1
	HelpMessage(1)="Choose which game to play."
	MenuTitle="CHOOSE GAME"
}