//=============================================================================
// Plant3.
//=============================================================================
class Plant3 extends Decoration;

#exec TEXTURE IMPORT NAME=JPlant31HD FILE=Models\plant3.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JPlant31 FILE=Models\plant3_old.pcx GROUP=Skins FLAGS=2 HD=JPlant31HD

#exec MESH IMPORT MESH=Plant3M ANIVFILE=Models\plant3_a.3d DATAFILE=ModelsFX\plant3_d.3d Curvy=1 LODSTYLE=2
//#exec MESH LODPARAMS MESH=Plant3M STRENGTH=0.5
#exec MESH ORIGIN MESH=Plant3M X=0 Y=100 Z=210 YAW=64

#exec MESH SEQUENCE MESH=plant3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=plant3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=plant3M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=plant3M NUM=1 TEXTURE=Jplant31

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Plant3M
	CollisionRadius=+00012.000000
	CollisionHeight=+00021.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockRigidBodyPhys=true
}
