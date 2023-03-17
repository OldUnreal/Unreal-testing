//=============================================================================
// WetTexture: Water amplitude used as displacement.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class WetTexture extends WaterTexture
	native
	runtimestatic;

var(WaterPaint)	texture			SourceTexture;
var transient	texture			OldSourceTex;
var				pointer<BYTE*>	LocalSourceBitmap;

defaultproperties
{
}
