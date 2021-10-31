//=============================================================================
// Chair.
//=============================================================================
class Chair extends Decoration;

#exec MESH IMPORT MESH=Chair1 ANIVFILE=Models\chair_a.3d DATAFILE=Models\chair_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Chair1 X=0 Y=0 Z=0 ROLL=-64
#exec MESH LODPARAMS MESH=Chair1 STRENGTH=0.5
#exec MESH SEQUENCE MESH=Chair1 SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JChair11 FILE=Models\chair.pcx GROUP="Skins" DETAIL=Wood2
#exec MESHMAP SCALE MESHMAP=Chair1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=Chair1 NUM=1 TEXTURE=JChair11

var() int Health;
var() int FragChunks;
var() Float Fragsize;

Auto State Animate
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
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
	Health=15
	FragChunks=9
	Fragsize=1.200000
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Chair1'
	CollisionRadius=17.000000
	CollisionHeight=15.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
}

