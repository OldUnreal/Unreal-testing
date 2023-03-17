//=============================================================================
// ScriptedTexture: A scriptable Unreal texture
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ScriptedTexture extends Texture
	safereplace
	native;

var() bool bUse32BitFormat, // Use high color mode, only functional with hardware render drivers.
			bConstantRender, // Call render every frame regardless of RenderCounter value.
			bClearScreen; // Clear screen automatically every new frame.
var transient bool bDrawFrame; // If bConstantRender is false, then call render every time this one is set to True.

var() byte DrawStyle,DrawOpacity; // Only functional with 32-bit format.

// A SciptedTexture calls its Script's Render() method to draw to the texture at
// runtime
var() Actor NotifyActor;
var() Texture SourceTexture;

var pointer<BYTE*> LocalSourceBitmap;	// C++ stuff
var pointer<TMap< UPalette*, TArray< BYTE > >*> PaletteMap;			// C++ stuff
var pointer<struct FScriptTexPortal*> PortalPtr;

var() struct export PortalRenderInfo // Draw portal additional params.
{
	var() float FOV; // Field of View
	var() byte RendMap; // Render mode
	var() plane ColorScale; // Portal color scale
	var() int PixelOffset; // To make screen wrap up or down (like static on TV screen)
	var() plane NearClip; // Near clipping plane
	var() bool bUseNearClip; // Near clipping plane enabled
	var() bool bWrapPixels; // Should wrap the pixels around or generate random noise when PixelOffset!=0
} PortalInfo;

enum ETexCompressType
{
	COMP_None, // Keep at max quality (32-bit)
	COMP_P8, // Paletted 256 colors compression.
	COMP_Mono, // Black and while monochrome compression.
};

native(473) final function DrawTile( float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Texture Tex, bool bMasked, optional color DrawColor );
native(472) final function DrawText( float X, float Y, string Text, Font Font, optional int NewLineX, optional int ClipX );
native(474) final function DrawColoredText( float X, float Y, string Text, Font Font, color FontColor, optional int NewLineX, optional int ClipX );
native(475) final function ReplaceTexture( Texture Tex );

// 227 functions:
static native(476) final function TextSize( string Text, out float XL, out float YL, Font Font );
native(588) final function ClearImage(); // Clear everything drawn to black.
native(589) final function InitImage( int X, int Y ); // Set texture resolution (must a value in power of two).

/* Get image data
Following compression values (with example of 128x128 texture):
COMP_None	> 2 + XRes x YRes x 4 bytes		> 64 kb
COMP_P8	> 3 + 3 x 256 + XRes x YRes bytes	> ~16,75 kb
COMP_Mono	> 2 + XRes x YRes bytes			> 16 kb
*/
native(590) final function GetDataString( out array<byte> Data, ETexCompressType Compress );
native(591) final function SetDataString( out array<byte> Data, ETexCompressType Compress ); // Set image data
native(592) final function CaptureScreenshot( Viewport V ); // Capture a screenshot onto this texture, only works on 32-bit mode.

// Saving and loading to external files, all actions limited to ..\Unreal\APIData\*.tex folder.
native(593) final function SaveTexture( string FileName, ETexCompressType Compress ); // Save current scripted texture to an external file.
native(594) final function LoadTexture( string FileName ); // Load current scripted texture from an external file.
static native(595) final iterator function ListTextures( out string FileName ); // Iterate through all scripted texture files.
static native(596) final function DeleteTexture( string FileName ); // Delete an external scripted texture file.

// Draw a portal (using software render code).
// @Map: SomeActor.XLevel property.
// @CamActor: The "first person" view of that actor.
native(597) final function DrawPortal( Level Map, vector Pos, rotator Rot, optional Actor CamActor );

event Main()
{
	if( NotifyActor )
		NotifyActor.RenderTexture(Self);
	else if( AppIsEditor() )
		DrawText(5,5,"Detached client",Font'MedFont');
}

defaultproperties
{
	bUse32BitFormat=False
	bConstantRender=True
	bClearScreen=True
    DrawStyle=1
	DrawOpacity=255
	PortalInfo=(FOV=90,RendMap=5,ColorScale=(X=1,Y=1,Z=1,W=1))
}