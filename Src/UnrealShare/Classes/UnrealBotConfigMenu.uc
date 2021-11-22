//=============================================================================
// UnrealBotConfigMenu
//=============================================================================
class UnrealBotConfigMenu extends UnrealLongMenu;

var   string MenuValues[20];
var		bool bAdjustSkill;
var		bool bRandomOrder;
var		UnrealServerMenu SvMenu;
var	  GameInfo	GameType;
var		byte Difficulty;

function InitConfig(GameInfo G)
{
	local BotInfo BotConfig;

	GameType = G;

	if ( (Level.Game != None) && Level.Game.IsA('DeathMatchGame') )
		BotConfig = DeathMatchGame(Level.Game).BotConfig;
	else
		BotConfig = Spawn(DeathMatchGame(GameType).Default.BotConfigType);

	bAdjustSkill = BotConfig.bAdjustSkill;
	bRandomOrder = BotConfig.bRandomOrder;

	if ( (Level.Game == None) || !Level.Game.IsA('DeathMatchGame') )
		BotConfig.Destroy();

	SvMenu = UnrealServerMenu(ParentMenu.ParentMenu);
	Difficulty = BotConfig.Difficulty;

	if ( SvMenu != None )
		SvMenu.Difficulty = Difficulty;
}

function AdjustDifficulty(int Dir)
{
	Difficulty = Clamp(Difficulty + Dir, 0, 3);

	if ( SvMenu != None )
		SvMenu.Difficulty = Difficulty;
	if ( Level.Game.IsA('DeathMatchGame') )
		Level.Game.Difficulty = Difficulty;
}

function bool ProcessYes()
{
	if ( Selection == 1 )
		bAdjustSkill = true;
	else if ( Selection == 3 )
		bRandomOrder = true;
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bMultiPlayerBots = True;
	else
		return false;

	return true;
}

function bool ProcessNo()
{
	if ( Selection == 1 )
		bAdjustSkill = false;
	else if ( Selection == 3 )
		bRandomOrder = false;
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bMultiPlayerBots = false;
	else
		return false;

	return true;
}

function bool ProcessLeft()
{
	if ( Selection == 1 )
		bAdjustSkill = !bAdjustSkill;
	else if ( Selection == 2 )
		AdjustDifficulty(- 1);
	else if ( Selection == 3 )
		bRandomOrder = !bRandomOrder;
	else if ( Selection == 5 )
		DeathMatchGame(GameType).InitialBots = Max(0, DeathMatchGame(GameType).InitialBots - 1);
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bMultiPlayerBots = !DeathMatchGame(GameType).bMultiPlayerBots;
	else
		return false;


	return true;
}

function bool ProcessRight()
{
	if ( Selection == 1 )
		bAdjustSkill = !bAdjustSkill;
	else if ( Selection == 2 )
		AdjustDifficulty(1);
	else if ( Selection == 3 )
		bRandomOrder = !bRandomOrder;
	else if ( Selection == 5 )
		DeathMatchGame(GameType).InitialBots = Min(15, DeathMatchGame(GameType).InitialBots + 1);
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bMultiPlayerBots = !DeathMatchGame(GameType).bMultiPlayerBots;
	else
		return false;

	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( Selection == 1 )
		bAdjustSkill = !bAdjustSkill;
	else if ( Selection == 3 )
		bRandomOrder = !bRandomOrder;
	else if ( Selection == 4 )
	{
		ChildMenu = spawn(class'UnrealIndivBotMenu', owner);
		UnrealIndivBotMenu(ChildMenu).InitConfig(GameType);
	}
	else if ( Selection == 6 )
		DeathMatchGame(GameType).bMultiPlayerBots = !DeathMatchGame(GameType).bMultiPlayerBots;
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
	local BotInfo BotConfig;

	if ( Level.Game.IsA('DeathMatchGame') )
	{
		DeathMatchGame(Level.Game).BotConfig.bAdjustSkill = bAdjustSkill;
		DeathMatchGame(Level.Game).BotConfig.bRandomOrder = bRandomOrder;
		DeathMatchGame(Level.Game).BotConfig.Difficulty = Difficulty;
	}
	BotConfig = Spawn(DeathMatchGame(GameType).Default.BotConfigType);
	BotConfig.bAdjustSkill = bAdjustSkill;
	BotConfig.bRandomOrder = bRandomOrder;
	BotConfig.Difficulty = Difficulty;
	Level.Game.SaveConfig();
	Level.Game.GameReplicationInfo.SaveConfig();
	BotConfig.SaveConfig();
	BotConfig.Destroy();
}

function DrawValues(canvas Canvas, Font RegFont, int Spacing, int StartX, int StartY)
{
	local int i;

	Canvas.Font = RegFont;
	for (i=0; i< MenuLength; i++ )
	{
		SetFontBrightness( Canvas, (i == Selection - 1) );
		Canvas.SetPos(StartX, StartY + Spacing * i);
		Canvas.DrawText(MenuValues[i + 1], false);
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

function DrawMenu(canvas Canvas)
{
	local DeathMatchGame DMGame;
	local int StartX, StartY, Spacing;

	DMGame = DeathMatchGame(GameType);

	DrawBackGround(Canvas, (Canvas.ClipY < 250) );

	// Draw Title
	DrawTitle(Canvas);

	Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);

	MenuValues[1] = BoolOptionString(bAdjustSkill);
	MenuValues[2] = string(Difficulty);
	MenuValues[3] = BoolOptionString(bRandomOrder);
	MenuValues[5] = string(DMGame.InitialBots);
	MenuValues[6] = BoolOptionString(DMGame.bMultiPlayerBots);

	DrawValues(Canvas, Canvas.MedFont, Spacing, StartX+160, StartY);

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing, 228);
}

defaultproperties
{
	MenuTitle="BOTS"
	MenuList(1)="Auto-Adjust Skills"
	MenuList(2)="Base Skill"
	MenuList(3)="Random Order"
	MenuList(4)="Configure Individual Bots"
	MenuList(5)="Number of Bots"
	MenuList(6)="Bots in Multiplayer"
	HelpMessage(1)="If true, bots adjust their skill level based on how they are doing against players."
	HelpMessage(2)="Base skill level of bots (between 0 and 3)."
	HelpMessage(3)="If true, bots enter the game in random order. If false, they enter in their configuration order."
	HelpMessage(4)="Change the configuration of individual bots."
	HelpMessage(5)="Number of bots to start play (max 15)."
	HelpMessage(6)="Use bots when playing with other people."
	MenuLength=6
}
