//=============================================================================
// MercFlare.
//=============================================================================
class MercFlare extends Effects
	transient;

#exec TEXTURE IMPORT NAME=RocketFlare FILE=..\UnrealShare\Models\rflare.pcx GROUP=Effects


defaultproperties
{
	LightType=LT_Steady
	LightPeriod=32
	LightCone=128
	VolumeBrightness=64
	VolumeRadius=0
	bStatic=False
	bNoDelete=False
	DrawType=DT_Sprite
	Style=STY_Translucent
	DrawScale=+00000.750000
	LightBrightness=250
	LightHue=28
	LightSaturation=32
	LightRadius=30
	bActorShadows=True
	bUnlit=True
	Texture=UnrealI.RocketFlare
	LifeSpan=+00000.100000
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
}
