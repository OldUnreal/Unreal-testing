//=============================================================================
// Get current client's username.
//=============================================================================
class GetClientUser expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
	Query.SendTextLine(Query.User,false);
}

defaultproperties
{
}
