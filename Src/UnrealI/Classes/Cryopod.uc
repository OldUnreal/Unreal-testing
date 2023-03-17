//=============================================================================
// Cryopod.
//=============================================================================
class Cryopod extends Decoration;

#exec TEXTURE IMPORT NAME=JCryopod1HD FILE=Models\cryo.pcx GROUP="HD" DETAIL=Metal
#exec TEXTURE IMPORT NAME=JCryopod1 FILE=Models\cryo_old.pcx GROUP=Skins DETAIL=Metal HD=JCryopod1HD

#exec MESH IMPORT MESH=CryopodM ANIVFILE=Models\cryo_a.3d DATAFILE=ModelsFX\cryo_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1
#exec MESH LODPARAMS MESH=CryopodM STRENGTH=1.0 MINVERTS=3 MORPH=0.1 ZDISP=800.0
#exec MESH ORIGIN MESH=CryopodM X=0 Y=0 Z=-220 YAW=64
#exec MESH SEQUENCE MESH=CryopodM SEQ=All  STARTFRAME=0  NUMFRAMES=22
#exec MESH SEQUENCE MESH=CryopodM SEQ=Close STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=CryopodM SEQ=Open STARTFRAME=11 NUMFRAMES=11
#exec MESHMAP SCALE MESHMAP=CryopodM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=CryopodM NUM=1 TEXTURE=JCryopod1 TLOD=10

var() Sound CryoOpen;
var() Sound CryoClose;

Auto State CryoPodState
{

	function Trigger( actor Other, pawn EventInstigator )
	{
		if (AnimSequence=='Close')
			GotoState( 'CryoPodState','Open');
		else
			GotoState( 'CryoPodState','Close');
	}

Open:
	Disable('Trigger');
	PlayAnim('Open',0.4);
	PlaySound(CryoOpen,SLOT_Misc,1.0);
	FinishAnim();
	Enable('Trigger');
	Stop;

Close:
	Disable('Trigger');
	PlayAnim('Close',0.4);
	PlaySound(CryoClose,SLOT_Misc,1.0);
	FinishAnim();
	Sleep(1.0);
	Enable('Trigger');
	Stop;

Begin:
	PlayAnim('Close',0.4);
}

// New 227 func:
function Reset()
{
	PlayAnim('Close',2);
}

defaultproperties
{
	bStatic=False
	bDirectional=True
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.CryopodM'
	CollisionRadius=40.000000
	bCollideActors=True
}
