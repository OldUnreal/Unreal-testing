//=============================================================================
// TitanCarcass.
//=============================================================================
class TitanCarcass extends CreatureCarcass;

#exec MESH IMPORT MESH=BigChunk1 ANIVFILE=..\UnrealShare\Models\g_cow2_a.3d DATAFILE=..\UnrealShare\Models\g_cow2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bigchunk1 X=0 Y=-30 Z=0 YAW=64
#exec MESH SEQUENCE MESH=bigchunk1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bigchunk1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow1  FILE=..\UnrealShare\Models\Nc_1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=bigchunk1 X=0.12 Y=0.12 Z=0.24
#exec MESHMAP SETTEXTURE MESHMAP=bigchunk1 NUM=1 TEXTURE=JGCow1

#exec MESH IMPORT MESH=bigchunk2 ANIVFILE=..\UnrealShare\Models\g_cowb_a.3d DATAFILE=..\UnrealShare\Models\g_cowb_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bigchunk2 X=0 Y=-30 Z=0 YAW=64
#exec MESH SEQUENCE MESH=bigchunk2 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bigchunk2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow1  FILE=..\UnrealShare\Models\Nc_1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=bigchunk2 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=bigchunk2 NUM=1 TEXTURE=JGCow1

function ForceMeshToExist()
{
	//never called
	Spawn(class 'Titan');
}

defaultproperties
{
	bPermanent=true
	bodyparts(0)=UnrealI.bigchunk1
	bodyparts(1)=UnrealI.bigchunk1
	bodyparts(2)=UnrealI.bigchunk2
	bodyparts(3)=UnrealI.bigchunk2
	bodyparts(4)=UnrealI.bigchunk1
	bodyparts(5)=UnrealI.bigchunk2
	bodyparts(6)=UnrealI.bigchunk1
	bodyparts(7)=UnrealI.bigchunk2
	ZOffset(0)=+00000.600000
	ZOffset(1)=+00000.500000
	ZOffset(3)=+00000.200000
	ZOffset(4)=-00000.200000
	ZOffset(5)=-00000.500000
	Mesh=Titan1
	AnimSequence=TDeat001
	CollisionRadius=+00115.000000
	CollisionHeight=+00110.000000
	Mass=+02000.000000
}
