class UBrowserFavoritesFact extends UBrowserServerListFactory;

struct FavoriteServerType
{
	var config int ServerPort;
	var config string ServerName,ServerIP;
};
var config array<FavoriteServerType> Favorites;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	local int i,l;

	l = Array_Size(Favorites);
	for ( i=0; i<l; i++ )
		FoundServer(Favorites[i].ServerIP, Favorites[i].ServerPort, "", "Unreal", Favorites[i].ServerName);

	Super.Query();
	QueryFinished(True);
}

function SaveFavorites()
{
	local UBrowserServerList I;
	local int j;

	Array_Size(Favorites,0); // Empty array first.
	for ( I=UBrowserServerList(Owner.Next); i!=None; I=UBrowserServerList(I.Next) )
	{
		Favorites[j].ServerIP = I.IP;
		Favorites[j].ServerPort = I.QueryPort;
		Favorites[j].ServerName = StripIniChars(I.HostName);
		j++;
	}
	SaveConfig();
}

/* Strip illegal ini characters. */
static final function string StripIniChars( string S )
{
	S = ReplaceStr(S,"\"","'");
	S = ReplaceStr(S,Chr(10),"");
	S = ReplaceStr(S,Chr(13),"");
	return S;
}

defaultproperties
{
}