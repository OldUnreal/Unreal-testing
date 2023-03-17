//=============================================================================
// Lamp1.
//=============================================================================
class Lamp1 extends Decoration;

#exec TEXTURE IMPORT NAME=JLamp11HD FILE=Models\lamp1.pcx GROUP="HD" FLAGS=2 DETAIL=Metal
#exec TEXTURE IMPORT NAME=JLamp11 FILE=Models\lamp1_old.pcx GROUP=Skins FLAGS=2 DETAIL=Metal HD=JLamp11HD

#exec MESH IMPORT MESH=Lamp1M ANIVFILE=Models\Lamp1_a.3d DATAFILE=Models\Lamp1_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

#exec MESH LODPARAMS MESH=Lamp1M STRENGTH=2.0 MINVERTS=35 MORPH=0.0 ZDISP=1200.0
#exec MESH ORIGIN MESH=Lamp1M X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH LODPARAMS MESH=Lamp1M STRENGTH=0.5
#exec MESH SEQUENCE MESH=Lamp1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lamp1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=Lamp1M MESH=Lamp1M
#exec MESHMAP SCALE MESHMAP=Lamp1M X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=Lamp1M NUM=0 TEXTURE=Jlamp11
#exec MESHMAP SETTEXTURE MESHMAP=Lamp1M NUM=1 TEXTURE=Jlamp11 TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Lamp1M'
	CollisionRadius=16.000000
	CollisionHeight=76.000000
	bCollideActors=True
	bCollideWorld=True
}
