// Box collision.
Class PXC_BoxCollision extends PXC_CollisionShape
	native;

var(Collision) vector Extent;

cpptext
{
	UPXC_BoxCollision() {}
	void DrawPreview(FSceneNode* Frame, const FCoords& Coords);
	PX_ShapesBase* GetShape();
}

defaultproperties
{
	Extent=(X=32,Y=32,Z=32)
}