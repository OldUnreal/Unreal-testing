//=============================================================================
// Boulder1.
//=============================================================================
class Boulder1 extends BigRock;

function SpawnChunks(int num)
{
	local int    NumChunks,i;
	local BigRock   TempRock;
	local float scale;

	NumChunks = 1+Rand(num);
	scale = 12 * sqrt(0.52/NumChunks);
	speed = VSize(Velocity);
	for (i=0; i<NumChunks; i++)
	{
		TempRock = Spawn(class'BigRock');
		if (TempRock != None )
			TempRock.InitFrag(self, scale);
	}
	InitFrag(self, 0.5);
}

auto state Flying
{
	function HitWall (vector HitNormal, actor Wall)
	{
		Velocity = 0.75 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
		SetRotation(rotator(HitNormal));
		DrawScale *= 0.7;
		SpawnChunks(8);
		Destroy();
	}
}

defaultproperties
{
	speed=+01300.000000
	MaxSpeed=+01300.000000
	Mesh=UnrealShare.BoulderM
	DrawScale=+00001.700000
	bMeshCurvy=False
	CollisionRadius=+00060.000000
	Damage=6850
}
