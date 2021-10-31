// Sunlight lens flare actor, written by .:..: for Unreal v 227.
Class SunlightCorona extends Light
	Native;

#exec Texture Import File="Textures\S_SunLight.pcx" Name="S_Sunlight" GROUP="Icons" Mips=Off Flags=2

struct export LensFlareCastType
{
	var() float ZDistance,Scale;
	var() texture LensTexture;
	var() color LensColor;
};
var() bool bMustMatchZone,bRenderLensFlares;
var() color SunlightColor;
var() float BlindingScale,BlindingFOV,MaxSkyDistance,SunFadeTimeScale;
var() texture SunlightTexture;
var() LensFlareCastType LensFlares[8];
var() float FlaresDisplayFov;
var bool bUScriptRenderHandler;

event RenderCorona( Canvas Canvas, float DeltaTime, bool bContactToSky );

defaultproperties
{
	LightBrightness=0
	LightRadius=0
	bMustMatchZone=True
	SunlightColor=(R=255,B=255,G=255)
	BlindingFOV=0.9
	BlindingScale=24
	MaxSkyDistance=10000
	SunFadeTimeScale=2
	SunlightTexture=Texture'S_SunLight'
	Texture=S_SunLight
	FlaresDisplayFov=0.8
	LensFlares(0)=(ZDistance=0.8,Scale=0.5,LensTexture=Texture'S_Light',LensColor=(R=255,B=255,G=255))
	LensFlares(1)=(ZDistance=0.6,Scale=0.35,LensTexture=Texture'S_Light',LensColor=(R=255,B=255,G=255))
	LensFlares(2)=(ZDistance=0.4,Scale=0.25,LensTexture=Texture'S_Light',LensColor=(R=255,B=255,G=255))
	LensFlares(3)=(ZDistance=0.2,Scale=0.1,LensTexture=Texture'S_Light',LensColor=(R=255,B=255,G=255))
	LensFlares(4)=(LensColor=(R=255,B=255,G=255))
	LensFlares(5)=(LensColor=(R=255,B=255,G=255))
	LensFlares(6)=(LensColor=(R=255,B=255,G=255))
	LensFlares(7)=(LensColor=(R=255,B=255,G=255))
	bRenderLensFlares=true
	bHandleOwnCorona=true
	bDirectional=true
}