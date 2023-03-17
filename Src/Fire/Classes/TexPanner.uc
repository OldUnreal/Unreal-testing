// Pan a texture.
// Written by .:..:
Class TexPanner extends TexModifier
	Native;

var(Material) vector InitPanning,PanningSpeed;
var transient vector PrevInitPan, // For caching.
						CurPanning; // Current panning with PanningSpeed.

function Reset()
{
	Super.Reset();
	InitPanning = vect(0,0,0);
	PanningSpeed = vect(0,0,0);
	CurPanning = vect(0,0,0);
}

defaultproperties
{
}
