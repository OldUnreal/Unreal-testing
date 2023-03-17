//=============================================================================
// RockSlide.
//=============================================================================
class RockSlide extends KeyPoint;

// Spawns a set of rocks within a cubical volume.  The rocks are
// produced at random intervals, and the entirety of the effect
// lasts for a set amount of time.  MZM

var() vector   CubeDimensions;
var() bool     TimeLimit;          // limit on it's spawning
var() float    TimeLength;
var() float    MinBetweenTime;
var() float    MaxBetweenTime;
var() float    MinScaleFactor;
var() float    MaxScaleFactor;
var() rotator  InitialDirection;
var() float    minInitialSpeed;
var() float    maxInitialSpeed;

var   float  NextRockTime;
var   float  TotalPassedTime;

var() class<Projectile> ProjectileClass;

function BeginPlay()
{
	// Initialize and check the values of variables.
	MaxScaleFactor = FMin(1.0, MaxScaleFactor);
	MinScaleFactor = FMax(0.0, MinScaleFactor);
	if (MinBetweenTime >= MaxBetweenTime)
		MaxBetweenTime=MinBetweenTime + 0.1;
	if (MinScaleFactor >= MaxScaleFactor)
		MaxScaleFactor=MinScaleFactor;

	Super.BeginPlay();
}

function MakeRock ()
{
	// Spawns another rock somewhere within the cube,
	// of a randomized size and shape.  The rock has
	// falling physics but no initial velocity, so it
	// needs to fall a distance before it becomes dangerous.

	local vector  SpawnLoc;
	local projectile    TempRock;

	SpawnLoc = Location - (CubeDimensions*0.5);
	SpawnLoc.X += FRand()*CubeDimensions.X;
	SpawnLoc.Y += FRand()*CubeDimensions.Y;
	SpawnLoc.Z += FRand()*CubeDimensions.Z;

	TempRock = Spawn(ProjectileClass,,,SpawnLoc);
	if( TempRock )
	{
		TempRock.Instigator = None;
		TempRock.SetRotation(InitialDirection);
		TempRock.Velocity = RandRange(MinInitialSpeed,MaxInitialSpeed)*Vector(Rotation);
		TempRock.DrawScale = RandRange(MinScaleFactor,MaxScaleFactor);
		TempRock.SetCollisionSize(TempRock.CollisionRadius*TempRock.DrawScale/TempRock.Default.DrawScale,
								  TempRock.CollisionHeight*TempRock.DrawScale/TempRock.Default.DrawScale);
	}
}

auto state() Triggered
{
	function Trigger (actor Other, pawn EventInstigator)
	{
		TotalPassedTime=0;
		MakeRock();
		GotoState ('Active');
	}
}

state Active
{
	function Trigger (actor Other, pawn EventInstigator)
	{
		if ( !TimeLimit )
			GotoState ('Triggered');
		else if (TotalPassedTime < TimeLength)
			TotalPassedTime = TimeLength;
		else
			gotostate ('Active','restart');
	}

restart:
	TotalPassedTime=0;

Begin:
	// A loop which lasts for the total time allowed for the
	// effect, producing rocks at randomized intervals.
RocksFall:
	MakeRock();
	NextRockTime = RandRange(MinBetweenTime, MaxBetweenTime);
	TotalPassedTime += NextRockTime;
	sleep (NextRockTime);
	if ( !TimeLimit || (TotalPassedTime < TimeLength) )
		goto 'RocksFall';
}

defaultproperties
{
	CubeDimensions=(X=50.000000,Y=50.000000,Z=50.000000)
	TimeLength=10.000000
	MinBetweenTime=1.000000
	MaxBetweenTime=3.000000
	MinScaleFactor=0.500000
	MaxScaleFactor=1.000000
	minInitialSpeed=500.000000
	maxInitialSpeed=800.000000
	ProjectileClass=Class'UnrealI.BigRock'
	bStatic=False
}
