// Simply modify colors of a source texture (paletted).
Class PaletteModifier extends Texture
	native;

struct export ColorModifyEntry
{
	var() color SourceColor; // Source color from source texture.
	var() color TargetColor; // Target color to modify the source texture.
	var() float Threshold; // 0-1 range how close the pixel must be to SourceColor for the modifier to be applied.
};
var() array<ColorModifyEntry> ColorModifiers; // List of colors to alter from source texture.
var() Texture SourceTexture;
var transient private bool bSourceValid;

native final function RefreshTexture(); // If you modify any parms you need to refresh this texture.

defaultproperties
{
	bParametric=true
	bFractical=true
}