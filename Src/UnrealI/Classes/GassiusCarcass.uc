//=============================================================================
// GassiusCarcass.
//=============================================================================
class GassiusCarcass extends CreatureCarcass;

#exec MESH IMPORT MESH=GasArm1 ANIVFILE=Models\g_gasa_a.3d DATAFILE=Models\g_gasa_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GasArm1 X=450 Y=150 Z=0 YAW=64
#exec MESH SEQUENCE MESH=GasArm1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasArm1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGas1  FILE=Models\g_gas1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=GasArm1 X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=GasArm1 NUM=1 TEXTURE=JGas1

#exec MESH IMPORT MESH=GasArm2 ANIVFILE=Models\g_gas2_a.3d DATAFILE=Models\g_gas2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GasArm2 X=450 Y=150 Z=0 YAW=64
#exec MESH SEQUENCE MESH=GasArm2 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasArm2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGas2  FILE=Models\g_gas2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=GasArm2 X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=GasArm2 NUM=1 TEXTURE=JGas2

#exec MESH IMPORT MESH=GasHand ANIVFILE=Models\g_gash_a.3d DATAFILE=Models\g_gash_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GasHand X=450 Y=150 Z=0 YAW=64
#exec MESH SEQUENCE MESH=GasHand SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasHand SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGas1  FILE=Models\g_gas1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=GasHand X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=GasHand NUM=1 TEXTURE=JGas1

#exec MESH IMPORT MESH=GasHead ANIVFILE=Models\g_gasz_a.3d DATAFILE=Models\g_gasz_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GasHead X=450 Y=150 Z=0 YAW=64
#exec MESH SEQUENCE MESH=GasHead SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasHead SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGas2  FILE=Models\g_gas2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=GasHead X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=GasHead NUM=1 TEXTURE=JGas2

#exec MESH IMPORT MESH=GasPart ANIVFILE=Models\g_gasp_a.3d DATAFILE=Models\g_gasp_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GasPart X=450 Y=150 Z=30 YAW=64
#exec MESH SEQUENCE MESH=GasPart SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GasPart SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGas1  FILE=Models\g_gas1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=GasPart X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=GasPart NUM=1 TEXTURE=JGas1


function ForceMeshToExist()
{
	//never called
	Spawn(class 'Gasbag');
}

defaultproperties
{
	bodyparts(0)=GasHead
	bodyparts(1)=GasArm1
	bodyparts(2)=GasArm2
	bodyparts(3)=GasHand
	bodyparts(4)=GasPart
	bodyparts(5)=GasPart
	ZOffset(0)=+00000.700000
	ZOffset(1)=+00000.000000
	ZOffset(2)=+00000.350000
	ZOffset(3)=-00000.300000
	ZOffset(4)=-00000.500000
	ZOffset(5)=-00000.700000
	Mesh=GasbagM
	AnimSequence=Deflate
	Mass=+00120.000000
}
