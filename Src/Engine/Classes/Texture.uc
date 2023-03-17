//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
// New compression formats have been added to be used at compile time (227j).
// To use them chose one the following new TEXTURE IMPORT parameters:
// BTC = 0 (Import as uncompressed RGBA8)
// BTC = 1 (BC1/DXT1) or DXT = 1
// BTC = 2 (BC2/DXT3) or DXT = 3
// BTC = 3 (BC3/DXT5) or DXT = 5
// BTC = 4 (BC4)
// BTC = 5 (BC5U/ATI2)
// BTC = 6 (BC6H)
// BTC = 7 (BC7)
// Import formats supported are BMP/DDS/PNG.
// Note that only uncompressed DDS files can be processed,
// already compressed dds files will be imported "as is".
//=============================================================================
class Texture extends Bitmap
	safereplace
	native
	runtimestatic
	nousercreate;

// Subtextures.
var() texture BumpMap;			// Bump map to illuminate this texture with.
var() texture HeightMap;		// Heightmap of this texture.
var() texture DetailTexture;	// Detail texture to apply.
var() texture MacroTexture;		// Macrotexture to apply, not currently used.
var() texture HDTexture;		// Only for HUD: HD texture to be drawn if stretching out this texture beyond it's resolution.
var() editinline PortalModifier PortalModifier; // To be used to modify mirrors or whatnot drawn through this texture.

// Surface properties.
var() float Diffuse;		// Diffuse lighting coefficient.
var() float Specular;		// Specular lighting coefficient.
var() float Alpha;			// Alpha.
var() float DrawScale;		// Scaling relative to parent.
var() float Friction;		// Surface friction coefficient, 0=none, 1=full, 10=ladder (Level must have bCheckWalkSurfaces enabled).
var() float MipMult;		// Mipmap multiplier.
var() float SuperGlow;		// Make mesh surface glow to white if reflection hits just right.

// Sounds.
var() sound FootstepSound[6];			// Footstep sound.
var() sound HitSound;					// Sound when the texture is hit with a projectile.

cppbitmask(PolyFlags)
{
	// Surface flags.
	var          bool bInvisible;
	var(Surface) bool bMasked;
	var(Surface) bool bTransparent;
	var          bool bNotSolid;
	var(Surface) bool bEnvironment;
	var          bool bSemisolid;
	var(Surface) bool bModulate;
	var(Surface) bool bFakeBackdrop;
	var(Surface) bool bTwoSided;
	var(Surface) bool bAutoUPan;
	var(Surface) bool bAutoVPan;
	var(Surface) bool bNoSmooth;
	var(Surface) bool bBigWavy;
	var(Surface) bool bSmallWavy;
	var(Surface) bool bWaterWavy;
	var          bool bLowShadowDetail;
	var          bool bNoMerge;
	var(Surface) bool bAlphaBlend;
	var          bool bDirtyShadows;
	var          bool bHighLedge;
	var          bool bSpecialLit;
	var          bool bGouraud;
	var(Surface) bool bUnlit;
	var          bool bHighShadowDetail;
	var          bool bPortal;
	var          const bool bMirrored, bX2, bX3;
	var          const bool bX4, bX5, bX6, bX7;
}

// Texture flags.
var(Quality) private	bool bHighColorQuality;   // High color quality hint (64bit).
var(Quality) private	bool bHighTextureQuality; // High texture quality hint.
var(Info) private editconst	bool bRealtime;           // Texture changes in realtime.
var(Info) private editconst	bool bParametric;         // Texture data need not be stored.
var private transient	bool bRealtimeChanged;    // Changed since last render.
var private				bool bHasComp;			// Whether a compressed version exists.
var private				bool bFractical;			// Don't touch, rendering helper.
var transient			bool bParmsDirty;		// Texture parms was changed and need to update internal texture info.

// Level of detail set.
var(Quality) enum ELODSet
{
	LODSET_None,   // No level of detail mipmap tossing.
	LODSET_World,  // World level-of-detail set.
	LODSET_Skin,   // Skin level-of-detail set.
} LODSet;

// Animation.
var(Animation) texture AnimNext;
var transient  texture AnimCurrent;
var(Animation) byte    PrimeCount;
var transient  byte    PrimeCurrent;
var(Animation) float   MinFrameRate, MaxFrameRate;
var transient  float   Accumulator;
var() private transient byte PreviewMipmap; // Draw a single mipmap on editor.

// Mipmaps.
var native const editconst array<Mipmap> Mips, DecompMips;
var native const editconst ETextureFormat DecompFormat;
var pointer<FMipmap*> SourceMip;

// Footprints, based on Decals.
var() enum ESurfaceTypes
{
	EST_Default,
	EST_Rock,
	EST_Dirt, // Footprints
	EST_Metal,
	EST_Wood,
	EST_Plant,
	EST_Flesh,
	EST_Ice,
	EST_Snow, // Footprints
	EST_Water,
	EST_Glass,
	EST_Carpet,
	EST_Custom00,
	EST_Custom01,
	EST_Custom02,
	EST_Custom03,
	EST_Custom04,
	EST_Custom05,
	EST_Custom06, // Footprints
	EST_Custom07, // Footprints
	EST_Custom08, // Footprints
	EST_Custom09, // Footprints
	EST_Custom10 // Footprints
} SurfaceType;

// Clamping mode for textures
var(Texture) enum EUClampMode
{
	UWrap,
	UClamp,
} UClampMode;
var(Texture) enum EVClampMode
{
	VWrap,
	VClamp,
} VClampMode;

// Color for firetextures
var(Texture) transient color PaletteTransform;	// change fade palette of the texture in editor

var pointer<FTextureInfo*> TextureHandle;		// Cached texture data.
var transient const editconst uint LastRenderedTime, RenderTag;

defaultproperties
{
	MipMult=1
	Diffuse=1
	Specular=0
	DrawScale=1
	Friction=1
	Alpha=1
	LODSet=LODSET_World
	UClampMode=UWrap
	VClampMode=VWrap
}