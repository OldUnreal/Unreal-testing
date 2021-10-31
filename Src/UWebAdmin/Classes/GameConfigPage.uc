//=============================================================================
// GameConfigPage.
//=============================================================================
class GameConfigPage expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
	Query.SendTextLine("<div class='GameConfigPage'>");
	Query.SendTextLine("<!-- Game config -->");
	Query.SendTextLine("<table><tr><th>Server Packages</th></tr><tr><th>Package name</th></tr>");
	AddPackageEditBox(Query,"ServerPackages","SP");
	Query.SendTextLine("</table>");
	Query.SendTextLine("<table><tr><th>Server Actors</th></tr><tr><th>Actor Package.Class name</th></tr>");
	AddPackageEditBox(Query,"ServerActors","SA");
	Query.SendTextLine("</table>");
	Query.SendTextLine("<p><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Submit\"><!-- End of Game config code-->");
    Query.SendTextLine("</div>");
}
Static final function AddPackageEditBox( WebQuery q, string PType, string FieldName )
{
	local string V,S;
	local int i,count;

	count = int(q.Manager.GameEnginePtr.GetPropertyText(PType$"[]"));

	for( i=0; i<count; ++i )
	{
		V = q.Manager.GameEnginePtr.GetPropertyText(PType$"["$i$"]");
		if( i==0 )
			S = V;
		else S = S$Chr(10)$V;
	}
	q.SendTextLine("<tr><td><textarea name=\""$FieldName$"\" rows=\""$Clamp(count,10,48)$"\" cols=\"120\">"$S$"</textarea></td></tr>");
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string V;

	// Get ServerPackages:
	V = Query.GetValue("SP","NIL");
	if( V!="NIL" )
		ParsePackageList(Query,V,"ServerPackages");

	// Get ServerActors:
	V = Query.GetValue("SA","NIL");
	if( V!="NIL" )
		ParsePackageList(Query,V,"ServerActors");

	Query.Manager.GameEnginePtr.SaveConfig();
}

static final function ParsePackageList( WebQuery q, string S, string Type )
{
	local int i,j;
	local string Sp,V;
	local array<string> List;

	// Parse string into array.
	Sp = Chr(13)$Chr(10);
	while( S!="" )
	{
		i = InStr(S,Sp);
		if( i==-1 )
		{
			V = S;
			S = "";
		}
		else
		{
			V = Left(S,i);
			S = Mid(S,i+2);
		}
		if( Len(V)>1 )
			List[j++] = V;
	}

	// Set array size.
	q.Manager.GameEnginePtr.SetPropertyText(Type$"[]",string(j));

	// Set every array element.
	for( i=0; i<j; i++ )
		q.Manager.GameEnginePtr.SetPropertyText(Type$"["$i$"]",List[i]);
}

defaultproperties
{
	RequiredPrivileges=1
}
