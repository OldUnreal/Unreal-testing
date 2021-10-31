//=============================================================================
// UBrowserRulesList - The rules returned by the server
//=============================================================================
class UBrowserRulesList extends UWindowList;

var string			Rule;
var string			Value;

// Sentinel only
var int				SortColumn;
var bool			bDescending;

function SortByColumn(int Column)
{
	if (SortColumn == Column)
	{
		bDescending = !bDescending;
	}
	else
	{
		SortColumn = Column;
		bDescending = False;
	}

	Sort();
}

function bool Compare(UWindowList T, UWindowList B)
{
	local bool bResult;

	if (B == None) return True;

	if (UBrowserRulesList(T).Rule < UBrowserRulesList(B).Rule)
	{
		bResult = True;
	}
	else
		bResult = False;

	if (UBrowserRulesList(Sentinel).bDescending)
		bResult = !bResult;

	return bResult;
}

defaultproperties
{
	SortColumn=1
}