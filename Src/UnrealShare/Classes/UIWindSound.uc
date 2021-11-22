//by Raven
class UIWindSound extends UIWeather;

#exec TEXTURE IMPORT NAME=WindS FILE="Textures\Icons\WndS.bmp" GROUP=Icons LODSET=2 FLAGS=2

var() sound StartWind, StopWind, LoopWind;

auto state idle
{
Begin:
}

state WindOn
{
Begin:
	if (StartWind != none) PlaySound(StartWind);
	if (LoopWind != none) AmbientSound=LoopWind;
	GoToState('Idle');
}

state WindOff
{
Begin:
	if (LoopWind != none) AmbientSound=none;
	if (StopWind != none) PlaySound(StopWind);
	GoToState('Idle');
}

defaultproperties
{
	Texture=Texture'UnrealShare.Icons.WindS'
	DrawType=DT_Sprite
}
