//=============================================================================
// Flag1.
//=============================================================================
class Flag1 extends Decoration;

#exec MESH IMPORT MESH=Flag1M ANIVFILE=Models\flag_a.3d DATAFILE=Models\flag_d.3d X=0 Y=0 Z=0 Curvy=1 LODSTYLE=2 ZEROTEX=1 MLOD=1

// 60 Vertices, 82 Triangles
#exec MESH LODPARAMS MESH=Flag1M STRENGTH=1.0 MINVERTS=3 MORPH=0.1 ZDISP=800.0

#exec MESH ORIGIN MESH=Flag1M X=0 Y=100 Z=0 YAW=128 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=flag1M SEQ=All    STARTFRAME=0  NUMFRAMES=14
#exec MESH SEQUENCE MESH=flag1M SEQ=Wave  STARTFRAME=1  NUMFRAMES=13
#exec TEXTURE IMPORT NAME=JFlag11 FILE=Models\flag.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=JFlag12 FILE=Models\flagb.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=flag1M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=flag1M NUM=0 TEXTURE=Jflag11 TLOD=10

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Wave',0.7,0.1);
}

defaultproperties
{
	bStatic=False
	Physics=PHYS_Walking
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Texture=Texture'UnrealI.Skins.JFlag11'
	Mesh=LodMesh'UnrealI.Flag1M'
}
