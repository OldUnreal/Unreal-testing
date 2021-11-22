//=============================================================================
// Physics Prop Book
//=============================================================================
Class Prop_Book extends PhysicsProp;

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=BookRigidBody
		Begin Object Class=PXC_BoxCollision Name=BookShapeBox
			Extent=(X=18.0,Y=22.0,Z=7.0)
			Offset=(Y=0.5,Z=0.5)
		End Object
		CollisionShape=BookShapeBox
		bCheckWallPenetration=true
		bStartSleeping=true
	End Object
	PhysicsData=BookRigidBody
	
	PushSound=Sound'Chunkhit2'
	ImpactSound=Sound'Chunkhit2'
	Mesh=LodMesh'BookM'
	CollisionRadius=12
	CollisionHeight=4
	Mass=5
	Buoyancy=4
	
	MinCrushVelocity=300
	CrushDamageScaling=0.25
}