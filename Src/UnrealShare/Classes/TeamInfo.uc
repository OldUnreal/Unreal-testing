//=============================================================================
// TeamInfo.
//=============================================================================
class TeamInfo extends Info
	NoUserCreate;

var string TeamName;
var int Size; //number of players on this team in the level
var float Score;
var int TeamIndex;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		TeamName, Size, Score, TeamIndex;
}

defaultproperties
{
	bAlwaysRelevant=true;
}
