//=============================================================================
// Plant6.
//=============================================================================
class Plant6 extends Decoration;


#exec MESH IMPORT MESH=Plant6M ANIVFILE=Models\Plant6_a.3d DATAFILE=Models\Plant6_d.3d Curvy=1 LODSTYLE=2
//#exec MESH LODPARAMS MESH=Plant6M STRENGTH=0.5
#exec MESH ORIGIN MESH=Plant6M X=0 Y=0 Z=0 ROLL=-64
#exec MESH SEQUENCE MESH=Plant6M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Plant6M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPlant61 FILE=Models\Plnt2m.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Plant6M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=Plant6M NUM=1 TEXTURE=JPlant61

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=UnrealShare.Plant6M
	bMeshCurvy=False
	bBlockRigidBodyPhys=true
}
