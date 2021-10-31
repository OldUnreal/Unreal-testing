//=============================================================================
// WebPageContent. Add some custom content to the site.
//=============================================================================
class WebPageContent expands WebObjectBase
	Native
	Config(WebServer);

var() bool bStandardForm; // Auto apply page header and body to this page.
var() config byte RequiredPrivileges; // The admin privileges required to access this page.

static event bool AllowAccess( WebQuery Query )
{
	return (Default.RequiredPrivileges<=Query.UserPrivileges);
}

static event NotEnoughPrivileges( WebQuery Query )
{
    Query.SendTextLine("<div class='WebPageContent'>");
	Query.SendTextLine("<h1>Not enough privileges to access this page.</h1><br />");
	Query.SendTextLine("You may not have enough admin privileges to access this page.");
	Query.SendTextLine("</div>");
}

static event LoadUpClassContent( WebQuery Query );

Static function ProcessReceivedData( WebQuery Query );

defaultproperties
{
	bStandardForm=true
}
