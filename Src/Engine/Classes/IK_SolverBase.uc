// Inverse kinematics resolver base class.
// To be used with SkeletalMeshes.
Class IK_SolverBase extends Object
	native
	abstract;

enum ERotationAxis
{
	ROT_PitchYawRoll,
	ROT_YawPitchRoll,
	ROT_PitchRollYaw,
	ROT_RollPitchYaw,
	ROT_RollYawPitch,
};

var pointer<struct FSkelMeshInstance*> MeshInstance;

var(IK) name Tag; // Optional unique tag to help find this in UnrealScript.
var(IK) const bool bEnabled;
var(IK) bool bLimitToPawn; // Only Pawn based owners can use this (to prevent preview player model from screwing it up).
var(IK) transient bool bPreviewMode,bPreviewMotion; // Editor preview mode.
var(IK) transient bool bPreviewAxis; // Editor preview rotation axis.

// About to enable/disable.
var float TimerRate,TimerCounter;
var bool bBlendOut;

// Force to refresh the parameters (link bone names to bone indices etc).
native final function Reset();

// Enable or disable this solver with a blend time.
native final function SetEnabled( bool bEnable, optional float BlendTime );
