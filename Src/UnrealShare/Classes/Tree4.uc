//=============================================================================
// Tree4.
//=============================================================================
class Tree4 extends Tree;

#exec MESH IMPORT MESH=Tree4M ANIVFILE=Models\Tree4_a.3d DATAFILE=ModelsFX\Tree4_d.3d LODSTYLE=8 Curvy=1 MLOD=1

// 27 Vertices, 30 Triangles
#exec MESH LODPARAMS MESH=Tree4M STRENGTH=1.0 MINVERTS=12 MORPH=0.3 ZDISP=1200.0

#exec MESH ORIGIN MESH=Tree4M X=50 Y=0 Z=50 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=Tree4M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Tree4M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTree41 FILE=Models\Tree4.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Tree4M X=0.25 Y=0.25 Z=0.5
#exec MESHMAP SETTEXTURE MESHMAP=Tree4M NUM=1 TEXTURE=JTree41 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Tree4M'
	CollisionRadius=25.00
	CollisionHeight=160.00
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
}
