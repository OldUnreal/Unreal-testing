//=============================================================================
// UnrealGameOptionsMenu
//=============================================================================
class UnrealGameOptionsMenu extends UnrealLongMenu;

var() localized string AdvancedString;
var() localized string AdvancedHelp;
var() config bool bCanModifyGore;
var() class<GameInfo> GameClass;
var	  GameInfo	GameType;

function Destroyed()
{
	Super.Destroyed();
	if ( GameType != Level.Game )
		GameType.Destroy();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	if (Level.Game != none && Level.Game.Class == GameClass)
		GameType = Level.Game;
	else
	{
		GameType = Spawn(GameClass);
		if ( Level.Game != None )
			GameType.SetGameSpeed(Level.Game.GameSpeed);
	}
}

function MenuProcessInput( byte KeyNum, byte ActionNum )
{
	Super.MenuProcessInput(KeyNum, ActionNum);
	if ( !bCanModifyGore )
	{
		if ( KeyNum == EInputKey.IK_Up )
		{
			if ( Selection == 2 )
				Selection = 1;
		}
		else if ( KeyNum == EInputKey.IK_Down )
		{
			if ( Selection == 2 )
				Selection = 3;
		}
	}
}
function bool ProcessLeft()
{
	if ( Selection == 1 )
	{
		if ( Level.Game != None )
		{
			Level.Game.SetGameSpeed(FMax(0.5, GameType.GameSpeed - 0.1));
			GameType.GameSpeed = Level.Game.GameSpeed;
		}
		else
			GameType.GameSpeed = FMax(0.5, GameType.GameSpeed - 0.1);
	}
	else if ( (Selection == 2) && bCanModifyGore )
		GameType.bLowGore = !GameType.bLowGore;
	else
		return false;

	return true;
}

function bool ProcessRight()
{
	if ( Selection == 1 )
	{
		if ( Level.Game != None )
		{
			Level.Game.SetGameSpeed(FMin(2.0, GameType.GameSpeed + 0.1));
			GameType.GameSpeed = Level.Game.GameSpeed;
		}
		else
			GameType.GameSpeed = FMin(2.0, GameType.GameSpeed + 0.1);
	}
	else if ( (Selection == 2) && bCanModifyGore )
		GameType.bLowGore = !GameType.bLowGore;
	else
		return false;

	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( (Selection == 2) && bCanModifyGore )
		Level.Game.bLowGore = !Level.Game.bLowGore;
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

function SaveConfigs()
{
	if ( GameType != None )
	{
		Level.Game.bLowGore = GameType.bLowGore;
		GameType.SaveConfig();
	}
	PlayerOwner.SaveConfig();
	if ( Level.Game != None )
		PlayerOwner.UpdateURL("GameSpeed",string(Level.Game.GameSpeed), false);
}

function DrawOptions(canvas Canvas, int StartX, int StartY, int Spacing)
{
	MenuList[1] = Default.MenuList[1];
	if ( bCanModifyGore )
		MenuList[2] = Default.MenuList[2];
	else
		MenuList[2] = "";

	DrawList(Canvas, false, Spacing, StartX, StartY);
}

function DrawValues(canvas Canvas, int StartX, int StartY, int Spacing)
{
	local int s;

	s = 10 * (GameType.GameSpeed + 0.02);
	MenuList[1] = (""$(10 * s)$"%");
	if ( bCanModifyGore )
		MenuList[2] = BoolOptionString(GameType.bLowGore);
	else
		MenuList[2] = "";

	DrawList(Canvas, false, Spacing, StartX + 160, StartY);
}

function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing;

	DrawBackGround(Canvas, false);

	StartX = Max(40, 0.5 * Canvas.ClipX - 115);

	if ( (MenuLength < 6) || (Canvas.ClipY > 240) )
	{
		DrawTitle(Canvas);
		Spacing = Clamp(0.04 * Canvas.ClipY, 12, 32);
		StartY = Max(40, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));
	}
	else
	{
		Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
		StartY = Max(4, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));
	}
	DrawOptions(Canvas, StartX, StartY, Spacing);
	DrawValues(Canvas, StartX, StartY, Spacing);
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing + 4, 228);
}

defaultproperties
{
	AdvancedString="Advanced Options"
	AdvancedHelp="Edit advanced game configuration options."
	bCanModifyGore=True
	GameClass=Class'UnrealShare.SinglePlayer'
	MenuLength=2
	HelpMessage(1)="Adjust the speed at which time passes in the game."
	HelpMessage(2)="If true, reduces the gore in the game."
	MenuList(1)="Game Speed"
	MenuList(2)="Reduced Gore"
	MenuTitle="GAME OPTIONS"
}
