//=============================================================================
// Lantern.
//=============================================================================
class Lantern extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=LanternM ANIVFILE=MODELS\Lantern_a.3d DATAFILE=MODELS\Lantern_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=LanternM X=237 Y=61 Z=0 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=LanternM STRENGTH=0.5
#exec MESH SEQUENCE MESH=LanternM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=LanternM SEQ=STILL STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JLantern1 FILE=Models\LNTR.pcx GROUP=Skins FLAGS=2 DETAIL=metal
#exec MESHMAP NEW   MESHMAP=LanternM MESH=LanternM
#exec MESHMAP SCALE MESHMAP=LanternM X=0.125 Y=0.125 Z=0.252

#exec MESHMAP SETTEXTURE MESHMAP=LanternM NUM=1 TEXTURE=JLantern1

function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	SetLocation(HitLocation+HitNormal*CollisionRadius*2, rotator(-HitNormal));
}

defaultproperties
{
	bDirectional=True
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.LanternM'
	LightType=LT_Steady
	LightBrightness=203
	LightHue=35
	LightSaturation=59
	LightRadius=32
}
