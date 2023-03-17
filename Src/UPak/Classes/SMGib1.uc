//=============================================================================
// SMGib1.
//=============================================================================
class SMGib1 expands SpaceMarineCarcass;

#exec MESH IMPORT MESH=smgib1 ANIVFILE=MODELS\MARINE\smgib1_a.3d DATAFILE=MODELS\MARINE\smgib1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=smgib1 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=smgib1 SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=smgib1 SEQ=fish STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jsmgib11 FILE=MODELS\MARINE\smgib1.PCX GROUP=Skins FLAGS=2 // SMblood4
#exec TEXTURE IMPORT NAME=Jsmgib12 FILE=MODELS\MARINE\smgib2.PCX GROUP=Skins // SMbloodx4

#exec MESHMAP NEW   MESHMAP=smgib1 MESH=smgib1
#exec MESHMAP SCALE MESHMAP=smgib1 X=0.3 Y=0.3 Z=0.4

#exec MESHMAP SETTEXTURE MESHMAP=smgib1 NUM=1 TEXTURE=Jsmgib11
#exec MESHMAP SETTEXTURE MESHMAP=smgib1 NUM=2 TEXTURE=Jsmgib12

defaultproperties
{
	bodyparts(1)=LodMesh'CowBody1'
	bodyparts(2)=LodMesh'CowBody2'
	bodyparts(3)=LodMesh'CowBody2'
	bodyparts(4)=LodMesh'LiverM'
	bodyparts(5)=LodMesh'LiverM'
	flies=4
	AnimSequence=Dead
	Mesh=LodMesh'SMGib1'
}
