// Helper to make skeletal model foot get nicely placed on ground.
Class IK_FootPlacement extends IK_Limb
	native;

var(IK) array<name> GroundAnimGroups, // Animation groups that's considered standing still (if empty, assume all animations).
					WalkAnimGroups; // Walking/Running animation group's where foot does contact the ground (optional).
var(IK) float GroundHeight, // Optional: If walking/running, when foot is at this height it's considered on ground.
				AdjustRenderZ; // While standing, allow to move model this much downwards to make feet stand on ground.
var(IK) rotator FootDir; // Green arrow must face forward from toes and blue arrow up at ground direction.

var vector Floor;

// Note: Call reset to sync up GroundAnimGroups/WalkAnimGroups to C++ codes.
var pointer<TSingleMap<FName>*> StandGroups;
var pointer<TSingleMap<FName>*> WalkGroups;
var pointer<const struct FMeshAnimSeq*> PrevAnimName;

var transient vector TweenFloor,TweenTarget;

var transient const bool bAnimStarted,bCorrectAnim,bCheckGroundHeight,bPrimaryController,bHasGround;

defaultproperties
{
	bEnabled=true
	bLimitToPawn=true
	AdjustRenderZ=20
}