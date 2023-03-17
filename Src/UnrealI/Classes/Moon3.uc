//=============================================================================
// Moon3.
//=============================================================================
class Moon3 extends Moon;

#exec TEXTURE IMPORT NAME=JMoon3HD FILE=Models\moon3.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=JMoon3 FILE=Models\moon3_old.pcx GROUP=Skins HD=JMoon3HD

#exec MESH IMPORT MESH=Moon3M ANIVFILE=Models\moon_a.3d DATAFILE=Models\moon_d.3d Curvy=1 X=0 Y=0 Z=0 ZEROTEX=1 MLOD=1

// 114 Vertices, 224 Triangles
#exec MESH LODPARAMS MESH=Moon3M STRENGTH=1.0 MINVERTS=70 MORPH=0.3 ZDISP=800.0

#exec MESH ORIGIN MESH=Moon3M X=0 Y=10000 Z=0 YAW=0 ROLL=7
#exec MESH SEQUENCE MESH=Moon3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Moon3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Moon3M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Moon3M NUM=0 TEXTURE=JMoon3 TLOD=10

defaultproperties
{
	Skin=None
	Mesh=LodMesh'UnrealI.Moon3M'
	DrawScale=0.150000
	RotationRate=(Yaw=400,Roll=100)
	DesiredRotation=(Yaw=400,Roll=100)
}
