//=============================================================================
// SpikeExplosion.
//=============================================================================
class SpikeExplosion extends Effects
	transient;

#exec MESH IMPORT MESH=SpikeExp ANIVFILE=Models\exp1_a.3d DATAFILE=Models\Exp1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SpikeExp X=0 Y=0 Z=-260 YAW=-64
#exec MESH SEQUENCE MESH=SpikeExp SEQ=All       STARTFRAME=0   NUMFRAMES=7
#exec MESH SEQUENCE MESH=SpikeExp SEQ=Explo     STARTFRAME=0   NUMFRAMES=7
#exec MESHMAP SCALE MESHMAP=SpikeExp X=0.03 Y=0.03 Z=0.06
#exec OBJ LOAD FILE=Textures\fireeffect15.utx PACKAGE=UnrealShare.Effect15
#exec MESHMAP SETTEXTURE MESHMAP=SpikeExp NUM=1 TEXTURE=UnrealShare.Effect15.FireEffect15

auto simulated state Exploding
{
	simulated function Tick( float DeltaTime )
	{
		LightBrightness = Max( LightBrightness - 250*DeltaTime, 0 );
	}
Begin:
	PlayAnim  ( 'Explo', 0.9 );
	PlaySound (EffectSound1);
	MakeNoise ( 1.0 );
	FinishAnim();
	Destroy   ();
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=UnrealShare.SpikeExp
	bUnlit=True
	bMeshCurvy=False
	CollisionRadius=+00000.000000
	CollisionHeight=+00000.000000
	Physics=PHYS_None
	LifeSpan=0.3
	RemoteRole=ROLE_SimulatedProxy
}
