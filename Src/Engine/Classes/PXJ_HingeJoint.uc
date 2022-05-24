//=============================================================================
// Simple hinge joint.
//=============================================================================
Class PXJ_HingeJoint extends PXJ_BaseJoint
	native;

var(Limit) bool bLimitMovement; // Add a movement limit to this joint.
var(Limit) bool bHardLimit; // Limited movement is soft or hard.
var(Limit) float LimitStiffness, LimitDamping;
var(Limit) float LimitRangeLow, LimitRangeHigh; // High/Low limit range in radians.

var(Motor) bool bMotor; // Enable automatic spinning.
var(Motor) bool bMotorFreeDrive; // Motor keeps accelerating instead of enforcing motor speed.
var(Motor) float MotorSpeed; // How fast should motor spin.
var(Motor) float MotorMaxSpeed; // Maximum allowed motor speed.

cpptext
{
	UPXJ_HingeJoint() {}
	UBOOL InitJoint( PX_JointObject& Joint, const FCoords& CA, const FCoords& CB );
	void DrawLimitations( FSceneNode* Frame, const FCoords& C );
}

defaultproperties
{
	MotorMaxSpeed=10000
	MotorSpeed=180
}