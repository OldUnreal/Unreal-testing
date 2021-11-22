//=============================================================================
// This joint is at a fixed coordinate.
//=============================================================================
Class PXJ_FixedJoint extends PXJ_BaseJoint
	native;

cpptext
{
	UPXJ_FixedJoint() {}
	PX_JointObject* InitJoint( PX_PhysicsObject* A, PX_PhysicsObject* B, const FCoords* CA, const FCoords* CB );
}

defaultproperties
{
}