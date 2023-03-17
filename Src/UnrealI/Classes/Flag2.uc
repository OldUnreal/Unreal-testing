//=============================================================================
// Flag2.
//=============================================================================
class Flag2 extends Decoration;

#exec TEXTURE IMPORT NAME=JFlag21HD FILE=Models\flag2.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JFlag21 FILE=Models\flag2_old.pcx GROUP=Skins FLAGS=2 HD=JFlag21HD

#exec MESH IMPORT MESH=Flag2M ANIVFILE=Models\flag2_a.3d DATAFILE=Models\flag2_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

// 60 Vertices, 82 Triangles
#exec MESH LODPARAMS MESH=Flag2M STRENGTH=1.0 MINVERTS=3 MORPH=0.1 ZDISP=800.0

#exec MESH ORIGIN MESH=Flag2M X=0 Y=100 Z=-120 YAW=64

#exec MESH SEQUENCE MESH=flag2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=flag2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=flag2M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=flag2M NUM=1 TEXTURE=Jflag21 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Flag2M'
}
