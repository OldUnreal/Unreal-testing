//=============================================================================
// Arm1.
//=============================================================================
class Arm1 extends PlayerChunks;


#exec MESH IMPORT MESH=Arm1M ANIVFILE=Models\g_Arm1_a.3d DATAFILE=Models\g_Arm1_d.3d X=0 Y=0 Z=0 MLOD=1
// 34 Vertices, 57 Triangles
#exec MESH LODPARAMS MESH=Arm1M STRENGTH=0.5 MINVERTS=18 MORPH=0.1 ZDISP=2000.0
#exec MESH ORIGIN MESH=Arm1M X=0 Y=0 Z=-160 YAW=64
#exec MESH SEQUENCE MESH=Arm1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Arm1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JArm11  FILE=Models\g_Arm.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Arm1M X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=Arm1M NUM=1 TEXTURE=JArm11 TLOD=10

defaultproperties
{
	Mesh=LodMesh'UnrealShare.Arm1M'
}
