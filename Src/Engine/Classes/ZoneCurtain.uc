//=============================================================================
// ZoneCurtain: A texture for zoneportals which fadeout on a distance.
// Can be used to optimize level.
// Note: This texture isn't very useful for anything else.
//=============================================================================
class ZoneCurtain extends Texture
	safereplace
	native
	runtimestatic;

var() float MaxDistance; // Max distance camera can be away from this zoneportal.
var() float FadeDistance; // % of maxdistance the portal will fadeout.
var() color PortalColor;

var(Backside) bool bEnableBackside; // Enable backside settings for this curtain (if you wish to disable entire backside, just make BSP surf one-sided).
var(Backside) float BackMaxDistance; // Maximum distance for backside.
var(Backside) color BackPortalColor; // Backside portal color.

var transient const int InitSetting; // C++
var transient int DrawDistance; // C++

defaultproperties
{
	Format=TEXF_BGRA8
	USize=1
	UClamp=1
	VSize=1
	VClamp=1
	UBits=0
	VBits=0
	bRealtime=true
	bParametric=true
	MaxDistance=1500
	FadeDistance=0.8
	PortalColor=(A=255)
	BackMaxDistance=1000
	BackPortalColor=(R=255,G=255,B=255,A=255)
}
