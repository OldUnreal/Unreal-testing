//=============================================================================
// TerrainInfo, largescale outdoors terrain.
//=============================================================================
class TerrainInfo extends Info
	native;

#exec Texture Import File=Textures\TerrainInfo.pcx Name=S_TerrainInfo Mips=Off Flags=2

enum ETexMapAxis
{
	TEXMAPAXIS_XY,
	TEXMAPAXIS_XZ,
	TEXMAPAXIS_YZ,
};
struct export TerrainMaterial
{
	var const array<byte> PaintMap;
	
	var() Texture		Texture;
	var() rotator		LayerRotation;
	var() float			UScale,VScale,UPan,VPan;
	var() ETexMapAxis	TextureMapAxis;
};
struct export DecorationLayer
{
	var const array<byte> PaintMap;
	
	var() array<Mesh>	Mesh;				// Random mesh for this layer.
	var() float			ScaleMultiplier[2];	// Random drawscale range of the decor mesh.
	var() float			VisibilityRadius;	// Visibility radius of the deco (0 = unlimited).
	var() float			Density;			// Density of the decorations.
	var() float			HeightOffset;		// Height offset from ground/ceiling.
	var int				Seed;
	var() bool			bAlignToTerrain;	// Decoration should be rotation aligned to terrain.
	var() bool			bRandomYaw;			// Randomized direction of the decos.
};
struct export TerrainDataInfo
{
	var const editconst array<byte> HeightMap;
	var const editconst array<int> EdgeTurn,Visibility;
};

var() const array<TerrainMaterial> TerrainMaterials;
var() const int SizeX,SizeY; // Terrain dimensions.
var() const vector TerrainScale; // Scale of a single terrain quad (Z being the terrain height).
var() const array<DecorationLayer> DecoLayers;
var() const bool bSimpleCollision; // Terrain should use simplified collision (only blocking actors by their feet/head).
var() const bool bIsCeiling; // Terrain is ceiling (flip direction).

var const editconst TerrainDataInfo TerrainData;
var pointer<class UTerrainMesh*> TerrainPrimitive;
var pointer<struct FTerrainLight*> TerrainLightData;

simulated function OnMirrorMode()
{
	DrawScale3D.Y *= -1.f;
}

defaultproperties
{
	bWorldGeometry=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bProjTarget=true
	bPathCollision=true
	bBlockRigidBodyPhys=true
	bSimpleCollision=true
	bUseMeshCollision=true
	bHidden=false
	SizeX=64
	SizeY=64
	TerrainScale=(X=64,Y=64,Z=2048)
	Texture=Texture'S_TerrainInfo'
	RenderIteratorClass=class'TerrainInfoRender'
	
	bStatic=true
	RemoteRole=ROLE_None
}