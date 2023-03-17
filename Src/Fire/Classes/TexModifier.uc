// Modify some specific texture.
// Written by .:..:
Class TexModifier extends TextureModifierBase
	Native
	Abstract;

var(Material) Texture Material;
var(Material) byte BitMapScaling[2];
var(Material) transient bool bSoftwarePreview; // See how it looks like with software handle.

var transient const texture OldVerifiedMaterial;
var transient const bool bTextureOK;
var transient const byte OldVBits,OldUBits,OldBitScaler[2];
var transient const array<int> PtrList;
var transient Coords2D TexCoords;

var transient bool bSourceDirty;

function Reset()
{
	Material = None;
	BitMapScaling[0] = 0;
	BitMapScaling[1] = 0;
}

defaultproperties
{
	bRealtime=true
}