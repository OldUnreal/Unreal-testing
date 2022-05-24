//=============================================================================
// Attempt to move physics object to a position (this joint ignores target actor).
//=============================================================================
Class PXJ_ShadowParm extends PXJ_BaseJoint
	native;

var() vector TargetLocation;
var() quat TargetRotation;

var() bool bOrientToLocation,bOrientToRotation;

final function SetLocation( vector V, rotator R )
{
	TargetLocation = V;
	TargetRotation = RotationToQuat(R);
}
final function SetRotation( rotator R )
{
	TargetRotation = RotationToQuat(R);
}

cpptext
{
	UPXJ_ShadowParm() {}
	UBOOL InitJoint( PX_JointObject& Joint, const FCoords& CA, const FCoords& CB );
	void UpdateCoords( UBOOL bOnlyWorld ) {}
}

defaultproperties
{
	TargetRotation=(X=1)
	bOrientToLocation=true
	bOrientToRotation=true
}