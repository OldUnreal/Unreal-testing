//=============================================================================
// MarineMatch.
//=============================================================================
class MarineMatch expands DeathMatchGame;

var() Class<SpaceMarine> MarineTypes[4];
var() config bool bTerranWeaponsOnly;
function PostBeginPlay()
{
	super.PostBeginPlay();
	if( bTerranWeaponsOnly )
		Class'CloakMatch'.Static.TerranWeaponSetup(Self);
}
function bool AddBot()
{
	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN;
	local class<Bots> ConfigBotClass;

	Difficulty = BotConfig.Difficulty;
	BotN = BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = FindPlayerStart(0);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = Spawn( MarineTypes[Rand(ArrayCount(MarineTypes))],,, StartSpot.Location, StartSpot.Rotation );
	if ( NewBot == None )
		return false;

	ConfigBotClass = BotConfig.GetBotClass(BotN);
	if (ConfigBotClass != none)
		NewBot.bIsFemale = ConfigBotClass.default.bIsFemale;

	StartSpot.PlayTeleportEffect(NewBot, true);

	// Init player's information.
	BotConfig.Individualize(NewBot, BotN, NumBots);
	NewBot.ViewRotation = StartSpot.Rotation;

	// broadcast a welcome message.
	BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, true );

	AddDefaultInventory( NewBot );
	NumBots++;
	return true;
}
function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	GameName = Class'DeathMatchGame'.Default.GameName;
}

defaultproperties
{
				MarineTypes(0)=Class'UPak.SpaceMarine'
				MarineTypes(1)=Class'UPak.MarineDesert'
				MarineTypes(2)=Class'UPak.MarineJungle'
				MarineTypes(3)=Class'UPak.MarineArctic'
				bTerranWeaponsOnly=True
				GameName="MarineMatch"
}