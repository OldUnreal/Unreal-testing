//=============================================================================
// Restart the current map.
//=============================================================================
class RestartMapCode expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
    Query.SendTextLine("<div class='RestartMapCode'>");
	Query.Connection.Level.ServerTravel(string(Query.Connection.Outer.Name),False);
	Query.SendTextLine("Restarting map, please wait.<br />");
	Query.SendTextLine("Please click <a href=\"/Index\" target=\"_parent\">here</a> once its done.");
	Query.SendTextLine("</div>");
}

defaultproperties
{
}
