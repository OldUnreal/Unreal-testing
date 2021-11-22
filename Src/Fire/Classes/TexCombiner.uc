// Combine multiple textures.
// Written by Marco
Class TexCombiner extends TextureModifierBase
	Native;

enum ECombineOperation
{
	CO_Add, // Mat1 + Mat2 color
	CO_Subtract, // Mat1 - Mat2 color
	CO_MaskOnly, // Do only masking operation on Mat1
	CO_OverlayWithTransp // Do overlay on Mat1 with translucent version of Mat2*Mask color.
};
var() ECombineOperation CombineOperation;
var() int MatUSize,MatVSize;
var() texture Material1,Material2,MaskTexture;
var() int MaterialAScale[2],MaterialBScale[2],MaterialCScale[2];

var const texture SoftwareFallback;

var() bool bStaticFrame; // Fast render, only for non-animating textures.
var transient bool bComputedFrame; // When 'bStaticFrame', frame is already computed, no need for update anymore.

defaultproperties
{
	bRealtime=true
	Format=TEXF_RGB32
	CombineOperation=CO_OverlayWithTransp
	MatUSize=64
	MatVSize=64
	SoftwareFallback=Texture'DefaultTexture'
	bStaticFrame=true
}
