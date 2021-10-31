//=============================================================================
// MapListPage. Maplist config page.
//=============================================================================
class MapListPage expands WebPageContent;

var string DoMapList; // Filled in by SubWebManager.

Static function LoadUpClassContent( WebQuery Query )
{
	local class<MapList> MPLC;
	local string S,PreF,ML;
	local int i,c;

    Query.SendTextLine("<div class='MapListPage'>");
	if( Default.DoMapList=="" )
	{
		Query.SendTextLine("<h1>Missing maplist code<h1>");
		Return;
	}
	i = InStr(Default.DoMapList,".");
	PreF = Left(Default.DoMapList,i);
	S = Mid(Default.DoMapList,i+1);
	MPLC = Class<MapList>(DynamicLoadObject(S,Class'Class',True));
	if( MPLC==None )
	{
		Query.SendTextLine("<h1>Bad maplist class specified: "$Default.DoMapList$"<h1>");
		Return;
	}
	Query.SendTextLine("<!-- Maplist auto-gen code -->");
	Query.SendTextLine("Select maps you wish to add or remove from the maplist, then press Submit (using Ctrl key you can select multiple maps).<br />");
	Query.SendTextLine("<form method=\"post\" action=\"MapList_"$Default.DoMapList$"?"$Default.Class$"\">");
	Query.SendTextLine("<table><tr><th>Maps not in cycle:</th><th>Maps in cycle:</th></tr>");
	Query.SendTextLine("<tr><td><select name=\"INC\" size=\"10\" multiple=\"multiple\">");

	// Fill up available maps list.
	c = Array_Size(MPLC.Default.MapsArray);
	foreach Query.AllFiles("unr",PreF,ML)
	{
		For( i=0; i<c; i++ )
		{
			if( MPLC.Default.MapsArray[i]~=ML )
				Break;
		}
		if( i==c )
			Query.SendTextLine("<option value=\""$ML$"\">"$ML$"</option>");
	}
	Query.SendTextLine("</select></td><td><select name=\"EXC\" size=\"10\" multiple=\"multiple\">");

	// Fill up used maps.
	For( i=0; i<c; i++ )
	{
		if( MPLC.Default.MapsArray[i]!="" )
		{
			if( !(Right(MPLC.Default.MapsArray[i],4)~=".unr") )
				MPLC.Default.MapsArray[i] = MPLC.Default.MapsArray[i]$".unr";
			Query.SendTextLine("<option value=\""$MPLC.Default.MapsArray[i]$"\">"$MPLC.Default.MapsArray[i]$"</option>");
		}
	}
	Query.SendTextLine("</select></td></tr></table>");
	Query.SendTextLine("<p><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Submit\"></form>");
	Query.SendTextLine("<!-- End of maplist code -->");
    Query.SendTextLine("</div>");
}

Static function ProcessReceivedData( WebQuery Query )
{
	local int i,c;
	local class<MapList> MPLC;
	local string S;

	i = InStr(Default.DoMapList,".");
	MPLC = Class<MapList>(DynamicLoadObject(Mid(Default.DoMapList,i+1),Class'Class',True));
	if( MPLC==None )
		Return;
	c = Array_Size(MPLC.Default.MapsArray);

	// Get include maps.
	foreach Query.MultiValue("INC",S)
		MPLC.Default.MapsArray[c++] = S;

	// Get exclude maps.
	foreach Query.MultiValue("EXC",S)
	{
		for( i=0; i<c; i++ )
		{
			if( MPLC.Default.MapsArray[i]~=S )
			{
				Array_Remove(MPLC.Default.MapsArray,i);
				c--;
				break;
			}
		}
	}
	MPLC.Static.StaticSaveConfig();
}

