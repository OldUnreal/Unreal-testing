//=============================================================================
// ReplicationInfo.
//=============================================================================
class ReplicationInfo extends Info
	abstract
	native;

// Internal linked list of ReplicationInfos for faster AllActors with these!
var transient private ReplicationInfo NextRI;

defaultproperties
{
	bAlwaysRelevant=True
	bCrossLevelNetwork=true
	bStatic=False
	bNoDelete=False
	NetUpdateFrequency=4
	NetPriority=6
	bForceDirtyReplication=true
}