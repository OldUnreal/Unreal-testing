//=============================================================================
// PredatorCarcass.
//=============================================================================
class PredatorCarcass expands CreatureCarcass;

#exec MESH IMPORT MESH=PredatorBody ANIVFILE=MODELS\Predator\gib-torso_a.3D DATAFILE=MODELS\Predator\gib-torso_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PredatorBody X=0 Y=0 Z=-2 YAW=-64
#exec MESH SEQUENCE MESH=PredatorBody SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PredatorBody SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=JGPredator1  FILE=MODELS\Predator\gib-torso1.PCX GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=JGPredator2  FILE=MODELS\Predator\gib-torso2.PCX GROUP=Skins // head4T6y
#exec MESHMAP NEW   MESHMAP=PredatorBody MESH=PredatorBody
#exec MESHMAP SCALE MESHMAP=PredatorBody X=0.45 Y=0.45 Z=0.90
#exec MESHMAP SETTEXTURE MESHMAP=PredatorBody NUM=1 TEXTURE=JGPredator1
#exec MESHMAP SETTEXTURE MESHMAP=PredatorBody NUM=2 TEXTURE=JGPredator2

#exec MESH IMPORT MESH=PredatorFoot ANIVFILE=MODELS\Predator\gib-foot-rt_a.3D DATAFILE=MODELS\Predator\gib-foot-rt_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PredatorFoot X=0 Y=0 Z=3 YAW=-64
#exec MESH SEQUENCE MESH=PredatorFoot SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PredatorFoot SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=PredatorFoot MESH=PredatorFoot
#exec MESHMAP SCALE MESHMAP=PredatorFoot X=0.45 Y=0.45 Z=0.90
#exec MESHMAP SETTEXTURE MESHMAP=PredatorFoot NUM=1 TEXTURE=JGPredator1
#exec MESHMAP SETTEXTURE MESHMAP=PredatorFoot NUM=2 TEXTURE=JGPredator2

#exec MESH IMPORT MESH=PredatorHead ANIVFILE=MODELS\Predator\gib-head_a.3D DATAFILE=MODELS\Predator\gib-head_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PredatorHead X=0 Y=0 Z=-1 YAW=-64
#exec MESH SEQUENCE MESH=PredatorHead SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PredatorHead SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=PredatorHead MESH=PredatorHead
#exec MESHMAP SCALE MESHMAP=PredatorHead X=0.45 Y=0.45 Z=0.90
#exec MESHMAP SETTEXTURE MESHMAP=PredatorHead NUM=1 TEXTURE=JGPredator1
#exec MESHMAP SETTEXTURE MESHMAP=PredatorHead NUM=2 TEXTURE=JGPredator2

#exec MESH IMPORT MESH=PredatorLeftLeg ANIVFILE=MODELS\Predator\gib-leg-lf_a.3D DATAFILE=MODELS\Predator\gib-leg-lf_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PredatorLeftLeg X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=PredatorLeftLeg SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PredatorLeftLeg SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=PredatorLeftLeg MESH=PredatorLeftLeg
#exec MESHMAP SCALE MESHMAP=PredatorLeftLeg X=0.45 Y=0.45 Z=0.90
#exec MESHMAP SETTEXTURE MESHMAP=PredatorLeftLeg NUM=1 TEXTURE=JGPredator1
#exec MESHMAP SETTEXTURE MESHMAP=PredatorLeftLeg NUM=2 TEXTURE=JGPredator2

#exec MESH IMPORT MESH=PredatorRightLeg ANIVFILE=MODELS\Predator\gib-leg-rt_a.3D DATAFILE=MODELS\Predator\gib-leg-rt_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PredatorRightLeg X=0 Y=0 Z=2 YAW=-64
#exec MESH SEQUENCE MESH=PredatorRightLeg SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PredatorRightLeg SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=PredatorRightLeg MESH=PredatorRightLeg
#exec MESHMAP SCALE MESHMAP=PredatorRightLeg X=0.45 Y=0.45 Z=0.90
#exec MESHMAP SETTEXTURE MESHMAP=PredatorRightLeg NUM=1 TEXTURE=JGPredator1
#exec MESHMAP SETTEXTURE MESHMAP=PredatorRightLeg NUM=2 TEXTURE=JGPredator2

#exec MESH IMPORT MESH=PredatorTail ANIVFILE=MODELS\Predator\gib-tail_a.3D DATAFILE=MODELS\Predator\gib-tail_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PredatorTail X=0 Y=0 Z=-2 YAW=-64
#exec MESH SEQUENCE MESH=PredatorTail SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PredatorTail SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=PredatorTail MESH=PredatorTail
#exec MESHMAP SCALE MESHMAP=PredatorTail X=0.45 Y=0.45 Z=0.90
#exec MESHMAP SETTEXTURE MESHMAP=PredatorTail NUM=1 TEXTURE=JGPredator1
#exec MESHMAP SETTEXTURE MESHMAP=PredatorTail NUM=2 TEXTURE=JGPredator2

function ForceMeshToExist()
{
	//never called
	Spawn( class 'Predator' );
}
function InitFor( actor Other )
{
	Super.InitFor( Other );
	if( AnimSequence == 'Death5' )
		bodyparts[6]=None;
}

defaultproperties
{
	bodyparts(0)=LodMesh'PredatorBody'
	bodyparts(1)=LodMesh'PredatorTail'
	bodyparts(2)=LodMesh'PredatorLeftLeg'
	bodyparts(3)=LodMesh'PredatorRightLeg'
	bodyparts(4)=LodMesh'PredatorFoot'
	bodyparts(5)=LodMesh'CowBody1'
	bodyparts(6)=LodMesh'PredatorHead'
	ZOffset(1)=0.500000
	ZOffset(2)=0.250000
	ZOffset(3)=0.250000
	ZOffset(5)=0.500000
	ZOffset(6)=0.500000
	AnimSequence=Death
	Mesh=LodMesh'Predator'
	CollisionRadius=16.000000
	CollisionHeight=20.000000
	Mass=50.000000
	Buoyancy=50.000000
}
