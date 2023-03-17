// Convex Brush collision (uses Actor.Brush as collision shape).
Class PXC_BrushCollision extends PXC_CollisionShape
	native;

cpptext
{
	UPXC_BrushCollision() {}
	void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	UBOOL IsValidShape() const;
}

defaultproperties
{
}