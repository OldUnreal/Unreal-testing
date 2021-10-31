//=============================================================================
// Sconce.
//=============================================================================
class Sconce extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=sconceM ANIVFILE=MODELS\Sconce_a.3d DATAFILE=MODELS\Sconce_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=sconceM X=132 Y=-22 Z=0 YAW=0 PITCH=-64 ROLL=64
#exec MESH SEQUENCE MESH=sconceM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=sconceM SEQ=STILL STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jsconce1 FILE=Models\sconce.pcx GROUP=Skins DETAIL=Metal
#exec MESHMAP NEW   MESHMAP=sconceM MESH=SconceM
#exec MESHMAP SCALE MESHMAP=sconceM X=0.125 Y=0.125 Z=0.25
#exec MESHMAP SETTEXTURE MESHMAP=sconceM NUM=0 TEXTURE=JSconce1

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.sconceM'
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
}
