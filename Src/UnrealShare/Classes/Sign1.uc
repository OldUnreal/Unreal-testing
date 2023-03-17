//=============================================================================
// Sign1.
//=============================================================================
class Sign1 extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec TEXTURE IMPORT NAME=JSign11HD FILE=Models\sign1.pcx GROUP="HD" FLAGS=2 DETAIL=wood1h
#exec TEXTURE IMPORT NAME=JSign11 FILE=Models\sign1_old.pcx GROUP=Skins FLAGS=2 DETAIL=wood1h HD=JSign11HD

#exec MESH IMPORT MESH=Sign1M ANIVFILE=Models\sign1_a.3d DATAFILE=ModelsFX\sign1_d.3d Curvy=1 X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=Sign1M STRENGTH=0.1
#exec MESH ORIGIN MESH=Sign1M X=0 Y=100 Z=-120 YAW=64

#exec MESH SEQUENCE MESH=sign1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=sign1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=sign1M X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=sign1M NUM=1 TEXTURE=Jsign11 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Sign1M
	bProjTarget=True
}
