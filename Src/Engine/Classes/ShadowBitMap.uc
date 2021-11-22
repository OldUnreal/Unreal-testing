// Project a shadow bitmap out of a Mesh Actor.
// Written by .:..:
Class ShadowBitMap extends Texture
	Native;

var() const Actor ProjectingActor; // Changed to constant to avoid data racing when modifing it while building shadow map.
var() rotator ProjectDirection;
var() byte Gradience,Softness;
var byte StaticLevel; // 0 = fully dynamic. 1 = static, but not rendered yet. 2 = fully static, never update anymore.
var() float ShadowScale;
var transient float PrevFadeDistance;

var transient private array<byte> BackBuffer;
var pointer<AActor*> LastActorRef;
var pointer<struct FShadowWorker*> ThreadProc;
var transient Palette SecPalette; // Secondary, modulated palette.

var const transient bool bIsValid;

native(1790) final function bool SetShadowRes( int X, int Y );
native(1791) final function bool SetActor( Actor Other ); // Changes ProjectingActor

defaultproperties
{
	Format=TEXF_P8
	USize=128
	VSize=128
	UClamp=128
	VClamp=128
	UBits=7
	VBits=7
	ShadowScale=1
	Softness=1
}