//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
	transient;

enum ERenderZTest
{
	ZTEST_Less, // Z<
	ZTEST_Equal, // Z==
	ZTEST_LessEqual, // Z<= (default)
	ZTEST_Greater, // Z>
	ZTEST_GreaterEqual, // Z>=
	ZTEST_NotEqual, // Z!=
	ZTEST_Always, // 1
};
struct export CanvasPoly
{
	var() config vector Points[3];
	var() config vector2d UV[3]; // U/V scaled in 0-1
	var() config plane Colors[3],Fog[3];
};

// Objects.
//#exec Texture Import File=Textures\HD_Font\HD_SmallFont.pcx Name=HD_SmallFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Font\HD_MedFont.pcx Name=HD_MedFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Font\HD_LargeFont.pcx Name=HD_LargeFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Font\HD_BigFont.pcx Name=HD_BigFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Font\BigFontWIP2NoMip.dds Name=HD_LargeFont Group="HD" Mips=Off Flags=131074

#exec Font Import File=Textures\SmallFont.bmp Name=SmallFont //HD=HD_SmallFont
#exec Font Import File=Textures\MedFont.pcx   Name=MedFont //HD=HD_MedFont
#exec Font Import File=Textures\LargeFont_New.pcx Name=LargeFont //HD=HD_LargeFont
#exec Font Import File=Textures\BigFontNew.pcx   Name=BigFont //HD=HD_BigFont

// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   SpaceX, SpaceY;  // Spacing for after Draw*.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
var float   CurX, CurY;      // Current position for drawing.
var float   Z;               // Z location. 1=no screenflash, 2=yes screenflash.
var byte    Style;           // Drawing style STY_None means don't draw.
var float   CurYL;           // Largest Y size since DrawText.
var float	FontScale;       // Draw scaling for DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var bool	bEnableFog;		 // Allow next DrawActor call apply fog on the actor.
var bool	bZRangeHack;	 // Enabled automatically during RenderOverlays, Z-range hack mode for drawing meshes that are near the HUD (for D3D and OpenGL)
var const int OffsetDrawFlags; // Used by 3D tile offset.
var const byte Recursion;    // Portal depth of this call (0 if in world, 1 if in mirror or skybox, 2 if in mirrors mirror etc...)
var const int Mirror;        // If current Canvas call is in a mirror then this will be -1
var const int SizeX, SizeY;  // Zero-based actual dimensions.
var const float ScaleFactor, NeqScaleFactor; // Current Canvas scaling factor.

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;            // Medium system font.
var font BigFont;            // Big system font.
var font LargeFont;          // Large system font.

// Internal.
var const viewport Viewport;			// Viewport that owns the canvas.
var pointer<struct FSceneNode*> Frame;		// Scene frame pointer.
var pointer<class URenderBase*> Render;	// Render device pointer, only valid during UGameEngine::Draw
var coords RenderCoords;				// Used by 3D tile offset.
var private array< pointer<struct FCanvasScaler*> > CanvasScalar; // Scaling stack for canvas.

// native functions.
native(464) final function StrLen( coerce string String, out float XL, out float YL );
native(465) final function DrawText( coerce string Text, optional bool CR, optional int PolyFlags );// PolyFlags can be used to override any style while DrawText style default sets (PF_TwoSided | PF_NoSmooth | PF_Masked). 0 makes use of a fonts default polyflags.
// 227j: PolyFlags can be used to override any style while DrawTile ignores PF_Masked and sets PF_TwoSided.However, it is recommended to keep PF_TWoSided for HUD drawing.
// WorldPos can be used to override draw position and draw sprite in world coordinates and scale.
native(466) final function DrawTile( texture Tex, float XL, float YL, float U, float V, float UL, float VL, optional int PolyFlags, optional vector WorldPos );
native(467) final function DrawActor( Actor A, optional bool WireFrame, optional bool ClearZ );
native(468) final function DrawTileClipped( texture Tex, float XL, float YL, float U, float V, float UL, float VL, optional int PolyFlags );// PolyFlags can be used to override any style...
native(469) final function DrawTextClipped( coerce string Text, optional bool bCheckHotKey, optional int PolyFlags );// PolyFlags can be used to override any style...
native(470) final function TextSize( coerce string String, out float XL, out float YL );
native(471) final function DrawClippedActor( Actor A, bool WireFrame, int X, int Y, int XB, int YB, optional bool ClearZ );
native(477) final function DrawTileStretched( Texture Tex, int X1, int Y1, int X2, int Y2 );
native(480) final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );

// New U227 functions:

/* Very fast:
Draw a clipped 2D line on the frame (vectors are given in screen space) */
native(1750) final function Draw2DLine( Color Col, vector Start, vector End );

/* Very fast:
Draw a 3D line (vectors are given in world space), rendering drivers notice:
-OpenGL/D3D8/D3D9 seems to render the line in world (meaning it can go behind objects and so). */
native(1751) final function Draw3DLine( Color Col, vector Start, vector End );

/* Very fast:
Convert a given world space location into screen coordinates.
- The result: X = X screen location, Y = Y screen location, Z = 1, world location is in front of camera / -1, world location is behind the camera.
@ ZDistance: The Z distance from camera. */
native(1752) final function vector WorldToScreen( vector WorldPos, optional out float ZDistance );

/* Very fast:
Convert a given screen location into world space location. */
native(1753) final function vector ScreenToWorld( vector ScreenPos );

/* Relative slow (debugging use only):
Draw the path network on HUD */
native(1754) final function DrawPathNetwork( bool bOnlyWalkable, optional float MaxDistance /*def 2000*/ );

/* enum ELineFlags
{
	LINE_None, = 0
	LINE_Transparent, = 1
	LINE_DepthCued = 2
};*/
// Render a circle
// Position is defined in world position.
native(1755) final function DrawCircle( Color Col, int LineFlags, vector Position, float Radius );

// Render a 3D box in world position.
native(1756) final function DrawBox( Color Col, int LineFlags, vector Start, vector End );

/* Very fast:
Get current camera location + rotation:
CamLocation = Origin
CamRotation = OrthoRotation(XAxis,YAxis,ZAxis) */
native(1757) final function coords GetCameraCoords();

// Set Tile drawing 3D offset.
// It is recommended you clear Z before using this (using Canvas.DrawActor(None,false,true);)
// @ bWorldOffset - Makes it take Offset and RotOffset as absolute world coordinates!
native(1758) final function SetTile3DOffset( bool bEnable, optional vector Offset, optional rotator RotOffset, optional bool bFlatZ, optional float Scale, optional bool bWorldOffset );

// Free draw a 2D polygon.
// @ bFogColor - Include fog color channel.
native(1746) final function DrawTris( Texture Tex, out array<CanvasPoly> Polys, optional int PolyFlags, optional bool bFogColor );

// Draw a rotated tile.
// @ bRotateUV - Rotate by UV instead of the whole texture.
// @ PivotX/Y - Rotated center pivot point (0-1).
native(1747) final function DrawRotatedTile( Texture Tex, float Roll, float XL, float YL, float U, float V, float UL, float VL, float PivotX, float PivotY, optional bool bRotateUV, optional int PolyFlags );

// Push/pop a new clipping plane for upcoming 3D draw. (returns false if overflowed, typically 32 planes)
// @ bLocal - If true, the clipping plane is in screenspace, otherwise in world space.
native(1748) final function bool PushClipPlane( vector Dir, float W, optional bool bLocal );
native(1749) final function PopClipPlane();

// Changes render Z testing mode (returns old value).
native(1759) final function ERenderZTest SetZTest( ERenderZTest ZTest );

// Push/pop a new canvas scaling factor, makes resolution for canvas appear smaller but draws bigger tiles.
// @ bAbsolute - Whatever or not new scale is relative to previous scaling factor.
native(1762) final function PushCanvasScale( float Scale, optional bool bAbsolute );
native(1763) final function PopCanvasScale();

// Set custom lighting mode for upcoming draw mesh calls, remember to reset it after use so it doesn't leak to other meshes in level.
// @ bDisableEngineLighting - Disallow engine light sources from in level (def to false).
// @ CustomAmbientLight - Custom ambient brightness for the actor (def to zonelight).
native(1774) final function SetCustomLighting( optional bool bDisableEngineLighting, optional vector CustomAmbientLight );

// Add a custom light source for upcoming draw mesh call (can add up to max 16 light sources).
// The returned actor is abstract and shouldn't be interacted with, only used to setup light params.
// @ bDefault - Reset all light parms to default Actor parms again to not to keep anything from previous calls.
native(1775) final function Actor AddCustomLightSource( vector Pos, optional rotator Dir, optional bool bDefault );

// Remove all custom light sources again.
native(1776) final function ClearCustomLightSources();

// Reset canvas to its initial state.
native final function Reset();
/* 227j: moved to C++ codes for faster and better handling.
{
	Font        = Default.Font;
	SpaceX      = Default.SpaceX;
	SpaceY      = Default.SpaceY;
	OrgX        = Default.OrgX;
	OrgY        = Default.OrgY;
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	Style       = Default.Style;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
	Z           = 1.0;
	FontScale   = 1.0;
	SetTile3DOffset(false);
}
*/

// UnrealScript functions.
final function SetPos( float X, float Y )
{
	CurX = X;
	CurY = Y;
}
final function SetOrigin( float X, float Y )
{
	OrgX = X;
	OrgY = Y;
}
final function SetClip( float X, float Y )
{
	ClipX = X;
	ClipY = Y;
}
final function DrawPattern( texture Tex, float XL, float YL, float Scale )
{
	DrawTile( Tex, XL, YL, (CurX-OrgX)*Scale, (CurY-OrgY)*Scale, XL*Scale, YL*Scale );
}
final function DrawIcon( texture Tex, float Scale )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*Scale, Tex.VSize*Scale, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawRect( texture Tex, float RectX, float RectY )
{
	DrawTile( Tex, RectX, RectY, 0, 0, Tex.USize, Tex.VSize );
}

final function SetDrawColorRGB(byte R, byte G, byte B)
{
	DrawColor.R = R;
	DrawColor.G = G;
	DrawColor.B = B;
}

final function SetDrawColorRGBA(byte R, byte G, byte B, byte A)
{
	DrawColor.R = R;
	DrawColor.G = G;
	DrawColor.B = B;
	DrawColor.A = A;
}

// Helper functions.
final function rotator GetCameraRotation()
{
	local coords C;

	C = GetCameraCoords();
	return OrthoRotation(C.XAxis, C.YAxis, C.ZAxis);
}
final function vector GetCameraLocation()
{
	local coords C;

	C = GetCameraCoords();
	return C.Origin;
}

// Clear Z-buffer.
final function ClearZ()
{
	DrawActor(None,,true);
}

defaultproperties
{
	Z=1.000000
	FontScale=1
	ScaleFactor=1
	NeqScaleFactor=1
	Style=STY_Normal
	bEnableFog=true
	DrawColor=(R=127,G=127,B=127,A=255)
	SmallFont=Font'Engine.SmallFont'
	MedFont=Font'Engine.MedFont'
	BigFont=Font'Engine.BigFont'
	LargeFont=Font'Engine.LargeFont'
}
