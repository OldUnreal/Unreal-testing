//=============================================================================
// Leg1.
//=============================================================================
class Leg1 extends PlayerChunks;


#exec MESH IMPORT MESH=leg1M ANIVFILE=Models\g_leg1_a.3d DATAFILE=Models\g_leg1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=leg1M X=0 Y=0 Z=-160 YAW=64
#exec MESH SEQUENCE MESH=leg1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=leg1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jleg11  FILE=Models\g_leg.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=leg1M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=leg1M NUM=1 TEXTURE=Jleg11
defaultproperties
{
	Mesh=Leg1M
	CollisionRadius=+00025.000000
	CollisionHeight=+00006.000000
}
