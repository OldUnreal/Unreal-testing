//=============================================================================
// PHeart.
//=============================================================================
class PHeart extends PlayerChunks;

#exec MESH IMPORT MESH=PHeartM ANIVFILE=Models\heartg_a.3d DATAFILE=Models\heartg_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PHeartM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=PHeartM SEQ=All    STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=PHeartM SEQ=Beat  STARTFRAME=0   NUMFRAMES=6
#exec TEXTURE IMPORT NAME=Jmisc1 FILE=Models\misc.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=PHeartM X=0.015 Y=0.015 Z=0.03
#exec MESHMAP SETTEXTURE MESHMAP=PHeartM NUM=1 TEXTURE=Jmisc1

auto state Dying
{
Begin:
	if( Mesh && HasAnim('Beat') )
		LoopAnim('Beat', 0.2);
	Sleep(0.1);
	GotoState('Dead');
}

defaultproperties
{
	Mesh=PHeartM
	CollisionRadius=+00014.000000
	CollisionHeight=+00003.000000
}
