//=============================================================================
// Tree2.
//=============================================================================
class Tree2 extends Tree;

#exec MESH IMPORT MESH=Tree2M ANIVFILE=Models\Tree2_a.3d DATAFILE=Models\Tree2_d.3d LODSTYLE=8 MLOD=1

// 21 Vertices, 26 Triangles
#exec MESH LODPARAMS MESH=Tree2M STRENGTH=1.0 MINVERTS=12 MORPH=0.3 ZDISP=1200.0

#exec MESH ORIGIN MESH=Tree2M X=50 Y=0 Z=50 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=Tree2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Tree2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTree21 FILE=Models\Tree2.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Tree2M X=0.25 Y=0.25 Z=0.5
#exec MESHMAP SETTEXTURE MESHMAP=Tree2M NUM=1 TEXTURE=JTree21 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Tree2M'
	CollisionRadius=25.00
	CollisionHeight=160.00
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
}
