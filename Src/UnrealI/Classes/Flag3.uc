//=============================================================================
// Flag3.
//=============================================================================
class Flag3 extends Decoration;

#exec TEXTURE IMPORT NAME=JFlag31HD FILE=Models\flag3.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JFlag31 FILE=Models\flag3_old.pcx GROUP=Skins FLAGS=2 HD=JFlag31HD

#exec MESH IMPORT MESH=Flag3M ANIVFILE=Models\flag3_a.3d DATAFILE=Models\flag3_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

// 60 Vertices, 82 Triangles
#exec MESH LODPARAMS MESH=Flag3M STRENGTH=1.0 MINVERTS=3 MORPH=0.1 ZDISP=800.0

#exec MESH ORIGIN MESH=Flag3M X=0 Y=100 Z=-120 YAW=64

#exec MESH SEQUENCE MESH=flag3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=flag3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=flag3M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=flag3M NUM=1 TEXTURE=Jflag31 TLOD=10

defaultproperties
{
	Physics=PHYS_Walking
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Flag3M'
}
