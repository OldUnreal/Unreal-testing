// Helper to make skeletal model limb reach for a target location.
Class IK_Limb extends IK_SolverBase
	native;

var(IK) name LimbBone; // Foot or hand bone, parent bone must be knee or elbow.
var(IK) vector Target, // Target vector.
			LimbOffset; // Center offset of the limb bone (ie. middle of hand or foot).
var(IK) rotator LowLimbDir,HighLimbDir; // Green arrow must face down long limb, blue arrow must face the direction the limb naturally rotates.
var(IK) float StretchLimit[2]; // Min/max stretch length if bAllowStretch.
var(IK) bool bAllowStretch, // Allow limb to stretch out to reach target.
			bHasDoubleBones; // Also take the next higher bone, the axel or thigh bone.

var transient int iLimbBone,iLowLimbBone,iHighLimbBone;
var const transient float PrevScale,AdjustAlpha,OldAlpha;
var transient vector JointBendDir;

var transient bool bNoUpdate;
var transient const bool bContact; // Is currently contacting Target vector.

defaultproperties
{
	StretchLimit(0)=0.8
	StretchLimit(1)=1.2
	bHasDoubleBones=true
}