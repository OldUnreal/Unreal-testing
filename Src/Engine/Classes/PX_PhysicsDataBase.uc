//=============================================================================
// PX_PhysicsDataBase: Additional RigidBody physics data for an actor.
//=============================================================================
Class PX_PhysicsDataBase extends PhysicsObject
	native
	abstract
	safereplace;

var(Physics) editinline array<PXJ_BaseJoint> Joints; // Joints associated to this physics object.
// NOTE: Joints are deleted when owner actor is destroyed.

var(Physics) const vector CustomGravity; // Gravity if bCustomGravity, overrides zone gravity.
var(Physics) const bool bCustomGravity; // Override zone gravity with CustomGravity.
var(Physics) Actor.EPhysics ServerPhysics; // Server physics simulation if bServerSimulate=false.
var(Physics) bool bDisableForces; // Don't allow ZoneVelocity to effect this physics object.

var(Physics) const bool bClientSimulate; // Should run simulation client-side too when actor is networked? (RigidBodies work best with this disabled)
var(Physics) const bool bServerSimulate; // Should simulate physics server-side?
var transient const editconst bool bPhysicsEnabled; // This actor has currently RigidBody physics enabled.
var transient const editconst Actor Actor; // Actor that owns this phyiscs data.

// Sleeping physics object takes up lesser resources but doesn't simulate physics.
native final function WakeUp( optional bool bPutToSleep );
native final function bool IsSleeping();

// Modify angular velocity.
native final function vector GetAngularVelocity();
native final function SetAngularVelocity( vector NewVel );

// Process a local impulse at a position and direction (or origin).
// @bCheckMass - Impulse force is scaled by mass, otherwise it is an absolute force.
native final function Impulse( vector Force, optional vector Position /*=COM offset*/, optional bool bCheckMass /*=true*/ );

// Modify gravity.
// Leave parm empty to set to regular zone gravity scaling.
native final function SetGravity( optional vector NewGravity );

// Changes already initialized physics object mass (will also set Actor.Mass to match with the new value).
native final function SetMass( float NewMass );

// Create and insert a new joint to joints array.
native final function PXJ_BaseJoint CreateJoint( class<PXJ_BaseJoint> JointClass, optional PXJ_BaseJoint Template );

// Attempt to delete joint if found. Will also delete the object so don't keep it referenced after.
native final function bool DeleteJoint( PXJ_BaseJoint Joint );

cpptext
{
	UPX_PhysicsDataBase() {}
	
	virtual void DrawPreview(FSceneNode* Frame);
	virtual void InitPhysics(PX_SceneBase* Scene) {}
	virtual void ExitPhysics() {}
	virtual void ShutDown();
	virtual void InitJoints();
}

defaultproperties
{
	bServerSimulate=true
}