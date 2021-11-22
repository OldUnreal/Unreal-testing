//=============================================================================
// PreferencesPageL.
//=============================================================================
class PreferencesPageL expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
	local string S;
	local int i;

    Query.SendTextLine("<div class='PreferencesPageL'>");
	Query.SendTextLine("<!-- Preferences list -->");
	Query.SendTextLine("<h1>Advanced Options</h1>");
	S = Mid(Query.URL,1);
	i = InStr(S,"|");
	if( i>=0 )
		S = Mid(S,i+1);
	else S = "";

	FillList("",S,Query,"","");
	Query.SendTextLine("<!-- End of Preferences list -->");
	Query.SendTextLine("</div>");
}
static final function FillList( string Cat, string URL, WebQuery Query, string Depth, string URLList )
{
	local array<PreferencesInfo> Prefs;
	local int i,l;
	local string S,U;

	if( Cat=="" )
		Query.GetPreferences(Prefs);
	else Query.GetPreferences(Prefs,Cat);

	// Grab wanted expand category.
	i = InStr(URL,"|");
	if( i>=0 )
	{
		S = Left(URL,i);
		URL = Mid(URL,i+1);
	}
	else
	{
		S = URL;
		URL = "";
	}

	if( URLList=="" )
		U = "|";
	else U = URLList;

	l = Array_Size(Prefs);
	for( i=0; i<l; ++i )
	{
		if( Prefs[i].ClassName=="" ) // Another expandable category.
		{
            Query.SendTextLine("<div class='PrefsMenuLeft'>");
			if( S==Prefs[i].Caption )
			{
				Query.SendTextLine(Depth$"<a href=\"../Mod_"$string(Default.Class)$U$"\">[-]"$Prefs[i].Caption$"</a><br />");
				FillList(Prefs[i].Caption,URL,Query,Depth$"--",U$Prefs[i].Caption$"|");
			}
			else Query.SendTextLine(Depth$"<a href=\"../Mod_"$string(Default.Class)$U$Prefs[i].Caption$"\">[+]"$Prefs[i].Caption$"</a><br />");
			Query.SendTextLine("</div>");
		}
		else
		{
            Query.SendTextLine("<div class='PrefsMenuRight'>");
            Query.SendTextLine(Depth$"<a href=\"../Mod_"$string(class'PreferencesPageR')$"|"$Prefs[i].ClassName$"|"$Prefs[i].Category$"|"$string(int(Prefs[i].Immediate))$"\">[*]"$Prefs[i].Caption$"</a><br />");
            Query.SendTextLine("</div>");
        }
	}
}

defaultproperties
{
	RequiredPrivileges=255
}
