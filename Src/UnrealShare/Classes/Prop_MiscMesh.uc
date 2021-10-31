//=============================================================================
// Physics Prop Misc model.
//=============================================================================
class Prop_MiscMesh extends PhysicsProp;

var() class<Fragment> DeathFragments; // Optional fragments effect on destruction.
var() int FragChunks;
var() float Fragsize;

function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	local PXC_MeshCollision M;
	
	Mesh = Mesh(class'LevelInfo'.Static.GetSelectedObject(class'Mesh'));
	if( Mesh==None )
	{
		Error("No mesh selected!");
		return;
	}
	Skin = None;
	M = new (Outer) class'PXC_MeshCollision';
	M.Mesh = Mesh;
	M.Friction = 0.025f;
	PX_RigidBodyData(PhysicsData).CollisionShape = M;
}
function Died( vector momentum, name damageType )
{
	if( DeathFragments!=None )
	{
		if( EffectWhenDestroyed!=None )
			Spawn(EffectWhenDestroyed);
		Frag(DeathFragments,Momentum,Fragsize,FragChunks);
	}
	else Super.Died(momentum,damageType);
}

defaultproperties
{
	Begin Object Class=PX_RigidBodyData Name=MiscMeshRigidBody
		Begin Object Class=PXC_MeshCollision Name=MiscStockShapeMeshCV
			Friction=0.025
			Mesh=LodMesh'BarrelM'
		End Object
		CollisionShape=MiscStockShapeMeshCV
		bStartSleeping=true
	End Object
	PhysicsData=MiscMeshRigidBody
	
	Health=10
	bPushable=True
	PushSound=Sound'ObjectPush'
	EndPushSound=Sound'Endpush'
	ImpactSound=Sound'Endpush'
	Skin=Texture'JBarrel1'
	Mesh=LodMesh'BarrelM'
	FragChunks=12
	Fragsize=1.5
	CollisionRadius=25
	CollisionHeight=25
	Mass=50
	Buoyancy=60
	DeathFragments=class'WoodFragments'
}