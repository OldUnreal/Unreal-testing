// Multiple collision shapes.
Class PXC_MultiCollision extends PXC_CollisionShape
	native;

var(Collision) export editinline array<PXC_CollisionShape> Shapes;

cpptext
{
	UPXC_MultiCollision() {}
	void DrawPreview(FSceneNode* Frame, class AActor* Owner);
	void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	UBOOL IsValidShape() const;
}
