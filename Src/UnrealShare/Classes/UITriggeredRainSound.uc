//==============================================================
// TriggeredRainSound
//==============================================================
// Designed for Weather Simulation System.
// It play's rain sound when raining.
//==============================================================
// by Raven
class UITriggeredRainSound extends UIWeather;

#exec TEXTURE IMPORT NAME=RainS FILE="Textures\Icons\RainS.bmp" GROUP=Icons LODSET=2

var(RainSound) sound RainSound;
var(RainSound) sound EndRainSound;

simulated function AssignRain(bool IsRaining)
{
	if (IsRaining==true)
	{
		AmbientSound=RainSound;
	}
	else
	{
		if (EndRainSound != none)PlaySound(EndRainSound);
		AmbientSound=none;
	}
}

defaultproperties
{
	DrawType=DT_Sprite
	bHidden=True
	Texture=Texture'UnrealShare.Icons.RainS'
	SoundRadius=64
	SoundVolume=190
}
