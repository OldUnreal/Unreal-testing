//by Raven
class UIWeatherSimulator extends UIWeather;

#exec TEXTURE IMPORT NAME=wss FILE="Textures\Icons\wss.bmp" GROUP=Icons LODSET=2

//Storm
var(Weather_Storm) bool bUseStorm;                       // is strom enabled
var(Weather_Storm) bool bAffectLight;                    // should affect lights (class WeatherLight)
var(Weather_Storm) byte StormBrightness;                 // light brightness in storm
var(Weather_Storm) float StormProbability;               // 1.0 - 100% storm
var(Weather_Storm) int StormTime;                        // in seconds
var(Weather_Storm) int MinTimeBetweenStorms;             // in seconds
var(Weather_Storm) name StormEvent;                      // event called when storm begins/ends

//Rain
var(Weather_RainAndSnow) bool bUseRain;
var(Weather_RainAndSnow) float RainProbability;          // 1.0 - 100% rain
var(Weather_RainAndSnow) int RainTime;                   // in seconds
var(Weather_RainAndSnow) int MinTimeBetweenRains;        // in seconds
var(Weather_RainAndSnow) name RainEvent;                 // event called when rain begins/ends
var(Weather_RainAndSnow) bool bRainOnlyInStorm;          // if true, rain will be simulated only when storm

var int PassedRain;
var int PassedStorm;
var int WaitStorm;
var int WaitRain;

replication
{
	reliable if (Role == ROLE_Authority)
		DoRain, DoLight, DoStorm;
}

function DoRain(optional bool bRain)
{
	local UITriggeredRainSound CHTriggeredRainSound;
	local SimulatorAtmospheric SimulatorAtmospheric;

	foreach AllActors(class'UITriggeredRainSound', CHTriggeredRainSound, Event)
	{
		if (CHTriggeredRainSound != none) CHTriggeredRainSound.AssignRain(bRain);
	}
	foreach AllActors(class'SimulatorAtmospheric', SimulatorAtmospheric, Event)
	{
		if (SimulatorAtmospheric != none) SimulatorAtmospheric.SetOn(bRain);
	}
	TriggerEvent(RainEvent,Self,Instigator);
}

function DoLight(bool bStorm)
{
	local UIWeatherLight CHWeatherLight;

	foreach AllActors(class'UIWeatherLight', CHWeatherLight, Event)
	{
		if (CHWeatherLight != none)
		{
			if (bStorm) CHWeatherLight.DecBrightness(StormBrightness);
			else CHWeatherLight.AddBrightness();
		}
	}
}

function DoStorm(bool bStorm)
{
	local UILightningTrigger CHLightningTrigger;

	foreach AllActors(class'UILightningTrigger', CHLightningTrigger, Event)
	{
		if (CHLightningTrigger != none) CHLightningTrigger.Storm(bStorm);
	}
	TriggerEvent(StormEvent,Self,Instigator);
}

auto state MainState
{
Begin:
//storm functions
	if (bUseStorm)
	{
		if (WaitStorm <= 0)
		{
			if (PassedStorm <= 0)
			{
				if (FRand() <= StormProbability)
				{
					PassedStorm=StormTime;
					DoStorm(true);
					if (bAffectLight) DoLight(true);

				}
			}
			else
			{
				PassedStorm--;
				if (PassedStorm <= 0)
				{
					DoStorm(false);
					if (bAffectLight) DoLight(false);
					WaitStorm=MinTimeBetweenStorms;
				}
			}
		}
		else
		{
			WaitStorm--;
		}
	}
//rain functions
	if (bRainOnlyInStorm) GoTo('RainSlave');
	if (bUseRain)
	{
		if (WaitRain <= 0)
		{
			if (PassedRain <= 0)
			{
				if (FRand() <= RainProbability)
				{
					PassedRain=RainTime;
					DoRain(true);
				}
			}
			else
			{
				PassedRain--;
				if (PassedRain <= 0)
				{
					DoRain(false);
					WaitRain=MinTimeBetweenRains;
				}
			}
		}
		else
		{
			WaitRain--;
		}
	}
	if (!bRainOnlyInStorm) GoTo('End');
RainSlave:
	if (bUseRain)
	{
		if (PassedStorm > 0)
		{
			if (WaitRain <= 0)
			{
				if (PassedRain <= 0)
				{
					if (FRand() <= RainProbability)
					{
						PassedRain=RainTime;
						DoRain(true);
					}
				}
				else
				{
					PassedRain--;
					if (PassedRain <= 0)
					{
						DoRain(false);
						WaitRain=MinTimeBetweenRains;
					}
				}
			}
			else
			{
				WaitRain--;
			}
		}
		else
		{
			DoRain(false);
			PassedRain=0;
			WaitRain=0;
		}
	}
End:
	Sleep(1.0);
	GoTo('Begin');
}

defaultproperties
{
	StormProbability=0.4
	RainProbability=0.4
	StormTime=120
	RainTime=120
	MinTimeBetweenRains=200
	MinTimeBetweenStorms=200
	StormBrightness=40
	bAffectLight=true


	DrawType=DT_Sprite
	bHidden=True
	Texture=Texture'UnrealShare.Icons.wss'
}
