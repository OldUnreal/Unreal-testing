//=============================================================================
// Plasma.
//=============================================================================
class Plasma extends Projectile;


#exec MESH IMPORT MESH=plasmaM ANIVFILE=Models\cros_t_a.3d DATAFILE=Models\cros_t_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=plasmaM X=0 Y=-420 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=plasmaM SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=plasmaM SEQ=Still  STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=plasmaM X=0.09 Y=0.15 Z=0.08
#exec  OBJ LOAD FILE=Textures\fireeffect1.utx PACKAGE=UnrealShare.Effect1
#exec MESHMAP SETTEXTURE MESHMAP=plasmaM NUM=0 TEXTURE=UnrealShare.Effect1.FireEffect1u
#exec MESHMAP SETTEXTURE MESHMAP=plasmaM NUM=1 TEXTURE=UnrealShare.Effect1.FireEffect1t

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * speed;
	RandSpin(50000);
	PlaySound(SpawnSound);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( Role == ROLE_Authority )
		HurtRadius(Damage,150.0, 'exploded', MomentumTransfer, HitLocation );
	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If ( (Other!=Instigator) && Other.IsA('DispersionAmmo') )
	Explode(HitLocation, HitLocation);
}

defaultproperties
{
	speed=1300.000000
	Mesh=Mesh'UnrealShare.plasmaM'
	bUnlit=True
	bMeshCurvy=False
}
