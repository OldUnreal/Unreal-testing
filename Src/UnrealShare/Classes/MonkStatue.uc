//=============================================================================
// MonkStatue.
//=============================================================================
class MonkStatue extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec TEXTURE IMPORT NAME=JMonkStatue1HD FILE=Models\monk.pcx GROUP="HD" DETAIL=rockde2
#exec TEXTURE IMPORT NAME=JMonkStatue1 FILE=Models\monk_old.pcx GROUP="Skins" DETAIL=rockde2 HD=JMonkStatue1HD

#exec  MESH IMPORT MESH=MonkStatueM ANIVFILE=Models\monk_a.3d DATAFILE=Models\monk_d.3d X=0 Y=0 Z=0 MLOD=1

// 53 Vertices, 102 Triangles
#exec MESH LODPARAMS MESH=MonkStatueM STRENGTH=0.5 MINVERTS=3 MORPH=0.3 ZDISP=1200.0
#exec MESH ORIGIN MESH=MonkStatueM X=0 Y=-55 Z=19 YAW=0 PITCH=0 ROLL=64
#exec MESH SEQUENCE MESH=MonkStatueM SEQ=ALL    STARTFRAME=0 NUMFRAMES=1 
#exec MESH SEQUENCE MESH=MonkStatueM SEQ=Still    STARTFRAME=0 NUMFRAMES=1 
#exec MESHMAP SCALE MESHMAP=MonkStatueM X=0.125 Y=0.125 Z=0.25
#exec MESHMAP SETTEXTURE MESHMAP=MonkStatueM NUM=0 TEXTURE=JMonkStatue1 TLOD=10

#exec AUDIO IMPORT FILE="Sounds\General\bPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"

Auto State Animate
{
	function HitWall (vector HitNormal, actor Wall)
	{
		if (bDeleteme)
			return;
		if (bStatic )
		{
			SetPhysics(PHYS_None);
			bBounce = False;
			return;
		}
		if ( (Velocity.z<-200) && (HitNormal.Z > 0.5)
				|| (Rotation.Pitch>4000) && (Rotation.Pitch<61000) )
			skinnedFrag(class'Fragment1',texture, VRand() * 40000,DrawScale*2.0,20);
		Velocity = 0.8*(( Velocity dot HitNormal ) * HitNormal * (-1.8 + FRand()*0.8) + Velocity);   // Reflect off Wall w/damping
		Velocity.Z = Velocity.Z*0.6;
		If ( (HitNormal.Z > 0.7) && (VSize(Velocity) < 60) )
		{
			SetPhysics(PHYS_None);
			bBounce = False;
		}
	}

	function Timer()
	{
		Global.Timer();
		if (Velocity.z<-80)
		{
			RotationRate.Yaw = 15000;
			RotationRate.Pitch = 15000;
			RotationRate.Roll = 15000;
			bRotatetoDesired=True;
			DesiredRotation.Pitch=16000;
			DesiredRotation.Yaw=0;
			DesiredRotation.Roll=0;
		}
	} 

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
		SetPhysics(PHYS_Falling);
		bBounce = True;
		Momentum.Z = 1000;
		Velocity=Momentum*0.01;
		SetTimer(0.4,False);
	}
}

function Bump( Actor Other )
{
	if (bStatic || bDeleteme)
		return;
	bBounce = ( bPushable && (Pawn(Other)!=None) );
	if ( bBounce )
		Super.Bump(Other);
}

defaultproperties
{
	bPushable=True
	PushSound=Sound'UnrealShare.General.ObjectPush'
	EndPushSound=Sound'UnrealShare.General.Endpush'
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.MonkStatueM'
	CollisionHeight=88.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bBounce=True
	Mass=100.000000
	Buoyancy=1.000000
	bBlockRigidBodyPhys=true
}