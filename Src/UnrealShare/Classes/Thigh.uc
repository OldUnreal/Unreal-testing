//=============================================================================
// Thigh.
//=============================================================================
class Thigh extends PlayerChunks;

#exec MESH IMPORT MESH=ThighM ANIVFILE=Models\g_pleg_a.3d DATAFILE=Models\g_pleg_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ThighM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=ThighM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ThighM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jparts1  FILE=Models\g_parts.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=ThighM X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=ThighM NUM=1 TEXTURE=Jparts1
defaultproperties
{
	Mesh=ThighM
	CollisionRadius=+00006.000000
	CollisionHeight=+00003.000000
}
