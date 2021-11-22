// Sphere collision.
Class PXC_SphereCollision extends PXC_CollisionShape
	native;

var(Collision) float Radius;

cpptext
{
	UPXC_SphereCollision() {}
	void DrawPreview(FSceneNode* Frame, const FCoords& Coords);
	PX_ShapesBase* GetShape();
}

defaultproperties
{
	Radius=32
}