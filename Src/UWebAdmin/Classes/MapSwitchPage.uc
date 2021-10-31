//=============================================================================
// MapSwitchPage. Switch the map/game/mutators.
//=============================================================================
class MapSwitchPage expands ModPageContent;

var bool bInitAll;
struct GTListType
{
	var string GClass,GName;
	var bool bSelected;
};
var array<GTListType> GTList,MUTList;
var int NumGTs,NumMUTs;

Static function AddModBasedString( WebQuery Query )
{
	local string CurM,ML;
	local int i;

    Query.SendTextLine("<div class='MapSwitchPage'>");
	Query.SendTextLine("Select your map/game/mutators you would like to switch to, * = currently being used.<br />");
	Query.SendTextLine("<h3>Map:</h3>");
	Query.SendTextLine("<select class=\"mini\" name=\"MP\">");

	// Fill up maplist.
	CurM = string(Query.Connection.Outer.Name);
	foreach Query.AllFiles("unr","",ML)
	{
		ML = Left(ML,Len(ML)-4);
		if( CurM~=ML )
			Query.SendTextLine("<option value=\""$ML$"\" selected=\"selected\">*"$ML$"</option>");
		else Query.SendTextLine("<option value=\""$ML$"\">"$ML$"</option>");
	}
	Query.SendTextLine("</select><br />");
	if( !Default.bInitAll )
		InitGameTypesMuts(Query.Connection);
	Query.SendTextLine("<h3>Game Type:</h3>");
	Query.SendTextLine("<select class=\"mini\" name=\"GT\">");

	// Fill up gametypes.
	For( i=0; i<Default.NumGTs; i++ )
	{
		if( Default.GTList[i].bSelected )
			Query.SendTextLine("<option value=\""$Default.GTList[i].GClass$"\" selected=\"selected\">*"$Default.GTList[i].GName$"</option>");
		else Query.SendTextLine("<option value=\""$Default.GTList[i].GClass$"\">"$Default.GTList[i].GName$"</option>");
	}
	Query.SendTextLine("</select><br />");
	Query.SendTextLine("<h3>Mutators:</h3>");
	Query.SendTextLine("<select name=\"MU\" size=\"10\" multiple=\"multiple\">");

	// Send mutators
	For( i=0; i<Default.NumMUTs; i++ )
	{
		if( Default.MUTList[i].bSelected )
			Query.SendTextLine("<option value=\""$Default.MUTList[i].GClass$"\" selected=\"selected\">*"$Default.MUTList[i].GName$"</option>");
		else Query.SendTextLine("<option value=\""$Default.MUTList[i].GClass$"\">"$Default.MUTList[i].GName$"</option>");
	}
	Query.SendTextLine("</select><br />");

	// Inventory checkbox.
	Query.SendTextLine("Keep Inventory: <input class=\"checkbox\" name=\"KI\" value=\"1\" type=\"checkbox\"><br />");
	Query.SendTextLine("</div>");
}

static function InitGameTypesMuts( Actor Other )
{
	local string Ent,Des,S;
	local int i;
	local Class<GameInfo> GE;
	local Mutator M;

	Default.bInitAll = True;
	foreach Other.IntDescIterator(string(Class'GameInfo'),Ent)
	{
		GE = Class<GameInfo>(DynamicLoadObject(Ent,Class'Class',True));
		if( GE!=None )
		{
			Default.GTList[Default.NumGTs].GClass = string(GE);
			Default.GTList[Default.NumGTs].GName = GE.Default.GameName@"("$GE.Name$")";
			++Default.NumGTs;
		}
	}

	S = string(Other.Level.Game.Class);
	For( i=0; i<Default.NumGTs; ++i )
	{
		if( Default.GTList[i].GClass~=S )
		{
			Default.GTList[i].bSelected = True;
			Break;
		}
	}
	if( i==Default.NumGTs )
	{
		Default.GTList[Default.NumGTs].GClass = S;
		Default.GTList[Default.NumGTs].GName = Other.Level.Game.GameName@"("$Other.Level.Game.Class.Name$")";
		Default.GTList[Default.NumGTs].bSelected = True;
		++Default.NumGTs;
	}

	foreach Other.IntDescIterator(string(Class'Mutator'),Ent,Des)
	{
		if( Des=="" )
			Des = Ent;
		else
		{
			i = InStr(Des,",");
			if( i>0 )
				Des = Left(Des,i); // Leave out mutator description.
		}
		Default.MUTList[Default.NumMUTs].GClass = Ent;
		Default.MUTList[Default.NumMUTs].GName = Des;
		++Default.NumMUTs;
	}
	For( M=Other.Level.Game.BaseMutator; M!=None; M=M.NextMutator )
	{
		if( M.Class==Class'Mutator' )
			Continue;
		S = string(M.Class);
		For( i=0; i<Default.NumMUTs; ++i )
		{
			if( Default.MUTList[i].GClass~=S )
			{
				Default.MUTList[i].bSelected = True;
				Break;
			}
		}
		if( i<Default.NumMUTs )
			Continue;
		Default.MUTList[Default.NumMUTs].GClass = S;
		Default.MUTList[Default.NumMUTs].GName = S;
		++Default.NumMUTs;
	}
}

Static function ProcessReceivedData( WebQuery Query )
{
	local bool bTravels;
	local string S,Muts,MapN,GameN;

	MapN = Query.GetValue("MP",string(Query.Connection.Outer.Name));
	GameN = Query.GetValue("GT",string(Query.Connection.Level.Game.Class));
	bTravels = bool(Query.GetValue("KI","0"));

	foreach Query.MultiValue("MU",S)
	{
		if( Muts=="" )
			Muts = "?Mutator="$S;
		else Muts = Muts$","$S;
	}
	if( Muts=="" )
		Muts = "?Mutator=None";

	// Make the mapswitch
	Query.Connection.Level.ServerTravel(MapN$"?Game="$GameN$Muts,bTravels);
}

defaultproperties
{
	bNoExtraInfo=true
}
