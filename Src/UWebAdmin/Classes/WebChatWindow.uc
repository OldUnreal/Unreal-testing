//=============================================================================
// Generate a list of in game chat.
//=============================================================================
class WebChatWindow expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
	local MessagingSpectator SP;
	local int i;

	SP = Query.Manager.TheWebSpec;
	if( SP==None || SP.bDeleteMe )
	{
		Query.Manager.TheWebSpec = None;
		Query.Manager.SpawnMessageSpec();
		return;
	}
	Query.SendTextLine("<div class='MessageBlock>'");
	Query.SendTextLine("<!-- Message block v 1.1 by .:..: -->");
	For( i=(Array_Size(SP.LastMessageLines)-1); i>=0; i-- )
		Query.SendTextLine(SP.LastMessageLines[i]$"<br />");
	Query.SendTextLine("<!-- Message block end-->");
	Query.SendTextLine("</div");
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string V;

	V = Query.GetValue("Cmd");
	if( V!="" )
	{
		while( Left(V,1)==" " )
			V = Mid(V,1);

		if( Query.Manager.TheWebSpec==None || Query.Manager.TheWebSpec.bDeleteMe )
			Query.Manager.SpawnMessageSpec();
		if( (Left(V,4)~="GET " || Left(V,4)~="SET ") && Query.UserPrivileges<255 )
			V = "You don't have enough admin privileges to use SET and GET.";
		else V = Query.Manager.TheWebSpec.ConsoleCommand(V);
		if( Len(V)>0 )
			Query.Manager.TheWebSpec.ClientMessage("Cmd result ("$Query.User$"):"@V);
	}
}
