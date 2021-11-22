// Useful for screenshot sequences, written by Marco.
// Note: Does not support Software Rendering.
class MaterialSequence extends TextureModifierBase
	native;

struct MaterialSequenceItem
{
	var() Texture Material;
	var() float DisplayTime,FadeOutTime;
};
var() array<MaterialSequenceItem> SequenceItems;
var() int MatUSize,MatVSize;
var() bool Loop;
var() bool Paused;
var transient float CurrentTime;
var transient Texture ConstFrameTex;
var const Texture SoftwareFallback;

defaultproperties
{
	Loop=True
	MatUSize=64
	MatVSize=64
	Format=TEXF_BGRA8_LM
	SoftwareFallback=Texture'DefaultTexture'
}
