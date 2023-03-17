// Scale a texture.
// Written by .:..:
Class TexScaler extends TexModifier
	Native;

var(Material) float XScaling,YScaling,XOffset,YOffset;
var transient float OldValues[4]; // For caching.

function Reset()
{
	Super.Reset();
	XScaling = 1.f;
	YScaling = 1.f;
	XOffset = 0.f;
	YOffset = 0.f;
}

defaultproperties
{
	XScaling=1
	YScaling=1
}
