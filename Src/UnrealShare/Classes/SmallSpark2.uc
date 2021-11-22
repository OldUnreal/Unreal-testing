//=============================================================================
// SmallSpark2.
//=============================================================================
class SmallSpark2 extends SmallSpark;

#exec MESH IMPORT MESH=SmallSpark2M ANIVFILE=Models\Spark2_a.3d DATAFILE=Models\Spark2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SmallSpark2M X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=SmallSpark2M SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SmallSpark2M SEQ=Explosion STARTFRAME=0   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=JSmlSpark1 FILE=Models\Spark.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=SmallSpark2M X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SmallSpark2M NUM=1 TEXTURE=JSmlSpark1

defaultproperties
{
	Mesh=UnrealShare.SmallSpark2M
}
