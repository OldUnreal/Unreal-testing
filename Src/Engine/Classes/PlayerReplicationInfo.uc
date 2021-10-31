//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo expands ReplicationInfo
	native
	NativeReplication
	NoUserCreate;

var string	    PlayerName;		// Player name, or blank if none.
var int			PlayerID;		// Unique id number.
var string	    TeamName;		// Team name, or blank if none.
var travel byte	Team;					// Player Team, 255 = None for player.
var int					TeamID;			// Player position in team.
var float				Score;			// Player's current score.
var float				Spree;			// Player is on a killing spree.
var class<VoicePack>	VoiceType;
var Decoration			HasFlag;
var int					Ping;
var bool				bIsFemale;
var	bool				bIsABot;
var bool				bFeigningDeath;
var bool				bIsSpectator;
var Texture				TalkTexture;
var ZoneInfo			PlayerZone;

replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		PlayerName, TeamName, Team, TeamID, Score, VoiceType,
		HasFlag, Ping, bIsABot, bFeigningDeath, TalkTexture, bIsSpectator, PlayerZone;
}

function PostBeginPlay()
{
	Timer();
	SetTimer(2.0, true);
	bIsFemale = Pawn(Owner).bIsFemale;
}

simulated function PostNetBeginPlay()
{
	if( Level.bIsDemoPlayback && Owner!=None && Owner.bIsPawn )
		Pawn(Owner).PlayerReplicationInfo = Self;
}

function Timer()
{
	if (PlayerPawn(Owner) != None)
		Ping = int(PlayerPawn(Owner).ConsoleCommand("GETPING"));
}

defaultproperties
{
	bAlwaysRelevant=True
	team=255
}
