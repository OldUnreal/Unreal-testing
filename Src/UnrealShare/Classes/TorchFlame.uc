//=============================================================================
// Torchflame.
//=============================================================================
class TorchFlame extends Light;

#exec MESH IMPORT MESH=TFlameM ANIVFILE=Models\flame_a.3d DATAFILE=Models\flame_d.3d MLOD=0
#exec MESH ORIGIN MESH=TFlameM X=0 Y=100 Z=350 YAW=0
#exec MESH SEQUENCE MESH=TFlameM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec OBJ LOAD FILE=Textures\fireeffect28.utx PACKAGE=UnrealShare.Effect28
#exec MESHMAP SCALE MESHMAP=TFlameM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=TFlameM NUM=0 TEXTURE=UnrealShare.Effect28.FireEffect28
#exec MESHMAP SETTEXTURE MESHMAP=TFlameM NUM=1 TEXTURE=UnrealShare.Effect28.FireEffect28a

defaultproperties
{
	bStatic=False
	bHidden=False
	bMovable=False
	DrawType=DT_Mesh
	Mesh=UnrealShare.FlameM
	bUnlit=True
	LightEffect=LE_FireWaver
	LightBrightness=40
	LightRadius=32
	AnimRate=+00001.000000
}
