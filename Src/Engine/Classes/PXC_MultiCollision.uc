// Multiple collision shapes.
Class PXC_MultiCollision extends PXC_CollisionShape
	native;

var(Collision) export editinline array<PXC_CollisionShape> Shapes;

cpptext
{
	UPXC_MultiCollision() {}
	void DrawPreview(FSceneNode* Frame, const FCoords& Coords);
	PX_ShapesBase* GetShape();
}
