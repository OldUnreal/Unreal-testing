//=============================================================================
// PXJ_BaseJoint: Joint to attach PhysX objects together.
//=============================================================================
Class PXJ_BaseJoint extends PhysicsObject
	native
	abstract
	safereplace;

var const editconst PX_PhysicsDataBase Owner;

var(Joint) name JoinedBoneA,JoinedBoneB; // Skeletal bones that are joined.
var(Joint) const Actor JoinedActor; // Other-side actor to join this with (None = World), ignore this if were a skeletal joint.
var(Joint) float MaxAllowedForce, MaxAllowedTorque; // Maximum force this joint can withstand, if it overflows it will break (disable itself) (-1 = no limit).
var(Joint) vector JointOffset; // Joint location offset relative to owner actor.
var(Joint) rotator JointAngle; // Joint rotation offset relative to owner actor.
var(Joint) vector BaseOffset;		// Offset from base actor.
var(Joint) rotator BaseRotOffset;	// Rotation offset from base actor.

var(Joint) bool bAbsoluteOffset; // Joint offset is in world space and not relative to owned actor.
var(Joint) const bool bDisabled; // Should start disabled, as a mod author you may want to start it as disabled in order to init other side actor first.

var bool bCalcCoords; // Calculate local coords on joint init.

var pointer<PX_JointObject*> PhysicsData;
var transient const editconst bool bPhysicsEnabled; // Joint is currently initialized and simulated (will also be false if disabled).

var coords LocalCoordsA,LocalCoordsB,WorldCoords; // Local coords is relative coords between joint and joined actors, world coords is if joint is attached to world...

native final function SetDisabled( bool bDisable ); // You can call SetDisabled(false) multiple times to re-init joint with new properties.
native final function SetJoinedActor( optional Actor Other ); // Change actor were joined to (empty for world).
native final function CalcCoords(); // Update LocalCoords/WorldCoords with current actors pose.

// Set new JointOffset/JointAngle, then CalcCoords, and UpdateCoords.
// @bWorldCoords - see bAbsoluteOffset
native final function SetJointOffset( optional vector NewOffset, optional rotator NewAngle, optional bool bWorldCoords /*=bAbsoluteOffset*/ );

// Coords updated, sync with PhysicsEngine.
native final function UpdateCoords();

cpptext
{
	UPXJ_BaseJoint() {}
	
	void PostLoad();
	void onPropertyChange(UProperty* Property, UProperty* OuterProperty);
	void Destroy();
	
	void Initialize();
	void ShutDown();
	void SetDisabled( UBOOL bDisable );
	
	virtual void UpdateCoords( UBOOL bOnlyWorld );
	void OtherSidePhysics( UBOOL bExit );
	void OtherSideDestroyed();
	void SetJoinedActor( AActor* Other );
	void DrawPreview( FSceneNode* Frame );
	
	virtual UBOOL InitJoint( PX_JointObject& Joint, const FCoords& CA, const FCoords& CB ) { return FALSE; }
	virtual void DrawLimitations( FSceneNode* Frame, const FCoords& C );
}

defaultproperties
{
	MaxAllowedForce=-1
	MaxAllowedTorque=-1
	bCalcCoords=true
	LocalCoordsA=(XAxis=(X=1),YAxis=(Y=1),ZAxis=(Z=1))
	LocalCoordsB=(XAxis=(X=1),YAxis=(Y=1),ZAxis=(Z=1))
	WorldCoords=(XAxis=(X=1),YAxis=(Y=1),ZAxis=(Z=1))
}