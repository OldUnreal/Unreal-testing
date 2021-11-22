// Weather particle emitter
Class XWeatherEmitter extends XParticleEmitter
	Native
	Abstract;

#EXEC TEXTURE IMPORT FILE="Textures\S_WeatherE.bmp" NAME="S_WeatherEmitter" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

#exec mesh import mesh=EmitSheetM anivfile=Models\EmitSheetM_a.3d datafile=Models\EmitSheetM_d.3d x=0 y=0 z=0 mlod=0
#exec mesh origin mesh=EmitSheetM x=0 y=0 z=0
#exec mesh sequence mesh=EmitSheetM seq=All startframe=0 numframes=1

#exec meshmap new meshmap=EmitSheetM mesh=EmitSheetM
#exec meshmap scale meshmap=EmitSheetM x=0.12500 y=0.12500 z=0.25000

enum EWeatherAreaType
{
	EWA_Box, // Use Location+AppearArea for rain appearance area.
	EWA_Zone, // Use current zone as the appearance area.
	EWA_Brush,
};
enum EFallingType
{
	EWF_Rain, // Rain it down (uses flat mesh sheet)
	EWF_Snow, // Snow it down
	EWF_Dust, // Make it slowly move around
	EWF_Neighter // Nothing particular, just fall it down.
};

// Natively updated variables, do not touch.
var transient float NextParticleTime,SpawnInterval;
var transient vector LastCamPosition,VecArea[2];
var transient Coords CachedCoords,TransfrmCoords;
var const array<XRainRestrictionVolume> NoRainBounds;
var const Mesh SheetModel;
var array<XEmitter> WallHitEmitters,WaterHitEmitters;
var const Volume RainVolume;
var pointer<FRainAreaTree*> RainTree;

var() EHitEventType WallHitEvent; // Action on particle wall hit
var() name WallHitEmitter;
var() name RainVolumeTag; // Matching volume if AppearAreaType=EWA_Brush
var() float WallHitMinZ; // Minimum floor Z value for the wallhit emitter FX to be spawned.
var() EHitEventType WaterHitEvent; // Action on entering water
var() name WaterHitEmitter;
var() array<Texture> PartTextures;
var() RangeVector Position,AppearArea;
var() RangeVector ParticlesColor;
var() FloatRange Lifetime,Speed,Size;
var() EWeatherAreaType AppearAreaType; /* Box - Uses AppearArea as rain range.
Zone - Uses current Zone this actor is inside of as rain area.
Brush - Uses matching volume with RainVolumeTag as rain area. */

var() EFallingType WeatherType;
var() int ParticleCount;
var() ERenderStyle PartStyle;
var() FloatRange FadeOutDistance;

// Bitmask:
var transient bool bUseAreaSpawns,bParticleColorEnabled;

var bool bIsEnabled; // Should be making those particles?
var transient bool bBoundsDirty; // Should update all internal bounds next tick.

native final function AddNoRainBounds( XRainRestrictionVolume NewVolume );
native final function RemoveNoRainBounds( XRainRestrictionVolume OldVolume );
native final function SetRainVolume( Volume NewVolume );

defaultproperties
{
	ParticleCount=250
	PartTextures(0)=Texture'S_Pawn'
	PartStyle=STY_Translucent
	Lifetime=(Min=0.4,Max=0.7)
	bIsEnabled=True
	Speed=(Min=300,Max=500)
	Size=(Min=0.15,Max=0.2)
	Position=(X=(Min=-50,Max=200),Y=(Min=-200,Max=200),Z=(Min=-50,Max=400))
	AppearAreaType=EWA_Zone
	Texture=Texture'S_WeatherEmitter'
	SheetModel=Mesh'EmitSheetM'
	ScaleGlow=0.8
	FadeOutDistance=(Min=50,Max=250)
	bDirectional=True
	WallHitMinZ=0.9
	bNotifyPositionUpdate=true
}
