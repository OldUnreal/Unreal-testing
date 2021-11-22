//=============================================================================
// TSmoke.
//=============================================================================
class TSmoke extends Effects
	NoUserCreate;

/*
FIXME JAMES REMOVE?

#exec MESH IMPORT MESH=TSmoke ANIVFILE=Models\Smoke2_a.3d DATAFILE=Models\Smoke2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TSmoke X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=TSmoke SEQ=All   STARTFRAME=0   NUMFRAMES=12
#exec MESH SEQUENCE MESH=TSmoke SEQ=Puff1 STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=TSmoke SEQ=Puff2 STARTFRAME=0  NUMFRAMES=6
#exec MESHMAP SCALE MESHMAP=TSmoke X=0.08 Y=0.08 Z=0.16
#exec TEXTURE IMPORT NAME=TSmk1 FILE=Models\tsmk.pcx  GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=TSmoke NUM=1 TEXTURE=TSmk1
 */

var int PuffNum;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (PuffNum==1) PlayAnim( 'Puff1', 0.2 );
	else if (PuffNum==2) PlayAnim( 'Puff2', 0.2 );
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	DrawType=DT_Mesh
	//Mesh=UnrealShare.TSmoke
	bUnlit=True
	bMeshCurvy=False
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
}