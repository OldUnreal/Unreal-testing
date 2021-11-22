//=============================================================================
// FlakShellAmmo.
//=============================================================================
class FlakShellAmmo extends FlakBox;

#exec MESH IMPORT MESH=FlakShAm ANIVFILE=Models\FlakSh_a.3d DATAFILE=Models\FlakSh_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FlakShAm X=0 Y=0 Z=0 ROLL=-64
#exec MESH LODPARAMS MESH=FlakShAm STRENGTH=0.3
#exec MESH SEQUENCE MESH=FlakShAm SEQ=All   STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlakShAm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JFlakShel1 FILE=..\UnrealShare\Models\FlakShel.pcx
#exec MESHMAP SCALE MESHMAP=FlakShAm X=0.2 Y=0.2 Z=0.4
#exec MESHMAP SETTEXTURE MESHMAP=FlakShAm NUM=1 TEXTURE=JFlakShel1

defaultproperties
{
	AmmoAmount=1
	ParentAmmo=UnrealI.FlakBox
	PickupMessage="You got a flak shell."
	PickupViewMesh=UnrealI.FlakShAm
	Mesh=UnrealI.FlakShAm
	CollisionRadius=+00010.000000
	CollisionHeight=+00008.000000
}
