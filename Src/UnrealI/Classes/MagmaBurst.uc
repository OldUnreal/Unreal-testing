//=============================================================================
// MagmaBurst.
//=============================================================================
class MagmaBurst extends Rockslide;

// Spawns off a number of Magma elements, which all die out
// within a random amount of time.  This code modified from
// Sparks.  MZM
// Reasonable defaults
var() int      MinSpawnedAtOnce;	// 1
var() int      MaxSpawnedAtOnce;	// 3
var() float    MinSpawnSpeed;		// 200
var() float    MaxSpawnSpeed;		// 300
var() rotator  SpawnCenterDir;
var() int      AngularDeviation;	// approx. 0x2000 -> 8192
var() class<Effects> EffectClass;

function MoreMagma ()
{
	local vector    SpawnLoc;
	local projectile TempMagma;
	local rotator  SpawnDir;


	SpawnLoc = Location - (CubeDimensions*0.5);
	SpawnLoc.X += FRand()*CubeDimensions.X;
	SpawnLoc.Y += FRand()*CubeDimensions.Y;
	SpawnLoc.Z += FRand()*CubeDimensions.Z;

	if ( ProjectileClass != None )
	{
		TempMagma = Spawn (ProjectileClass, , '', SpawnLoc);
		TempMagma.instigator=none;
	}
	if ( EffectClass != None )
		Spawn (EffectClass, , '', SpawnLoc);

	SpawnDir = SpawnCenterDir;
	SpawnDir.Pitch += -AngularDeviation + Rand(AngularDeviation*2);
	SpawnDir.Yaw   += -AngularDeviation + Rand(AngularDeviation*2);
	if ( TempMagma != None )
	{
		TempMagma.SetRotation(SpawnDir);
		TempMagma.RotationRate = RotRand();
		TempMagma.velocity  = (MinSpawnSpeed +
							   FRand()*(MaxSpawnSpeed-MinSpawnSpeed))*Vector(SpawnDir);
		TempMagma.DrawScale = (MaxScaleFactor-MinScaleFactor)*FRand()+MinScaleFactor;
	}
}


state() Active
{
	function MakeRock()
	{
		local int i, NumSpawnedNow;

		NumSpawnedNow = Rand(MaxSpawnedAtOnce-MinSpawnedAtOnce+1)+MinSpawnedAtOnce;
		for (i=0; i<NumSpawnedNow; i++)
			MoreMagma();
	}
}


auto state() Triggered
{
	function Trigger (actor Other, pawn EventInstigator)
	{
		TotalPassedTime=0;
		GotoState ('Active');
	}
}

defaultproperties
{
	MinSpawnedAtOnce=1
	MaxSpawnedAtOnce=4
	MinSpawnSpeed=200.000000
	MaxSpawnSpeed=1000.000000
	SpawnCenterDir=(Pitch=20000)
	AngularDeviation=36000
	EffectClass=Class'UnrealShare.FlameBall'
	CubeDimensions=(X=60.000000,Y=60.000000,Z=60.000000)
	MinBetweenTime=0.700000
	MaxBetweenTime=1.700000
	MinScaleFactor=0.600000
	MaxScaleFactor=1.300000
	ProjectileClass=Class'UnrealI.BigRock'
	Tag=MagmaTest1
}
