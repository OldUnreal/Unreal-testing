//=============================================================================
// Simple socket joint.
//=============================================================================
Class PXJ_SocketJoint extends PXJ_BaseJoint
	native;

var(Limit) bool bLimitMovement; // Limit socket movement by cone.
var(Limit) vector2d MovementLimit; // Limit by X/Y axis in regular angles.

cpptext
{
	UPXJ_SocketJoint() {}
	PX_JointObject* InitJoint( PX_PhysicsObject* A, PX_PhysicsObject* B, const FCoords* CA, const FCoords* CB );
	void DrawLimitations( FSceneNode* Frame, const FCoords& C );
}

defaultproperties
{
	MovementLimit=(X=45,Y=45)
}