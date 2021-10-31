//=============================================================================
// CowCarcass.
//=============================================================================
class CowCarcass extends CreatureCarcass;

#exec MESH IMPORT MESH=CowFoot ANIVFILE=Models\g_cowf_a.3d DATAFILE=Models\g_cowf_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CowFoot X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=CowFoot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CowFoot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow1  FILE=Models\Nc_1.pcx FAMILY=Skins
#exec MESHMAP SCALE MESHMAP=CowFoot X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=CowFoot NUM=1 TEXTURE=JGCow1

#exec MESH IMPORT MESH=CowHead ANIVFILE=Models\g_cowh_a.3d DATAFILE=Models\g_cowh_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CowHead X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=CowHead SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CowHead SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow2  FILE=Models\Nc_2.pcx FAMILY=Skins
#exec MESHMAP SCALE MESHMAP=CowHead X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=CowHead NUM=1 TEXTURE=JGCow2

#exec MESH IMPORT MESH=CowLeg ANIVFILE=Models\g_cowl_a.3d DATAFILE=Models\g_cowl_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CowLeg X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=CowLeg SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CowLeg SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow2  FILE=Models\Nc_2.pcx FAMILY=Skins
#exec MESHMAP SCALE MESHMAP=CowLeg X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=CowLeg NUM=1 TEXTURE=JGCow2

#exec MESH IMPORT MESH=CowTail ANIVFILE=Models\g_cowt_a.3d DATAFILE=Models\g_cowt_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CowTail X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=CowTail SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CowTail SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow2  FILE=Models\Nc_2.pcx FAMILY=Skins
#exec MESHMAP SCALE MESHMAP=CowTail X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=CowTail NUM=1 TEXTURE=JGCow2

#exec AUDIO IMPORT FILE="Sounds\Cow\thump1.wav" NAME="thumpC" GROUP="Cow"

function ForceMeshToExist()
{
	//never called
	Spawn(class 'Cow');
}

defaultproperties
{
	bodyparts(0)=CowHead
	bodyparts(1)=CowBody2
	bodyparts(2)=CowBody1
	bodyparts(3)=CowLeg
	bodyparts(4)=CowTail
	bodyparts(5)=CowFoot
	LandedSound=thumpC
	Mesh=NaliCow
	CollisionRadius=+00048.000000
	CollisionHeight=+00032.000000
	Mass=+00120.000000
}
