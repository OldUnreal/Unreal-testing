//=============================================================================
// Get the current clients IP.
//=============================================================================
class GetClientIP expands WebPageContent;

Static function LoadUpClassContent( WebQuery Query )
{
	Query.SendTextLine(Query.Connection.AddressString,false);
}

defaultproperties
{
}
