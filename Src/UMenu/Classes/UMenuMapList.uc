class UMenuMapList expands UWindowListBoxItem;

var string MapName;
var string DisplayName;

function bool Compare(UWindowList T, UWindowList B)
{
	if (Caps(UMenuMapList(T).MapName) < Caps(UMenuMapList(B).MapName))
		return true;

	return false;
}

// Call only on sentinel
function UMenuMapList FindMap(string FindMapName)
{
	local UMenuMapList I;

	for (I = UMenuMapList(Next); I != None; I = UMenuMapList(I.Next))
		if (I.MapName ~= FindMapName)
			return I;

	return None;
}

defaultproperties
{
}
