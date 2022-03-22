//=============================================================================
// EscapePod.
//=============================================================================
class EscapePod extends Decoration;

#exec MESH IMPORT MESH=Escapep ANIVFILE=Models\Escape_a.3d DATAFILE=Models\Escape_d.3d X=0 Y=0 Z=0 LODSTYLE=8 LODFRAME=1 MLOD=1
#exec MESH LODPARAMS MESH=Escapep STRENGTH=1.0 MINVERTS=42 MORPH=0.3 ZDISP=800.0
#exec MESH ORIGIN MESH=Escapep X=0 Y=100 Z=0 YAW=64
#exec MESH SEQUENCE MESH=Escapep SEQ=All    STARTFRAME=0   NUMFRAMES=5
#exec MESH SEQUENCE MESH=Escapep SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Escapep SEQ=Flame  STARTFRAME=1   NUMFRAMES=4
#exec TEXTURE IMPORT NAME=JEscapep1 FILE=Models\escape.pcx GROUP=Skins DETAIL=Metal
#exec MESHMAP SCALE MESHMAP=Escapep X=0.5 Y=0.5 Z=1.0
#exec MESHMAP SETTEXTURE MESHMAP=Escapep NUM=1 TEXTURE=JEscapep1 TLOD=10
#exec MESHMAP SETTEXTURE MESHMAP=Escapep NUM=0 TEXTURE=UnrealShare.Skins.JFlameball1

function Trigger( actor Other, pawn EventInstigator )
{
	if (bStatic || bDeleteme)
		return;
	SetPHysics(PHYS_Projectile);
	Velocity = Vect(0,0,50.0);
	LoopAnim('Flame',20.0);
	SetTimer(15.0,False);
}

function Timer()
{
	Destroy();
}

defaultproperties
{
	bStatic=False
	bDirectional=True
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Escapep'
	bNoDynamicShadowCast=true
	bNetInterpolatePos=true
}