// Modify some specific texture.
// Written by .:..:
Class TextureModifierBase extends Texture
	Native
	Abstract;

// Will reinitialize texture with a given size.
native final function InitImage( int X, int Y );

defaultproperties
{
}