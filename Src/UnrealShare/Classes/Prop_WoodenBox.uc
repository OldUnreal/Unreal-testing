//=============================================================================
// Physics Prop WoodenBox
//=============================================================================
Class Prop_WoodenBox extends PhysicsProp;

var() int FragChunks;
var() float Fragsize;

function Died( vector momentum, name damageType )
{
	Frag(Class'WoodFragments',momentum,FragSize,FragChunks);
}

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=BoxRigidBody
		Begin Object Class=PXC_BoxCollision Name=BoxShapeBox
			Friction=0.025
			Extent=(X=52.0,Y=52.0,Z=52.0)
		End Object
		CollisionShape=BoxShapeBox
		bStartSleeping=true
	End Object
	PhysicsData=BoxRigidBody
	
	Health=20
	FragChunks=12
	Fragsize=1.75
	PushSound=Sound'ObjectPush'
	EndPushSound=Sound'Endpush'
	ImpactSound=Sound'Endpush'
	Mesh=LodMesh'WoodenBoxM'
	CollisionRadius=29
	CollisionHeight=26
	Mass=50
	Buoyancy=65
}