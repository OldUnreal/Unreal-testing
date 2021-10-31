//=============================================================================
// Pottery1.
//=============================================================================
class Pottery1 extends Vase;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Pottery1M ANIVFILE=Models\pot1_a.3d DATAFILE=Models\pot1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pottery1M X=0 Y=0 Z=98 YAW=64
#exec MESH LODPARAMS MESH=Pottery1M STRENGTH=0.5
#exec MESH SEQUENCE MESH=Pottery1M SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pottery1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPottery11 FILE=Models\pot1.pcx GROUP=Skins DETAIL=Marble
#exec MESHMAP SCALE MESHMAP=Pottery1M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Pottery1M NUM=1 TEXTURE=JPottery11

defaultproperties
{
	Mesh=Pottery1M
	bMeshCurvy=False
	CollisionRadius=+00014.000000
	CollisionHeight=+00019.500000
}
