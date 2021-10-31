//=============================================================================
// Physics Prop Chair
//=============================================================================
class Prop_Chair extends PhysicsProp;

function Died( vector momentum, name damageType )
{
	Frag(Class'WoodFragments',Momentum,1.2f,9);
}

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=ChairRigidBody
		Begin Object Class=PXC_MeshCollision Name=ChairShapeMeshCV
			Friction=0.025
			Mesh=LodMesh'Chair1'
		End Object
		CollisionShape=ChairShapeMeshCV
		bStartSleeping=true
		COMOffset=(Z=-8)
	End Object
	PhysicsData=ChairRigidBody
	
	Health=15
	bPushable=True
	PushSound=Sound'ObjectPush'
	EndPushSound=Sound'Endpush'
	ImpactSound=Sound'Endpush'
	Mesh=LodMesh'Chair1'
	CollisionRadius=17
	CollisionHeight=15
	Mass=65
	Buoyancy=5
}