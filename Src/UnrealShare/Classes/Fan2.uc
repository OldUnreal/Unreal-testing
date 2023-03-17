//=============================================================================
// Fan2.
//=============================================================================
class Fan2 extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=Fan2M ANIVFILE=Models\Fan2_a.3d DATAFILE=ModelsFX\Fan2_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1
#exec MESH LODPARAMS MESH=Fan2M STRENGTH=0.5 MINVERTS=15 MORPH=0.3 ZDISP=1200.0
#exec MESH ORIGIN MESH=Fan2M X=0 Y=-300 Z=0 YAW=64
#exec MESH SEQUENCE MESH=fan2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=fan2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JFan21HD FILE=Models\Fan2.pcx GROUP="HD" FLAGS=2 DETAIL=Metal
#exec TEXTURE IMPORT NAME=JFan21 FILE=Models\Fan2_old.pcx GROUP=Skins FLAGS=2 DETAIL=Metal HD=JFan21HD

#exec MESHMAP SCALE MESHMAP=Fan2M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=fan2M NUM=1 TEXTURE=Jfan21


auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
		skinnedFrag(class'Fragment1',texture'JFan21', Momentum,2.0, 9);
	}
Begin:
}

defaultproperties
{
	bStatic=False
	Physics=PHYS_Rotating
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Fan2M'
	CollisionRadius=44.000000
	CollisionHeight=44.000000
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
	bFixedRotationDir=True
	RotationRate=(Roll=20000)
	DesiredRotation=(Roll=1)
}

