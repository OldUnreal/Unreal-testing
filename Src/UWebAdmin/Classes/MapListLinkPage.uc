//=============================================================================
// MapListLinkPage.
//=============================================================================
class MapListLinkPage expands WebPageContent;

var bool bInitMapLists;
struct MLType
{
	var string GName,MCName,Prefix;
};
var array<MLType> MapListsType;
var int NumMListE;

Static function LoadUpClassContent( WebQuery Query )
{
	local int i;

    Query.SendTextLine("<div class='MapListLinkPage'>");
	Query.SendTextLine("<h2>Custom maplist configures:</h2>");
	if( !Default.bInitMapLists )
		InitMapsLists(Query.Connection);
	For( i=0; i<Default.NumMListE; i++ )
		Query.SendTextLine("<a href=\"/MapList_"$Default.MapListsType[i].Prefix$"."$Default.MapListsType[i].MCName$"\">"$Default.MapListsType[i].GName$"</a><br />");
    Query.SendTextLine("</div>");
}

static function InitMapsLists( Actor Other )
{
	local string Ent,S;
	local int j;
	local Class<GameInfo> GE;

	Default.bInitMapLists = True;

	foreach Other.IntDescIterator(string(Class'GameInfo'),Ent)
	{
		GE = Class<GameInfo>(DynamicLoadObject(Ent,Class'Class',True));
		if( GE!=None && GE.Default.MapListType!=None && GE.Default.MapPrefix!="" )
		{
			S = string(GE.Default.MapListType);
			For( j=0; j<Default.NumMListE; j++ )
			{
				if( Default.MapListsType[j].MCName==S )
					Break;
			}
			if( j==Default.NumMListE )
			{
				Default.MapListsType[Default.NumMListE].MCName = S;
				Default.MapListsType[Default.NumMListE].GName = GE.Default.GameName@"("$GE.Name@"/"@GE.Default.MapListType.Name$")";
				Default.MapListsType[Default.NumMListE].Prefix = GE.Default.MapPrefix;
				++Default.NumMListE;
			}
		}
	}
}

defaultproperties
{
}
