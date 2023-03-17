//=============================================================================
// Physics Prop Table
//=============================================================================
class Prop_Table extends PhysicsProp;

function Died( vector momentum, name damageType )
{
	Frag(Class'WoodFragments',Momentum,1,17);
}

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=TableRigidBody
		Begin Object Class=PXC_MeshCollision Name=TableShapeMeshCV
			Friction=0.025
			Mesh=LodMesh'Table1'
		End Object
		CollisionShape=TableShapeMeshCV
		bStartSleeping=true
		COMOffset=(Z=-10)
		InertiaTensor=(X=3,Y=3,Z=2)
	End Object
	PhysicsData=TableRigidBody
	
	Health=25
	bPushable=True
	ImpactSound=Sound'Endpush'
	Mesh=LodMesh'Table1'
	CollisionRadius=45
	CollisionHeight=19
	Mass=100
	Buoyancy=45
	bCanCarryProp=false
}