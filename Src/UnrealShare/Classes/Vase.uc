//=============================================================================
// Vase.
//=============================================================================
class Vase extends Decoration;

#exec AUDIO IMPORT FILE="Sounds\General\BPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"

#exec TEXTURE IMPORT NAME=Jvase1HD  FILE=Models\vase.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=Jvase1 FILE=Models\vase_old.pcx GROUP=Skins HD=Jvase1HD

#exec MESH IMPORT MESH=vaseM ANIVFILE=Models\Vase_a.3d DATAFILE=Models\Vase_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vaseM X=37 Y=0 Z=0 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=vaseM STRENGTH=0.5
#exec MESH SEQUENCE MESH=vaseM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=vaseM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vaseM X=0.125 Y=0.126 Z=0.253
#exec MESHMAP NEW   MESHMAP=vaseM MESH=vaseM
#exec MESHMAP SETTEXTURE MESHMAP=vaseM NUM=1 TEXTURE=Jvase1



auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
	Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		skinnedFrag(class'Fragment1',texture'JVase1', Momentum,0.7,7);
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
	}

Begin:
}

defaultproperties
{
	bPushable=True
	PushSound=Sound'UnrealShare.General.ObjectPush'
	EndPushSound=Sound'UnrealShare.General.Endpush'
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.vaseM'
	CollisionHeight=28.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	Mass=100.000000
}

