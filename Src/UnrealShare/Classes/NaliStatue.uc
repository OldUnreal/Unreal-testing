//=============================================================================
// NaliStatue.
//=============================================================================
class NaliStatue extends MonkStatue;

#exec OBJ LOAD FILE=Detail.utx

#exec TEXTURE IMPORT NAME=JNaliStatue1HD FILE=Models\nstatue.pcx GROUP="HD" DETAIL=rockde2
#exec TEXTURE IMPORT NAME=JNaliStatue1 FILE=Models\nstatue_old.pcx GROUP="Skins" DETAIL=rockde2 HD=JNaliStatue1HD

#exec MESH IMPORT MESH=NaliStatueM ANIVFILE=Models\statue_a.3d DATAFILE=Models\statue_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1

#exec MESH LODPARAMS MESH=NaliStatueM STRENGTH=1.0 MINVERTS=120 MORPH=0.3 ZDISP=1200.0
#exec MESH ORIGIN MESH=NaliStatueM X=0 Y=0 Z=0 YAW=0
#exec MESH LODPARAMS MESH=NaliStatueM STRENGTH=0.5
#exec MESH SEQUENCE MESH=NaliStatueM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliStatueM SEQ=Still STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=NaliStatueM X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=NaliStatueM NUM=1 TEXTURE=JNaliStatue1 TLOD=10

defaultproperties
{
	Mesh=LodMesh'UnrealShare.NaliStatueM'
}
