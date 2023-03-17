class UWindowEditBoxHistoryFile expands UWindowBase
	config(User)
	PerObjectConfig;

var config array<string> H; // History lines.
var config array<string> Blacklist; // Blacklist lines.
var config int MaxHistory;

final function UWindowEditBoxHistory LoadHistory( UWindowEditBoxHistory L )
{
	local int i;
	local UWindowEditBoxHistory Result;
	
	L.DisconnectList();
	if( MaxHistory>0 )
	{
		for( i=(Min(H.Size(),MaxHistory) - 1); i>=0; --i )
		{
			Result = UWindowEditBoxHistory(L.Insert(class'UWindowEditBoxHistory'));
			Result.HistoryText = H[i];
		}
	}
	return Result;
}
final function SaveFullHistory( UWindowEditBoxHistory L )
{
	local int i;
	local UWindowEditBoxHistory C;
	
	if( MaxHistory<=0 )
		H.Empty();
	else
	{
		for ( C=UWindowEditBoxHistory(L.Next); (C!=none && i<MaxHistory); C = UWindowEditBoxHistory(C.Next))
		{
			H[i++] = C.HistoryText;
		}
		H.SetSize(i);
	}
	SaveConfig();
}
final function SaveNewHistory( string Str )
{
	local int i;
	
	if( MaxHistory<=0 )
		H.Empty();
	else
	{
		for( i=(Blacklist.Size()-1); i>=0; --i )
			if( StartsWith(Str,Blacklist[i]$" ",true) )
				return;
		
		i = H.Find(Str);
		if( i>=0 )
			H.Remove(i);
		H.Insert(0);
		H[0] = Str;
		if( H.Size()>MaxHistory )
			H.SetSize(MaxHistory);
	}
	SaveConfig();
}

defaultproperties
{
	MaxHistory=24
}
