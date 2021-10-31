// A mouse cursor that can be used in-game.
Class UnrealCursor extends Object
	native;

var() byte HotSpotX,HotSpotY; // Center offset from top-left corner of the texture.
var() array<Texture> Frames; // Animation frames for the cursor (MUST be >=8 and <=256 pixels in size and uncompressed P8 palette format).
var() byte AnimRate; // Animation rate as in 60/AnimRate FPS.
var() byte FallbackCursor; // If unsupported (invalid format or unsupported OS), use this default cursor type instead (see Player.uc).
var pointer<struct FCursorData*> CursorData;

cpptext
{
	UUnrealCursor(){}
	void Destroy();
}

defaultproperties
{
	AnimRate=10
	FallbackCursor=0
}