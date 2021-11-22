//=============================================================================
// Plant7.
//=============================================================================
class Plant7 extends Decoration;

#exec MESH IMPORT MESH=Plant7M ANIVFILE=Models\Plant7_a.3d DATAFILE=Models\Plant7_d.3d LODSTYLE=2 Curvy=1 MLOD=1
// 21 Vertices, 24 Triangles
#exec MESH LODPARAMS MESH=Plant7M STRENGTH=1.0 MINVERTS=9 MORPH=0.3 ZDISP=800.0

#exec MESH ORIGIN MESH=Plant7M X=0 Y=0 Z=0 ROLL=-64
#exec MESH SEQUENCE MESH=Plant7M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Plant7M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPlant61 FILE=Models\Plnt2m.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Plant7M X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=Plant7M NUM=1 TEXTURE=JPlant61

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Plant7M'
	bBlockRigidBodyPhys=true
}
