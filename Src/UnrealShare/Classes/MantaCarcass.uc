//=============================================================================
// MantaCarcass.
//=============================================================================
class MantaCarcass extends CreatureCarcass;

#exec MESH IMPORT MESH=MantaHead ANIVFILE=Models\g_mtah_a.3d DATAFILE=Models\g_mtah_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MantaHead X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MantaHead SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=MantaHead SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmta1  FILE=Models\g_manta1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=MantaHead X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=MantaHead NUM=1 TEXTURE=Jmta1

#exec MESH IMPORT MESH=MantaPart ANIVFILE=Models\g_mtap_a.3d DATAFILE=Models\g_mtap_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MantaPart X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MantaPart SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=MantaPart SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmta1  FILE=Models\g_manta1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=MantaPart X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=MantaPart NUM=1 TEXTURE=Jmta1

#exec MESH IMPORT MESH=MantaTail ANIVFILE=Models\g_mtat_a.3d DATAFILE=Models\g_mtat_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MantaTail X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MantaTail SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=MantaTail SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmta2  FILE=Models\g_manta2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=MantaTail X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=MantaTail NUM=1 TEXTURE=Jmta2

#exec MESH IMPORT MESH=MantaWing1 ANIVFILE=Models\g_mtaw_a.3d DATAFILE=Models\g_mtaw_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

// 20 Vertices, 30 Triangles
#exec MESH LODPARAMS MESH=MantaWing1 STRENGTH=0.5 MINVERTS=20 MORPH=0.1 ZDISP=2000.0
#exec MESH ORIGIN MESH=MantaWing1 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MantaWing1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=MantaWing1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmta2  FILE=Models\g_manta2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=MantaWing1 X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=MantaWing1 NUM=1 TEXTURE=Jmta2 TLOD=10

#exec MESH IMPORT MESH=MantaWing2 ANIVFILE=Models\g_mta2_a.3d DATAFILE=Models\g_mta2_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

// 14 Vertices, 25 Triangles
#exec MESH LODPARAMS MESH=MantaWing2 STRENGTH=0.5 MINVERTS=14 MORPH=0.1 ZDISP=2000.0
#exec MESH ORIGIN MESH=MantaWing2 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MantaWing2 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=MantaWing2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmta2  FILE=Models\g_manta2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=MantaWing2 X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=MantaWing2 NUM=1 TEXTURE=Jmta2 TLOD=10

#exec AUDIO IMPORT FILE="Sounds\Manta\dslap2.wav" NAME="thumpmt" GROUP="Manta"

function ForceMeshToExist()
{
	//never called
	Spawn(class 'Manta');
}

defaultproperties
{
	bodyparts(0)=LodMesh'UnrealShare.MantaPart'
	bodyparts(1)=LodMesh'UnrealShare.MantaPart'
	bodyparts(2)=LodMesh'UnrealShare.MantaHead'
	bodyparts(3)=LodMesh'UnrealShare.MantaTail'
	bodyparts(4)=LodMesh'UnrealShare.MantaWing1'
	bodyparts(5)=LodMesh'UnrealShare.MantaWing2'
	ZOffset(0)=0.000000
	ZOffset(1)=0.000000
	LandedSound=Sound'UnrealShare.Manta.thumpmt'
	AnimSequence=Death
	AnimFrame=0.960000
	Mesh=LodMesh'UnrealShare.Manta1'
	CollisionRadius=27.000000
	CollisionHeight=12.000000
	Mass=80.000000
	Style=STY_Masked
}
