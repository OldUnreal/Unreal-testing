//=============================================================================
// FluidSurfaceOscillator - To use match the Tag with the FluidSurfaceInfo's
//=============================================================================
class FluidSurfaceOscillator extends Info
	native;

#exec Texture Import File=Textures\S_FluidSurfOsc.pcx Name=S_FluidSurfOsc Mips=Off Flags=2

var() float							Frequency; // The rate of wave production.
var() byte							Phase; // The wave offset.
var() float							Strength; // The force applied to the fluid surface.
var() float							Radius; // Determines the area affected by the oscillator.

var FluidSurfaceInfo				FluidSurface;
var transient const float			OscTime;

simulated function PostBeginPlay()
{
	Role = ROLE_Authority;
}

defaultproperties
{
	Texture=S_FluidSurfOsc
	bHidden=true
	Frequency=1
	Phase=0
	Strength=10
	Radius=0
	bNoDelete=true
	bStatic=true
	RemoteRole=ROLE_None
}