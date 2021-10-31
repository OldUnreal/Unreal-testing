// RigidBody physics collision shapes.
Class PXC_CollisionShape extends Object
	native
	abstract;

var(Collision) float Friction; // Friction of this shape (in range of 0-1).
var(Collision) float Restitution; // Bouncyness of this shape (in range of 0-1).
var(Collision) vector Offset;
var(Collision) rotator RotOffset;
var pointer<PX_ShapesBase*> Data;

cpptext
{
	UPXC_CollisionShape() {}
	void Destroy();
	virtual void DrawPreview(FSceneNode* Frame, const FCoords& Coords) {}
	virtual PX_ShapesBase* GetShape();
	void Cleanup();
	
protected:
	FCoords GetTransformCoords();
}

defaultproperties
{
	Friction=0.5
	Restitution=0.4
}