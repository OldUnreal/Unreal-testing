// Convex Mesh collision.
Class PXC_MeshCollision extends PXC_CollisionShape
	native;

var(Collision) vector Size;
var(Collision) Mesh Mesh;
var(Collision) bool bUseConvex; // You should use convex shape in order to allow it to collide with world.

cpptext
{
	UPXC_MeshCollision() {}
	void DrawPreview(FSceneNode* Frame, class AActor* Owner);
	void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	UBOOL IsValidShape() const;
}

defaultproperties
{
	bUseConvex=true
	Size=(X=1,Y=1,Z=1)
}