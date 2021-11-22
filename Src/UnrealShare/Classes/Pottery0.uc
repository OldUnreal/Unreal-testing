//=============================================================================
// Pottery0.
//=============================================================================
class Pottery0 extends Vase;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Pottery0M ANIVFILE=Models\pot0_a.3d DATAFILE=Models\pot0_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pottery0M X=0 Y=0 Z=80 YAW=64
#exec MESH LODPARAMS MESH=Pottery0M STRENGTH=0.5
#exec MESH SEQUENCE MESH=Pottery0M SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pottery0M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPottery01 FILE=Models\pot0.pcx GROUP=Skins DETAIL=Marble
#exec MESHMAP SCALE MESHMAP=Pottery0M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Pottery0M NUM=1 TEXTURE=JPottery01

defaultproperties
{
	Mesh=Pottery0M
	bMeshCurvy=False
	CollisionRadius=+00016.000000
	CollisionHeight=+00016.000000
}
