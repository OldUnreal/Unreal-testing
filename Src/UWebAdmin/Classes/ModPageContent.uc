//=============================================================================
// ModPageContent. Simple way for custom mods to add in their own variables.
//=============================================================================
class ModPageContent extends WebPageContent;

var() string PageName;
var bool bNoExtraInfo;

Static function LoadUpClassContent( WebQuery Query )
{
    Query.SendTextLine("<div class='ModPageContent'>");
	Query.SendTextLine("<!-- Mod config ("$Default.Class$") -->");
	Query.SendTextLine("<form action=\"Mod_"$Default.Class$"?"$Default.Class$"\" method=\"post\">");
	if( !Default.bNoExtraInfo )
		Query.SendTextLine("<h2>"$Default.PageName$"</h2><br /><a href=\"/Mod_UWebAdmin.ModLinkPage\" target=\"menumain\">Return</a> to last page.<br />");
	AddModBasedString(Query);
	Query.SendTextLine("<p><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Submit\"></form>");
	Query.SendTextLine("<!-- End of Mod config code-->");
    Query.SendTextLine("</div>");
}

// Rate this!
Static function AddModBasedString( WebQuery Query );

// Called before doing any configure macros.
Static function StartTable( WebQuery Query )
{
	Query.SendTextLine("<table>");
}
// Called after the configure macros.
Static function EndTable( WebQuery Query )
{
	Query.SendTextLine("</table>");
}

// @ InfoStr - Variable info
// @ bIsChecked - Checkbox currently checked?
// @ ResponseVar - Used for idetifying with responseline.
Static function AddConfigCheckbox( WebQuery Query, string InfoStr, bool bIsChecked, string ResponseVar, optional bool bNotTable )
{
	local string Ch;

	if( bIsChecked )
		Ch = " checked=\"checked\"";
	if( bNotTable )
		Query.SendTextLine(InfoStr$":<input class=\"checkbox\" name=\""$ResponseVar$"\" value=\"1\""$Ch$" type=\"checkbox\">");
	else Query.SendTextLine("<tr><td>"$InfoStr$":</td><td><input class=\"checkbox\" name=\""$ResponseVar$"\" value=\"1\""$Ch$" type=\"checkbox\"></td></tr>");
}

// @ InfoStr - Variable info
// @ CurVal - Current text value now.
// @ MaxLen - Maximum length of the text.
// @ ResponseVar - Used for idetifying with responseline.
Static function AddConfigEditbox( WebQuery Query, string InfoStr, string CurVal, int MaxLen, string ResponseVar, optional bool bNotTable )
{
	CurVal = Query.ParseSafeText(CurVal);
	if( bNotTable )
		Query.SendTextLine(InfoStr$":<input class=\"textbox\" class=\"text\" name=\""$ResponseVar$"\" size=\""$Min(100,MaxLen)$"\" value=\""$CurVal$"\" maxlength=\""$MaxLen$"\">");
	else Query.SendTextLine("<tr><td>"$InfoStr$":</td><td><input class=\"textbox\" class=\"text\" name=\""$ResponseVar$"\" size=\""$Min(100,MaxLen)$"\" value=\""$CurVal$"\" maxlength=\""$MaxLen$"\"></td></tr>");
}

defaultproperties
{
	PageName="Mod page"
}
