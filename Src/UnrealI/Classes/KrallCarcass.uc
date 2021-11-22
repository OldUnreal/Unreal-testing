//=============================================================================
// KrallCarcass.
//=============================================================================
class KrallCarcass extends CreatureCarcass;


#exec MESH IMPORT MESH=KrallHead ANIVFILE=Models\g_krlh_a.3d DATAFILE=Models\g_krlh_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=KrallHead X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=KrallHead SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrallHead SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgkrl1  FILE=Models\g_kral1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=KrallHead X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=KrallHead NUM=1 TEXTURE=Jgkrl1

#exec MESH IMPORT MESH=KrallWeapon ANIVFILE=Models\g_krlw_a.3d DATAFILE=Models\g_krlw_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=KrallWeapon X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=KrallWeapon SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrallWeapon SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgkrl0  FILE=Models\g_kral0.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=KrallWeapon X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=KrallWeapon NUM=1 TEXTURE=Jgkrl0

#exec MESH IMPORT MESH=KrallFoot ANIVFILE=Models\g_krlf_a.3d DATAFILE=Models\g_krlf_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=KrallFoot X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=KrallFoot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrallFoot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgkrl0  FILE=Models\g_kral0.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=KrallFoot X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=KrallFoot NUM=1 TEXTURE=Jgkrl0

#exec MESH IMPORT MESH=KrallPiece ANIVFILE=Models\g_krlf_a.3d DATAFILE=Models\g_krlf_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=KrallPiece X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=KrallPiece SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrallPiece SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgkrl0  FILE=Models\g_kral0.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=KrallPiece X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=KrallPiece NUM=1 TEXTURE=Jgkrl0

#exec MESH IMPORT MESH=KrallHand ANIVFILE=Models\g_krlz_a.3d DATAFILE=Models\g_krlz_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=KrallHand X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=KrallHand SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrallHand SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jgkrl1  FILE=Models\g_kral1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=KrallHand X=0.09 Y=0.09 Z=0.18
#exec MESHMAP SETTEXTURE MESHMAP=KrallHand NUM=1 TEXTURE=Jgkrl1

function ForceMeshToExist()
{
	//never called
	Spawn(class 'Krall');
}

static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Dead5') && (N == 4) )
		return false;
	if ( (A == 'LeglessDeath') && (N == 2) )
		return false;

	return true;
}

function InitFor(actor Other)
{
	Super.InitFor(Other);
	if ( AnimSequence == 'LeglessDeath' )
		SetCollision(true, false, false);
}

defaultproperties
{
	bodyparts(0)=UnrealI.KrallWeapon
	bodyparts(1)=UnrealI.KrallHand
	bodyparts(2)=UnrealI.KrallFoot
	bodyparts(3)=UnrealI.KrallPiece
	bodyparts(4)=UnrealI.KrallHead
	Mesh=KrallM
	Mass=+00140.000000
	Buoyancy=+00130.000000
	style=STY_Masked
}
