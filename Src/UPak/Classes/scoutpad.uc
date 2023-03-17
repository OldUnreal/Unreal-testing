//=============================================================================
// scoutpad.
//=============================================================================
class scoutpad expands Decoration;

#exec MESH IMPORT MESH=scoutpad ANIVFILE=MODELS\SCOUTC\scoutpad_a.3d DATAFILE=MODELS\SCOUTC\scoutpad_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=scoutpad STRENGTH=0.0

#exec MESH ORIGIN MESH=scoutpad X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=scoutpad SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=scoutpad SEQ=SCOUTPAD STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jscoutpad1 FILE=MODELS\SCOUTC\scoutpad01.PCX GROUP=Skins FLAGS=2 // mat1

#exec MESHMAP NEW   MESHMAP=scoutpad MESH=scoutpad
#exec MESHMAP SCALE MESHMAP=scoutpad X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=scoutpad NUM=1 TEXTURE=Jscoutpad1

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'scoutpad'
}
