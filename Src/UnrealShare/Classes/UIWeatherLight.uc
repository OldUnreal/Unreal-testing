//==============================================================
// Weather Light
//==============================================================
// Light designed specially for Weather Simulation System :)
//==============================================================
// by Raven
class UIWeatherLight extends UIWeather;

#exec TEXTURE IMPORT NAME=WeatherLightIc FILE="Textures\Icons\We_Light.pcx" GROUP=Icons LODSET=2 FLAGS=2

var() bool bSmoothFadeLight;
var() float LightFadingSleep;

var byte BrightnessBck;
var byte AdBr,DcBr;
var int kl;
var float SlpTime;

simulated function BeginPlay()
{
	DrawType = DT_None;
}

simulated function AddBrightness()
{
	AdBr=BrightnessBck;
	if (bSmoothFadeLight)
	{
		GoToState('AddBrightnessState');
		return;
	}
	LightBrightness=BrightnessBck;
}

simulated function DecBrightness(byte BRH)
{
	if (BRH > LightBrightness) return;

	BrightnessBck=LightBrightness;

	DcBr=BRH;

	if (bSmoothFadeLight)
	{
		GoToState('DecBrightnessState');
		return;
	}

	LightBrightness=BRH;
}

simulated State Idle
{
}

simulated State AddBrightnessState
{
	simulated function EndState()
	{
		LightBrightness=AdBr;
	}
Begin:
	if (AdBr > LightBrightness)
	{
		for (kl=LightBrightness; kl<AdBr; kl++)
		{
			LightBrightness++;
			Sleep(LightFadingSleep);
		}
	}
	GoToState('Idle');
}

simulated State DecBrightnessState
{
	simulated function EndState()
	{
		LightBrightness=DcBr;
	}
Begin:
	if (DcBr < LightBrightness)
	{
		for (kl=LightBrightness; kl>DcBr; kl--)
		{
			LightBrightness--;
			Sleep(LightFadingSleep);
		}
	}
	GoToState('Idle');
}
defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bStatic=False
	bStasis=false
	bMovable=True
	bNoDelete=True
	Texture=Texture'UnrealShare.Icons.WeatherLightIc'
	CollisionRadius=24.000000
	CollisionHeight=24.000000
	LightType=LT_Steady
	LightBrightness=64
	LightSaturation=255
	LightRadius=64
	LightPeriod=32
	LightCone=128
	VolumeBrightness=64
	DrawType=DT_Sprite
	bHidden=false

	bSmoothFadeLight=false
	LightFadingSleep=0.01
}
