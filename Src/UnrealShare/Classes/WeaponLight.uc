//=============================================================================
// WeaponLight.
//=============================================================================
class WeaponLight extends Light
	transient;

#exec TEXTURE IMPORT NAME=WepLightPal FILE=Textures\exppal.pcx GROUP=Effects

defaultproperties
{
	bStatic=False
	bNetOptional=True
	bNetTemporary=true
	bNoDelete=False
	bMovable=True
	Skin=UnrealShare.WepLightPal
	LightType=LT_TexturePaletteOnce
	LightEffect=LE_NonIncidence
	LightBrightness=250
	LightHue=28
	LightSaturation=32
	LightRadius=6
	bActorShadows=True
	LifeSpan=+00000.150000
	RemoteRole=ROLE_SimulatedProxy
}
