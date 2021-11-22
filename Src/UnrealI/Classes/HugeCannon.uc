//=============================================================================
// HugeCannon.
//=============================================================================
class HugeCannon extends Cannon;

#exec MESH IMPORT MESH=HugeCannonM ANIVFILE=Models\Cannon_a.3d DATAFILE=Models\Cannon_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=HugeCannonM X=0 Y=270 Z=0 YAW=-64 ROLL=-64
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=All  STARTFRAME=0  NUMFRAMES=20
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=Activate STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=Angle0  STARTFRAME=10  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=Angle1  STARTFRAME=11  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=Angle2  STARTFRAME=12  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=Angle3  STARTFRAME=13  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=Angle4  STARTFRAME=14  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=FAngle0  STARTFRAME=15  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=FAngle1  STARTFRAME=16  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=FAngle2  STARTFRAME=17  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=FAngle3  STARTFRAME=18  NUMFRAMES=1
#exec MESH SEQUENCE MESH=HugeCannonM SEQ=FAngle4 STARTFRAME=19  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JCannon1 FILE=Models\Cannon.pcx GROUP=Skins
#exec OBJ LOAD FILE=..\UnrealShare\Textures\fireeffect13.utx PACKAGE=UNREALI.Effect13
#exec MESHMAP SCALE MESHMAP=HugeCannonM X=0.6 Y=0.6 Z=1.2
#exec MESHMAP SETTEXTURE MESHMAP=HugeCannonM NUM=0 TEXTURE=UnrealI.Effect13.FireEffect13
#exec MESHMAP SETTEXTURE MESHMAP=HugeCannonM NUM=1 TEXTURE=JCannon1

defaultproperties
{
	TrackingRate=7000
	Drop=+00220.000000
	Health=+00500.000000
	Mesh=UnrealI.HugeCannonM
	CollisionRadius=+00088.000000
	CollisionHeight=+00088.000000
}
