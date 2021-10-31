// Scale a texture.
// Written by .:..:
Class TexScaler extends TexModifier
	Native;

var(Material) float XScaling,YScaling,XOffset,YOffset;
var transient float OldValues[4]; // For caching.

defaultproperties
{
	XScaling=1
	YScaling=1
}
