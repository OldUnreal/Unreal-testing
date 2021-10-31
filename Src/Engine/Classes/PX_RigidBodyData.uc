//=============================================================================
// PX_RigidBodyData: Basic rigidbody physics
//=============================================================================
Class PX_RigidBodyData extends PX_PhysicsDataBase
	native;

var(Physics) export noduplicate editinline PXC_CollisionShape CollisionShape; // Single or multiple collision shapes of this object.
var(Physics) vector COMOffset; // Center of mass offset.
var(Physics) vector AngularVelocity; // Angular velocity on init (note, this isn't updated on real-time, use GetAngularVelocity for that).

var(Physics) float MaxAngularVelocity, MaxLinearVelocity; // Max linear/angular velocity of this actor.
var(Physics) float AngularDamping, LinearDamping; // Linear/Angular scale damping over time.
var(Physics) float WaterMaxAngularVelocitySc, WaterMaxLinearVelocitySc; // When in water, scale linear/angular velocity by this much.
var(Physics) float WaterAngularDamping, WaterLinearDamping; // When in water, linear/angular damping by this much.
var(Physics) float MinImpactThreshold; // Minimum impact threshold before calling PhysicsImpact event callback (0 = never called).

var(Physics) bool bStartSleeping; // This actor should start in sleeping state.
var(Physics) bool bCheckWallPenetration; // Should do a safety trace from actor location between updates to avoid penetrating world (important for small objects moving at high speed).

cpptext
{
	UPX_RigidBodyData() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
	void ExitPhysics();
	void Serialize( FArchive& Ar );
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
}