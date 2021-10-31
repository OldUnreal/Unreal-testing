//=============================================================================
// Generate a list of banned players.
//=============================================================================
class BanListGen expands ModPageContent;

Static function AddModBasedString( WebQuery Query )
{
	local string R,D[4];
	local int i,c;
	local bool bResultDone;

	Query.SendTextLine("<div class='BanListGen'>");
	Query.SendTextLine("   Banlist page, here you can unban banned players.<br />");
	Query.SendTextLine("<table><tr><th colspan=\"5\">Banned players</th></tr><tr><th>Player name</th><th>IP Address</th><th>Client ID</th><th>Unban client</th></tr>");
	R = Query.Connection.ConsoleCommand("UBanList");
	bResultDone = (R=="");
	While( !bResultDone )
	{
		i = InStr(R,"]");
		c = int(Mid(R,1,i-1));
		R = Mid(R,i+9);
		i = InStr(R," with IP ");
		D[0] = Left(R,i);
		R = Mid(R,i+9);
		i = InStr(R," IdentNr ");
		D[1] = Left(R,i);
		R = Mid(R,i+9);
		i = InStr(R," Identity ");
		D[2] = Left(R,i);
		R = Mid(R,i+10);
		i = InStr(R,"[");
		if( i==-1 )
		{
			bResultDone = True;
			D[2] = D[2]$"/"$R;
		}
		else
		{
			D[2] = D[2]$"/"$Left(R,i);
			R = Mid(R,i);
		}
		D[0] = Query.ParseSafeText(D[0]);
		Query.SendTextLine("<tr><td>"$D[0]$"</td><td>"$D[1]$"</td><td>"$D[2]$"</td><td><input type=\"radio\" name=\"BR\" value=\""$c$"\"></td></tr>");
	}
	Query.SendTextLine("</table>");
	Query.SendTextLine("</div>");
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string S;

	S = Query.GetValue("BR");
	if( S!="" )
	{
		Query.Connection.ConsoleCommand("UUnBan"@S);
		Log("Unbanned client number"@S,'WebServer');
	}
}

defaultproperties
{
	RequiredPrivileges=5
	bNoExtraInfo=true
}
