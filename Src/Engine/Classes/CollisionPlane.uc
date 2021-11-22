// Written by .:..:, simple collision plane for setting up map boundries.
Class CollisionPlane extends KeyPoint
	Native;

var() float CollisionBounds[4]; // Bounds depth values in: X / -X / Y / -Y
var() bool bBlockZeroExtent,bBlockNonZeroExtent;

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	CollisionBounds(0)=64
	CollisionBounds(1)=-64
	CollisionBounds(2)=32
	CollisionBounds(3)=-32
	bBlockNonZeroExtent=true
	bWorldGeometry=true
	bHidden=true
	bDirectional=true
}
