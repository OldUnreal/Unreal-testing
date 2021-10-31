// Capsule collision.
Class PXC_CapsuleCollision extends PXC_CollisionShape
	native;

var(Collision) float Height,Radius;

cpptext
{
	UPXC_CapsuleCollision() {}
	void DrawPreview(FSceneNode* Frame, const FCoords& Coords);
	PX_ShapesBase* GetShape();
}

defaultproperties
{
	Height=8
	Radius=32
}