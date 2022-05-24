//=============================================================================
// UnrealScoreBoard
//=============================================================================
class UnrealScoreBoard extends ScoreBoard
	NoUserCreate;

var string PlayerNames[16];
var string TeamNames[16];
var float Scores[16];
var byte Teams[16];
var int Pings[16];
var GameReplicationInfo CachedGRI;
var localized string DeadStr,SpectatorStr;

// MOTD
var() localized string GameType;
var() localized string MapTitle;
var() localized string Author;
var() localized string IdealPlayerCount;

function DrawHeader( canvas Canvas )
{
	local float XL, YL;

	if ( CachedGRI==None )
	{
		foreach AllActors(class'GameReplicationInfo', CachedGRI)
			Break;
		if ( CachedGRI==None )
			Return;
	}
	if (Canvas.ClipX > 500)
	{
		Canvas.bCenter = true;

		Canvas.SetPos(0.0, 32);
		Canvas.StrLen("TEST", XL, YL);
		if (Level.Netmode != NM_StandAlone)
			Canvas.DrawText(CachedGRI.ServerName);
		Canvas.SetPos(0.0, 32 + YL);
		Canvas.DrawText(GameType$CachedGRI.GameName, true);
		Canvas.SetPos(0.0, 32 + 2*YL);
		Canvas.DrawText(MapTitle$Level.Title, true);
		Canvas.SetPos(0.0, 32 + 3*YL);
		Canvas.DrawText(Author$Level.Author, true);
		Canvas.SetPos(0.0, 32 + 4*YL);
		if (Level.IdealPlayerCount != "")
			Canvas.DrawText(IdealPlayerCount$Level.IdealPlayerCount, true);

		Canvas.bCenter = false;
	}
}

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local string HourString, MinuteString, SecondString;
	local float XL, YL;

	if (Canvas.ClipX > 500)
	{
		Seconds = int(Level.TimeSeconds);
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);

		if (Seconds < 10)
			SecondString = "0"$Seconds;
		else
			SecondString = string(Seconds);

		if (Minutes < 10)
			MinuteString = "0"$Minutes;
		else
			MinuteString = string(Minutes);

		if (Hours < 10)
			HourString = "0"$Hours;
		else
			HourString = string(Hours);

		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - YL);
		Canvas.DrawText("Elapsed Time: "$HourString$":"$MinuteString$":"$SecondString, true);
		Canvas.bCenter = false;
	}

	if( Pawn(Owner).PlayerReplicationInfo!=None && Pawn(Owner).PlayerReplicationInfo.bIsSpectator )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - YL*6);
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
		Canvas.DrawText(SpectatorStr, true);
		Canvas.bCenter = false;
	}
	else if( Pawn(Owner).Health<=0 )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - YL*6);
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
		Canvas.DrawText(DeadStr, true);
		Canvas.bCenter = false;
	}
}

function DrawName( canvas Canvas, int I, float XOffset, int LoopCount )
{
	local int Step;

	if (Canvas.ClipX >= 640)
		Step = 16;
	else
		Step = 8;

	Canvas.SetPos(Canvas.ClipX/4, Canvas.ClipY/4 + (LoopCount * Step));
	Canvas.DrawText(PlayerNames[I], false);
}

function DrawPing( canvas Canvas, int I, float XOffset, int LoopCount )
{
	local float XL, YL;
	local int Step;

	if (Canvas.ClipX >= 640)
		Step = 16;
	else
		Step = 8;

	if (Level.Netmode == NM_Standalone)
		return;

	Canvas.StrLen(Pings[I], XL, YL);
	Canvas.SetPos(Canvas.ClipX/4 - XL - 8, Canvas.ClipY/4 + (LoopCount * Step));
	Canvas.Font = Font'TinyWhiteFont';
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawText(Pings[I], false);
	Canvas.Font = RegFont;
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
}

function DrawScore( canvas Canvas, int I, float XOffset, int LoopCount )
{
	local int Step;

	if (Canvas.ClipX >= 640)
		Step = 16;
	else
		Step = 8;

	Canvas.SetPos(Canvas.ClipX/4 * 3, Canvas.ClipY/4 + (LoopCount * Step));

	if (Scores[I] >= 100.0)
		Canvas.CurX -= 6.0;
	if (Scores[I] >= 10.0)
		Canvas.CurX -= 6.0;
	if (Scores[I] < 0.0)
		Canvas.CurX -= 6.0;
	Canvas.DrawText(int(Scores[I]), false);
}

function Swap( int L, int R )
{
	local string TempPlayerName, TempTeamName;
	local float TempScore;
	local byte TempTeam;
	local int TempPing;

	TempPlayerName = PlayerNames[L];
	TempTeamName = TeamNames[L];
	TempScore = Scores[L];
	TempTeam = Teams[L];
	TempPing = Pings[L];

	PlayerNames[L] = PlayerNames[R];
	TeamNames[L] = TeamNames[R];
	Scores[L] = Scores[R];
	Teams[L] = Teams[R];
	Pings[L] = Pings[R];

	PlayerNames[R] = TempPlayerName;
	TeamNames[R] = TempTeamName;
	Scores[R] = TempScore;
	Teams[R] = TempTeam;
	Pings[R] = TempPing;
}

function SortScores(int N)
{
	local int I, J, Max;

	for ( I=0; I<N-1; I++ )
	{
		Max = I;
		for ( J=I+1; J<N; J++ )
			if (Scores[J] > Scores[Max])
				Max = J;
		Swap( Max, I );
	}
}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, LoopCount, I;

	Canvas.Font = RegFont;

	// Header
	DrawHeader(Canvas);

	// Trailer
	DrawTrailer(Canvas);

	// Wipe everything.
	for ( I=0; I<16; I++ )
	{
		Scores[I] = -500;
	}

	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;

	foreach AllActors (class'PlayerReplicationInfo', PRI)
	if ( !PRI.bIsSpectator )
	{
		PlayerNames[PlayerCount] = PRI.PlayerName;
		TeamNames[PlayerCount] = PRI.TeamName;
		Scores[PlayerCount] = PRI.Score;
		Teams[PlayerCount] = PRI.Team;
		Pings[PlayerCount] = PRI.Ping;

		if ( ++PlayerCount>=ArrayCount(PlayerNames) )
			break;
	}

	SortScores(PlayerCount);

	LoopCount = 0;

	for ( I=0; I<PlayerCount; I++ )
	{
		// Player name
		DrawName(Canvas, I, 0, LoopCount);

		// Player ping
		DrawPing(Canvas, I, 0, LoopCount);

		// Player score
		DrawScore(Canvas, I, 0, LoopCount);

		LoopCount++;
	}

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

defaultproperties
{
	RegFont=Font'WhiteFont'
	DeadStr="You are dead.  Hit [Fire] to respawn!"
	SpectatorStr="You are spectating.  Hit [Fire] to view from another player!"
	GameType="Game Type: "
	MapTitle="Map Title: "
	Author="Author: "
	IdealPlayerCount="Ideal Player Load: "
}
