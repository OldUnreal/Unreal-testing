//=============================================================================
// Object: The base class all objects.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Object
		native
			noexport;

//=============================================================================
// UObject variables.

// Internal variables.
var pointer ObjectVtbl;
var native const editconst int ObjectIndex;
var pointer ObjectInternal[4];
var native const editconst object Outer;
var native const editconst object ObjectArchetype;
var native const editconst int ObjectFlags;
var(Object) native const editconst name Name;
var(Object) native const editconst class Class;

//=============================================================================
// Unreal base structures.

// Object flags.
const RF_Transactional	= 0x00000001; // Supports editor undo/redo.
const RF_Public         = 0x00000004; // Can be referenced by external package files.
const RF_Transient      = 0x00004000; // Can't be saved or loaded.
const RF_Standalone		= 0x00080000; // Keep object around for editing even if unreferenced.
const RF_NotForClient	= 0x00100000; // Don't load for game client.
const RF_NotForServer	= 0x00200000; // Don't load for game server.
const RF_NotForEdit		= 0x00400000; // Don't load for editor.
const RF_HasStack		= 0x02000000; // Has execution stack.
const RF_Native			= 0x04000000; // Native.
const RF_PendingDelete	= 0x40000000; // Object is marked for deletion.

// Template base for dynamic arrays (only used for C++ props).
struct Template { var const byte B; };

// A globally unique identifier.
struct Guid
{
	var int A, B, C, D;
};

// A point or direction vector in 3d space.
// Network usage: 10 - 55 bits (depending on distance size of vector)
// NOTE: Pre 227j clients always uses 48 bits of data!
struct nativereplication Vector
{
	var() config float X, Y, Z;
};

// Vector described in 2D space.
// Network usage: 32 bits
struct nativereplication Vector2D
{
	var() config float X, Y;
};

// A plane definition in 3d space.
// Network usage: 64 bits
struct nativereplication Plane extends Vector
{
	var() config float W;
};

// An orthogonal rotation in 3d space.
// Network usage: 3 - 27 bits (lesser the more components are zero).
struct nativereplication Rotator
{
	var() config int Pitch, Yaw, Roll;
};

// Can be used to replicate a packed integer where Value is a positive integer number and MaxValue is the maximum value.
// Value will be clamped between 0-MaxValue value.
// MaxValue MUST be in sync between client and server (as its not network syncronized).
// Do not try to use this as function parameter as it will always fail!
// Network usage: nearest power of two number -1 of bits of data as defined in MaxValue (1, 3, 7, 15, 31 etc are key values).
struct nativereplication PackedInt
{
	var() config int Value;
	var const int MaxValue;
};

// Same as a vector but will be packed in networking as a normal.
// Network usage: 16 bits, or 1 bit if zero value.
struct nativereplication VectorNormal
{
	var() config float X, Y, Z;
};

// An arbitrary coordinate system in 3d space.
struct Coords
{
	var() config vector Origin, XAxis, YAxis, ZAxis;
};

struct Coords2D
{
	var() config vector2d Origin, XAxis, YAxis;
};

// A scale and sheering.
struct Scale
{
	var() config vector Scale;
	var() config float SheerRate;
	var() config enum ESheerAxis
	{
		SHEER_None,
		SHEER_XY,
		SHEER_XZ,
		SHEER_YX,
		SHEER_YZ,
		SHEER_ZX,
		SHEER_ZY,
	} SheerAxis;
};

// A color.
struct Color
{
	var() config byte R, G, B, A;
};

// A bounding box.
struct BoundingBox
{
	var() vector Min, Max;
	var byte IsValid;
};

// A bounding box sphere together.
struct BoundingVolume extends BoundingBox
{
	var plane Sphere;
};

struct Quat
{
    var() config float X,Y,Z,W;
};

struct USScriptCallPair
{
	var Object Object; // Object function being executed on.
	var Object Func; // Function object executing code (or State object).
};

// Advanced animation notify.

enum eAnimNotifyEval {
	ANE_Equal,
	ANE_Greater,
	ANE_Less,
	ANE_GreaterOrEqual,
	ANE_LessOrEqual
};

// Any property types

enum EAnyPropertyType
{
	ANYTYPE_Null,
	ANYTYPE_Int,
	ANYTYPE_Float,
	ANYTYPE_Bool,
	ANYTYPE_String,
	ANYTYPE_Name,
	ANYTYPE_Struct,
	ANYTYPE_Object,
};

//=============================================================================
// Constants.

const MaxInt = 0x7fffffff;
const Pi     = 3.1415926535897932;

//=============================================================================
// Basic native operators and functions.

// Bool operators.
native(129) static final preoperator  bool  !  ( coerce bool A );
native(242) static final operator(24) bool  == ( coerce bool A, coerce bool B );
native(243) static final operator(26) bool  != ( coerce bool A, coerce bool B );
native(130) static final operator(30) bool  && ( coerce bool A, coerce skip bool B );
native(131) static final operator(30) bool  ^^ ( coerce bool A, coerce bool B );
native(132) static final operator(32) bool  || ( coerce bool A, coerce skip bool B );

// Byte operators.
native(133) static final operator(34) byte *= ( out byte A, byte B );
native(134) static final operator(34) byte /= ( out byte A, byte B );
native(135) static final operator(34) byte += ( out byte A, byte B );
native(136) static final operator(34) byte -= ( out byte A, byte B );
native(137) static final preoperator  byte ++ ( out byte A );
native(138) static final preoperator  byte -- ( out byte A );
native(139) static final postoperator byte ++ ( out byte A );
native(140) static final postoperator byte -- ( out byte A );

// Integer operators.
native(141) static final preoperator  int  ~  ( int A );
native(143) static final preoperator  int  -  ( int A );
native(144) static final operator(16) int  *  ( int A, int B );
native(145) static final operator(16) int  /  ( int A, int B );
native(146) static final operator(20) int  +  ( int A, int B );
native(147) static final operator(20) int  -  ( int A, int B );
native(148) static final operator(22) int  << ( int A, int B );
native(149) static final operator(22) int  >> ( int A, int B );
native(196) static final operator(22) int  >>>( int A, int B );
native(150) static final operator(24) bool <  ( int A, int B );
native(151) static final operator(24) bool >  ( int A, int B );
native(152) static final operator(24) bool <= ( int A, int B );
native(153) static final operator(24) bool >= ( int A, int B );
native(154) static final operator(24) bool == ( int A, int B );
native(155) static final operator(26) bool != ( int A, int B );
native(156) static final operator(28) int  &  ( int A, int B );
native(157) static final operator(28) int  ^  ( int A, int B );
native(158) static final operator(28) int  |  ( int A, int B );
native(159) static final operator(34) int  *= ( out int A, float B );
native(160) static final operator(34) int  /= ( out int A, float B );
native(161) static final operator(34) int  += ( out int A, int B );
native(162) static final operator(34) int  -= ( out int A, int B );
native(163) static final preoperator  int  ++ ( out int A );
native(164) static final preoperator  int  -- ( out int A );
native(165) static final postoperator int  ++ ( out int A );
native(166) static final postoperator int  -- ( out int A );

// Integer functions.
native(167) static final Function     int  Rand  ( int Max ); // Maximum value is 0x7FFF (32,767)
native(249) static final function     int  Min   ( int A, int B );
native(250) static final function     int  Max   ( int A, int B );
native(251) static final function     int  Clamp ( int V, int A, int B );

// Float operators.
native(169) static final preoperator  float -  ( float A );
native(170) static final operator(12) float ** ( float A, float B );
native(171) static final operator(16) float *  ( float A, float B );
native(172) static final operator(16) float /  ( float A, float B );
native(173) static final operator(18) float %  ( float A, float B );
native(174) static final operator(20) float +  ( float A, float B );
native(175) static final operator(20) float -  ( float A, float B );
native(176) static final operator(24) bool  <  ( float A, float B );
native(177) static final operator(24) bool  >  ( float A, float B );
native(178) static final operator(24) bool  <= ( float A, float B );
native(179) static final operator(24) bool  >= ( float A, float B );
native(180) static final operator(24) bool  == ( float A, float B );
native(210) static final operator(24) bool  ~= ( float A, float B );
native(181) static final operator(26) bool  != ( float A, float B );
native(182) static final operator(34) float *= ( out float A, float B );
native(183) static final operator(34) float /= ( out float A, float B );
native(184) static final operator(34) float += ( out float A, float B );
native(185) static final operator(34) float -= ( out float A, float B );

// Float functions.
native(186) static final function     float Abs   ( float A );
native(187) static final function     float Sin   ( float A );
native(188) static final function     float Cos   ( float A );
native(197) static final function     float Acos  ( float A );
native(189) static final function     float Tan   ( float A );
native(190) static final function     float Atan  ( float A );
native(191) static final function     float Exp   ( float A );
native(192) static final function     float Loge  ( float A );
native(193) static final function     float Sqrt  ( float A );
native(194) static final function     float Square( float A );
native(195) static final function     float FRand ();
native(244) static final function     float FMin  ( float A, float B );
native(245) static final function     float FMax  ( float A, float B );
native(246) static final function     float FClamp( float V, float A, float B );
native(247) static final function     float Lerp  ( float Alpha, float A, float B );
native(248) static final function     float Smerp ( float Alpha, float A, float B );

// Vector operators.
native(211) static final preoperator  vector -     ( vector A );
native(212) static final operator(16) vector *     ( vector A, float B );
native(213) static final operator(16) vector *     ( float A, vector B );
native(296) static final operator(16) vector *     ( vector A, vector B );
native(214) static final operator(16) vector /     ( vector A, float B );
native(215) static final operator(20) vector +     ( vector A, vector B );
native(216) static final operator(20) vector -     ( vector A, vector B );
native(275) static final operator(22) vector <<    ( vector A, rotator B );
native(276) static final operator(22) vector >>    ( vector A, rotator B );
native(217) static final operator(24) bool   ==    ( vector A, vector B );
native(218) static final operator(26) bool   !=    ( vector A, vector B );
native(219) static final operator(16) float  Dot   ( vector A, vector B );
native(220) static final operator(16) vector Cross ( vector A, vector B );
native(221) static final operator(34) vector *=    ( out vector A, float B );
native(297) static final operator(34) vector *=    ( out vector A, vector B );
native(222) static final operator(34) vector /=    ( out vector A, float B );
native(223) static final operator(34) vector +=    ( out vector A, vector B );
native(224) static final operator(34) vector -=    ( out vector A, vector B );
native(410) static final operator(24) bool   ~=    ( vector A, vector B );

// Vector functions.
native(225) static final function float  VSize  ( vector A );
native(253) static final function float  VSizeSq( vector A ); // 227j: SizeSquared of vector (faster than normal VSize)
native(271) static final function float  VSize2D( vector A ); // 227j: VSize of a vector where Z axis is ignored.
native(273) static final function float  VSize2DSq( vector A ); // 227j: VSizeSq of a vector where Z axis is ignored.
native(226) static final function vector Normal ( vector A );
native(274) static final function vector Normal2D( vector A ); // 227j: Normalize a vector where Z axis is ignored.
native(227) static final function        Invert ( out vector X, out vector Y, out vector Z );
native(252) static final function vector VRand  ( );
native(300) static final function vector MirrorVectorByNormal( vector Vect, vector Normal );
native(228) static final function vector RandomSpreadVector(float A); //Return a random unit vector within a cone of spread_degrees (A).

// Rotator operators and functions.
native(142) static final operator(24) bool ==     ( rotator A, rotator B );
native(203) static final operator(26) bool !=     ( rotator A, rotator B );
native(287) static final operator(16) rotator *   ( rotator A, float    B );
native(288) static final operator(16) rotator *   ( float    A, rotator B );
native(289) static final operator(16) rotator /   ( rotator A, float    B );
native(290) static final operator(34) rotator *=  ( out rotator A, float B  );
native(291) static final operator(34) rotator /=  ( out rotator A, float B  );
native(316) static final operator(20) rotator +   ( rotator A, rotator B );
native(317) static final operator(20) rotator -   ( rotator A, rotator B );
native(318) static final operator(34) rotator +=  ( out rotator A, rotator B );
native(319) static final operator(34) rotator -=  ( out rotator A, rotator B );
native(229) static final function GetAxes         ( rotator A, out vector X, out vector Y, out vector Z );
native(230) static final function GetUnAxes       ( rotator A, out vector X, out vector Y, out vector Z );
native(320) static final function rotator RotRand ( optional bool bRoll );
native      static final function rotator OrthoRotation( vector X, vector Y, vector Z );
native      static final function rotator Normalize( rotator Rot );

// String operators.
native(112) static final operator(40) string $  ( coerce string A, coerce string B );
native(168) static final operator(40) string @  ( coerce string A, coerce string B );
native(115) static final operator(24) bool   <  ( string A, string B );
native(116) static final operator(24) bool   >  ( string A, string B );
native(120) static final operator(24) bool   <= ( string A, string B );
native(121) static final operator(24) bool   >= ( string A, string B );
native(122) static final operator(24) bool   == ( string A, string B );
native(123) static final operator(26) bool   != ( string A, string B );
native(124) static final operator(24) bool   ~= ( string A, string B );
// rjp --
native(322) static final operator(44) string $= ( out	 string A, coerce string B );
native(323) static final operator(44) string @= ( out    string A, coerce string B );
native(324) static final operator(45) string -= ( out    string A, coerce string B );
// -- rjp

// String functions.
native(125) static final function int    Len    ( coerce string S );

//227 enhancement - returns position of SubStr in Src after Start charcters (-1 is returned if SubStr can not be found).
//If start is greater then number of characters in string Src, then standard InStr function is called.
native(126) static final function int    InStr  ( coerce string S, coerce string t, optional int Start);
native(127) static final function string Mid    ( coerce string S, int i, optional int j );
native(128) static final function string Left   ( coerce string S, int i );
native(234) static final function string Right  ( coerce string S, int i );
native(235) static final function string Caps   ( coerce string S );
native(236) static final function string Chr    ( int i );
native(237) static final function int    Asc    ( string S, optional int Pos );

// Converts Value to string; if length of string(Value) is less than MinWidth, then the digits are prefixed by
// padding zeroes to make length of the resulting string equal to MinWidth
// Examples: IntToStr(12, 5) == "00012", IntToStr(-12, 5) == "-0012", IntToStr(123, 2) == "123"
native(325) static final function string IntToStr(int Value, int MinWidth);

/* Lower-case some text */
native(238) static final function string Locs( string InStr );
/* Replace parts of some text */
native(239) static final function string ReplaceStr( string Text, string FindStr, skip string ReplaceWith, optional bool bCaseInsensitive );

// Call a function by name and string parameters.
// Parms are parsed the same way as ConsoleCommands.
// Returns True if function was found and executed.
// @ ReturnValue = filled with the return value if exists.
native(390) final function bool ExecFunctionStr( name FuncName, string Parms, optional out string ReturnVal );

// Convert string to name (name length is limited to 63 chars).
// If bFind, returns None if name entry has not already been registered.
static native(391) final function name StringToName( string S, optional bool bFind );

//  Determining if a string Str starts with other string SubStr.
native(392) static final function bool StartsWith(coerce string Str, coerce string SubStr, optional bool bCaseInsensitive);

/* Sort a dynamic array:
SortCode, a simple boolean function MUST be used for this or else it will return false without doing anything:
array<int> would use have following rules:
 - Return parameter MUST be a boolean.
final function bool SortInteger( int A, int B ) <- There MUST be 2 parms in same type as the dynamic array parm is.
{
	return (A<B); <- There may ONLY be a single return value as the contents of the function.
} */
native(240) static final function bool SortArray( ArrayProperty Prop, Function SortCode );

/* Sort a static array, follows same rules as dynamic array:
SortSize - Number of elements that should be sorted, default value is the size of the array. */
native(241) static final function bool SortStaticArray( Property Prop, Function SortCode, optional int SortSize );


// 227f: FCoords Maths
native(330) static final operator(16) Coords * ( Coords A, Coords B ); // Rotate coords A by B
native(331) static final operator(34) Coords *= ( out Coords A, Coords B );
native(332) static final operator(34) Coords *= ( out Coords A, rotator B ); // Rotate coords by rotator
native(333) static final operator(34) Coords /= ( out Coords A, rotator B ); // Inverted rotate coords by rotator
native(334) static final operator(34) vector *= ( out vector A, Coords B ); // Rotate vector by coords
native(335) static final function Coords GetUnitCoords(); // Get default forward direction coords.

// Transform a rotator by some specific floor normal (using rotator Yaw/Pitch components from incoming rotator).
static native(336) final function TransformRotatorByNormal( out rotator R, vector FloorNormal );

// Same as above but instead do it on an incoming coords.
static native(337) final function TransformCoordsByNormal( out Coords C, vector FloorNormal );

// Object operators.
native(114) static final operator(24) bool == ( Object A, Object B );
native(119) static final operator(26) bool != ( Object A, Object B );

// Name operators.
native(254) static final operator(24) bool == ( name A, name B );
native(255) static final operator(26) bool != ( name A, name B );

// Load an enitre package to memory.
// @ PackageName - The name of package to load.
// @ ListType - Type of objects it should list.
// @ PckContents - The list of objects it found from it.
native(257) static final function bool LoadPackageContents( string PackageName, optional Class<Object> ListType, optional out array<Object> PckContents );

//=============================================================================
// General functions.

// Logging.
native(231) final static function Log( coerce string S, optional name Tag );
native(232) final static function Warn( coerce string S );
// 227j @ DefaultStr - If non-empty, it will return that as fallback if not found, and not throw error on log.
native static function string Localize( string SectionName, string KeyName, string PackageName, optional string DefaultStr );

// Goto state and label.
native(113) final function GotoState( optional name NewState, optional name Label );
native(281) final function bool IsInState( name TestState );
native(284) final function name GetStateName();

// Objects.
native(258) static final function bool ClassIsChildOf( class TestClass, class ParentClass );
native(303) final function bool IsA( name ClassName );

// Probe messages.
native(117) final function Enable( name ProbeFunc );
native(118) final function Disable( name ProbeFunc );

// Properties.
native final function string GetPropertyText( string PropName ); // don't use on arrays, only designed to work with structs!
native final function SetPropertyText( string PropName, string PropValue ); // don't use on arrays, only designed to work with structs!
native static final function string ExportFullProperties( optional bool bDelta /*=true*/ ); // Export a full list of properties (skipping 'private' variables and doesn't export 'export' objects), properties seperated by \r\n linebreaks.
																							// bDelta = if true, only export modified properties from superclass/class defaults.
native static final function ImportFullProperties( string S ); // Import a full list of properties (skipping 'private' and 'const' variables).
native static final function name GetEnum( object E, int i );
native static final function object DynamicLoadObject( string ObjectName, class ObjectClass, optional bool MayFail );

// Configuration.
native(536) final function SaveConfig( optional bool bNoWriteINI /* =false (if true, don't write data instantly to ini file, wait til next SaveConfig call) */ );
native(537) static final function ClearConfig( optional string PropName /* =all properties */ );
native(543) static final function ResetConfig();
native static final function StaticSaveConfig();
native static final function array<string> GetPerObjectNames( string ININame, optional string ObjectClass, optional int MaxResults /*unlimited if unspecified*/ );

// U227 added functions:
native(198) static final function color MakeColor( byte R, byte G, byte B, optional byte A );

/* Very fast:
Find an object based on object name (and outer name), example:
SomeTexture = FindObject(Class'Texture',"Engine.P_Pawn"); */
native(600) static final function Object FindObject( Class<Object> ObjClass, string ObjectName );

/* Very fast:
Returns the parent class of the desired class (defaults to current class) */
native(601) static final function Class GetParentClass( optional Class ObjClass );

/* Slow:
Iterate through all objects and return the desired ones.
@InOuter = New in 227j, specify desired outer, or if you specify Property as BaseClass and a Struct as InOuter, you will iterate struct parms:
	foreach AllObjects(class'Property',P,Struct'Vector')*/
native(602) static final iterator function AllObjects( class<Object> BaseClass, out Object Obj, optional Object InOuter );

/* Fast:
Iterate through all files of a type (file extension are "unr", "uax", "u", "utx", "umx" or empty string for all files). */
native(603) static final iterator function AllFiles( string FileExtension, string FilePrefix, out string FileName );

/* Very fast:
Find an object based on object index (SomeObject.ObjectIndex) */
native(644) static final function Object FindObjectIndex( int Index );

// Return a random number within the given range.
static final native function float RandRange( float Min, float Max );
static final native function int RandIntRange( int Min, int Max ); // Note: As oppose to Rand(X) this supports random numbers up to 1,073,741,823

// 227 Implementation of quaternion by Raven based on work of Usaar33 and BeyondUnrealForums
// Functions used to convert Quat to rotator and rotator to quat. Fixed up by .:..:

native(620) static final function Quat CoordsToQuat( Coords C );
native(621) static final function Coords QuatToCoords( Quat Q, optional vector Origin );
native(604) static final function Quat RotationToQuat( rotator R );
native(605) static final function rotator QuatToRotation( Quat Q );
native(606) static final function Quat MakeQuat(float x, float y, float z, float w);
//Add a rotator relative to the first one. Note: R1 & R2 != R2 & R1.
native(607) static final operator(12) rotator & ( rotator R1, rotator R2 );
//mult quad by vector
native(608) static final operator(16) Quat * ( Quat A, Vector B );
//mult quad by vector (other order)
native(609) static final operator(16) Quat * ( Vector B, Quat A );
//mult quads by scalar
native(610) static final operator(16) Quat * ( Quat A, float B );
//mult quads by scalar (other order)
native(611) static final operator(16) Quat * ( float B, Quat A );
// Multiply 2 Quats. Note: Q1 * Q2 != Q2 * Q1.
native(612) static final operator(16) Quat * ( Quat Q1, Quat Q2 );
//add quads
native(613) static final operator(20) Quat + ( Quat A, Quat B );
//subtracts quads
native(614) static final operator(20) Quat - ( Quat A, Quat B );
//add quads to
native(615) static final operator(34) Quat += ( out Quat A, Quat B );
//subtracts quads from
native(616) static final operator(34) Quat -= ( out Quat A, Quat B );
//mult by scalar
native(617) static final operator(34) Quat *= ( out Quat A, float B );
//divide by scalar
native(618) static final operator(34) Quat /= ( out Quat A, float B );
//conjugate (negative of vector part)
native(619) static final preoperator Quat ~ ( out Quat A );
// Dot product of axes to get cos of angle  #Warning some people use .W component here too !
native(622) static final operator(16) float Dot ( Quat A, Quat B );
//get unit vector part.
native(623) static final function vector QuatGetVect(Quat A);
//get size (faster)
native(624) static final function float QuatSizeSquared(Quat A);
//get size (magnitude)
native(625) static final function float QuatSize(Quat A);
//normalize
native(626) static final function Quat QuatNormal(Quat A);
//get angle about quad vector axis
native(627) static final function float QuatGetAngle(Quat A);
//get unit vector along rot.
native(628) static final function vector QuatGetAxis(Quat A);
//rotate A by B
native(629) static final function Quat QuatRotate(Quat A, Quat B);
//rotate vector B by Quat A
native(630) static final function Vector QuatVRotate(Quat A, Vector B);
// No-frills spherical interpolation. Assumes aligned quaternions, and the output is not normalized.
// If bAlign, then normalize and align both quaternions before slerping them.
native(631) static final function Quat QuatSlerp( Quat A, Quat B, float C, optional bool bAlign );
// Takes a vector representing an axis and an angle in radians.
// Returns the quaternion representing a rotation of Theta about the axis.
native(632) static final function Quat QuatFromAxisAndAngle(Vector Axis, float Angle);
// Error measure (angle) between two quaternions, ranged [0..1]
native(633) static final function float QuatError(Quat A, Quat B);
// Ensure quat1 points to same side of the hypersphere as quat2
native(634) static final function Quat AlignQuatWith(Quat A, Quat B);
// Ceil
native(635) static final function int Ceil( float f );

native final function vector LerpVector( vector Dest, vector Src, float Alpha ); // Dest * Alpha + Src * (1-Alpha)
native final function rotator LerpRotation( rotator Dest, rotator Src, float Alpha ); // ^ Same as above but uses shortest rotation.
native final function rotator SlerpRotation( rotator Dest, rotator Src, float Alpha ); // Will use quaternion for actual shortest rotation.

// Give all linkers (almost) full information.
// PackageName = the name of the package (i.e: Engine)
// FileName = the filename of the package (i.e: ..\System\Engine.u)
// GUID = an 16 characters GUID identifier of the package.
// NmCount = name count of this package.
// ImpCount = import count of this package.
// ExpCount = export count of this package.
// FileSize = file size of this package (in bytes).
native(636) static final iterator function AllLinkers( out name PackageName, out string FileName, out string GUID,
		out int NmCount, out int ImpCount, out int ExpCount, out int FileSize );

// Return the default object from some desired class (in other words Class'SomeClass'.Default.SomeVar)
// Note: this object should be threated carefully as it may easly give some unexpected results.
native(637) static final function Object GetDefaultObject( Class ObjClass );

// Split a string into two parts with Divider as the cut-off point.
// Returns true when the string was divided.
native(638) static final function bool Divide( coerce string Src, string Divider, out string LeftPart, out string RightPart );

// Returns a string from between Left and Right Divider:
// if bAdvanced is false:
// Src = string1(string2)string3
// LeftDivide = (
// RightDivider = )
// result MidString = string2
// if bAdvanced is true it takes occurance of LeftDivider into account:
// Src = string1(string2(string3)string4)string5
// LeftDivide = (
// RightDivider = )
// result MidString = string2(string3)string4
native(639) static final function bool ExtractString(string Src, string LeftDivider, string RightDivider, out string MidString, optional bool bAdvanced);

// Get or change the size of a dynamic array
// Also works with using: ArrayProperty.Size() - ArrayProperty.SetSize(x) - ArrayProperty.Empty() operators.
native(640) static final function int Array_Size( out array<template> Ar, optional int SetSize );

// Insert space into a dynamic array, returns false if bad parameters (or array is const or private and inaccessible)
// Also works with using: ArrayProperty.Insert(x,y) operator.
native(641) static final function bool Array_Insert( out array<template> Ar, int Offset, optional int Count );

// Remove space from a dynamic array, returns false if fails.
// Also works with using: ArrayProperty.Remove(x,y) operator.
native(642) static final function bool Array_Remove( out array<template> Ar, int Offset, optional int Count );

//Returns how long the app has been running. Subtract in the same function to use for execution time (this is most ideal for benchmarking code)
Native(643) static final function float AppSeconds();

// Currently executing code in UnrealEd.
native(645) static final function bool AppIsEditor();

// Find a function by name.
native(646) static final function Function FindFunction( name FuncName, optional name TestState );

// Get current UnrealScript function call stack.
// Final entry will be the function calling this function.
native(647) static final function GetCallStack( out array<USScriptCallPair> Stack );

//=============================================================================
// Engine notification functions.

//
// Called immediately when entering a state, while within
// the GotoState call that caused the state change.
//
event BeginState();

//
// Called immediately before going out of the current state,
// while within the GotoState call that caused the state change.
//
event EndState();

//
// Called when game is about to shut down, for all objects.
//
event AppShutdown();

//
// Object was deleted using 'delete' operator in UScript (not from garbage collector).
//
event ObjectDeleted();

//
// Called when an object property has been changed with properties window, SET command or SetPropertyText (called on both client and in editor).
// @ ParentProperty - Incase Property is a struct member, this is set to the outer most property name (i.e: Property='X' and ParentProperty='Location').
//
event OnPropertyChange( name Property, name ParentProperty );

// Same as OnPropertyChange but called when editing defaultproperties or advanced options.
static event StaticPropertyChange( name Property, name ParentProperty );

// Get Object index name of object, can be passed in as a string property to get correct reference passed (such as ConsoleCommand/ExecFunctionStr/FindObject/SetPropertyText)
// Returned name is like: MaleTwo'#845'
simulated final function string GetPointerName()
{
	return string(Class.Name)$"'#"$string(ObjectIndex)$"'";
}

defaultproperties
{
}
