//=============================================================================
// SmokeTrail.
//=============================================================================
class SmokeTrail extends Effects
	NoUserCreate;

#exec MESH IMPORT MESH=SmoketrailM ANIVFILE=Models\Smoke1_a.3d DATAFILE=Models\Smoke1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SmoketrailM X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SmoketrailM SEQ=All     STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=SmoketrailM X=0.2 Y=0.2 Z=0.4 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=SmoketrailM NUM=0 TEXTURE=DefaultTexture

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=UnrealShare.SmokeTrailM
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	RemoteRole=ROLE_SimulatedProxy
}
