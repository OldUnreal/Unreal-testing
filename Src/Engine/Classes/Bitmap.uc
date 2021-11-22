//=============================================================================
// Bitmap: An abstract bitmap.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Bitmap extends Object
	native
	abstract;

// Texture format.
var(Info) const editconst enum ETextureFormat
{
	// Original.
	TEXF_P8,
	TEXF_BGRA8_LM,	// Highest bit is ignored. LightMaps: 0..127 maps to 0.0..2.0, alpha is ignored. FogMaps: 0..127 maps to 0.0..1.0. Prior: TEXF_RGBA7.
	TEXF_R5G6B5,	// Prior: TEXF_RGB16. !! Conflicted with naming scheme.
	TEXF_BC1,		// Solid alpha variant. See TEXF_BC1_PA for punchthrough alpha variant.
	TEXF_RGB8,
	TEXF_BGRA8,		// Prior: TEXF_RGBA8. !! Conflicted with naming scheme.

	// S3TC (continued).
	TEXF_BC2,
	TEXF_BC3,

	// RGTC.
	TEXF_BC4,
	TEXF_BC4_S,
	TEXF_BC5,
	TEXF_BC5_S,

	// BPTC.
	TEXF_BC7,
	TEXF_BC6H_S,
	TEXF_BC6H,

	// Normalized RGBA.
	TEXF_RGBA16,
	TEXF_RGBA16_S,
	TEXF_RGBA32,
	TEXF_RGBA32_S,

	// Monocrome texture (fonts mainly)
	TEXF_MONO,

    // Meta.
	TEXF_UNCOMPRESSED,		// Default quality uncompressed meta target.
	TEXF_UNCOMPRESSED_LOW,	// Low quality uncompressed meta target.
	TEXF_UNCOMPRESSED_HIGH,	// High quality uncompressed meta target.
	TEXF_COMPRESSED,		// Default quality compressed meta target.
	TEXF_COMPRESSED_LOW,	// Low quality compressed meta target.
	TEXF_COMPRESSED_HIGH,	// High quality compressed meta target.

	// S3TC (continued).
	TEXF_BC1_PA,			// Punchthrough alpha variant. See TEXF_BC1 for solid alpha variant.

	// Normalized RGBA (continued).
	TEXF_R8,
	TEXF_R8_S,
	TEXF_R16,
	TEXF_R16_S,
	TEXF_R32,
	TEXF_R32_S,
	TEXF_RG8,
	TEXF_RG8_S,
	TEXF_RG16,
	TEXF_RG16_S,
	TEXF_RG32,
	TEXF_RG32_S,
	TEXF_RGB8_S,
	TEXF_RGB16_, // Snake'd.
	TEXF_RGB16_S,
	TEXF_RGB32,
	TEXF_RGB32_S,
	TEXF_RGBA8_, // Snake'd.
	TEXF_RGBA8_S,

	// Floating point RGBA.
	TEXF_R16_F,
	TEXF_R32_F,
	TEXF_RG16_F,
	TEXF_RG32_F,
	TEXF_RGB16_F,
	TEXF_RGB32_F,
	TEXF_RGBA16_F,
	TEXF_RGBA32_F,

	// ETC1/ETC2/EAC.
	TEXF_ETC1,
	TEXF_ETC2,
	TEXF_ETC2_PA,
	TEXF_ETC2_RGB_EAC_A,
	TEXF_EAC_R,
	TEXF_EAC_R_S,
	TEXF_EAC_RG,
	TEXF_EAC_RG_S,

	// ASTC.
	TEXF_ASTC_4x4, //
	TEXF_ASTC_5x4, // ASTC can store an
	TEXF_ASTC_5x5, // HDR alpha channel.
	TEXF_ASTC_6x5, //
	TEXF_ASTC_6x6,
	TEXF_ASTC_8x5,
	TEXF_ASTC_8x6,
	TEXF_ASTC_8x8,
	TEXF_ASTC_10x5,
	TEXF_ASTC_10x6,
	TEXF_ASTC_10x8,
	TEXF_ASTC_10x10,
	TEXF_ASTC_12x10,
	TEXF_ASTC_12x12,
	TEXF_ASTC_3x3x3, //
	TEXF_ASTC_4x3x3, // Block can has
	TEXF_ASTC_4x4x3, // three deezs.
	TEXF_ASTC_4x4x4, //
	TEXF_ASTC_5x4x4,
	TEXF_ASTC_5x5x4,
	TEXF_ASTC_5x5x5,
	TEXF_ASTC_6x5x5,
	TEXF_ASTC_6x6x5,
	TEXF_ASTC_6x6x6,

	// PVRTC.
	TEXF_PVRTC1_2BPP, // Could use better names, maybe
	TEXF_PVRTC1_4BPP, // something about the block size
	TEXF_PVRTC2_2BPP, // but I have no real clue about
	TEXF_PVRTC2_4BPP, // these formats. --han

	// RGBA (Integral).
	TEXF_R8_UI,
	TEXF_R8_I,
	TEXF_R16_UI,
	TEXF_R16_I,
	TEXF_R32_UI,
	TEXF_R32_I,
	TEXF_RG8_UI,
	TEXF_RG8_I,
	TEXF_RG16_UI,
	TEXF_RG16_I,
	TEXF_RG32_UI,
	TEXF_RG32_I,
	TEXF_RGB8_UI,
	TEXF_RGB8_I,
	TEXF_RGB16_UI,
	TEXF_RGB16_I,
	TEXF_RGB32_UI,
	TEXF_RGB32_I,
	TEXF_RGBA8_UI,
	TEXF_RGBA8_I,
	TEXF_RGBA16_UI,
	TEXF_RGBA16_I,
	TEXF_RGBA32_UI,
	TEXF_RGBA32_I,

	// Special.
	TEXF_ARGB8,
	TEXF_ABGR8,
	TEXF_RGB10A2,
	TEXF_RGB10A2_UI,
	TEXF_RGB10A2_LM,	// Highest bit and alpha is ignored. Otherwise same old song as TEXF_BGRA8_LM: 0..1023 maps to 0.0..2.0.
	TEXF_RGB9E5,		// No sign bit, individual 9 bit mantissa with a shared 5 bit exponent.
	TEXF_P8_RGB9E5,		// Palette for RGB9E5 data. Intended as an option to store HDR data for FireTexture.
	TEXF_R1,			// Unsigned normalized red format stored as 8x1 blocks taking 1 byte each. Upper left pixel is stored in least significant bit.
    TEXF_NODATA,
} Format;

// Texture mipmap.
struct Mipmap
{
	var pointer<BYTE*> DataPtr;						// Pointer to data, valid only when locked.
	var() const editconst int USize, VSize;			// Power of two tile dimensions.
	var() const editconst byte UBits, VBits;		// Power of two tile bits.
	var() const editconst lazyarray<byte> DataArray;// Data.
};

// Palette.
var(Texture) palette Palette;

// Internal info.
var const editconst byte  UBits, VBits;
var(Info) nowarn const editconst int   USize, VSize;
var(Texture) const int UClamp, VClamp;
var const editconst color MipZero;
var const editconst color MaxColor;

defaultproperties
{
	MipZero=(R=64,G=128,B=64,A=0)
	MaxColor=(R=255,G=255,B=255,A=255)
}
