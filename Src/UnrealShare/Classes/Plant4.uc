//=============================================================================
// Plant4.
//=============================================================================
class Plant4 extends Decoration;

#exec MESH IMPORT MESH=Plant4M ANIVFILE=Models\Plant4_a.3d DATAFILE=ModelsFX\Plant4_d.3d Curvy=1 LODSTYLE=2
//#exec MESH LODPARAMS MESH=Plant4M STRENGTH=0.5
#exec MESH ORIGIN MESH=Plant4M X=0 Y=0 Z=0 ROLL=-64
#exec MESH SEQUENCE MESH=Plant4M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Plant4M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JPlant41 FILE=Models\Plnt1.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=Plant4M X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=Plant4M NUM=1 TEXTURE=JPlant41

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=UnrealShare.Plant4M
	bMeshCurvy=False
	CollisionRadius=+00011.000000
	CollisionHeight=+00037.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bBlockRigidBodyPhys=true
}
