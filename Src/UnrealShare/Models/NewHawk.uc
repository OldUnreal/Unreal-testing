class NewHawk expands Actor;

#exec MESH IMPORT MESH=NewHawk ANIVFILE=Models\NewHawk_a.3d DATAFILE=Models\NewHawk_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=NewHawk X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=NewHawk SEQ=All STARTFRAME=0 NUMFRAMES=45
//#exec MESH SEQUENCE MESH=NewHawk SEQ=??? STARTFRAME=0 NUMFRAMES=45

#exec MESHMAP NEW MESHMAP=NewHawk MESH=NewHawk
#exec MESHMAP SCALE MESHMAP=NewHawk X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=Jtex1 FILE=texture1.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=Jtex1 FILE=texture1.pcx GROUP=Skins PALETTE=Jtex1
#exec MESHMAP SETTEXTURE MESHMAP=NewHawk NUM=1 TEXTURE=Jtex1

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=NewHawk
}
