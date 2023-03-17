//=============================================================================
// Plant2.
//=============================================================================
class Plant2 extends Decoration;

#exec TEXTURE IMPORT NAME=JPlant21HD FILE=Models\plant2.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JPlant21 FILE=Models\plant2_old.pcx GROUP=Skins FLAGS=2 HD=JPlant21HD

#exec MESH IMPORT MESH=Plant2M ANIVFILE=Models\plant2_a.3d DATAFILE=Models\plant2_d.3d Curvy=1 LODSTYLE=2
//#exec MESH LODPARAMS MESH=Plant2M STRENGTH=0.5
#exec MESH ORIGIN MESH=Plant2M X=0 Y=100 Z=100 YAW=64

#exec MESH SEQUENCE MESH=plant2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=plant2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=plant2M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=plant2M NUM=1 TEXTURE=Jplant21

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Plant2M
	CollisionRadius=+00006.000000
	CollisionHeight=+00009.000000
	bCollideWorld=True
	bBlockRigidBodyPhys=true
}
