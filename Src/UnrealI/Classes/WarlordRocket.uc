//=============================================================================
// WarlordRocket.
//=============================================================================
class WarlordRocket extends Projectile;

#exec MESH IMPORT MESH=perock ANIVFILE=Models\perock_a.3d DATAFILE=Models\perock_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=perock X=0 Y=0 Z=0 YAW=0 ROLL=0 PITCH=-64
#exec MESH SEQUENCE MESH=perock SEQ=All       STARTFRAME=0   NUMFRAMES=16
#exec MESH SEQUENCE MESH=perock SEQ=Ignite    STARTFRAME=0   NUMFRAMES=3
#exec MESH SEQUENCE MESH=perock SEQ=Flying    STARTFRAME=3   NUMFRAMES=13
#exec TEXTURE IMPORT NAME=Jpeace1 FILE=Models\peaceg.pcx
#exec MESHMAP SCALE MESHMAP=perock  X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=perock NUM=1 TEXTURE=Jpeace1

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\General\8blfly2.wav" NAME="BRocket" GROUP="General"

var vector OriginalDirection;
var float Count,SmokeRate;

function PostBeginPlay()
{
	if (Level.bHighDetailMode)
		SmokeRate = 0.035;
	else SmokeRate = 0.15;
}

function Explode(vector HitLocation, vector HitNormal)
{
	HurtRadius(damage, 200.0, 'exploded', MomentumTransfer, HitLocation);
	Spawn(class'SpriteBallExplosion',,,HitLocation);
	Destroy();
}

function Tick(float DeltaTime)
{
	local Effects E;

	if ( Level.NetMode == NM_DedicatedServer )
		DeltaTime*=0.5f; // Hacky way to reduce bandwidth usage on servers.
	//	return;
	Count += DeltaTime;
	if ( Count>(SmokeRate+FRand()*SmokeRate) )
	{
		Count=0.0;
		if (Region.Zone.bWaterZone)
		{
			E = Spawn(class'Bubble1');
			if ( E!=none )
				E.DrawScale = FRand()*0.1+0.1;
		}
		else Spawn(class'SpriteSmokePuff');
	}
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( !Other.IsA('warlord') && (WarlordRocket(Other)==none) && (Other!=Instigator) )
			Explode(HitLocation, vect(0,0,0));
	}

	function BeginState()
	{
		PlaySound(SpawnSound);
		if ( ScriptedPawn(Instigator) != None )
		{
			Speed = default.speed + ScriptedPawn(Instigator).skill*50;
			if (Level.Game.difficulty > 3)
				Speed += 50*FClamp(Level.Game.difficulty-3, 1, 3);
		}
		Velocity = Vector(Rotation) * 500.0;
		Acceleration = Velocity * 0.4;
	}
Begin:
	Sleep(7.0);
	Explode(Location,vect(0,0,0));
}

simulated function Destroyed()
{
	local vector Dir,HL,HN,Ex;

	if ( Level.NetMode==NM_Client && Role==Role_DumbProxy )
	{
		Dir = vector(Rotation);
		Ex.X = CollisionRadius;
		Ex.Y = Ex.X;
		Ex.Z = CollisionHeight;
		if ( Trace(HL,HN,Location+Dir*30,Location-Dir*10,False,Ex)!=None )
			spawn(ExplosionDecal,,,Location, rotator(HN));
	}
	Super.Destroyed();
}

defaultproperties
{
	speed=500.000000
	MaxSpeed=1500.000000
	Damage=60.000000
	MomentumTransfer=50000
	ExplosionDecal=Class'BlastMark'
	bNetTemporary=False
	LifeSpan=7.500000
	Mesh=LodMesh'perock'
	DrawScale=2.500000
	AmbientGlow=1
	bUnlit=True
	SoundRadius=20
	SoundVolume=255
	AmbientSound=Sound'BRocket'
	bBounce=True
	bNetInterpolatePos=true
	bNetInitialVelocity=false
	bNetInitExactLocation=false
}