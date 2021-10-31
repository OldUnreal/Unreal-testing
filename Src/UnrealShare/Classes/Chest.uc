//=============================================================================
// Chest.
//=============================================================================
class Chest extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=ChestM ANIVFILE=Models\chest_a.3d DATAFILE=Models\chest_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ChestM X=0 Y=0 Z=16 YAW=64
#exec MESH LODPARAMS MESH=ChestM STRENGTH=0.5
#exec MESH SEQUENCE MESH=ChestM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ChestM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JChest1 FILE=Models\chest.pcx GROUP=Skins DETAIL=wood1h
#exec MESHMAP SCALE MESHMAP=ChestM X=0.05 Y=0.05 Z=0.10
#exec MESHMAP SETTEXTURE MESHMAP=ChestM NUM=1 TEXTURE=JChest1 TLOD=3

var() int Health;
var() int FragChunks;
var() Float Fragsize;


Auto State Still
{
	function HitWall (vector HitNormal, actor Wall)
	{
		SetPhysics(PHYS_None);
		bBounce = False;
	}

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		Instigator = InstigatedBy;
		bBobbing = false;
		if (Health<0) Return;
		if ( Instigator != None )
			MakeNoise(1.0);
		Health -= NDamage;
		if (Health <0)
		{
			Frag(class'WoodFragments',Momentum,FragSize,FragChunks);

		}
		else
		{
			SetPhysics(PHYS_Falling);
			bBounce = True;
			Momentum.Z = 1000;
			Velocity=Momentum*0.016;
		}
	}
Begin:
}

defaultproperties
{
	Health=10
	FragChunks=10
	Fragsize=1.200000
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.ChestM'
	CollisionRadius=28.000000
	CollisionHeight=12.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	Mass=10.000000
	NetPriority=0.500000
}
