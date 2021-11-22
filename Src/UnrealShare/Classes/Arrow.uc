//=============================================================================
// Arrow.
//=============================================================================
class Arrow extends Projectile;

#exec MESH IMPORT MESH=ArrowM ANIVFILE=Models\arrow_a.3d DATAFILE=Models\arrow_d.3d X=0 Y=0 Z=0 LODSTYLE=1 MLOD=1
// 24 Vertices, 31 Triangles
#exec MESH LODPARAMS MESH=ArrowM STRENGTH=1.0 MINVERTS=3 MORPH=0.3 ZDISP=1200.0

#exec MESH ORIGIN MESH=ArrowM X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=ArrowM SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=ArrowM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JArrow1 FILE=Models\arrow.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=ArrowM X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=ArrowM NUM=1 TEXTURE=JArrow1 TLOD=10

#exec MESH IMPORT MESH=burst ANIVFILE=Models\burst_a.3d DATAFILE=Models\burst_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=burst X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=burst SEQ=All       STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=burst SEQ=Explo     STARTFRAME=0   NUMFRAMES=6
#exec TEXTURE IMPORT NAME=Jburst1 FILE=Models\burst.pcx GROUP=Skin
#exec MESHMAP SCALE MESHMAP=burst X=0.2 Y=0.2 Z=0.4 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=burst NUM=0 TEXTURE=Jburst1

#exec AUDIO IMPORT FILE="Sounds\General\ArrowSpawn.wav" NAME="ArrowSpawn" GROUP="General"
#exec AUDIO IMPORT FILE="..\UnrealI\Sounds\Razor\bladehit.wav" NAME="BladeHit" GROUP="RazorJack"

function PostBeginPlay()
{
	local rotator RandRot;

	Super.PostBeginPlay();

	Velocity = Vector(Rotation) * Speed;      // velocity
	RandRot.Pitch = FRand() * 200 - 100;
	RandRot.Yaw = FRand() * 200 - 100;
	RandRot.Roll = FRand() * 200 - 100;
	Velocity = Velocity >> RandRot;
	PlaySound(SpawnSound, SLOT_Misc, 2.0);
}

simulated function ProcessTouch( Actor Other, Vector HitLocation )
{
	if( Arrow(Other)==None )
	{
		if( Other.Role==ROLE_Authority )
			Other.TakeDamage(damage, instigator,HitLocation,(MomentumTransfer * Normal(Velocity)), 'shot');
		Destroy();
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local Texture T;

	Super.HitWall(HitNormal, Wall);
	MakeNoise(0.3);
	RemoteRole = ROLE_None; // Tear off.
	if ( Level.NetMode==NM_DedicatedServer )
	{
		Destroy();
		return;
	}
	PlaySound(ImpactSound, SLOT_Misc, 0.5);
	T = GetHitTexture();
	if ( (Level.TimeSeconds-LastRenderedTime)<2.f )
		Spawn(class'WallCrack',,,Location, rotator(HitNormal));
	if( T==None || (T.SurfaceType!=EST_Wood && T.SurfaceType!=EST_Plant && T.SurfaceType!=EST_Flesh && T.SurfaceType!=EST_Carpet) )
	{
		mesh = mesh'Burst';
		Skin = Texture'JArrow1';
		PlayAnim('Explo',0.9);
	}
	else LifeSpan = 2.f;
	SetPhysics(PHYS_None);
	SetCollision(false);
}
simulated function Explode(vector HitLocation, vector HitNormal)
{
}
simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	speed=700.000000
	Damage=20.000000
	MomentumTransfer=2000
	SpawnSound=Sound'UnrealShare.General.ArrowSpawn'
	ImpactSound=Sound'UnrealShare.Razorjack.BladeHit'
	RemoteRole=ROLE_SimulatedProxy
	Mesh=LodMesh'UnrealShare.ArrowM'
	bUnlit=True
}
