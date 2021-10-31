//=============================================================================
// WoodenBox.
//=============================================================================
class WoodenBox extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec AUDIO IMPORT FILE="Sounds\General\bPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"

#exec OBJ COLLISIONBRUSH FILE="Collision\BoxModel.t3d" NAME=BoxCollisionShape
#exec MESH IMPORT MESH=WoodenBoxM ANIVFILE="Models\Box_a.3d" DATAFILE="ModelsFX\Box_d.3d" X=0 Y=0 Z=0 FLAT=1
#exec MESH COLLISION MESH=WoodenBoxM MODEL=BoxCollisionShape
#exec MESH ORIGIN MESH=WoodenBoxM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=WoodenBoxM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=WoodenBoxM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JWoodenBox1 FILE=Models\Box.pcx GROUP=Skins Specular=0.5 DETAIL=wood2 SurfaceType=EST_Wood
#exec MESHMAP SCALE MESHMAP=WoodenBoxM X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=WoodenBoxM NUM=1 TEXTURE=JWoodenBox1

var() int Health;
var() int FragChunks;
var() Float Fragsize;

function PreBeginPlay()
{
	// some boxes will float (randomly)
	if ( Buoyancy == Default.Buoyancy)
		Buoyancy = Mass * (0.9 + 0.6 * FRand());

	Super.PreBeginPlay();
}

Auto State Animate
{

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
	Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		Instigator = InstigatedBy;
		if (Health<0) Return;
		if ( Instigator != None )
			MakeNoise(1.0);
		bBobbing = false;
		Health -= NDamage;
		if (Health <0)
			Frag(Class'WoodFragments',Momentum,FragSize,FragChunks);
		else
		{
			SetPhysics(PHYS_Falling);
			Momentum.Z = 1000;
			Velocity=Momentum*0.016;
		}
	}
}

defaultproperties
{
	Health=20
	FragChunks=12
	Fragsize=1.750000
	bPushable=True
	PushSound=Sound'UnrealShare.General.ObjectPush'
	EndPushSound=Sound'UnrealShare.General.Endpush'
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.WoodenBoxM'
	CollisionRadius=29.000000
	CollisionHeight=26.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	Mass=50.000000
	bOrientToGround=true
	bNetInterpolatePos=true
}