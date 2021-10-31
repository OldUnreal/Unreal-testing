//=============================================================================
// Tree9.
//=============================================================================
class Tree9 extends Tree;

#exec MESH IMPORT MESH=Tree9M ANIVFILE=Models\Tree15_a.3d DATAFILE=ModelsFX\Tree15_d.3d Curvy=1 LODSTYLE=2 MLOD=1

// 26 Vertices, 25 Triangles
#exec MESH LODPARAMS MESH=Tree9M STRENGTH=1.0 MINVERTS=12 MORPH=0.3 ZDISP=800.0

#exec MESH ORIGIN MESH=Tree9M X=0 Y=320 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=Tree9M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Tree9M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTree91 FILE=Models\Tree15.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Tree9M X=0.12 Y=0.12 Z=0.24
#exec MESHMAP SETTEXTURE MESHMAP=Tree9M NUM=1 TEXTURE=JTree91 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Tree9M'
	CollisionRadius=15.00
	CollisionHeight=39.00
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True

}
