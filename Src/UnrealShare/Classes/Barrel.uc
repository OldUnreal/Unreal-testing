//=============================================================================
// Barrel.
//=============================================================================
class Barrel extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec AUDIO IMPORT FILE="Sounds\General\BPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"

#exec TEXTURE IMPORT NAME=JBarrel1HD FILE=Models\Barrel.pcx GROUP="HD" FLAGS=2 DETAIL=wood2
#exec TEXTURE IMPORT NAME=JBarrel1 FILE=Models\Barrel_old.pcx GROUP=Skins FLAGS=2 DETAIL=wood2 HD=JBarrel1HD

#exec MESH IMPORT MESH=BarrelM ANIVFILE=Models\Barrel_a.3d DATAFILE=Models\Barrel_d.3d ZEROTEX=1
#exec MESH LODPARAMS MESH=BarrelM STRENGTH=0.5
#exec MESH ORIGIN MESH=BarrelM X=320 Y=160 Z=95 YAW=64
#exec MESH SEQUENCE MESH=BarrelM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BarrelM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=BarrelM X=0.15 Y=0.15 Z=0.3
#exec MESHMAP SETTEXTURE MESHMAP=BarrelM NUM=0 TEXTURE=JBarrel1 TLOD=10

var() int Health;

Auto State Animate
{
	function HitWall (vector HitNormal, actor Wall)
	{
		if ( bDeleteme )
			return;
		if (bStatic )
		{
			SetPhysics(PHYS_None);
			bBounce = False;
			return;
		}
		if (Velocity.Z<-200) TakeDamage(100,Pawn(Owner),HitNormal,HitNormal*10000,'shattered');
		bBounce = False;
		Velocity = vect(0,0,0);
	}
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		if ( bStatic || bDeleteme )
			return;
		Instigator = InstigatedBy;
		bBobbing = false;
		if (Health<0) Return;
		if ( Instigator != None )
			MakeNoise(1.0);
		Health -= NDamage;
		if (Health <0)
			Frag(class'WoodFragments',Momentum,1.75,12);
		else
		{
			SetPhysics(PHYS_Falling);
			bBounce = True;
			Momentum.Z = 1000;
			Velocity=Momentum*0.01;
		}
	}

Begin:
}

defaultproperties
{
	Health=10
	bPushable=True
	PushSound=Sound'UnrealShare.General.ObjectPush'
	EndPushSound=Sound'UnrealShare.General.Endpush'
	bStatic=False
	DrawType=DT_Mesh
	Skin=Texture'UnrealShare.Skins.JBarrel1'
	Mesh=LodMesh'UnrealShare.BarrelM'
	CollisionRadius=24.000000
	CollisionHeight=29.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	Mass=50.000000
	Buoyancy=60.000000
	bNetInterpolatePos=true
}