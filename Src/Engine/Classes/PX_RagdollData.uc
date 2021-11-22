//=============================================================================
// PX_RagdollData: Skeletal mesh ragdoll physics.
//=============================================================================
Class PX_RagdollData extends PX_RigidBodyData
	native;

var(Physics) PX_SkeletalBody SkeletalPhysBody; // Physics body for owner skeletal mesh (will override default skeletaldata from the current skeletalmesh).

var const editconst transient SkeletalMesh Mesh;

cpptext
{
	UPX_RagdollData() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
	void ExitPhysics();
}

defaultproperties
{
}