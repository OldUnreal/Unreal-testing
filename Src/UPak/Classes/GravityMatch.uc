//=============================================================================
// GravityMatch.
//=============================================================================
class GravityMatch expands DeathMatchGame;

var() globalconfig vector Gravity;
var() config bool bTerranWeaponsOnly;

function PostBeginPlay()
{
	local string NextPlayerClass;
	local int i;
	local ZoneInfo ZI;
	
	if( bTerranWeaponsOnly )
		Class'CloakMatch'.Static.TerranWeaponSetup(Self);
	
	foreach allactors( class'ZoneInfo', ZI )
	{
		if( !ZI.bWaterZone && !ZI.IsA( 'SkyZoneInfo' ) && !ZI.IsA( 'Waterzone' ) && !ZI.IsA( 'LavaZone' ) )
		{
			ZI.bGravityZone = true;
			ZI.ZoneGravity = Gravity;
		}
	}


	BotConfig = spawn(BotConfigType);
	RemainingTime = 60 * TimeLimit;
	if ( (Level.NetMode == NM_Standalone) || bMultiPlayerBots )
		RemainingBots = InitialBots;
	Super.PostBeginPlay();

	// load all player classes
	NextPlayerClass = GetNextInt("UnrealiPlayer", 0); 
	while ( NextPlayerClass != "" )
	{
		DynamicLoadObject(NextPlayerClass, class'Class');
		i++;
		NextPlayerClass = GetNextInt("UnrealiPlayer", i); 
	}
}

function float PlaySpawnEffect(inventory Inv)
{
	spawn( class 'ReSpawn',,, Inv.Location );
	return 0.3;
}

function UpdateAirControl( PlayerPawn Player )
{
	if( Player.AirControl < 0.4 )
		Player.AirControl = 0.4;
}	


event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass );
	UpdateAirControl( NewPlayer );
	if ( NewPlayer != None )
	{
		if ( Left(NewPlayer.PlayerReplicationInfo.PlayerName, 6) == DefaultPlayerName )
			ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
		NewPlayer.bAutoActivate = true;
	}

	return NewPlayer;
}

defaultproperties
{
     Gravity=(Z=-200.000000)
     bTerranWeaponsOnly=True
     GameName="GravityMatch"
}
