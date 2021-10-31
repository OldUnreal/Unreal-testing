//=============================================================================
// BallExplosion.
//=============================================================================
class BallExplosion extends Effects
	NoUserCreate;

#exec MESH IMPORT MESH=b1exp ANIVFILE=Models\b1exp_a.3d DATAFILE=Models\b1exp_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=b1exp X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=b1exp SEQ=All       STARTFRAME=0   NUMFRAMES=11
#exec MESH SEQUENCE MESH=b1exp SEQ=Explo     STARTFRAME=0   NUMFRAMES=11
#exec MESHMAP SCALE MESHMAP=b1exp X=0.3 Y=0.3 Z=0.6 YAW=128
#exec OBJ LOAD FILE=Textures\fireeffect6.utx PACKAGE=UnrealShare.Effect6
#exec MESHMAP SETTEXTURE MESHMAP=b1exp NUM=1 TEXTURE=UnrealShare.Effect6.FireEffect6

#exec AUDIO IMPORT FILE="Sounds\Flak\expl2.wav" NAME="expl2" GROUP="Flak"

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
		LightBrightness = Max( LightBrightness - 250*DeltaTime, 0 );
}

simulated function PostBeginPlay()
{
	PlayAnim  ( 'Explo', 0.6 );
	MakeSound();
	Super.PostBeginPlay();
}

function MakeSound()
{
	PlaySound (EffectSound1);
	MakeNoise ( 1.0 );
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	EffectSound1=UnrealShare.expl2
	DrawType=DT_Mesh
	Mesh=UnrealShare.b1exp
	AmbientGlow=159
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=192
	LightHue=29
	LightSaturation=177
	LightRadius=9
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
}
