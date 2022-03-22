// Capsule collision.
Class PXC_CapsuleCollision extends PXC_CollisionShape
	native;

var(Collision) float Height,Radius;

cpptext
{
	UPXC_CapsuleCollision() {}
	void DrawPreview(FSceneNode* Frame, class AActor* Owner);
	void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	UBOOL IsValidShape() const
	{
		return TRUE;
	}
}

defaultproperties
{
	Height=8
	Radius=32
}