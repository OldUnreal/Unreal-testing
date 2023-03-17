//=============================================================================
// Candle.
//=============================================================================
class Candle extends Decoration;

#exec TEXTURE IMPORT NAME=JCandle1HD FILE=Models\candle.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=JCandle1 FILE=Models\candle_old.pcx GROUP=Skins HD=JCandle1HD

#exec MESH IMPORT MESH=CandleM ANIVFILE=Models\candle_a.3d DATAFILE=Models\candle_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1

// 24 Vertices, 35 Triangles
#exec MESH LODPARAMS MESH=CandleM STRENGTH=1.0 MINVERTS=6 MORPH=0.3 ZDISP=400.0

#exec MESH ORIGIN MESH=CandleM X=0 Y=0 Z=-50 YAW=64
#exec MESH SEQUENCE MESH=CandleM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CandleM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec OBJ LOAD FILE=Textures\cflame.utx PACKAGE=UnrealShare.CFLAM
#exec MESHMAP SCALE MESHMAP=CandleM X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=CandleM NUM=1 TEXTURE=Jcandle1 TLOD=10
#exec MESHMAP SETTEXTURE MESHMAP=CandleM NUM=0 TEXTURE=UnrealShare.CFLAM.cflame TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'CandleM'
	CollisionRadius=2.000000
	CollisionHeight=14.000000
	bCollideActors=True
	bCollideWorld=True
}
