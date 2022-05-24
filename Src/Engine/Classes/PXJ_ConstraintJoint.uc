//=============================================================================
// Multi-purpose joint.
//=============================================================================
Class PXJ_ConstraintJoint extends PXJ_BaseJoint
	native;

enum EJointMotionLimit
{
	MOTION_Locked,
	MOTION_Limited,
	MOTION_Free,
};
struct export CC_LimitType
{
	var() EJointMotionLimit Limit; // Limit type of this axis (Locked = 0 freedom of movement).
	var() float Limit1,Limit2; // High or low limit when MOTION_Limited
};
struct export CC_DistanceType
{
	var() float MaxDistance; // Max distance for the joint.
	var() bool bLimitDistance; // Limit motion distance from origin of joint.
};

var(Limit) CC_LimitType XAxis,YAxis,ZAxis; // Movement limitations for each axis.
var(Limit) CC_LimitType ConeLimit; // Limit in cone motion.
var(Limit) CC_LimitType TwistLimit; // Limit in twisting.
var(Limit) CC_DistanceType DistanceLimit; // Limit on distance.

// How strong handle is.
var(Limit)	float	LinearDamping;
var(Limit)	float	LinearStiffness;
var(Limit)	vector	LinearStiffnessScale3D; // Scales the handle spring stiffness along each axis (in local space of handle)
var(Limit)	vector	LinearDampingScale3D; // Scales the handle spring damping along each axis (in local space of handle)
var(Limit)	float	AngularDamping;
var(Limit)	float	AngularStiffness;

cpptext
{
	UPXJ_ConstraintJoint() {}
	UBOOL InitJoint( PX_JointObject& Joint, const FCoords& CA, const FCoords& CB );
	void DrawLimitations( FSceneNode* Frame, const FCoords& C );
}

defaultproperties
{
	ConeLimit=(Limit=MOTION_Free,Limit1=45,Limit2=45)
	TwistLimit=(Limit=MOTION_Free,Limit1=-45,Limit2=45)
	LinearDamping=0
	LinearStiffness=0
	AngularDamping=0
	AngularStiffness=0
	LinearStiffnessScale3D=(X=1.0,Y=1.0,Z=1.0)
	LinearDampingScale3D=(X=1.0,Y=1.0,Z=1.0)
}