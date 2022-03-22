// Box collision.
Class PXC_BoxCollision extends PXC_CollisionShape
	native;

var(Collision) vector Extent;

cpptext
{
	UPXC_BoxCollision() {}
	void DrawPreview(FSceneNode* Frame, class AActor* Owner);
	void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	UBOOL IsValidShape() const
	{
		return TRUE;
	}
}

defaultproperties
{
	Extent=(X=32,Y=32,Z=32)
}