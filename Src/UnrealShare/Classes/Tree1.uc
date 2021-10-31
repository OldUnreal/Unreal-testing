//=============================================================================
// Tree1.
//=============================================================================
class Tree1 extends Tree;

#exec MESH IMPORT MESH=Tree1M ANIVFILE=Models\Tree1_a.3d DATAFILE=Models\Tree1_d.3d LODSTYLE=8 MLOD=1

// 21 Vertices, 26 Triangles
#exec MESH LODPARAMS MESH=Tree1M STRENGTH=1.0 MINVERTS=12 MORPH=0.3 ZDISP=1200.0

#exec MESH ORIGIN MESH=Tree1M X=25 Y=0 Z=-14 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=Tree1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Tree1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTree11 FILE=Models\Tree1.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Tree1M X=0.2 Y=0.2 Z=0.4
#exec MESHMAP SETTEXTURE MESHMAP=Tree1M NUM=1 TEXTURE=JTree11 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Tree1M'
	CollisionRadius=25.00
	CollisionHeight=160.00
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
}
