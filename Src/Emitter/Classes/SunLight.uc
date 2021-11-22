// Sunlight actor.
Class SunLight extends DistantLightActor;

#exec Texture Import File="Textures\SunIcon.pcx" Name="SunIcon" GROUP="Icons" Mips=Off Flags=2

defaultproperties
{
	NewLightRadius=98304
	bDirectional=True
	LightEffect=LE_Sunlight
	DrawScale=2
	Texture=Texture'SunIcon'
	LightRadius=255
}