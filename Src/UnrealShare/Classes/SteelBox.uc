//=============================================================================
// SteelBox.
//=============================================================================
class SteelBox extends Decoration
	DependsOn(WoodenBox);

#exec AUDIO IMPORT FILE="Sounds\General\BPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"

#exec MESH IMPORT MESH=SteelBoxM ANIVFILE=Models\Box_a.3d DATAFILE=ModelsFX\Box_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH COLLISION MESH=SteelBoxM MODEL=BoxCollisionShape
#exec MESH ORIGIN MESH=SteelBoxM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=SteelBoxM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=SteelBoxM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JSteelBox1 FILE=Models\steelBox.pcx GROUP=Skins Specular=1 Diffuse=0.7
#exec MESHMAP SCALE MESHMAP=SteelBoxM X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=SteelBoxM NUM=1 TEXTURE=JSteelBox1


Auto State Animate
{

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
	Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		Instigator = InstigatedBy;
		SetPhysics(PHYS_Falling);
		Momentum.Z = 1000;
		Velocity=Momentum*0.016;
	}
}

defaultproperties
{
	bPushable=True
	PushSound=Sound'UnrealShare.General.ObjectPush'
	EndPushSound=Sound'UnrealShare.General.Endpush'
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.SteelBoxM'
	CollisionRadius=29.000000
	CollisionHeight=26.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	Mass=60.000000
	bOrientToGround=true
	bNetInterpolatePos=true
}