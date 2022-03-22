// Sphere collision.
Class PXC_SphereCollision extends PXC_CollisionShape
	native;

var(Collision) float Radius;

cpptext
{
	UPXC_SphereCollision() {}
	void DrawPreview(FSceneNode* Frame, class AActor* Owner);
	void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	UBOOL IsValidShape() const
	{
		return TRUE;
	}
}

defaultproperties
{
	Radius=32
}