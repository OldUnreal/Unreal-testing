//=============================================================================
// FlameBall.
//=============================================================================
class FlameBall extends Effects
	transient;

#exec MESH IMPORT MESH=flameballM ANIVFILE=Models\flamba_a.3d DATAFILE=Models\flamba_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=flameballM X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=flameballM SEQ=All       STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=flameballM SEQ=Explosion STARTFRAME=0   NUMFRAMES=6
#exec TEXTURE IMPORT NAME=Jflameball1 FILE=Models\flambal.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=flameballM X=.2 Y=0.2 Z=0.4 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=flameballM NUM=1 TEXTURE=Jflameball1

#exec AUDIO IMPORT FILE="Sounds\Flak\Explode1.wav" NAME="Explode1" GROUP="Flak"

var rotator NormUp;

simulated function AnimEnd()
{
	Destroy();
}

auto state Explode
{
	simulated function Tick( float DeltaTime )
	{
		LightBrightness = Max( LightBrightness - 250*DeltaTime, 0 );
	}

	function MakeSound()
	{
		PlaySound (EffectSound1);
		MakeNoise(1.0);
	}

	simulated function BeginState()
	{
		if ( Level.NetMode == NM_DedicatedServer )
			Disable('Tick');
		else
			PlayAnim( 'Explosion', 1 );
		MakeSound();
	}
}

defaultproperties
{
	EffectSound1=UnrealShare.Explode1
	DrawType=DT_Mesh
	Mesh=UnrealShare.FlameBallM
	AmbientGlow=183
	LightType=LT_Steady
	LightBrightness=226
	LightHue=29
	LightSaturation=177
	LightRadius=9
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=+4.0
}
