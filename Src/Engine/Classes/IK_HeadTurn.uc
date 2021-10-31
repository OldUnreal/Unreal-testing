// Helper to make skeletal model head focus at a position.
Class IK_HeadTurn extends IK_SolverBase
	native;

var(IK) vector ViewPosition; // World location to face at.
var(IK) name HeadBone; // The head bone in question.
var(IK) int MaxAngYaw[2],MaxAngPitch[2]; // Limited view angles of head.
var(IK) float RotationRate; // Rotation speed of head.
var(IK) rotator HeadBoneDir; // Enable bPreviewAxis and try to get Green arrow to face forward and blue arrow upwards from head.
var(IK) ERotationAxis RotationAxis; // Rotation axis to apply to bones.
var(IK) bool bOutofRangeForward; // Make the head face forward when view target is out of range (behind).
var(IK) bool bFlipYaw,bFlipPitch; // Flip rotation axis if it's inverted.

var transient int iHeadBone;
var transient float RotationAlpha,OldAlpha;
var transient rotator CurrentTurn;

defaultproperties
{
	MaxAngYaw(0)=-16384
	MaxAngYaw(1)=16384
	MaxAngPitch(0)=-8000
	MaxAngPitch(1)=8000
	ViewPosition=(X=800)
	bFlipYaw=true
	RotationAxis=ROT_RollYawPitch
	RotationRate=32000
}