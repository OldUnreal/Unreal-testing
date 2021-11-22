//=============================================================================
// UPakDMScoreBoard.
//=============================================================================
class UPakDMScoreBoard expands UnrealScoreBoard;

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
		Minutes = Minutes - (Hours * 60);
		Seconds = Seconds - (Minutes * 60);

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

		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 255;
		Canvas.Style = 3;
		Canvas.Font=Font'SmallFont';
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0.0, 32 + 15*YL);
		Canvas.DrawText( "CARIFLE KILLS: "$UPakReplicationInfo( UPakPlayer( Owner ).PlayerReplicationInfo ).CARKills );
		Canvas.SetPos(0.0, 32 + 16*YL);
		Canvas.DrawText( "RL Kills     : "$UPakReplicationInfo( UPakPlayer( Owner ).PlayerReplicationInfo ).RLKills );
		Canvas.SetPos(0.0, 32 + 17*YL);
		Canvas.DrawText( "GL Kills     : "$UPakReplicationInfo( UPakPlayer( Owner ).PlayerReplicationInfo ).GLKills );
		Canvas.SetPos(0.0, 32 + 19*YL);
		Canvas.DrawText( "Total Kills  : "$UPakReplicationInfo( UPakPlayer( Owner ).PlayerReplicationInfo ).TotalKills );

//		Canvas.Font = Font'MedFont';

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
	{
		PlayerNames[PlayerCount] = PRI.PlayerName;
		TeamNames[PlayerCount] = PRI.TeamName;
		Scores[PlayerCount] = PRI.Score;
		Teams[PlayerCount] = PRI.Team;
		Pings[PlayerCount] = PRI.Ping;

		PlayerCount++;
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
}
