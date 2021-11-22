//=============================================================================
// NaliCarcass.
//=============================================================================
class NaliCarcass extends CreatureCarcass;

#exec MESH IMPORT MESH=NaliFoot ANIVFILE=Models\g_nalf_a.3d DATAFILE=Models\g_nalf_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=NaliFoot X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=NaliFoot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliFoot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgnali2  FILE=Models\g_nali2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=NaliFoot X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=NaliFoot NUM=1 TEXTURE=Jgnali2

#exec MESH IMPORT MESH=NaliHand1 ANIVFILE=Models\g_nalh_a.3d DATAFILE=Models\g_nalh_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

// 28 Vertices, 45 Triangles
#exec MESH LODPARAMS MESH=NaliHand1 STRENGTH=0.5 MINVERTS=18 MORPH=0.1 ZDISP=2000.0
#exec MESH ORIGIN MESH=NaliHand1 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=NaliHand1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliHand1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgnali1  FILE=Models\g_nali1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=NaliHand1 X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=NaliHand1 NUM=1 TEXTURE=Jgnali1 TLOD=10

#exec MESH IMPORT MESH=NaliHand2 ANIVFILE=Models\g_nal2_a.3d DATAFILE=Models\g_nal2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=NaliHand2 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=NaliHand2 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliHand2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgnali1  FILE=Models\g_nali1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=NaliHand2 X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=NaliHand2 NUM=1 TEXTURE=Jgnali1

#exec MESH IMPORT MESH=NaliHead ANIVFILE=Models\g_nalz_a.3d DATAFILE=Models\g_nalz_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=NaliHead X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=NaliHead SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliHead SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgnali2  FILE=Models\g_nali2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=NaliHead X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=NaliHead NUM=1 TEXTURE=Jgnali2

#exec MESH IMPORT MESH=NaliLeg ANIVFILE=Models\g_nall_a.3d DATAFILE=Models\g_nall_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=NaliLeg X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=NaliLeg SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliLeg SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgnali1  FILE=Models\g_nali1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=NaliLeg X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=NaliLeg NUM=1 TEXTURE=Jgnali1

#exec MESH IMPORT MESH=NaliPart ANIVFILE=Models\g_nalb_a.3d DATAFILE=Models\g_nalb_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=NaliPart X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=NaliPart SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=NaliPart SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgnali2  FILE=Models\g_nali2.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=NaliPart X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=NaliPart NUM=1 TEXTURE=Jgnali2

#exec AUDIO IMPORT FILE="Sounds\Nali\thump1.wav" NAME="thumpn" GROUP="Nali"

function ForceMeshToExist()
{
	//never called
	Spawn(class 'Nali');
}

static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Dead3') && (N == 6) )
		return false;

	return true;
}

function CreateReplacement()
{
	local CreatureChunks carc;

	if (bHidden)
		return;
	carc = Spawn(class'NaliMasterChunk');
	if (carc != None)
	{
		carc.bMasterChunk = true;
		carc.Initfor(self);
		carc.Bugs = Bugs;
		if ( Bugs != None )
			Bugs.SetBase(carc);
		Bugs = None;
	}
	else if ( Bugs != None )
		Bugs.Destroy();
}

defaultproperties
{
	bodyparts(0)=LodMesh'UnrealShare.NaliPart'
	bodyparts(1)=LodMesh'UnrealShare.NaliLeg'
	bodyparts(2)=LodMesh'UnrealShare.NaliPart'
	bodyparts(3)=LodMesh'UnrealShare.NaliFoot'
	bodyparts(4)=LodMesh'UnrealShare.NaliHand1'
	bodyparts(5)=LodMesh'UnrealShare.NaliHand2'
	bodyparts(6)=LodMesh'UnrealShare.NaliHead'

	ZOffset(0)=0.000000
	ZOffset(3)=-0.500000
	ZOffset(6)=0.500000
	LandedSound=Sound'UnrealShare.Nali.thumpn'
	Mesh=LodMesh'UnrealShare.Nali1'
	CollisionRadius=24.000000
	CollisionHeight=48.000000
	Mass=100.000000
	Buoyancy=96.000000
}
