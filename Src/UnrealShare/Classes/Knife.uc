//=============================================================================
// Knife.
//=============================================================================
class Knife extends Decoration;


#exec MESH IMPORT MESH=KnifeM ANIVFILE=Models\Knife_a.3d DATAFILE=Models\Knife_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1
// 32 Vertices, 55 Triangles
#exec MESH LODPARAMS MESH=KnifeM STRENGTH=1.0 MINVERTS=12 MORPH=0.3 ZDISP=1200.0
#exec MESH ORIGIN MESH=KnifeM X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=KnifeM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KnifeM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JLantern1 FILE=Models\LNTR.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=KnifeM X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=KnifeM NUM=1 TEXTURE=JLantern1 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.KnifeM'
}
