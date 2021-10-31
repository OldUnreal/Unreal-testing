// A dynamic corona light actor, can be spawned/moved around in game.
// Written by .:..: for Unreal v 227.
Class DynamicCorona extends Light
	Native;

enum ECoronaAttenuateType
{
	CATT_WorldOnly, // Fastest check
	CATT_WorldNMovers, // Fast check
	CATT_Actors // Relative fast check
};
var() bool bEnabled; // Corona is visible.
var() bool bDirectionalCorona; // Should only be visible 180 degrees forward.
var() bool bBrightnessDependent; // Corona depends not only on ScaleGlow but also LightBrightness.
var() float MaxSize, // Maximum size of the corona.
			DisplayDistance, // Maximum distance of corona.
			CoronaSize, // Corona scaling.
			FadeOutDistance, // Distance where corona starts fading out.
			RollRate, // Corona spin rate as you close in or move out from the source.
			CoronaFadeTimeScale; // How fast should corona fade in and out when visible or not.
var() color CoronaColor, // Corona color.
			CloseDistanceColor; // Close distance corona color.
var() ECoronaAttenuateType CoronaAttenuate; // Type of actors that will occlude this corona.

var(DirectionalCorona) Texture DirTexture; // Directional light beam for this corona.
var(DirectionalCorona) float DirCoronaLength,DirCoronaWide; // Directional corona size.
var(DirectionalCorona) float DirCoronaPullback; // The amount it should be pulled back into the actor origin (0 = fully infront, 1 = fully behind).
var(DirectionalCorona) float DirCoronaMinDot,DirCoronaMaxDot; // Dot angle (0-1) to which range it will fade out to regular corona texture.
var(DirectionalCorona) bool bFlipUV; // Mirror the directional corona texture along length axis.
var(DirectionalCorona) bool bRotateUV; // Rotate the directional corona texture by 90 degrees.
var(DirectionalCorona) bool bHideNormalCorona; // When directional corona is visible, hide the normal corona.

struct export LensFlare
{
	var() Texture Texture;
	var() float Opacity, // 0-1 opacity.
				Scale, // Lens flare scale relative to main corona.
				Offset, // 0-1 relative offset to screen origin.
				RollRate; // Lens flare spin rate as you close in or move out from the source.
};
var() array<LensFlare> LensFlares;

simulated function BeginPlay()
{
	// Client authority physics.
	Role = ROLE_Authority;
}

defaultproperties
{
	LightBrightness=0
	LightRadius=0
	Skin=Texture'S_LightCorona'
	CoronaColor=(R=255,B=255,G=255)
	CloseDistanceColor=(R=255,B=100,G=255)
	bDirectional=True
	bEnabled=true
	MaxSize=200
	DisplayDistance=7000
	FadeOutDistance=5000
	CoronaSize=200
	bHandleOwnCorona=true
	LightType=LT_None
	Texture=S_LightCorona
	bHidden=false
	DrawType=DT_Terraform
	DirCoronaLength=86
	DirCoronaWide=48
	DirCoronaMinDot=0.7
	DirCoronaMaxDot=0.95
	DirCoronaPullback=0.25
	CoronaFadeTimeScale=2
	
	bNoDelete=true
	RemoteRole=ROLE_None
	bMovable=true
}