//=============================================================================
// MessagingSpectator. (Webadmin spectator)
//=============================================================================
class MessagingSpectator expands Spectator
	Config(WebServer);

var transient array<string> LastMessageLines;
var config byte MaxChatLines;
var config array<string> BannedKeywords;

var config bool bHideWebSpectator;

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName = "WebAdmin";
	PlayerReplicationInfo.PlayerID = 0;
	if( bHideWebSpectator )
	{
		PlayerReplicationInfo.bAlwaysRelevant = False;
		PlayerReplicationInfo.RemoteRole = ROLE_None;
	}
	if( Level.Game.CurrentID==0 )
		Level.Game.CurrentID++;
	bIsPlayer = True;
	bAdmin = True;
}
exec function Fly();
function ClientReStart();
exec function Say( string Msg )
{
	local Pawn P;

	Log("WebAdmin:"@Msg,'ChatLog');
	if( bHideWebSpectator )
	{
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.bIsPlayer )
				P.ClientMessage("WebAdmin:"@Msg,'Event',True);
		Return;
	}
	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.bIsPlayer )
			P.TeamMessage( PlayerReplicationInfo, Msg, 'Say' );
}
function Possess();
function PostBeginPlay()
{
	bIsPlayer = true;
}
exec function Fire( optional float F );
exec function AltFire( optional float F );
function ChangeTeam( int N );
exec function BehindView( Bool B );
exec function ActivateItem();
event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type )
{
	if( PRI!=None )
		AddMessage("("$PRI.PlayerName$"): "$S);
	else AddMessage("(None): "$S);
}
event ClientMessage( coerce string S, optional name Type, optional bool bBeep )
{
	if( Type=='' )
		Type = 'Event';
	AddMessage("("$Type$"): "$S);
}
function AddMessage( string Msg )
{
	local int i;

	Array_Insert(LastMessageLines,0);
	LastMessageLines[0] = Class'WebQuery'.Static.ParseSafeText(Msg);
	i = Array_Size(LastMessageLines);
	if( i>MaxChatLines )
		Array_Size(LastMessageLines,MaxChatLines);
}
function string ConsoleCommand( string Command )
{
	local int i,l;
	local string CCmd;

	if( Left(Command,4)~="Say " )
	{
		Say(Mid(Command,4));
		Return "";
	}
	CCmd = Caps(Command);
	if( InStr(CCmd," BANNEDKEYWORDS")>0 )
		return "Command not allowed to execute, keyword 'BannedKeywords' is blocked.";
	l = Array_Size(BannedKeywords);
	for( i=0; i<l; i++ )
		if( InStr(CCmd,Caps(BannedKeywords[i]))>=0 )
			return "Command not allowed to execute, keyword '"$BannedKeywords[i]$"' is blocked.";
	Return Super(Actor).ConsoleCommand(Command);
}
function Destroyed()
{
	local int NumSp,NumPl;
	
	NumSp = Level.Game.NumSpectators;
	NumPl = Level.Game.NumPlayers;
	Super.Destroyed();
	Level.Game.NumSpectators = NumSp;
	Level.Game.NumPlayers = NumPl;
}

defaultproperties
{
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	RemoteRole=ROLE_None
	bCollideWorld=false
	bCollideActors=false
	bMovable=false
	MaxChatLines=35
}