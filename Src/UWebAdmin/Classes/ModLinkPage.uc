//=============================================================================
// ModLinkPage.
//=============================================================================
class ModLinkPage expands WebPageContent;

var bool bHasInit;
var struct ModListLinksType
{
	var string Description,ModConClass;
} ModLinks[80];
var byte NumModLinks;

Static function LoadUpClassContent( WebQuery Query )
{
	local byte i;
    Query.SendTextLine("<div class='ModLinkPage'>");
	if( !Default.bHasInit )
		InitModLinks(Query.Connection.Level);
	Query.SendTextLine("<!-- Mod Link page -->");
	Query.SendTextLine("<h2>Custom mod configures:</h2>");
	For( i=0; i<Default.NumModLinks; i++ )
		Query.SendTextLine("<a href=\"/"$Default.ModLinks[i].ModConClass$"\">"$Default.ModLinks[i].Description$"</a><br />");
	Query.SendTextLine("<!-- End of Mod Link page code-->");
	Query.SendTextLine("</div>");
}
static function InitModLinks( Actor Other )
{
	local string Ent,Des;
	local int i;

	Default.bHasInit = True;
	Other.GetNextIntDesc(string(Class'ModPageContent'),(i++),Ent,Des);
	While( Ent!="" )
	{
		if( Des=="" )
			Des = Ent;
		Default.ModLinks[Default.NumModLinks].Description = Des;
		Default.ModLinks[Default.NumModLinks].ModConClass = "Mod_"$Ent;
		Default.NumModLinks++;
		if( Default.NumModLinks>=ArrayCount(Default.ModLinks) )
			Return;
		Other.GetNextIntDesc(string(Class'ModPageContent'),(i++),Ent,Des);
	}
}

defaultproperties
{
}
