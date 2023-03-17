// Physics body for a skeletal mesh.
Class PX_SkeletalBody extends PhysicsObject
	native
	safereplace
	runtimestatic;

struct export SkeletalBodyPart
{
	var() editinline PXJ_BaseJoint Joint; // Joint attached to parent bone.
	var() editinline PXC_CollisionShape Shape; // Physical body of this bone.
	var() name BoneName; // Name of the bone this part is attached to.
	var() float MassDistribution; // How much of the body weight goes to this bone.
	var() bool bPartialSimulation; // This bone-tree supports partial physics simulation (when actor is not fully ragdolled).
	
	var() button<"Delete Branch"> zDeleteBranch; // Delete this branch of skeletal bones.
};
var() array<SkeletalBodyPart> BodyParts;

struct export SkeletalBonePair
{
	var() name A,B;
};
var array<SkeletalBonePair> DisableCollision; // NOT SUPPORTED: Disable collision between these bone pairs.

cpptext
{
	static INT iDrawBody;
	static USkeletalMesh* RefSkel;
	UPX_SkeletalBody() {}
	void DrawPreview( FSceneNode* Frame, USkeletalMesh* Mesh, AActor* Actor );
	void onPropertyChange(UProperty* Property, UProperty* OuterProperty);
	void onPropertyFocus(UProperty* Property, UProperty* OuterProperty, INT ArrayIndex);
	void onEditSubObject(UObject* Obj);
}