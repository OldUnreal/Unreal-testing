//=============================================================================
// Stomach.
//=============================================================================
class Stomach extends PlayerChunks;

#exec MESH IMPORT MESH=stomachM ANIVFILE=Models\g_stm_a.3d DATAFILE=Models\g_stm_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=stomachM X=0 Y=0 Z=0 YAW=64 PITCH=128
#exec MESH SEQUENCE MESH=stomachM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=stomachM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jparts1  FILE=Models\g_parts.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=stomachM X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=stomachM NUM=1 TEXTURE=Jparts1
defaultproperties
{
	Mesh=StomachM
	CollisionRadius=+00007.000000
	CollisionHeight=+00003.000000
}
