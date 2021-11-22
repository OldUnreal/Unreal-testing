//=============================================================================
// UnrealDMGameOptionsMenu
//=============================================================================
class UnrealDMGameOptionsMenu extends UnrealGameOptionsMenu;

var() localized string GameStyle[3];
var() localized string DeathMessages[2];

function bool ProcessYes()
{
	if ( Selection == 6 )
		DeathMatchGame(GameType).bCoopWeaponMode = True;
	else if ( Selection == 9 )
		GameType.bClassicDeathmessages = True;
	else
		return Super.ProcessYes();

	return true;
}

function bool ProcessNo()
{
	if ( Selection == 6 )
		DeathMatchGame(GameType).bCoopWeaponMode = False;
	else if ( Selection == 9 )
		GameType.bClassicDeathmessages = False;
	else
		return Super.ProcessNo();

	return true;
}

function bool ProcessLeft()
{
	if ( Selection == 3 )
		DeathMatchGame(GameType).FragLimit = FMax(0, DeathMatchGame(GameType).FragLimit - 5);
	else if ( Selection == 4 )
		DeathMatchGame(GameType).TimeLimit = FMax(0, DeathMatchGame(GameType).TimeLimit - 5);
	else if ( Selection == 5 )
		GameType.MaxPlayers = Max(1, GameType.MaxPlayers - 1);
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bCoopWeaponMode = !DeathMatchGame(GameType).bCoopWeaponMode;
	else if ( Selection == 8 )
	{
		if ( DeathMatchGame(GameType).bMegaSpeed )
			DeathMatchGame(GameType).bMegaSpeed = false;
		else if ( DeathMatchGame(GameType).bHardCoreMode )
			DeathMatchGame(GameType).bHardCoreMode = false;
		else
		{
			DeathMatchGame(GameType).bMegaSpeed = true;
			DeathMatchGame(GameType).bHardCoreMode = true;
		}
	}
	else if ( Selection == 9 )
		GameType.bClassicDeathmessages = !GameType.bClassicDeathmessages;
	else
		return Super.ProcessLeft();

	return true;
}

function bool ProcessRight()
{
	if ( Selection == 3 )
		DeathMatchGame(GameType).FragLimit += 5;
	else if ( Selection == 4 )
		DeathMatchGame(GameType).TimeLimit += 5;
	else if ( Selection == 5 )
		GameType.MaxPlayers = Min(16, GameType.MaxPlayers + 1);
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bCoopWeaponMode = !DeathMatchGame(GameType).bCoopWeaponMode;
	else if ( Selection == 8 )
	{
		if ( DeathMatchGame(GameType).bMegaSpeed )
		{
			DeathMatchGame(GameType).bMegaSpeed = false;
			DeathMatchGame(GameType).bHardCoreMode = false;
		}
		else if ( DeathMatchGame(GameType).bHardCoreMode )
			DeathMatchGame(GameType).bMegaSpeed = true;
		else
			DeathMatchGame(GameType).bHardCoreMode = true;
	}
	else if ( Selection == 9 )
		GameType.bClassicDeathmessages = !GameType.bClassicDeathmessages;
	else
		return Super.ProcessRight();

	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( Selection == 6 )
		DeathMatchGame(GameType).bCoopWeaponMode = !DeathMatchGame(GameType).bCoopWeaponMode;
	else if ( Selection == 7 )
	{
		ChildMenu = spawn(class'UnrealBotConfigMenu', owner);
		ChildMenu.ParentMenu = self;
		UnrealBotConfigMenu(ChildMenu).InitConfig(GameType);
	}
	else if ( Selection == 8 )
		DeathMatchGame(GameType).bHardCoreMode = !DeathMatchGame(GameType).bHardCoreMode;
	else if ( Selection == 9 )
		GameType.bClassicDeathmessages = !GameType.bClassicDeathmessages;
	else
		return Super.ProcessSelection();

	if ( ChildMenu != None )
	{
		HUD(Owner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
	}
	return true;
}

function DrawOptions(canvas Canvas, int StartX, int StartY, int Spacing)
{
	local int i;

	for ( i=3; i<MenuLength+1; i++ )
		MenuList[i] = Default.MenuList[i];

	Super.DrawOptions(Canvas, StartX, StartY, Spacing);
}

function DrawValues(canvas Canvas, int StartX, int StartY, int Spacing)
{
	local DeathMatchGame DMGame;

	DMGame = DeathMatchGame(GameType);

	// draw text
	MenuList[3] = string(DMGame.FragLimit);
	MenuList[4] = string(DMGame.TimeLimit);
	MenuList[5] = string(DMGame.MaxPlayers);
	MenuList[6] = string(DMGame.bCoopWeaponMode);
	MenuList[7] = "";
	if ( DMGame.bMegaSpeed )
		MenuList[8] = GameStyle[2];
	else if ( DMGame.bHardcoreMode )
		MenuList[8] = GameStyle[1];
	else
		MenuList[8] = GameStyle[0];
	MenuList[9] = DeathMessages[int(!DMGame.bClassicDeathmessages)];

	Super.DrawValues(Canvas, StartX, StartY, Spacing);
}

defaultproperties
{
	GameClass=Class'UnrealShare.DeathMatchGame'
	MenuLength=9
	HelpMessage(3)="Number of frags scored by leading player to end game.  If 0, there is no limit."
	HelpMessage(4)="Time limit (in minutes) to end game.  If 0, there is no limit."
	HelpMessage(5)="Maximum number of players allowed in the game."
	HelpMessage(6)="If Weapons Stay is enabled, weapons respawn instantly, but can only be picked up once by a given player."
	HelpMessage(7)="Configure bot game and individual parameters."
	HelpMessage(8)="Choose Game Style:  Hardcore game speed is faster and weapons do more damage than Classic. Turbo is Hardcore with really fast movement."
	HelpMessage(9)="Classic or new style (weapon based) deathmessages."
	MenuList(3)="Frag limit"
	MenuList(4)="Time Limit"
	MenuList(5)="Max Players"
	MenuList(6)="Weapons Stay"
	MenuList(7)="Configure Bots"
	MenuList(8)="Game Style"
	MenuList(9)="DeathMessages"
	GameStyle(0)="Classic"
	GameStyle(1)="Hardcore"
	GameStyle(2)="Turbo"
	DeathMessages(0)="Classic"
	DeathMessages(1)="Weapon Based"
}
