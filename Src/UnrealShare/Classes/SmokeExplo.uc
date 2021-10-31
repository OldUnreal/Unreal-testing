//=============================================================================
// SmokeExplo.
//=============================================================================
class SmokeExplo extends AnimSpriteEffect
	transient;

#exec TEXTURE IMPORT NAME=SmokeE1 FILE=Models\F201.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE2 FILE=Models\F202.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE3 FILE=Models\F203.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE4 FILE=Models\F204.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE5 FILE=Models\F205.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE6 FILE=Models\F206.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE7 FILE=Models\F207.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE8 FILE=Models\F208.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=SmokeE9 FILE=Models\F209.pcx GROUP=Effects

defaultproperties
{
	SpriteAnim(0)=UnrealShare.SmokeE1
	SpriteAnim(1)=UnrealShare.SmokeE2
	SpriteAnim(2)=UnrealShare.SmokeE3
	SpriteAnim(3)=UnrealShare.SmokeE4
	SpriteAnim(4)=UnrealShare.SmokeE5
	SpriteAnim(5)=UnrealShare.SmokeE6
	SpriteAnim(6)=UnrealShare.SmokeE7
	SpriteAnim(7)=UnrealShare.SmokeE8
	SpriteAnim(8)=UnrealShare.SmokeE9
	NumFrames=9
	Pause=+00000.050000
	DrawScale=+00000.200000
	LightType=LT_None
	LightBrightness=68
	LightHue=0
	LightSaturation=255
	LightRadius=3
	LifeSpan=+00001.000000
}
