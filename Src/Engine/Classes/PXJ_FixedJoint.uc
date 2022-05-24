//=============================================================================
// This joint is at a fixed coordinate.
//=============================================================================
Class PXJ_FixedJoint extends PXJ_BaseJoint
	native;

cpptext
{
	UPXJ_FixedJoint() {}
	UBOOL InitJoint( PX_JointObject& Joint, const FCoords& CA, const FCoords& CB );
}

defaultproperties
{
}