//=============================================================================
// Candle2
//=============================================================================
class Candle2 extends Decoration;

#exec TEXTURE IMPORT NAME=JCandl21HD FILE=Models\candl2.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JCandl21 FILE=Models\candl2_old.pcx GROUP=Skins FLAGS=2 HD=JCandl21HD

#exec MESH IMPORT MESH=Candl2 ANIVFILE=Models\candl2_a.3d DATAFILE=ModelsFX\candl2_d.3d X=0 Y=0 Z=0 Curvy=1 LODSTYLE=8 MLOD=1
// 10 Vertices, 10 Triangles
#exec MESH LODPARAMS MESH=Candl2 STRENGTH=1.0 MINVERTS=7 MORPH=0.3 ZDISP=800.0

#exec MESH ORIGIN MESH=Candl2 X=30 Y=-105 Z=-40 YAW=64
#exec MESH SEQUENCE MESH=Candl2 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Candl2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec OBJ LOAD FILE=Textures\cflame.utx PACKAGE=UnrealShare.CFLAM
#exec MESHMAP SCALE MESHMAP=candl2 X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=Candl2 NUM=1 TEXTURE=Jcandl21 TLOD=10
#exec MESHMAP SETTEXTURE MESHMAP=Candl2 NUM=0 TEXTURE=cflame TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Candl2'
	CollisionRadius=3.000000
	CollisionHeight=12.500000
	bCollideActors=True
	bCollideWorld=True
}
