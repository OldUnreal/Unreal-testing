//=============================================================================
// Lantern2.
//=============================================================================
class Lantern2 extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Lantern2M ANIVFILE=Models\Lantr2_a.3d DATAFILE=Models\Lantr2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Lantern2M X=0 Y=0 Z=0 ROLL=-64
#exec MESH LODPARAMS MESH=Lantern2M STRENGTH=0.5
#exec MESH SEQUENCE MESH=Lantern2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lantern2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JLantern1 FILE=Models\LNTR.pcx GROUP=Skins FLAGS=2 DETAIL=metal
#exec MESHMAP SCALE MESHMAP=Lantern2M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Lantern2M NUM=1 TEXTURE=JLantern1 TLOD=10

function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	SetLocation(HitLocation+HitNormal*(CollisionHeight+4), rotator(HitNormal)+rotang(90,0,0));
}

defaultproperties
{
	bDirectional=True
	DrawType=DT_Mesh
	Mesh=Lantern2M
	bMeshCurvy=False
	LightBrightness=201
	LightHue=36
	LightSaturation=60
	LightRadius=33
}
