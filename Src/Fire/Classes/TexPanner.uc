// Pan a texture.
// Written by .:..:
Class TexPanner extends TexModifier
	Native;

var(Material) vector InitPanning,PanningSpeed;
var transient vector OldVals[2],CurPanning; // For caching.
var transient bool bHasAutoPan;

defaultproperties
{
}
