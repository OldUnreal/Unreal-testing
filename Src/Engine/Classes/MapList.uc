//=============================================================================
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
	NoUserCreate;

var string Maps[32]; // 227g: Old code.
var transient int MapNum; // 227g: Old code.
var(Maps) config bool bShuffleMaps;
var(Maps) config array<string> MapsArray;

function string GetNextMap()
{
	local string CurrentMap,MapNameExt;
	local int i,c;

	CurrentMap = string(Outer.Name);
	MapNameExt = CurrentMap$".unr";
	c = MapsArray.Size();
	if( c==0 )
		return "";
	if( bShuffleMaps )
	{
		while( ++i<5 )
		{
			MapNum = Rand(c);
			if( !(CurrentMap~=MapsArray[MapNum]) && !(MapNameExt~=MapsArray[MapNum]) )
				break;
		}
	}
	else
	{
		for( i=0; i<c; i++ )
			if( CurrentMap~=MapsArray[i] || MapNameExt~=MapsArray[i] )
			{
				MapNum = i;
				break;
			}
		if( ++MapNum==c )
			MapNum = 0;
	}
	return MapsArray[MapNum];
}
static function string StaticGetNextMap( string CurrentMap )
{
	local string MapNameExt;
	local int i,c,Index;

	MapNameExt = CurrentMap$".unr";
	c = Default.MapsArray.Size();
	if( c==0 )
		return "";
	if( Default.bShuffleMaps )
	{
		while( ++i<5 )
		{
			Index = Rand(c);
			if( !(CurrentMap~=Default.MapsArray[Index]) && !(MapNameExt~=Default.MapsArray[Index]) )
				break;
		}
	}
	else
	{
		for( i=0; i<c; i++ )
			if( CurrentMap~=Default.MapsArray[i] || MapNameExt~=Default.MapsArray[i] )
			{
				Index = i;
				break;
			}
		if( ++Index==c )
			Index = 0;
	}
	return Default.MapsArray[Index];
}

defaultproperties
{
	RemoteRole=ROLE_None
}