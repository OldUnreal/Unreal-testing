//=============================================================================
// PX_RigidBodyData: Basic rigidbody physics
//=============================================================================
Class PX_RigidBodyData extends PX_PhysicsDataBase
	native;

var(Physics) export noduplicate editinline PXC_CollisionShape CollisionShape; // Single or multiple collision shapes of this object.
var(Physics) const export editinline array<PX_Repulsor> Repulsors; // List of physics repulsors to this object.
var(Physics) vector COMOffset; // Center of mass offset.
var(Physics) vector AngularVelocity; // Angular velocity on init (note, this isn't updated on real-time, use GetAngularVelocity for that).
var(Physics) vector InertiaTensor; // Moment of inertia: Controls how hard it is for each axis of the object to rotate (higher value means harder).

var(Physics) float MaxAngularVelocity, MaxLinearVelocity; // Max linear/angular velocity of this actor.
var(Physics) float AngularDamping, LinearDamping; // Linear/Angular scale damping over time.
var(Physics) float WaterMaxAngularVelocitySc, WaterMaxLinearVelocitySc; // When in water, scale linear/angular velocity by this much.
var(Physics) float WaterAngularDamping, WaterLinearDamping; // When in water, linear/angular damping by this much.
var(Physics) float MinImpactThreshold; // Minimum impact threshold before calling PhysicsImpact event callback (0 = never called).

var(Physics) float	StayUprightRollResistAngle, // Max angle of freedom (range 0-Pi).
					StayUprightPitchResistAngle, // ^
					StayUprightStiffness,
					StayUprightDamping;

var(Physics) bool bStartSleeping; // This actor should start in sleeping state.
var(Physics) bool bCheckWallPenetration; // Should do a safety trace from actor location between updates to avoid penetrating world (important for small objects moving at high speed).
var(Physics) bool bStayUpright; // Force this object to stay upright.

var transient const bool bWallContact; // Physics object is currently touching something.
var transient const vector HitLocation; // Wall hit location.
var transient const vector HitNormal; // Wall hit normal.

cpptext
{
	UPX_RigidBodyData() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
	void ExitPhysics();
	void Serialize( FArchive& Ar );
	void TraceRepulsors();
}

defaultproperties
{
	MaxAngularVelocity=100
	MaxLinearVelocity=2500
	AngularDamping=0.05
	LinearDamping=0.01
	WaterMaxAngularVelocitySc=0.5
	WaterMaxLinearVelocitySc=0.5
	WaterAngularDamping=0.25
	WaterLinearDamping=0.05
	MinImpactThreshold=10
	InertiaTensor=(X=1,Y=1,Z=1)
	
	StayUprightRollResistAngle=0
	StayUprightPitchResistAngle=0
	StayUprightStiffness=650
	StayUprightDamping=200
}