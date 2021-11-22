//=============================================================================
// Get the current clients Port.
//=============================================================================
class GetClientPort expands GetClientIP;

Static function LoadUpClassContent( WebQuery Query )
{
	Query.SendTextLine(string(Query.Connection.AddressPort),false);
}

defaultproperties
{
}
