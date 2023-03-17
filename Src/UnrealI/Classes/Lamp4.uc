//=============================================================================
// Lamp4.
//=============================================================================
class Lamp4 extends Decoration;

#exec TEXTURE IMPORT NAME=JLamp41HD FILE=Models\lamp4.pcx GROUP="HD" FLAGS=2 DETAIL=Pock
#exec TEXTURE IMPORT NAME=JLamp41 FILE=Models\lamp4_old.pcx GROUP=Skins FLAGS=2 DETAIL=Pock HD=JLamp41HD

#exec MESH IMPORT MESH=Lamp4M ANIVFILE=MODELS\Lamp4_a.3d DATAFILE=MODELS\Lamp4_d.3d X=0 Y=0 Z=0 MLOD=1
#exec MESH ORIGIN MESH=Lamp4M X=-83 Y=0 Z=0 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=Lamp4M STRENGTH=0.5
#exec MESH SEQUENCE MESH=Lamp4M SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Lamp4M SEQ=STILL STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=Lamp4M MESH=Lamp4M
#exec MESHMAP SCALE MESHMAP=Lamp4M X=0.1255 Y=0.1255 Z=0.251

#exec MESHMAP SETTEXTURE MESHMAP=Lamp4M NUM=0 TEXTURE=JLamp41

auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
	Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		skinnedFrag(class'Fragment1',texture'JLamp41', Momentum, 0.3, 5);
		if ( Instigator != None )
			MakeNoise(1.0);
	}

Begin:
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Lamp4M'
	CollisionHeight=32.000000
	CollisionRadius=8.00
	bCollideActors=True
	bCollideWorld=True
}
