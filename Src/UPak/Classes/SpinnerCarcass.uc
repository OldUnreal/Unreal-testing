//=============================================================================
// SpinnerCarcass.
//=============================================================================
class SpinnerCarcass expands CreatureCarcass;

#exec MESH IMPORT MESH=SpinnerHead ANIVFILE=MODELS\Spinner\gib-torso_a.3D DATAFILE=MODELS\Spinner\gib-torso_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerHead X=0 Y=0 Z=-20 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerHead SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerHead SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=JGSpinner1  FILE=MODELS\Spinner\gib-torso1.PCX GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=JGSpinner2  FILE=MODELS\Spinner\gib-torso2.PCX GROUP=Skins // head4T6y
#exec MESHMAP NEW   MESHMAP=SpinnerHead MESH=SpinnerHead
#exec MESHMAP SCALE MESHMAP=SpinnerHead X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerHead NUM=1 TEXTURE=JGSpinner1
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerHead NUM=2 TEXTURE=JGSpinner2

#exec MESH IMPORT MESH=SpinnerBody ANIVFILE=MODELS\Spinner\gib-torso-02_a.3D DATAFILE=MODELS\Spinner\gib-torso-02_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerBody X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerBody SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerBody SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerBody MESH=SpinnerBody
#exec MESHMAP SCALE MESHMAP=SpinnerBody X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerBody NUM=1 TEXTURE=JGSpinner1

#exec MESH IMPORT MESH=SpinnerClaw ANIVFILE=MODELS\Spinner\gib-claw-lf_a.3d DATAFILE=MODELS\Spinner\gib-claw-lf_d.3d X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerClaw X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerClaw SEQ=All         STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerClaw SEQ=SpinnerClaw STARTFRAME=0 NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerClaw MESH=SpinnerClaw
#exec MESHMAP SCALE MESHMAP=SpinnerClaw X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerClaw NUM=1 TEXTURE=JGSpinner1

#exec MESH IMPORT MESH=SpinnerLeg1 ANIVFILE=MODELS\Spinner\gib-leg-01_a.3D DATAFILE=MODELS\Spinner\gib-leg-01_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg1 X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerLeg1 SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerLeg1 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerLeg1 MESH=SpinnerLeg1
#exec MESHMAP SCALE MESHMAP=SpinnerLeg1 X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg1 NUM=1 TEXTURE=JGSpinner1

#exec MESH IMPORT MESH=SpinnerLeg2 ANIVFILE=MODELS\Spinner\gib-leg-02_a.3D DATAFILE=MODELS\Spinner\gib-leg-02_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg2 X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerLeg2 SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerLeg2 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerLeg2 MESH=SpinnerLeg2
#exec MESHMAP SCALE MESHMAP=SpinnerLeg2 X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg2 NUM=1 TEXTURE=JGSpinner1

#exec MESH IMPORT MESH=SpinnerLeg3 ANIVFILE=MODELS\Spinner\gib-leg-03_a.3D DATAFILE=MODELS\Spinner\gib-leg-03_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg3 X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerLeg3 SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerLeg3 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerLeg3 MESH=SpinnerLeg3
#exec MESHMAP SCALE MESHMAP=SpinnerLeg3 X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg3 NUM=1 TEXTURE=JGSpinner1

#exec MESH IMPORT MESH=SpinnerLeg4 ANIVFILE=MODELS\Spinner\gib-leg-04_a.3D DATAFILE=MODELS\Spinner\gib-leg-04_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg4 X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerLeg4 SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerLeg4 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerLeg4 MESH=SpinnerLeg4
#exec MESHMAP SCALE MESHMAP=SpinnerLeg4 X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg4 NUM=1 TEXTURE=JGSpinner1

#exec MESH IMPORT MESH=SpinnerTail ANIVFILE=MODELS\Spinner\gib-tail_a.3D DATAFILE=MODELS\Spinner\gib-tail_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerTail X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=SpinnerTail SEQ=All    STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SpinnerTail SEQ=Still  STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP NEW   MESHMAP=SpinnerTail MESH=SpinnerTail
#exec MESHMAP SCALE MESHMAP=SpinnerTail X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=SpinnerTail NUM=1 TEXTURE=JGSpinner2

function ForceMeshToExist()
{
	//never called
	Spawn( class 'Spinner' );
}

function InitFor( actor Other )
{
	Super.InitFor( Other );
	if( AnimSequence == 'Death5' )
		bodyparts[7]=None;
}

defaultproperties
{
	bodyparts(0)=LodMesh'SpinnerBody'
	bodyparts(1)=LodMesh'SpinnerTail'
	bodyparts(2)=LodMesh'SpinnerLeg1'
	bodyparts(3)=LodMesh'SpinnerLeg2'
	bodyparts(4)=LodMesh'SpinnerLeg3'
	bodyparts(5)=LodMesh'SpinnerLeg4'
	bodyparts(6)=LodMesh'SpinnerClaw'
	bodyparts(7)=LodMesh'SpinnerHead'
	ZOffset(1)=0.750000
	ZOffset(2)=0.250000
	ZOffset(3)=0.250000
	ZOffset(4)=0.250000
	ZOffset(5)=0.250000
	ZOffset(7)=0.500000
	bGreenBlood=True
	AnimSequence=Death
	Mesh=LodMesh'Spinner'
	CollisionRadius=32.000000
	CollisionHeight=22.000000
	Mass=100.000000
	Buoyancy=100.000000
}
