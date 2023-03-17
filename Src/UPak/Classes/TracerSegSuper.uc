//=============================================================================
// BalefireSegSuper.
//=============================================================================
class TracerSegSuper expands TracerSeg;

#exec MESH IMPORT MESH=TR010 ANIVFILE=MODELS\TRACER\TR010_a.3d DATAFILE=MODELS\TRACER\TR010_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TR010 X=-303 Y=0 Z=0

#exec MESH SEQUENCE MESH=TR010 SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TR010 SEQ=TR010 STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JTR0101 FILE=MODELS\TRACER\Tracer2.PCX GROUP=Skins FLAGS=2 

#exec MESHMAP NEW   MESHMAP=TR010 MESH=TR010
#exec MESHMAP SCALE MESHMAP=TR010 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=TR010 NUM=0 TEXTURE=JTR0101

defaultproperties
{
	SegmentType=Class'TracerSegLg'
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=None
	Mesh=LodMesh'TR100'
	DrawScale=16.000000
	bUnlit=True
	CollisionRadius=512.000000
	bCollideWorld=False
}
