//=============================================================================
// Urn
//=============================================================================
class Urn extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec TEXTURE IMPORT NAME=JUrn1HD FILE=Models\urn.pcx GROUP="HD" FLAGS=2 DETAIL=Metal
#exec TEXTURE IMPORT NAME=JUrn1 FILE=Models\urn_old.pcx GROUP=Skins FLAGS=2 DETAIL=Metal HD=JUrn1HD

#exec MESH IMPORT MESH=UrnM ANIVFILE=MODELS\Urn_a.3d DATAFILE=MODELS\Urn_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=UrnM X=-113 Y=0 Z=0 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=UrnM STRENGTH=0.5
#exec MESH SEQUENCE MESH=UrnM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=UrnM SEQ=STILL STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=UrnM MESH=UrnM
#exec MESHMAP SCALE MESHMAP=UrnM X=0.01875 Y=0.01875 Z=0.0375
#exec MESHMAP SETTEXTURE MESHMAP=UrnM NUM=1 TEXTURE=JUrn1

auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		skinnedFrag(class'Fragment1', texture'JUrn1', Momentum,0.5, 5);
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
	}
Begin:
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.UrnM'
	CollisionRadius=19.000000
	CollisionHeight=11.000000
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
	Mass=100.000000
}
