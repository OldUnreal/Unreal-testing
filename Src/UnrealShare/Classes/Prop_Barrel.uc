//=============================================================================
// Physics Prop Barrel
//=============================================================================
class Prop_Barrel extends PhysicsProp;

function Died( vector momentum, name damageType )
{
	Frag(class'WoodFragments',Momentum,1.75,12);
}

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=BarrelRigidBody
		Begin Object Class=PXC_MeshCollision Name=BarrelShapeMeshCV
			Friction=0.025
			Mesh=LodMesh'BarrelM'
		End Object
		CollisionShape=BarrelShapeMeshCV
		bStartSleeping=true
	End Object
	PhysicsData=BarrelRigidBody
	
	Health=10
	bPushable=True
	PushSound=Sound'ObjectPush'
	EndPushSound=Sound'Endpush'
	ImpactSound=Sound'Endpush'
	Skin=Texture'JBarrel1'
	Mesh=LodMesh'BarrelM'
	CollisionRadius=24
	CollisionHeight=29
	Mass=50
	Buoyancy=60
}