//=============================================================================
// BloodTrail.
//=============================================================================
class BloodTrail extends Blood2;

#exec MESH IMPORT MESH=BloodTrl ANIVFILE=Models\Blood2_a.3d DATAFILE=Models\Blood2_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=BloodTrl X=0 Y=0 Z=0 YAW=128
#exec MESH SEQUENCE MESH=BloodTrl SEQ=All       STARTFRAME=0   NUMFRAMES=45
#exec MESH SEQUENCE MESH=BloodTrl SEQ=Spray     STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=BloodTrl SEQ=Still     STARTFRAME=6   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BloodTrl SEQ=GravSpray STARTFRAME=7   NUMFRAMES=5
#exec MESH SEQUENCE MESH=BloodTrl SEQ=Stream    STARTFRAME=12  NUMFRAMES=11
#exec MESH SEQUENCE MESH=BloodTrl SEQ=Trail     STARTFRAME=23  NUMFRAMES=11
#exec MESH SEQUENCE MESH=BloodTrl SEQ=Burst     STARTFRAME=34  NUMFRAMES=2
#exec MESH SEQUENCE MESH=BloodTrl SEQ=GravSpray2 STARTFRAME=36 NUMFRAMES=7

#exec TEXTURE IMPORT NAME=BloodSpot FILE=Models\bloods2.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=BloodSGrn FILE=Models\bloodg2.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=BloodTrl X=0.11 Y=0.055 Z=0.11 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=BloodTrl NUM=0  TEXTURE=BloodSpot

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Trail');
}

function AnimEnd()
{
}

defaultproperties
{
	Physics=PHYS_Trailer
	LifeSpan=5.000000
	AnimSequence=trail
	Mesh=Mesh'UnrealShare.BloodTrl'
	DrawScale=0.200000
	AmbientGlow=0
	bNetTemporary=false
}
