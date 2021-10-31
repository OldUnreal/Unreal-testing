//=============================================================================
// MasterCreatureChunk
//=============================================================================
class MasterCreatureChunk extends CreatureChunks;

var PlayerReplicationInfo PlayerRep;

replication
{
	// Things the server should send to the client.
	unreliable if ( Role==ROLE_Authority )
		PlayerRep;
}

function SetAsMaster(Actor Other)
{
	Velocity = Other.Velocity;
	CarcassAnim = Other.AnimSequence;
	CarcHeight = Other.CollisionHeight;
}

defaultproperties
{
	TrailSize=0.5
	CarcHeight=+39.0
	bMasterChunk=true
}