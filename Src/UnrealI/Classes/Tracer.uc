//=============================================================================
// Tracer.
//=============================================================================
class Tracer extends Projectile;

#exec MESH IMPORT MESH=TracerM ANIVFILE=Models\tracer_a.3d DATAFILE=Models\tracer_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TracerM X=0 Y=0 Z=-0 YAW=64
#exec MESH SEQUENCE MESH=TracerM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=TracerM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmisc2 FILE=..\UnrealShare\Models\misc2.pcx
#exec MESHMAP SCALE MESHMAP=TracerM X=0.07 Y=0.2 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=TracerM NUM=0 TEXTURE=Jmisc2

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * speed;
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != instigator)
		Destroy();
}

defaultproperties
{
	speed=+10000.000000
	MaxSpeed=+10000.000000
	DrawType=DT_Mesh
	Mesh=TracerM
	AmbientGlow=130
	bUnlit=True
	bMeshCurvy=False
	CollisionRadius=+00000.000000
	CollisionHeight=+00000.000000
	Physics=PHYS_Projectile
	LifeSpan=+00003.000000
	RemoteRole=ROLE_SimulatedProxy
}
