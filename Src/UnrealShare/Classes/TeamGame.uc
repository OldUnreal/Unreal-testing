//=============================================================================
// TeamGame.
//=============================================================================
class TeamGame extends DeathMatchGame
	NoUserCreate;

var() config bool   bSpawnInTeamArea;
var() config bool	bNoTeamChanges;
var() config float  FriendlyFireScale; //scale friendly fire damage by this value
var() config int	MaxTeams; //Maximum number of teams allowed in (up to 16)
var	TeamInfo Teams[16];
var() config float  GoalTeamScore; //like fraglimit
var() config int	MaxTeamSize;
var  localized string NewTeamMessage;
var		int			NextBotTeam;
var byte TEAM_Red, TEAM_Blue, TEAM_Green, TEAM_Gold;
var localized string TeamColor[4];

function PostBeginPlay()
{
	local int i;
	for (i=0; i<4; i++)
	{
		Teams[i] = Spawn(class'TeamInfo');
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = TeamColor[i];
		Teams[i].TeamIndex = i;
	}
	Super.PostBeginPlay();
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	GoalTeamScore = FragLimit;
}

//------------------------------------------------------------------------------
// Player start functions


//FindPlayerStart
//- add teamnames as new teams enter
//- choose team spawn point if bSpawnInTeamArea

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	if ( newPlayer == None)
		return None;

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(newPlayer.PlayerReplicationInfo.Team, Portal);
		if ( StartSpot != None )
		{
			if( NewPlayer.Level!=StartSpot.Level )
				NewPlayer.SendToLevel(StartSpot.Level, StartSpot.Location);
			NewPlayer.SetLocation(StartSpot.Location, StartSpot.Rotation);
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation(NewPlayer.Rotation);
			StartSpot.PlayTeleportEffect( NewPlayer, true );
		}
	}

	return newPlayer;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.PlayerReplicationInfo==None || Exiting.IsA('Spectator') )
		return;
	Teams[Exiting.PlayerReplicationInfo.Team].Size--;
}

function NavigationPoint FindPlayerStart( byte Team, optional string incomingName )
{
	local PlayerStart Dest,Best;
	local int Score,BestScore;
	local Pawn P;
	local LevelInfo L;
	
	L = (SpawnLevel!=None) ? SpawnLevel : Level;

	while( true )
	{
		//choose candidates
		foreach L.AllActors( class 'PlayerStart', Dest )
		{
			Score = Rand(100); // Randomize base scoring.
			if( !Dest.bEnabled )
				Score-=10000;
			if( Dest.bCoopStart || (bSpawnInTeamArea && Team!=Dest.TeamNumber) )
				Score-=1000;
			if( Dest.Region.Zone.bWaterZone )
				Score-=1500;

			foreach L.RadiusActors(class'Pawn',P,2000,Dest.Location)
				if( P.bIsPlayer && P.Health>0 && P.bBlockActors && P.Region.Zone==Dest.Region.Zone )
				{
					if (VSize(Dest.Location-P.Location) < (P.CollisionRadius + P.CollisionHeight))
						Score-=200;
					else if( P.LineOfSightTo(Dest) )
						Score-=100;
				}
			if( Best==None || Score>BestScore )
			{
				Best = Dest;
				BestScore = Score;
			}
		}
		if( Best!=None || L==Level )
			break;
		L = Level;
	}

	if( Best==None )
		return Level.NavigationPointList; // Attempt to recover.
	return Best;
}

function bool AddBot()
{
	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN, DesiredTeam;
	local GameRules G;

	BotN = BotConfig.ChooseBotInfo();

	// Find a start spot.
	StartSpot = FindPlayerStart(0);
	if ( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = StartSpot.Spawn(BotConfig.GetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation,None);

	if ( NewBot == None )
		return false;

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		NewBot.Destroy();
		log("Failed to spawn bot");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);
	if ( GameRules!=None )
	{
		for ( G=GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifySpawnPoint )
				G.ModifyPlayerStart(None,StartSpot,0);
	}

	// Init player's information.
	BotConfig.Individualize(NewBot, BotN, NumBots);
	NewBot.ViewRotation = StartSpot.Rotation;

	// broadcast a welcome message.
	BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, true );

	AddDefaultInventory( NewBot );
	NumBots++;

	DesiredTeam = BotConfig.GetBotTeam(BotN);
	if ( (DesiredTeam == 255) || !ChangeTeam(NewBot, DesiredTeam) )
	{
		ChangeTeam(NewBot, NextBotTeam);
		NextBotTeam++;
		if ( NextBotTeam >= MaxTeams )
			NextBotTeam = 0;
	}

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(newBot.PlayerReplicationInfo.Team);
		if ( StartSpot != None )
		{
			NewBot.SetLocation(StartSpot.Location, StartSpot.Rotation);
			NewBot.ViewRotation = StartSpot.Rotation;
			NewBot.ClientSetRotation(NewBot.Rotation);
			StartSpot.PlayTeleportEffect( NewBot, true );
		}
	}

	return true;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification

//Use reduce damage for teamplay modifications, etc.
function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
		return 0;

	if ( instigatedBy == None )
		return Damage;

	Damage *= instigatedBy.DamageScaling;

	if ( (instigatedBy != injured)
			&& (injured.GetTeamNum() == instigatedBy.GetTeamNum()) )
		return (Damage * FriendlyFireScale);
	else
		return Damage;
}

function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);

	if ( (killer == Other) || (killer == None) )
	{
		if( Other.PlayerReplicationInfo!=None )
			Teams[Other.PlayerReplicationInfo.Team].Score -= 1.0;
	}
	else if( killer.PlayerReplicationInfo!=None )
		Teams[killer.PlayerReplicationInfo.Team].Score += 1.0;

	if ( (GoalTeamScore > 0) && killer.PlayerReplicationInfo!=None && (Teams[killer.PlayerReplicationInfo.Team].Score >= GoalTeamScore) )
		EndGame("teamscorelimit");
}

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, s;
	local teaminfo SmallestTeam;

	for ( i=0; i<MaxTeams; i++ )
		if ( (Teams[i].Size < MaxTeamSize)
				&& ((SmallestTeam == None) || (SmallestTeam.Size > Teams[i].Size)) )
		{
			s = i;
			SmallestTeam = Teams[i];
		}

	if ( NewTeam == 255 )
		NewTeam = s;

	if ( Other.IsA('Spectator') )
	{
		Other.PlayerReplicationInfo.Team = NewTeam;
		Other.PlayerReplicationInfo.TeamName = Teams[NewTeam].TeamName;
		return true;
	}
	if ( Other.PlayerReplicationInfo.Team != 255 )
	{
		if ( bNoTeamChanges )
			return false;
		Teams[Other.PlayerReplicationInfo.Team].Size--;
	}

	for ( i=0; i<MaxTeams; i++ )
	{
		if ( i == NewTeam )
		{
			if (Teams[i].Size < MaxTeamSize)
			{
				AddToTeam(i, Other);
				return true;
			}
			else
				break;
		}
	}

	if ( (SmallestTeam != None) && (SmallestTeam.Size < MaxTeamSize) )
	{
		AddToTeam(s, Other);
		return true;
	}

	return false;
}

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	aTeam = Teams[num];

	aTeam.Size++;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
		Other.PlayerReplicationInfo.TeamID = 0;
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			if ( P.bIsPlayer && (P != Other)
					&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
					&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$NewTeamMessage$aTeam.TeamName, false);

	Other.static.GetMultiSkin(Other, SkinName, FaceName);
	Other.static.SetMultiSkin(Other, SkinName, FaceName, num);
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return ( (Spectator(Viewer) != None)
			 || ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).GetTeamNum() == Viewer.GetTeamNum())) );
}

defaultproperties
{
	MaxTeams=2
	MaxTeamSize=16
	NewTeamMessage=" is now on "
	bCanChangeSkin=False
	bTeamGame=True
	ScoreBoardType=Class'UnrealShare.UnrealTeamScoreBoard'
	GameMenuType=Class'UnrealShare.UnrealTeamGameOptionsMenu'
	HUDType=Class'UnrealShare.UnrealTeamHUD'
	BeaconName="Team"
	GameName="Team Game"
	TeamColor(0)="Red"
	TeamColor(1)="Blue"
	TeamColor(2)="Green"
	TeamColor(3)="Gold"
	TEAM_Blue=1
	TEAM_Green=2
	TEAM_Gold=3
	RulesMenuType="UMenu.UMenuTeamGameRulesSClient"
	SettingsMenuType="UMenu.UMenuGameSettingsSClient"
}
