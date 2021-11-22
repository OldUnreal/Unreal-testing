//=============================================================================
// BloodPool.
//=============================================================================
class BloodPool extends Effects
	transient;

#exec MESH IMPORT MESH=BSpot ANIVFILE=Models\bpool_a.3d DATAFILE=Models\bpool_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BSpot X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=BSpot SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=BSpot SEQ=Explo     STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP SCALE MESHMAP=BSpot X=0.2 Y=0.2 Z=0.2
#exec TEXTURE IMPORT NAME=T_BPool FILE=Models\BPool.pcx GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=BSpot NUM=1 TEXTURE=T_BPool

function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim ( 'Explo', 0.005 );
}

simulated function EndAnim()
{
	Destroy();
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Mesh'UnrealShare.BSpot'
	AmbientGlow=100
	bMeshCurvy=False
	Physics=PHYS_None
	LifeSpan=5.000000
	AnimSequence=Explo
	bHighDetail=true
	CollisionRadius=+00000.000000
	CollisionHeight=+00000.000000
}
