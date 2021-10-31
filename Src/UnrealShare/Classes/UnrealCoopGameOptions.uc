//=============================================================================
// UnrealCoopGameOptions
//=============================================================================
class UnrealCoopGameOptions extends UnrealGameOptionsMenu;

var localized string Difficulties[7]; // unused, preserved for binary compatibility

function bool ProcessLeft()
{
	switch (Selection) {
		case 3:
			UnrealServerMenu(ParentMenu).Difficulty = Max( 0, UnrealServerMenu(ParentMenu).Difficulty - 1 );
			break;
		case 4:
			CoopGame(GameType).bNoFriendlyFire = false;
			break;
		case 5:
			GameType.bCoopWeaponMode = false;
			break;
		case 6:
			CoopGame(GameType).bInstantWeaponRespawn = false;
			break;
		case 7:
			CoopGame(GameType).bInstantItemRespawn = false;
			break;
		default:
			return Super.ProcessLeft();
	}

	return true;
}

function bool ProcessRight()
{
	switch (Selection) {
		case 3:
			UnrealServerMenu(ParentMenu).Difficulty = Min( 6, UnrealServerMenu(ParentMenu).Difficulty + 1 );
			break;
		case 4:
			CoopGame(GameType).bNoFriendlyFire = true;
			break;
		case 5:
			GameType.bCoopWeaponMode = true;
			break;
		case 6:
			CoopGame(GameType).bInstantWeaponRespawn = true;
			break;
		case 7:
			CoopGame(GameType).bInstantItemRespawn = true;
			break;
		default:
			return Super.ProcessRight();
	}

	return true;
}

function DrawOptions(canvas Canvas, int StartX, int StartY, int Spacing)
{
	MenuList[3] = Default.MenuList[3];
	MenuList[4] = Default.MenuList[4];
	MenuList[5] = Default.MenuList[5];
	MenuList[6] = Default.MenuList[6];
	MenuList[7] = Default.MenuList[7];
	Super.DrawOptions(Canvas, StartX, StartY, Spacing);
}

function DrawValues(canvas Canvas, int StartX, int StartY, int Spacing)
{
	local DeathMatchGame DMGame;

	DMGame = DeathMatchGame(GameType);

	// draw text
	if (UnrealServerMenu(ParentMenu).Difficulty < 0 || UnrealServerMenu(ParentMenu).Difficulty > 6)
		UnrealServerMenu(ParentMenu).Difficulty = 1;
	MenuList[3] = string(UnrealServerMenu(ParentMenu).Difficulty);
	MenuList[4] = BoolOptionString(CoopGame(GameType).bNoFriendlyFire);
	MenuList[5] = BoolOptionString(GameType.bCoopWeaponMode);
	MenuList[6] = BoolOptionString(CoopGame(GameType).bInstantWeaponRespawn);
	MenuList[7] = BoolOptionString(CoopGame(GameType).bInstantItemRespawn);
	Super.DrawValues(Canvas, StartX, StartY, Spacing);
}

defaultproperties
{
	MenuLength=7
	MenuList(3)="Difficulty"
	MenuList(4)="No Friendly Fire"
	MenuList(5)="Weapons Stay"
	MenuList(6)="Instant Weapon Respawn"
	MenuList(7)="Instant Item Respawn"
	HelpMessage(3)="Skill level setting."
	HelpMessage(4)="If enabled, weapons respawn instantly, but can only be picked up once by a given player."
	HelpMessage(5)="If enabled, no friendly fire is allowed."
	HelpMessage(6)="If enabled, weapons will be respawned instantly."
	HelpMessage(7)="If enabled, items will be respawned instantly."
	GameClass=CoopGame
}