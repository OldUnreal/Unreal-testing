// IK Solver to give mesh a jaw movement while talking
Class IK_LipSync extends IK_SolverBase
	native;

enum EJawRotateAxis
{
	JAWAXIS_Pitch,
	JAWAXIS_Yaw,
	JAWAXIS_Roll,
};
var(IK) name JawBone; // Name of the jaw bone.
var(IK) int JawBoneRot; // Maximum rotation of the jawbone to consider mouth wide open.
var(IK) EJawRotateAxis JawRotationAxis; // Rotation axis of the jaw bone.

var transient int iJawBone;
var transient const float VoiceVolume, LIPSyncTime, LIPSyncRate, OldAlpha;
var transient const Sound LIPSyncSound;

native final function StartLIPSyncTrack( Sound Sound, optional float Pitch );

defaultproperties
{
	JawBoneRot=8000
	JawRotationAxis=JAWAXIS_Pitch
}