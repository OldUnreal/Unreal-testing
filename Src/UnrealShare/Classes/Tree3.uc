//=============================================================================
// Tree3.
//=============================================================================
class Tree3 extends Tree;

#exec MESH IMPORT MESH=Tree3M ANIVFILE=Models\Tree3_a.3d DATAFILE=ModelsFX\Tree3_d.3d Curvy=1 LODSTYLE=8 MLOD=1

// 27 Vertices, 30 Triangles
#exec MESH LODPARAMS MESH=Tree3M STRENGTH=1.0 MINVERTS=12 MORPH=0.3 ZDISP=1200.0

#exec MESH ORIGIN MESH=Tree3M X=50 Y=0 Z=50 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=Tree3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Tree3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTree31 FILE=Models\Tree3.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Tree3M X=0.25 Y=0.25 Z=0.5
#exec MESHMAP SETTEXTURE MESHMAP=Tree3M NUM=1 TEXTURE=JTree31 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Tree3M'
	CollisionRadius=25.00
	CollisionHeight=160.00
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
}
