//=============================================================================
// Naliskel.
//=============================================================================
class Naliskel expands Decoration;

#exec MESH IMPORT MESH=Naliskel ANIVFILE=MODELS\NALISKEL\Naliskel_a.3d DATAFILE=MODELS\NALISKEL\Naliskel_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Naliskel X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Naliskel SEQ=All       STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=Naliskel SEQ=SKELETON1 STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Naliskel SEQ=SKELETON2 STARTFRAME=1 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Naliskel SEQ=SKELETON3 STARTFRAME=2 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JNaliskel0 FILE=MODELS\NALISKEL\Naliskel1.PCX GROUP=Skins FLAGS=2 // SKIN
#exec TEXTURE IMPORT NAME=JNaliskel1 FILE=MODELS\NALISKEL\Naliskel1.PCX GROUP=Skins // Base

#exec MESHMAP NEW   MESHMAP=Naliskel MESH=Naliskel
#exec MESHMAP SCALE MESHMAP=Naliskel X=0.4 Y=0.4 Z=0.7

#exec MESHMAP SETTEXTURE MESHMAP=Naliskel NUM=0 TEXTURE=JNaliskel0
#exec MESHMAP SETTEXTURE MESHMAP=Naliskel NUM=1 TEXTURE=JNaliskel1

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'Naliskel'
	CollisionHeight=35.000000
	bCollideWorld=True
}
