//=============================================================================
// DecalSparks.
//=============================================================================
class DecalSparks extends Effects
	transient;

#exec MESH IMPORT MESH=SparksM ANIVFILE=Models\Decals\blood2_a.3d DATAFILE=Models\Decals\Blood2_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec TEXTURE IMPORT NAME=Sparky FILE=Models\Decals\Spark.pcx GROUP=Effects
#exec MESH ORIGIN MESH=SparksM X=0 Y=0 Z=0 YAW=128
#exec MESH SEQUENCE MESH=SparksM SEQ=All       STARTFRAME=0   NUMFRAMES=45
#exec MESH SEQUENCE MESH=SparksM SEQ=Spray     STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=SparksM SEQ=Still     STARTFRAME=6   NUMFRAMES=1
#exec MESH SEQUENCE MESH=SparksM SEQ=GravSpray STARTFRAME=7   NUMFRAMES=5
#exec MESH SEQUENCE MESH=SparksM SEQ=Stream    STARTFRAME=12  NUMFRAMES=11
#exec MESH SEQUENCE MESH=SparksM SEQ=Trail     STARTFRAME=23  NUMFRAMES=11
#exec MESH SEQUENCE MESH=SparksM SEQ=Burst     STARTFRAME=34  NUMFRAMES=2
#exec MESH SEQUENCE MESH=SparksM SEQ=GravSpray2 STARTFRAME=36 NUMFRAMES=7

#exec MESHMAP SCALE MESHMAP=SparksM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=SparksM NUM=0  TEXTURE=Sparky

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim('GravSpray');
}

simulated function Landed( vector HitNormal )
{
	Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Destroy();
}

simulated function ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
		Destroy();
}

defaultproperties
{
	AnimSequence=GravSpray
	DrawType=DT_Mesh
	Mesh=Mesh'Unrealshare.SparksM'
	bParticles=True
	Physics=PHYS_Falling
	RemoteRole=ROLE_None
	LifeSpan=1.000000
	Style=STY_Translucent
	Texture=Texture'Unrealshare.Effects.Sparky'
	DrawScale=0.100000
	bUnlit=True
	bMeshCurvy=False
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	bCollideWorld=True
}

