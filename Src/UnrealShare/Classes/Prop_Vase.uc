//=============================================================================
// Physics Prop Vase
//=============================================================================
class Prop_Vase extends PhysicsProp;

function Died( vector momentum, name damageType )
{
	skinnedFrag(class'Fragment1',texture'JVase1', Momentum,0.7,7);
}

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=VaseRigidBody
		Begin Object Class=PXC_MeshCollision Name=VaseShapeMeshCV
			Friction=0.025
			Mesh=LodMesh'vaseM'
		End Object
		CollisionShape=VaseShapeMeshCV
		bStartSleeping=true
	End Object
	PhysicsData=VaseRigidBody
	
	Health=2
	bPushable=True
	PushSound=Sound'ObjectPush'
	EndPushSound=Sound'Endpush'
	ImpactSound=Sound'Endpush'
	Skin=Texture'JBarrel1'
	Mesh=LodMesh'vaseM'
	CollisionRadius=24
	CollisionHeight=28
	Mass=100
	Buoyancy=5
}