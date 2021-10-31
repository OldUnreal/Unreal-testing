//=============================================================================
// UPakGame.uc
// $Author: Deb $
// $Date: 4/23/99 12:14p $
// $Revision: 1 $
//=============================================================================
class UPakGame expands DeathMatchGame;

function PostBeginPlay()
{
	local ZoneInfo ZI;
	
	bHardCoreMode = false;
	bMegaSpeed = false;
	foreach allactors( class'ZoneInfo', ZI )
	{
		if( !ZI.bWaterZone && !ZI.IsA( 'SkyZoneInfo' ) && !ZI.IsA( 'Waterzone' ) && !ZI.IsA( 'LavaZone' ) )
		{
			ZI.bGravityZone = true;
			ZI.ZoneGravity = vect(0, 0, -100 );
		}
	}

	InitialBots = 4;
	BotConfig = spawn(class'UPakSMBotInfo');
	RemainingTime = 120;
	bMultiPlayerBots = false;
	if( (Level.NetMode == NM_Standalone) || bMultiPlayerBots )
		RemainingBots = InitialBots;
	FragLimit = 25;
	UPakGameSetup();
	Class'PathNodeIterator'.Static.CheckUPak();

	Super.PostBeginPlay();
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<PlayerPawn> SpawnClass
)
{
	local playerpawn NewPlayer;
	
	if( (MaxPlayers > 0) && (NumPlayers >= MaxPlayers) )
	{
		Error = MaxedOutMessage;
		return None;
	}

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass );
	
	if ( NewPlayer != None )
	{
		NumPlayers++;
	}

	NewPlayer.bAutoActivate = true;
		
	return NewPlayer;
}

function UPakGameSetup()
{
	Class'CloakMatch'.Static.TerranWeaponSetup(Self);
}

// Monitor killed messages for fraglimit
function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);

	if( Killer != none && UPakReplicationInfo(Killer.PlayerReplicationInfo)!=none && UPakPlayer(Killer)!=None )
	{
		if( Killer.Weapon.IsA('CARifle') )
			UPakPlayer( Killer ).CARKills++;
		else if( Killer.Weapon.IsA('RocketLauncher') )
			UPakReplicationInfo(Killer.PlayerReplicationInfo).RLKills++;
		else if( Killer.Weapon.IsA('GrenadeLauncher') )
			UPakReplicationInfo(Killer.PlayerReplicationInfo).GLKills++;
		else UPakReplicationInfo(Killer.PlayerReplicationInfo).OtherKills++;
		UPakReplicationInfo(Killer.PlayerReplicationInfo).TotalKills++;
	}
	if ( (killer == None) || (Other == None) )
		return;
	if ( (FragLimit > 0) && (killer.PlayerReplicationInfo.Score >= FragLimit) )
		EndGame("FragLimit");

	if ( BotConfig.bAdjustSkill && (killer.IsA('PlayerPawn') || Other.IsA('PlayerPawn')) )
	{
		if ( killer.IsA('Bots') )
			Bots(killer).AdjustSkill(true);
		if ( Other.IsA('Bots') )
			Bots(Other).AdjustSkill(false);
	}
}	

function bool AddBot()
{
	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN;

	BotN = BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = FindPlayerStart(0);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = Spawn(BotConfig.GetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);
	if ( NewBot == None )
		return false;

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		NewBot.Destroy();
		log("Failed to spawn bot");
		return false;
	}

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

defaultproperties
{
     DefaultPlayerClass=Class'UPak.UPakMaleOne'
     DefaultWeapon=Class'UPak.CARifle'
     ScoreBoardType=Class'UPak.UPakDMScoreBoard'
     HUDType=Class'UPak.UPakHUD'
}
