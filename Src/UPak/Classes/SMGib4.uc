//=============================================================================
// SMGib4.
//=============================================================================
class SMGib4 expands SpaceMarineCarcass;

#exec MESH IMPORT MESH=smgib4 ANIVFILE=MODELS\MARINE\smgib4_a.3d DATAFILE=MODELS\MARINE\smgib4_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=smgib4 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=smgib4 SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=smgib4 SEQ=bee STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jsmgib41 FILE=MODELS\MARINE\smgib1.PCX GROUP=Skins FLAGS=2 // SMblood4
#exec TEXTURE IMPORT NAME=Jsmgib42 FILE=MODELS\MARINE\smgib2.PCX GROUP=Skins // SMbloodx4

#exec MESHMAP NEW   MESHMAP=smgib4 MESH=smgib4
#exec MESHMAP SCALE MESHMAP=smgib4 X=0.3 Y=0.3 Z=0.4

#exec MESHMAP SETTEXTURE MESHMAP=smgib4 NUM=1 TEXTURE=Jsmgib41
#exec MESHMAP SETTEXTURE MESHMAP=smgib4 NUM=2 TEXTURE=Jsmgib42

defaultproperties
{
     bodyparts(1)=LodMesh'CowBody1'
     bodyparts(2)=LodMesh'CowBody2'
     bodyparts(3)=LodMesh'CowBody2'
     bodyparts(4)=LodMesh'LiverM'
     bodyparts(5)=LodMesh'LiverM'
     flies=4
     AnimSequence=Dead
     Mesh=LodMesh'SMGib4'
}
