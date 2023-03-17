//=============================================================================
// SMGib2.
//=============================================================================
class SMGib2 expands SpaceMarineCarcass;

#exec MESH IMPORT MESH=smgib2 ANIVFILE=MODELS\MARINE\smgib2_a.3d DATAFILE=MODELS\MARINE\smgib2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=smgib2 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=smgib2 SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=smgib2 SEQ=bird STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jsmgib21 FILE=MODELS\MARINE\smgib1.PCX GROUP=Skins FLAGS=2 // SMblood4
//#exec TEXTURE IMPORT NAME=Jsmgib22 FILE=MODELS\MARINE\smgib2.PCX GROUP=Skins // SMbloodx4

#exec MESHMAP NEW   MESHMAP=smgib2 MESH=smgib2
#exec MESHMAP SCALE MESHMAP=smgib2 X=0.3 Y=0.3 Z=0.4

#exec MESHMAP SETTEXTURE MESHMAP=smgib2 NUM=1 TEXTURE=Jsmgib21
//UG #exec MESHMAP SETTEXTURE MESHMAP=smgib2 NUM=2 TEXTURE=Jsmgib22

defaultproperties
{
	bodyparts(1)=LodMesh'CowBody1'
	bodyparts(2)=LodMesh'CowBody2'
	bodyparts(3)=LodMesh'CowBody2'
	bodyparts(4)=LodMesh'LiverM'
	bodyparts(5)=LodMesh'LiverM'
	flies=4
	AnimSequence=Dead
	Mesh=LodMesh'SMGib2'
}
