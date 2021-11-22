//=============================================================================
// Generate a list of current players in server.
//=============================================================================
class PlayersListDebug expands WebPageContent;

var() config byte BanPrivileges;

Static function LoadUpClassContent( WebQuery Query )
{
	local string S;
	local Pawn P;

	Query.SendTextLine("<div class='PlayersListDebug'>");
	Query.SendTextLine("<!-- Players List -->");
	Query.SendTextLine("<h1>Players list ("$Query.Connection.Outer.Name$")</h1>");
	Query.SendTextLine("<table><tr></tr><tr><th>ID</th><th>Name</th><th>Score</th><th>Ping</th><th>IP Address</th><th>Kick</th><th>Ban</th></tr>");
	For( P=Query.Connection.Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( P.PlayerReplicationInfo!=None && MessagingSpectator(P)==None )
		{
			S = Query.ParseSafeText(P.PlayerReplicationInfo.PlayerName);
			Query.SendTextLine("<tr><td>"$P.PlayerReplicationInfo.PlayerID$"</td><td>"$S$"</td><td>"$int(P.PlayerReplicationInfo.Score)$"</td><td>"$P.PlayerReplicationInfo.Ping$"</td><td>");
			if( PlayerPawn(P)==None || PlayerPawn(P).Player==None )
				Query.SendTextLine("Bot</td><td><input class=\"checkbox\" name=\"KK"$P.PlayerReplicationInfo.PlayerID$"\" value=\"kick\" type=\"checkbox\"></td><td>-</td></tr>");
			else
			{
				Query.SendTextLine(P.ConsoleCommand("UGetIP")$"</td><td><input type=\"radio\" name=\"KK"$P.PlayerReplicationInfo.PlayerID$"\" value=\"kick\"></td>",false);
				if( Query.UserPrivileges>=Default.BanPrivileges )
					Query.SendTextLine("<td><input type=\"radio\" name=\"KK"$P.PlayerReplicationInfo.PlayerID$"\" value=\"ban\"></td></tr>");
			}
		}
	}
	Query.SendTextLine("</table>");
	Query.SendTextLine("<p><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Submit\"><!-- End of players list code-->");
    Query.SendTextLine("</div>");
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string ID,V;
	local Pawn P;

	foreach Query.AllValues(ID,V,"KK")
	{
		P = FindPlayerByID(Query.Connection.Level,int(Mid(ID,2)));
		if( P!=None )
		{
			Switch( Caps(V) )
			{
				Case "KICK":
					Query.Connection.BroadcastMessage(P.PlayerReplicationInfo.PlayerName@"was kicked.");
					P.ClientMessage("NE_Kick",'Networking');
					P.Destroy();
					Break;
				Case "BAN":
					if( Query.UserPrivileges>=Default.BanPrivileges )
					{
						Query.Connection.BroadcastMessage(P.PlayerReplicationInfo.PlayerName@"was banned.");
						Query.Connection.Level.Game.ConsoleCommand("UBanID"@ID);
					}
					Break;
			}
		}
	}
}
Static final function Pawn FindPlayerByID( LevelInfo Level, int ID )
{
	local Pawn P;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( P.PlayerReplicationInfo!=None && MessagingSpectator(P)==None && P.PlayerReplicationInfo.PlayerID==ID )
			Return P;
	}
	Return None;
}

defaultproperties
{
	BanPrivileges=5
}
