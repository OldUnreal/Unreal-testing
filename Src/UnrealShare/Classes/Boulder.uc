//=============================================================================
// Boulder.
//=============================================================================
class Boulder extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=BoulderM ANIVFILE=Models\rock_a.3d DATAFILE=Models\rock_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BoulderM X=0 Y=0 Z=0 YAW=64

#exec MESH SEQUENCE MESH=BoulderM SEQ=All  STARTFRAME=0  NUMFRAMES=4
#exec MESH SEQUENCE MESH=BoulderM SEQ=Pos1  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BoulderM SEQ=Pos2  STARTFRAME=1   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BoulderM SEQ=Pos3  STARTFRAME=2   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BoulderM SEQ=Pos4  STARTFRAME=3   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JBoulder1 FILE=Models\rock.pcx GROUP=Skins DETAIL=rockde2
#exec MESHMAP SCALE MESHMAP=BoulderM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=BoulderM NUM=1 TEXTURE=JBoulder1

simulated function PostBeginPlay()
{
	local float Decision;

	Super.PostBeginPlay();
	if ( Mesh!=Default.Mesh )
		Return; // Must do this to avoid scriptwarning(s)
	Decision = FRand();
	if (Decision<0.25) PlayAnim('Pos1');
	else if (Decision<0.5) PlayAnim('Pos2');
	else if (Decision<0.75) PlayAnim('Pos3');
	else PlayAnim('Pos4');
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=UnrealShare.BoulderM
	bMeshCurvy=False
	CollisionRadius=+00026.000000
	CollisionHeight=+00016.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bProjTarget=True
	bNoDynamicShadowCast=true
	bNetInterpolatePos=true
}
