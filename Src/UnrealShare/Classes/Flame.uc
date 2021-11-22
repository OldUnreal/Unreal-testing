//=============================================================================
// Flame.
//=============================================================================
class Flame extends Effects;

#exec MESH IMPORT MESH=FlameM ANIVFILE=Models\Flame_a.3d DATAFILE=Models\Flame_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FlameM X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=FlameM SEQ=All       STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=FlameM X=0.3 Y=0.3 Z=0.6 YAW=128
#exec OBJ LOAD FILE=Textures\fireeffect28.utx PACKAGE=UnrealShare.Effect28
#exec MESHMAP SETTEXTURE MESHMAP=FlameM NUM=0 TEXTURE=UnrealShare.Effect28.FireEffect28
#exec MESHMAP SETTEXTURE MESHMAP=FlameM NUM=1 TEXTURE=UnrealShare.Effect28.FireEffect28a

defaultproperties
{
	DrawType=DT_Mesh
	bUnlit=True
	bMeshCurvy=False
}
