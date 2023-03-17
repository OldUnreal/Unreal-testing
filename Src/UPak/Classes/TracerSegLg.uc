//=============================================================================
// BalefireSegLg.
//=============================================================================
class TracerSegLg expands TracerSeg;

#exec MESH IMPORT MESH=TR025 ANIVFILE=MODELS\TRACER\TR025_a.3d DATAFILE=MODELS\TRACER\TR025_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TR025 X=-279 Y=0 Z=0

#exec MESH SEQUENCE MESH=TR025 SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TR025 SEQ=TR025 STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JTR0251 FILE=MODELS\TRACER\Tracer2.PCX GROUP=Skins FLAGS=2

#exec MESHMAP NEW   MESHMAP=TR025 MESH=TR025
#exec MESHMAP SCALE MESHMAP=TR025 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=TR025 NUM=0 TEXTURE=JTR0251

defaultproperties
{
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=None
	Mesh=LodMesh'TR050'
	DrawScale=8.000000
	bUnlit=True
	CollisionRadius=256.000000
	bCollideWorld=False
}
