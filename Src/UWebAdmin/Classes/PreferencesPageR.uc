//=============================================================================
// PreferencesPageR.
//=============================================================================
class PreferencesPageR expands ModPageContent;

var int EditLineNum,EditArrayLine;

static final function string GrabClassName( WebQuery Query )
{
	local int i;
	local string S;

	S = Mid(Query.URL,1);
	i = InStr(S,"|");
	if( i>=0 )
	{
		S = Mid(S,i+1);
		i = InStr(S,"|");
		if( i>=0 )
			return Left(S,i);
		return S;
	}
	return "";
}
static final function string GrabCategory( WebQuery Query )
{
	local int i;
	local string S;

	S = Query.URL;
	i = InStr(S,"|");
	if( i==-1 )
		return "";
	S = Mid(S,i+1);
	i = InStr(S,"|");
	if( i==-1 )
		return "";
	S = Mid(S,i+1);
	i = InStr(S,"|");
	if( i>=0 )
		return Left(S,i);
	return S;
}
static final function int GrabImmediate( WebQuery Query )
{
	local int i;
	local string S;

	S = Query.URL;
	i = InStr(S,"|");
	if( i==-1 )
		return 0;
	S = Mid(S,i+1);
	i = InStr(S,"|");
	if( i==-1 )
		return 0;
	S = Mid(S,i+1);
	i = InStr(S,"|");
	if( i>=0 )
		return int(Mid(S,i+1));
	return 0;
}
Static function LoadUpClassContent( WebQuery Query )
{
	local int i,Id,j;
	local string S,VN;
	local Object C;
	local array<VariableInfo> Vars;

	S = GrabClassName(Query);
	if( S!="" )
		C = DynamicLoadObject(S,Class'Class');
	VN = GrabCategory(Query);

	Query.SendTextLine("<div class='PreferencesPageR'>");
	Query.SendTextLine("<!-- Object properties -->");
	Query.SendTextLine("<form action=\"../Mod_"$Default.Class$"|"$S$"|"$VN$"|"$string(GrabImmediate(Query))$"?"$Default.Class$"\" method=\"post\">");
	StartTable(Query);
	Query.SendTextLine("<tr><th>");
	if( C==None )
		Query.SendTextLine("Unknown object '"$S$"'");
	else Query.SendTextLine(string(C)$" properties");
	Query.SendTextLine("</th></tr>");

	if( C!=None && Query.GetVariables(S,VN,Vars) )
	{
		for( i=0; i<Array_Size(Vars); ++i )
		{
			Id = Vars[i].NumElements;

			// Add number of array elements if it is an array.
			if( Id==1 )
				VN = string(Vars[i].VarName);
			else if( Id>1 )
				VN = string(Vars[i].VarName)$"["$Id$"]";
			else VN = string(Vars[i].VarName)$"["$(-Id)$"]";

			// Add description if available.
			if( Vars[i].VarDesc!="" )
				Query.SendTextLine("<tr><td><p title=\""$Vars[i].VarDesc$"\">"$VN$"</p></td><td>",false);
			else Query.SendTextLine("<tr><td>"$VN$"</td><td>",false);
			if( Default.EditLineNum==i )
			{
				if( Id==1 )
				{
					SendInputControls(Query,Vars[i].VarType,Vars[i].VarName,Vars[i].Value[0],Vars[i].EnumList);
					Query.SendTextLine("</td><td><input class=\"button\" type=\"submit\" name=\"edi"$i$"\" value=\"Submit\"></td></tr>");
				}
				else if( Id>1 ) // Static array.
				{
					Query.SendTextLine("</td></tr>");
					for( j=0; j<Id; ++j )
					{
						Query.SendTextLine("<tr><td>["$j$"]</td><td>",false);
						if( j==Default.EditArrayLine )
						{
							SendInputControls(Query,Vars[i].VarType,Vars[i].VarName,Vars[i].Value[j],Vars[i].EnumList);
							Query.SendTextLine("</td><td><input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"\" value=\"Submit\"></td></tr>");
						}
						else Query.SendTextLine(Query.ParseSafeText(Vars[i].Value[j])$"</td><td><input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"\" value=\"Edit\"></td></tr>");
					}
				}
				else // Dynamic array.
				{
					Query.SendTextLine("</td></tr>");
					Id = -Id;
					for( j=0; j<Id; ++j )
					{
						Query.SendTextLine("<tr><td>["$j$"]</td><td>",false);
						if( j==Default.EditArrayLine )
						{
							SendInputControls(Query,Vars[i].VarType,Vars[i].VarName,Vars[i].Value[j],Vars[i].EnumList);
							Query.SendTextLine("</td><td><input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"\" value=\"Submit\"></td></tr>");
						}
						else
						{
							Query.SendTextLine(Query.ParseSafeText(Vars[i].Value[j])$"</td><td><input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"\" value=\"Edit\">",false);
							Query.SendTextLine("<input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"_"$Vars[i].VarName$"\" value=\"Insert\">",false);
							Query.SendTextLine("<input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"_"$Vars[i].VarName$"\" value=\"Delete\"></td></tr>");
						}
					}
					Query.SendTextLine("<tr><td></td><td></td><td><input class=\"button\" type=\"submit\" name=\"edi"$i$"_"$j$"_"$Vars[i].VarName$"\" value=\"Add\"></td></tr>",false);
				}
			}
			else
			{
				if( Id==1 )
					Query.SendTextLine(Query.ParseSafeText(Vars[i].Value[0])$"</td>");
				else
				{
					if( Id<0 )
						Id = -Id;
					Query.SendTextLine("...</td>");
				}
				Query.SendTextLine("<td><input class=\"button\" type=\"submit\" name=\"edi"$i$"\" value=\"Edit\"></td></tr>");
			}
		}
	}
	EndTable(Query);
	Query.SendTextLine("</form><!-- End of Object properties -->");
    Query.SendTextLine("</div>");

	// Reset temporary variables.
	Default.EditLineNum = -1;
	Default.EditArrayLine = -1;
}
Static function ProcessReceivedData( WebQuery Query )
{
	local string ID,Value;
	local bool bSubmitted;

	foreach Query.AllValues(ID,Value,"edi")
	{
		if( Value=="Edit" )
		{
			GrabInputLines(Mid(ID,3),Default.EditLineNum,Default.EditArrayLine);
			return;
		}
		else if( Value=="Insert" )
		{
			GrabInputLines(Mid(ID,3),Default.EditLineNum,Default.EditArrayLine);
			Query.SetVariable(GrabClassName(Query),GrabVarName(ID)$"+"$Default.EditArrayLine,"",bool(GrabImmediate(Query)));
			return;
		}
		else if( Value=="Add" )
		{
			GrabInputLines(Mid(ID,3),Default.EditLineNum,Default.EditArrayLine);
			Query.SetVariable(GrabClassName(Query),GrabVarName(ID)$"++","",bool(GrabImmediate(Query)));
			return;
		}
		else if( Value=="Delete" )
		{
			GrabInputLines(Mid(ID,3),Default.EditLineNum,Default.EditArrayLine);
			Query.SetVariable(GrabClassName(Query),GrabVarName(ID)$"-"$Default.EditArrayLine,"",bool(GrabImmediate(Query)));
			Default.EditArrayLine = -1;
			return;
		}
		else if( Value=="Submit" )
		{
			GrabInputLines(Mid(ID,3),Default.EditLineNum,Default.EditArrayLine);
			bSubmitted = true;
		}
		break;
	}
	if( bSubmitted )
	{
		foreach Query.AllValues(ID,Value,"_")
		{
			if( Default.EditArrayLine>=0 )
				Query.SetVariable(GrabClassName(Query),Mid(ID,1)$"|"$Default.EditArrayLine,Value,bool(GrabImmediate(Query)));
			else Query.SetVariable(GrabClassName(Query),Mid(ID,1),Value,bool(GrabImmediate(Query)));
			break;
		}
	}
	if( Default.EditArrayLine==-1 )
		Default.EditLineNum = -1;
	else Default.EditArrayLine = -1;
}

static final function GrabInputLines( string S, out int A, out int B )
{
	local int i;

	i = InStr(S,"_");
	if( i==-1 )
	{
		A = int(S);
		B = -1;
	}
	else
	{
		A = int(Left(S,i));
		B = int(Mid(S,i+1));
	}
}
static final function string GrabVarName( string S )
{
	S = Mid(S,InStr(S,"_")+1);
	return Mid(S,InStr(S,"_")+1);
}
static final function SendInputControls( WebQuery Query, byte Type, name VarName, string Value, array<name> EnumAr )
{
	local string S;
	local int j;

	switch( Type )
	{
	case 7: // bool
		Query.SendTextLine("<select class=\"mini\" name=\"_"$VarName$"\">");
		if( bool(Value) )
			Query.SendTextLine("<option value=\"1\" selected=\"selected\">True</option><option value=\"0\">False</option>");
		else Query.SendTextLine("<option value=\"1\">True</option><option value=\"0\" selected=\"selected\">False</option>");
		Query.SendTextLine("</select>",false);
		break;
	case 3: // enum
		Query.SendTextLine("<select class=\"mini\" name=\"_"$VarName$"\">");
		for( j=0; j<Array_Size(EnumAr); ++j )
		{
			if( Value~=string(EnumAr[j]) )
				S = " selected=\"selected\"";
			else S = "";
			Query.SendTextLine("<option value=\""$EnumAr[j]$"\""$S$">"$EnumAr[j]$"</option>");
		}
		Query.SendTextLine("</select>",false);
		break;
	case 2: // byte
		Query.SendTextLine("<input class=\"textbox\" class=\"text\" name=\"_"$VarName$"\" size=\"3\" value=\""$Value$"\" maxlength=\"3\">",false);
		break;
	default: // everything else.
		Query.SendTextLine("<input class=\"textbox\" class=\"text\" name=\"_"$VarName$"\" size=\"64\" value=\""$Query.ParseSafeText(Value)$"\" maxlength=\"255\">",false);
	}
}

defaultproperties
{
	RequiredPrivileges=255
	EditLineNum=-1
	EditArrayLine=-1
}
