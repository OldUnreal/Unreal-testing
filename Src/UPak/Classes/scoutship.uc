//=============================================================================
// scout.
//=============================================================================
class scoutship expands Decoration;

#exec MESH IMPORT MESH=scout ANIVFILE=MODELS\SCOUTC\scout_a.3d DATAFILE=MODELS\SCOUTC\scout_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=scout STRENGTH=0.0

#exec MESH ORIGIN MESH=scout X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=scout SEQ=All   STARTFRAME=0 NUMFRAMES=4
#exec MESH SEQUENCE MESH=scout SEQ=scout STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE MESH=scout SEQ=crash STARTFRAME=2 NUMFRAMES=2

#exec TEXTURE IMPORT NAME=Jscout1 FILE=MODELS\SCOUTC\scout01.PCX GROUP=Skins FLAGS=2 // copter2
#exec TEXTURE IMPORT NAME=Jscout2 FILE=MODELS\SCOUTC\glass01.PCX GROUP=Skins // glass02

#exec MESHMAP NEW   MESHMAP=scout MESH=scout
#exec MESHMAP SCALE MESHMAP=scout X=4.5 Y=4.5 Z=9.0

#exec MESHMAP SETTEXTURE MESHMAP=scout NUM=1 TEXTURE=Jscout1
#exec MESHMAP SETTEXTURE MESHMAP=scout NUM=2 TEXTURE=Jscout2

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Scout'
}
