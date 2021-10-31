//=============================================================================
// Pottery2.
//=============================================================================
class Pottery2 extends Vase;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Pottery2M ANIVFILE=Models\pot2_a.3d DATAFILE=Models\pot2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pottery2M X=0 Y=0 Z=110 YAW=64
#exec MESH LODPARAMS MESH=Pottery2M STRENGTH=0.5
#exec MESH SEQUENCE MESH=Pottery2M SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pottery2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPottery21 FILE=Models\pot2.pcx GROUP=Skins DETAIL=Marble
#exec MESHMAP SCALE MESHMAP=Pottery2M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Pottery2M NUM=1 TEXTURE=JPottery21

defaultproperties
{
	Mesh=Pottery2M
	bMeshCurvy=False
	CollisionRadius=+00014.000000
	CollisionHeight=+00022.000000
}
