//=============================================================================
// UnrealTeamScoreBoard
//=============================================================================
class UnrealTeamScoreBoard extends UnrealScoreBoard
	NoUserCreate;

var int PlayerCounts[4];
var localized string TeamName[4];
var() color TeamColor[4];
var() color AltTeamColor[4];

function DrawName( canvas Canvas, int I, float XOffset, int LoopCount )
{
	local float YOffset;

	switch (Teams[I])
	{
	case 0:
		YOffset = Canvas.ClipY/4 + (LoopCount * 16);
		break;
	case 1:
		YOffset = Canvas.ClipY/4 + (LoopCount * 16);
		break;
	case 2:
		YOffset = Canvas.ClipY/4 + (PlayerCounts[0] * 16) + int(PlayerCounts[0] > 0) * 48 + (LoopCount * 16);
		break;
	case 3:
		YOffset = Canvas.ClipY/4 + (PlayerCounts[1] * 16) + int(PlayerCounts[1] > 0) * 48 + (LoopCount * 16);
		break;
	}

	Canvas.SetPos(XOffset, YOffset);
	Canvas.DrawText(PlayerNames[I], false);
}

function DrawPing( canvas Canvas, int I, float XOffset, int LoopCount )
{
	local float XL, YL;
	local float YOffset;

	if (Level.Netmode == NM_Standalone)
		return;

	switch (Teams[I])
	{
	case 0:
		YOffset = Canvas.ClipY/4 + (LoopCount * 16);
		break;
	case 1:
		YOffset = Canvas.ClipY/4 + (LoopCount * 16);
		break;
	case 2:
		YOffset = Canvas.ClipY/4 + (PlayerCounts[0] * 16) + int(PlayerCounts[0] > 0) * 48 + (LoopCount * 16);
		break;
	case 3:
		YOffset = Canvas.ClipY/4 + (PlayerCounts[1] * 16) + int(PlayerCounts[1] > 0) * 48 + (LoopCount * 16);
		break;
	}

	Canvas.StrLen(Pings[I], XL, YL);
	Canvas.SetPos(XOffset - XL - 8, YOffset);
	Canvas.Font = Font'TinyWhiteFont';
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawText(Pings[I], false);
	Canvas.Font = RegFont;
}

function DrawScore( canvas Canvas, int I, float XOffset, int LoopCount )
{
	local float XL, YL;
	local float YOffset;

	switch (Teams[I])
	{
	case 0:
		XOffset = Canvas.ClipX/2 - Canvas.ClipX/8;
		YOffset = Canvas.ClipY/4 + (LoopCount * 16);
		break;
	case 1:
		XOffset = Canvas.ClipX - Canvas.ClipX/8;
		YOffset = Canvas.ClipY/4 + (LoopCount * 16);
		break;
	case 2:
		XOffset = Canvas.ClipX/2 - Canvas.ClipX/8;
		YOffset = Canvas.ClipY/4 + (PlayerCounts[0] * 16) + int(PlayerCounts[0] > 0) * 48 + (LoopCount * 16);
		break;
	case 3:
		XOffset = Canvas.ClipX - Canvas.ClipX/8;
		YOffset = Canvas.ClipY/4 + (PlayerCounts[1] * 16) + int(PlayerCounts[1] > 0) * 48 + (LoopCount * 16);
		break;
	}

	Canvas.StrLen(int(Scores[I]), XL, YL);
	XOffset -= XL;
	Canvas.SetPos(XOffset, YOffset);
	Canvas.DrawText(int(Scores[I]), false);
}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, I, XOffset;
	local int LoopCountTeam[4];
	local float XL, YL, YOffset;
	local TeamInfo TI;

	Canvas.Font = RegFont;

	// Header
	DrawHeader(Canvas);

	// Trailer
	DrawTrailer(Canvas);

	for ( I=0; I<16; I++ )
		Scores[I] = -500;

	for ( I=0; I<4; I++ )
		PlayerCounts[I] = 0;

	PlayerCount = 0;
	foreach AllActors (class'PlayerReplicationInfo', PRI)
	if ( !PRI.bIsSpectator )
	{
		if (PlayerCount >= 16)
			break;

		PlayerNames[PlayerCount] = PRI.PlayerName;
		TeamNames[PlayerCount] = PRI.TeamName;
		Scores[PlayerCount] = PRI.Score;
		Teams[PlayerCount] = PRI.Team;
		Pings[PlayerCount] = PRI.Ping;

		PlayerCount++;
		PlayerCounts[PRI.Team]++;
	}
	SortScores(PlayerCount);

	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Teams[I] % 2 == 1 )
			XOffset = Canvas.ClipX/8 + Canvas.ClipX/2;
		else
			XOffset = Canvas.ClipX/8;
		Canvas.DrawColor = AltTeamColor[Teams[I]];

		// Player name
		DrawName( Canvas, I, XOffset, LoopCountTeam[Teams[I]] );

		// Player ping
		DrawPing( Canvas, I, XOffset, LoopCountTeam[Teams[I]] );

		// Player score
		Canvas.DrawColor = TeamColor[Teams[I]];
		DrawScore( Canvas, I, XOffset, LoopCountTeam[Teams[I]] );

		LoopCountTeam[Teams[I]]++;
	}

	foreach AllActors(class'TeamInfo', TI)
	{
		if (PlayerCounts[TI.TeamIndex] > 0)
		{
			if ( TI.TeamIndex % 2 == 1 )
				XOffset = Canvas.ClipX/8 + Canvas.ClipX/2;
			else
				XOffset = Canvas.ClipX/8;
			if ( TI.TeamIndex > 1 )
			{
				if (PlayerCounts[TI.TeamIndex - 2] > 0)
					YOffset = Canvas.ClipY/4 + PlayerCounts[TI.TeamIndex - 2] * 16 + 32;
				else
					YOffset = Canvas.ClipY/4 - 16;
			}
			else
				YOffset = Canvas.ClipY/4 - 16;
			Canvas.DrawColor = TeamColor[TI.TeamIndex];
			Canvas.SetPos(XOffset, YOffset);
			Canvas.StrLen(TeamName[TI.TeamIndex], XL, YL);
			Canvas.DrawText(TeamName[TI.TeamIndex], false);
			Canvas.SetPos(XOffset + 96, YOffset);
			Canvas.DrawText(int(TI.Score), false);
		}
	}

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

defaultproperties
{
	TeamName(0)="Red Team: "
	TeamName(1)="Blue Team: "
	TeamName(2)="Green Team: "
	TeamName(3)="Gold Team: "
	TeamColor(0)=(R=255,G=0,B=0)
	TeamColor(1)=(R=0,G=128,B=255)
	TeamColor(2)=(R=0,G=255,B=0)
	TeamColor(3)=(R=255,G=255,B=0)
	AltTeamColor(0)=(R=200,G=0,B=0)
	AltTeamColor(1)=(R=0,G=94,B=187)
	AltTeamColor(2)=(R=0,G=128,B=0)
	AltTeamColor(3)=(R=255,G=255,B=128)
}
