//=============================================================================
// UBrowserPlayerList - The player list returned by the server.
//=============================================================================
class UBrowserPlayerList extends UWindowList;

var string			PlayerName;
var string			PlayerMesh;
var string			PlayerSkin;
var string			PlayerTeam;
var int				PlayerFrags;
var int				PlayerPing;
var int				PlayerID;

// Sentinel Only
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
	local UBrowserPlayerList PT, PB;

	if (B == None) return True;

	PT = UBrowserPlayerList(T);
	PB = UBrowserPlayerList(B);

	switch (UBrowserPlayerList(Sentinel).SortColumn)
	{
	case 0:
		if (Caps(PT.PlayerName) < Caps(PB.PlayerName))
			bResult = True;
		else if (PT.PlayerName > PB.PlayerName)
			bResult = False;
		else
			bResult = (PT.PlayerPing < PB.PlayerPing);
		break;
	case 1:
		if (PT.PlayerFrags > PB.PlayerFrags)
			bResult = True;
		else if (PT.PlayerFrags < PB.PlayerFrags)
			bResult = False;
		else
			bResult = (PT.PlayerName < PB.PlayerName);
		break;
	case 2:
		if (PT.PlayerPing < PB.PlayerPing)
			bResult = True;
		else if (PT.PlayerPing > PB.PlayerPing)
			bResult = False;
		else
			bResult = (PT.PlayerName < PB.PlayerName);
		break;
	case 3:
		if (PT.PlayerTeam > PB.PlayerTeam)
			bResult = True;
		else if (PT.PlayerTeam < PB.PlayerTeam)
			bResult = False;
		else
			bResult = (PT.PlayerName < PB.PlayerName);
		break;
	case 4:
		if (PT.PlayerMesh < PB.PlayerMesh)
			bResult = True;
		else if (PT.PlayerMesh > PB.PlayerMesh)
			bResult = False;
		else
			bResult = (PT.PlayerName < PB.PlayerName);
		break;
	case 5:
		if (PT.PlayerSkin < PB.PlayerSkin)
			bResult = True;
		else if (PT.PlayerSkin > PB.PlayerSkin)
			bResult = False;
		else
			bResult = (PT.PlayerName < PB.PlayerName);
		break;
	case 6:
		if (PT.PlayerID < PB.PlayerID)
			bResult = True;
		else if (PT.PlayerID > PB.PlayerID)
			bResult = False;
		else
			bResult = (PT.PlayerName < PB.PlayerName);
		break;
	}


	if (UBrowserPlayerList(Sentinel).bDescending) bResult = !bResult;

	return bResult;
}

function UBrowserPlayerList FindID(int ID)
{
	local UBrowserPlayerList l;

	l = UBrowserPlayerList(Next);
	while (l != None)
	{
		if (l.PlayerID == ID) return l;
		l = UBrowserPlayerList(l.Next);
	}
	return None;
}

defaultproperties
{
	SortColumn=1
}