//=============================================================================
// Chunk1.
//=============================================================================
class Chunk1 extends Chunk;

#exec MESH IMPORT MESH=Chnk1 ANIVFILE=Models\Chunk1_a.3d DATAFILE=Models\Chunk1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Chnk1 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=Chnk1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Chnk1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jflakshel1 FILE=..\UnrealShare\Models\FlakShel.pcx
#exec MESHMAP SCALE MESHMAP=Chnk1 X=0.025 Y=0.025 Z=0.05
#exec MESHMAP SETTEXTURE MESHMAP=Chnk1 NUM=1 TEXTURE=Jflakshel1

defaultproperties
{
	Damage=+00016.000000
	Mesh=UnrealI.Chnk1
	AmbientGlow=43
	Class=UnrealI.Chunk1
}
