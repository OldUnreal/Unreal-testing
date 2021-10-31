//=============================================================================
// PreferencesPage.
//=============================================================================
class PreferencesPageMain expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
	if( !Query.SettingsEnabled(1) )
	{
		Query.LocalizeWebPage("PageHeader");
        Query.SendTextLine("<div class='PreferencesPageMain'>");
		Query.SendTextLine("<h1>Preferences is disabled on this server.</h1><br />");
		Query.SendTextLine("To enable it, edit ../WebServer/WebServer.ini and change AllowPreferences=True");
        Query.SendTextLine("</div>");
		Query.LocalizeWebPage("PageEnding");
	}
	else
	{
		Query.LocalizeWebPage("PreferencesPageL");
		Query.LocalizeWebPage("PreferencesPageR");
	}
}

defaultproperties
{
	RequiredPrivileges=255
	bStandardForm=false
}
