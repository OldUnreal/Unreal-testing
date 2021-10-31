//=============================================================================
// TinyBurst.
//=============================================================================
class TinyBurst extends Effects
	transient;

#exec MESH IMPORT MESH=TBurst ANIVFILE=Models\TBurst_a.3d DATAFILE=Models\TBurst_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TBurst X=0 Y=0 Z=-0 YAW=0 PITCH=-64
#exec MESH SEQUENCE MESH=TBurst SEQ=All        STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=TBurst SEQ=Explosion  STARTFRAME=0   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=Jflakshel1 FILE=Models\FlakShel.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=TBurst X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=TBurst NUM=1 TEXTURE=Jflakshel1

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim   ( 'Explosion', 0.3 );
		PlaySound (EffectSound1);
	}
	MakeNoise  (0.5);
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=TBurst
	AmbientGlow=157
	bUnlit=True
	bNoSmooth=True
	bMeshCurvy=False
	LightType=LT_Steady
	LightBrightness=140
	LightHue=29
	LightSaturation=160
	LightRadius=3
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=+3.0
}
