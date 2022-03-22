// RigidBody physics collision shapes.
Class PXC_CollisionShape extends Object
	native
	abstract;

var(Collision) float Friction; // Friction of this shape (in range of 0-1).
var(Collision) float Restitution; // Bouncyness of this shape (in range of 0-1).
var(Collision) vector Offset;
var(Collision) rotator RotOffset;

cpptext
{
	UPXC_CollisionShape() {}
	virtual void DrawPreview(FSceneNode* Frame, class AActor* Owner) {}
	virtual void ApplyShape( struct PX_PhysicsObject* Object, const FVector& Scale );
	virtual UBOOL IsValidShape() const
	{
		return FALSE;
	}
}

defaultproperties
{
	Friction=0.75
	Restitution=0.4
}