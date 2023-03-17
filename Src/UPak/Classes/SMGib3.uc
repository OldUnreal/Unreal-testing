//=============================================================================
// SMGib3.
//=============================================================================
class SMGib3 expands SpaceMarineCarcass;

#exec MESH IMPORT MESH=smgib3 ANIVFILE=MODELS\MARINE\smgib3_a.3d DATAFILE=MODELS\MARINE\smgib3_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=smgib3 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=smgib3 SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=smgib3 SEQ=flower STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jsmgib31 FILE=MODELS\MARINE\smgib1.PCX GROUP=Skins FLAGS=2 // SMblood4
#exec TEXTURE IMPORT NAME=Jsmgib32 FILE=MODELS\MARINE\smgib2.PCX GROUP=Skins // SMbloodx4

#exec MESHMAP NEW   MESHMAP=smgib3 MESH=smgib3
#exec MESHMAP SCALE MESHMAP=smgib3 X=0.3 Y=0.3 Z=0.4

#exec MESHMAP SETTEXTURE MESHMAP=smgib3 NUM=1 TEXTURE=Jsmgib31
#exec MESHMAP SETTEXTURE MESHMAP=smgib3 NUM=2 TEXTURE=Jsmgib32

defaultproperties
{
	bodyparts(1)=LodMesh'CowBody1'
	bodyparts(2)=LodMesh'CowBody2'
	bodyparts(3)=LodMesh'CowBody2'
	bodyparts(4)=LodMesh'LiverM'
	bodyparts(5)=LodMesh'LiverM'
	flies=4
	AnimSequence=Dead
	Mesh=LodMesh'SMGib3'
}
