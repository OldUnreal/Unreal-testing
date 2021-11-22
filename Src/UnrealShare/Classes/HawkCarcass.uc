// Hawk Carcass
Class HawkCarcass extends MantaCarcass;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	DesiredRotation.Yaw = Rotation.Yaw;
}
function Landed(vector HitNormal)
{
	local rotator R;

	R.Yaw = Rotation.Yaw;
	SetRotation(R);
	PlayAnim('DeathLand', 0.2,0.4);
	SetPhysics(PHYS_None);
	PrePivot.Z = 0;
	LieStill();
}
function ReduceCylinder()
{
	local float OldHeight;

	RemoteRole=ROLE_DumbProxy;
	bReducedHeight = true;
	bBlockActors = false;
	bBlockPlayers = false;
	OldHeight = CollisionHeight;
	SetCollisionSize(Default.CollisionRadius*DrawScale,Default.CollisionHeight*DrawScale);
	Mass = Mass * 0.8;
	Buoyancy = Buoyancy * 0.8;
	Move(vect(0,0,-1)*(OldHeight-CollisionHeight));
}
function AnimEnd();

defaultproperties
{
	Mesh=Mesh'HawkM'
	AnimSequence="DeathLand"
	CollisionHeight=10
	bFixedRotationDir=true
	bRotateToDesired=true
}