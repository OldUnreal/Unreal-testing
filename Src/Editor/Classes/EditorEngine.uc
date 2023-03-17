//=============================================================================
// EditorEngine: The UnrealEd subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class EditorEngine extends Engine extends FNotifyHook
	Native
	Transient;

#exec Texture Import File=Textures\B_MenuDn.pcx Mips=Off
#exec Texture Import File=Textures\B_MenuUp.pcx Mips=Off
#exec Texture Import File=Textures\B_CollOn.pcx Mips=Off
#exec Texture Import File=Textures\B_CollOf.pcx Mips=Off
#exec Texture Import File=Textures\B_PlyrOn.pcx Mips=Off
#exec Texture Import File=Textures\B_PlyrOf.pcx Mips=Off
#exec Texture Import File=Textures\B_LiteOn.pcx Mips=Off
#exec Texture Import File=Textures\B_LiteOf.pcx Mips=Off

#exec Texture Import File=Textures\Bad.pcx
#exec Texture Import File=Textures\Bkgnd.pcx
#exec Texture Import File=Textures\BkgndHi.pcx

#exec Texture Import File=Textures\backdropcol.bmp Mips=Off Name="TexPreviewBack"

#exec Texture Import File=Textures\ModeCamera.pcx Name=J_EM_ModeCamera Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeVertex.pcx Name=J_EM_ModeVertex Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeSheer.pcx Name=J_EM_ModeSheer Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeScale.pcx Name=J_EM_ModeScale Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeStretch.pcx Name=J_EM_ModeStretch Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeSnapScale.pcx Name=J_EM_ModeSnapScale Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeRotate.pcx Name=J_EM_ModeRotate Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\TexturePan.pcx Name=J_EM_TexturePan Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\TextureRotate.pcx Name=J_EM_TextureRotate Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeBrushClip.pcx Name=J_EM_ModeBrushClip Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeFaceDrag.pcx Name=J_EM_ModeFaceDrag Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\ModeTerrainEdit.pcx Name=J_EM_ModeTerrainEdit Group="EditMode" Mips=Off Flags=2
#exec Texture Import File=Textures\SphereIc.pcx Name=J_SphereMarker Mips=Off Flags=2

// Editor mode settings (mirrored in Engine/UnCamera.h).
const noexport EM_None			= 0;	// Gameplay, editor disabled.
const noexport EM_ViewportMove	= 1;	// Move viewport normally.
const noexport EM_ViewportZoom	= 2;	// Move viewport with acceleration.
const noexport EM_BrushRotate	= 5;	// Rotate brush.
const noexport EM_BrushSheer	= 6;	// Sheer brush.
const noexport EM_BrushScale	= 7;	// Scale brush.
const noexport EM_BrushStretch	= 8;	// Stretch brush.
const noexport EM_TexturePan	= 11;	// Pan textures.
const noexport EM_TextureRotate	= 13;	// Rotate textures.
const noexport EM_TextureScale	= 14;	// Scale textures.
const noexport EM_BrushSnap		= 18;	// Brush snap-scale.
const noexport EM_TexView		= 19;	// Viewing textures.
const noexport EM_TexBrowser	= 20;	// Browsing textures.
const noexport EM_MeshView		= 21;	// Viewing mesh.
const noexport EM_MeshBrowser	= 22;	// Browsing mesh.
const noexport EM_BrushClip		= 23;	// brush Clipping.
const noexport EM_VertexEdit	= 24;	// Multiple Vertex Editing.
const noexport EM_FaceDrag		= 25;	// Face Dragging.
const noexport EM_TerrainEdit	= 26;	// Terrain heightmap.

// Objects.
var const Level       Level;
var const Model       TempModel,bspProcessModel;
var const Texture     CurrentTexture;
var const Font        CurrentFont;
var const Class       CurrentClass;
var pointer<class UTransactor*>			Trans;
var pointer<class UTextBuffer*>			Results;
var pointer<class WObjectProperties*>	ActorProperties;
var pointer<class WObjectProperties*>	LevelProperties;
var pointer<class WConfigProperties*>	Preferences;
var pointer<class WProperties*>			UseDest;
var int AutosaveCounter;

// Icons.
var Texture MenuUp, MenuDn;
var Texture CollOn, CollOff;
var Texture PlyrOn, PlyrOff;
var Texture LiteOn, LiteOff;
var Texture BackPrev;
var Texture TerrainMarker;

// Textures.
var Texture Bad, Bkgnd, BkgndHi;

// Toggles.
var const bool FastRebuild, Bootstrapping;

// Other variables.
var const config int AutoSaveIndex;
var const int AutoSaveCount, Mode, ClickFlags;
var const float MovementSpeed;
var const Object ParentContext;
var const vector ClickLocation;
var const plane ClickPlane;

// Misc.
var const array<Object> Tools;
var const Class BrowseClass;

// Grid.
var(Grid) config bool GridEnabled;
var(Grid) config bool SnapVertices;
var(Grid) config bool AffectRegion;
var(Grid) config bool TextureLock;
var(Grid) config bool SelectionLock;
var(Grid) config float SnapDistance;
var(Grid) config vector GridSize;

// Rotation grid.
var(RotationGrid) config bool RotGridEnabled;
var(RotationGrid) config rotator RotGridSize;

// Advanced.
var(Advanced) config float FovAngleDegrees;
var transient bool GodMode; // obsolete
var(Advanced) config bool UnlitMeshViewer; // Meshes in mesh browser should be drawn unlit instead of single light source lit.
var(Advanced) config bool FreeMeshView; // Mesh browser viewport controls allows for free flying camera.
var(Advanced) config bool SaveLevelSummary; // Should include LevelSummary with the level? Will result in game being able to load preview info on menu, but breaks compatibility with pre-226 versions.
var(Advanced) config bool AutoSave;
var(Advanced) config byte AutosaveTimeMinutes;
var(Advanced) config bool AskSave; // Whenever you save level, ask if should overwrite file if the old filesize is larger then new one.
var(Advanced) config string GameCommandLine; // Commandline to append whenever you play level from editor, you can use it to boot level with mutators etc.
var(Advanced) config array<string> EditPackages;
var(Advanced) config string CodePath; // Relative path for source codes to launcher exe when compiling with UCC make
var(Advanced) config bool AlwaysPermanentBrush; // Red builder brush is always transformed permanently whenever modified.
var(Advanced) config bool bMultiThreadBSPBuild; // Enable multi-threading to BSP rebuilder.

// Color preferences.
var(Colors) config color
	C_WorldBox,
	C_GroundPlane,
	C_GroundHighlight,
	C_BrushWire,
	C_Pivot,
	C_Select,
	C_Current,
	C_AddWire,
	C_SubtractWire,
	C_GreyWire,
	C_BrushVertex,
	C_BrushSnap,
	C_Invalid,
	C_ActorWire,
	C_ActorHiWire,
	C_Black,
	C_White,
	C_Mask,
	C_SemiSolidWire,
	C_NonSolidWire,
	C_WireBackground,
	C_WireGridAxis,
	C_ActorArrow,
	C_ScaleBox,
	C_ScaleBoxHi,
	C_ZoneWire,
	C_Mover,
	C_OrthoBackground;

var const int NumberOfCPUs;
var bool bAbortBSPBuild;
var pointer<const TCHAR*> BuildStageTitle;

struct CompileError
{
	var string ErrorMsg,File;
	var int Line;
	var name MsgType;
};
var array<CompileError> CompilerError; // List of script compiler errors from last build.

enum noexport EEditorInput
{
	VK_0, VK_1, VK_2, VK_3, VK_4, VK_5, VK_6, VK_7, VK_8, VK_9,
	VK_A, VK_B, VK_C, VK_D, VK_E, VK_F, VK_G, VK_H, VK_I, VK_J, VK_K, VK_L, VK_M, VK_N, VK_O, VK_P, VK_Q, VK_R, VK_S, VK_T, VK_U, VK_V, VK_W, VK_X, VK_Y, VK_Z,
	VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10, VK_F11, VK_F12,
	VK_PLUS, VK_MINUS, VK_ENTER, VK_SPACE, VK_INSERT, VK_HOME, VK_PGUP, VK_PGDN, VK_END, VK_DELETE, VK_TAB, VK_BACKSPACE, VK_PAUSE, VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_MULTI, VK_DIVISION, VK_ESCAPE,
	VK_NUM0, VK_NUM1, VK_NUM2, VK_NUM3, VK_NUM4, VK_NUM5, VK_NUM6, VK_NUM7, VK_NUM8, VK_NUM9,
};
struct export EdKeyBinding
{
	var() config EEditorInput Key;
	var() config bool bAlt, bShift, bCtrl;
	var() config string Cmd;
};
var(Advanced) config array<EdKeyBinding> KeyBindings;

struct export EditModeType
{
	var string Tooltip;
	var Texture Image;
	var int Mode;
};
var array<EditModeType> EditModeList;

struct export TerrainModeSettings
{
	var int Mode,Index;
	var float Radius,InnerRadius,Strength;
	var TerrainInfo Terrain;
};
var const TerrainModeSettings TerrainSettings;

defaultproperties
{
	MenuUp=B_MenuUp
	MenuDn=B_MenuDn
	CollOn=B_CollOn
	CollOff=B_CollOf
	PlyrOn=B_PlyrOn
	PlyrOff=B_PlyrOf
	LiteOn=B_LiteOn
	Bad=Bad
	Bkgnd=Bkgnd
	BkgndHi=BkgndHi
	TerrainMarker=Texture'J_SphereMarker'
	GridSize=(X=16,Y=16,Z=16)
	BackPrev=TexPreviewBack
	AlwaysPermanentBrush=True
	CodePath="..\\"
	SaveLevelSummary=True
	bMultiThreadBSPBuild=true
	TerrainSettings=(Radius=0.32,Strength=1)
	
	EditModeList.Add((Mode=EM_ViewportMove,Image=Texture'J_EM_ModeCamera',Tooltip="Camera Movement"))
	EditModeList.Add((Mode=EM_VertexEdit,Image=Texture'J_EM_ModeVertex',Tooltip="Vertex Editing"))
	EditModeList.Add((Mode=EM_BrushSheer,Image=Texture'J_EM_ModeSheer',Tooltip="Brush Sheering"))
	EditModeList.Add((Mode=EM_BrushScale,Image=Texture'J_EM_ModeScale',Tooltip="Actor Scaling"))
	EditModeList.Add((Mode=EM_BrushStretch,Image=Texture'J_EM_ModeStretch',Tooltip="Actor Stretching"))
	EditModeList.Add((Mode=EM_BrushSnap,Image=Texture'J_EM_ModeSnapScale',Tooltip="Snapped Brush Scaling"))
	EditModeList.Add((Mode=EM_BrushRotate,Image=Texture'J_EM_ModeRotate',Tooltip="Brush Rotate"))
	EditModeList.Add((Mode=EM_TexturePan,Image=Texture'J_EM_TexturePan',Tooltip="Texture Pan"))
	EditModeList.Add((Mode=EM_TextureRotate,Image=Texture'J_EM_TextureRotate',Tooltip="Texture Rotate"))
	EditModeList.Add((Mode=EM_BrushClip,Image=Texture'J_EM_ModeBrushClip',Tooltip="Brush Clipping"))
	//EditModeList.Add((Mode=EM_FaceDrag,Image=Texture'J_EM_ModeFaceDrag',Tooltip="Face Drag")) // TODO - fix this mode someday...
	EditModeList.Add((Mode=EM_TerrainEdit,Image=Texture'J_EM_ModeTerrainEdit',Tooltip="Terrain Edit"))
	
	KeyBindings.Add((Key=VK_F1,Cmd="HOOK OPEN HELP"))
	KeyBindings.Add((Key=VK_F1,Cmd="HOOK BROWSE ACTOR",bCtrl=True))
	KeyBindings.Add((Key=VK_F2,Cmd="HOOK OPEN WEBHELP"))
	KeyBindings.Add((Key=VK_F2,Cmd="HOOK BROWSE GROUP",bCtrl=True))
	KeyBindings.Add((Key=VK_F3,Cmd="HOOK OPEN LOG"))
	KeyBindings.Add((Key=VK_F3,Cmd="HOOK BROWSE MASTER",bCtrl=True))
	KeyBindings.Add((Key=VK_F4,Cmd="HOOK OPEN ACTORPROPERTIES"))
	KeyBindings.Add((Key=VK_F4,Cmd="HOOK BROWSE MESH",bCtrl=True))
	KeyBindings.Add((Key=VK_F5,Cmd="HOOK OPEN SURFPROPERTIES"))
	KeyBindings.Add((Key=VK_F5,Cmd="HOOK BROWSE MUSIC",bCtrl=True))
	KeyBindings.Add((Key=VK_F6,Cmd="HOOK OPEN LEVELPROPERTIES"))
	KeyBindings.Add((Key=VK_F6,Cmd="HOOK BROWSE SCRIPT",bCtrl=True))
	KeyBindings.Add((Key=VK_F7,Cmd="HOOK OPEN PREFERENCES"))
	KeyBindings.Add((Key=VK_F7,Cmd="HOOK BROWSE SOUND",bCtrl=True))
	KeyBindings.Add((Key=VK_F8,Cmd="HOOK BROWSE TEXTURE",bCtrl=True))
	KeyBindings.Add((Key=VK_F8,Cmd="HOOK BUILD OPTIONS"))
	
	KeyBindings.Add((Key=VK_H,Cmd="HOOK SHOWACTORS XOR"))
	KeyBindings.Add((Key=VK_H,Cmd="ACTOR HIDE INVERT",bAlt=True,bShift=True))
	KeyBindings.Add((Key=VK_H,Cmd="ACTOR HIDE SELECTED",bCtrl=True))
	KeyBindings.Add((Key=VK_H,Cmd="ACTOR UNHIDE ALL",bCtrl=True,bShift=True))
	KeyBindings.Add((Key=VK_H,Cmd="ACTOR HIDE UNSELECTED",bCtrl=True,bAlt=True))
	KeyBindings.Add((Key=VK_A,Cmd="BRUSH ADD",bShift=True))
	KeyBindings.Add((Key=VK_D,Cmd="BRUSH FROM DEINTERSECTION",bShift=True))
	KeyBindings.Add((Key=VK_I,Cmd="BRUSH FROM INTERSECTION",bShift=True))
	KeyBindings.Add((Key=VK_B,Cmd="HOOK OPEN BRUSH",bCtrl=true,bShift=True))
	KeyBindings.Add((Key=VK_B,Cmd="HOOK BUILD ALL",bCtrl=True))
	KeyBindings.Add((Key=VK_S,Cmd="BRUSH SUBTRACT",bShift=True))
	KeyBindings.Add((Key=VK_P,Cmd="HOOK BUILD PLAY",bCtrl=True))
	KeyBindings.Add((Key=VK_P,Cmd="HOOK SHOWFLAGS REALTIME"))
	KeyBindings.Add((Key=VK_C,Cmd="EDIT COPY",bCtrl=True))
	KeyBindings.Add((Key=VK_X,Cmd="EDIT CUT",bCtrl=True))
	KeyBindings.Add((Key=VK_V,Cmd="EDIT PASTE",bCtrl=True))
	KeyBindings.Add((Key=VK_D,Cmd="DUPLICATE",bCtrl=True))
	KeyBindings.Add((Key=VK_F,Cmd="HOOK OPEN FINDACTOR",bCtrl=True))
	KeyBindings.Add((Key=VK_Y,Cmd="TRANSACTION REDO",bCtrl=True))
	KeyBindings.Add((Key=VK_Z,Cmd="TRANSACTION UNDO",bCtrl=True))
	KeyBindings.Add((Key=VK_R,Cmd="ACTOR REPLACE CURRENT",bCtrl=True))
	KeyBindings.Add((Key=VK_R,Cmd="HOOK SHOWFLAGS REALTIMEBACKDROP"))
	KeyBindings.Add((Key=VK_A,Cmd="ACTOR SELECT ALL",bCtrl=True))
	KeyBindings.Add((Key=VK_A,Cmd="POLY SELECT ALL",bCtrl=True,bShift=True))
	KeyBindings.Add((Key=VK_A,Cmd="ACTOR SELECT INVERT",bCtrl=True,bAlt=True))
	KeyBindings.Add((Key=VK_Q,Cmd="SELECT NONE",bCtrl=True))
	KeyBindings.Add((Key=VK_N,Cmd="HOOK MAPFILE NEW",bCtrl=True))
	KeyBindings.Add((Key=VK_N,Cmd="HOOK MAPFILE NEWADDITIVE",bCtrl=True,bShift=True))
	KeyBindings.Add((Key=VK_O,Cmd="HOOK MAPFILE OPEN",bCtrl=True))
	KeyBindings.Add((Key=VK_S,Cmd="HOOK MAPFILE SAVE",bCtrl=True))
	KeyBindings.Add((Key=VK_S,Cmd="HOOK MAPFILE SAVEAS",bCtrl=True,bShift=True))
	KeyBindings.Add((Key=VK_K,Cmd="HOOK SHOWFLAGS BACKDROP"))
	KeyBindings.Add((Key=VK_B,Cmd="HOOK SHOWFLAGS BRUSH"))
	KeyBindings.Add((Key=VK_E,Cmd="HOOK OPEN SCRIPT",bCtrl=True))
	KeyBindings.Add((Key=VK_U,Cmd="POLY SELECT MEMORY UNION",bShift=True))
	KeyBindings.Add((Key=VK_M,Cmd="POLY SELECT MEMORY SET",bShift=True))
	KeyBindings.Add((Key=VK_O,Cmd="POLY SELECT MEMORY INTERSECTION",bShift=True))
	KeyBindings.Add((Key=VK_R,Cmd="POLY SELECT MEMORY RECALL",bShift=True))
	KeyBindings.Add((Key=VK_C,Cmd="POLY SELECT ADJACENT COPLANARS",bShift=True))
	KeyBindings.Add((Key=VK_F,Cmd="POLY SELECT ADJACENT FLOORS",bShift=True))
	KeyBindings.Add((Key=VK_S,Cmd="POLY SELECT ADJACENT SLANTS",bShift=True))
	KeyBindings.Add((Key=VK_W,Cmd="POLY SELECT ADJACENT WALLS",bShift=True))
	KeyBindings.Add((Key=VK_J,Cmd="POLY SELECT ADJACENT ALL",bShift=True))
	KeyBindings.Add((Key=VK_B,Cmd="POLY SELECT MATCHING BRUSH",bShift=True))
	KeyBindings.Add((Key=VK_G,Cmd="POLY SELECT MATCHING GROUPS",bShift=True))
	KeyBindings.Add((Key=VK_I,Cmd="POLY SELECT MATCHING ITEMS",bShift=True))
	KeyBindings.Add((Key=VK_P,Cmd="POLY SELECT MATCHING POLYFLAGS",bShift=True))
	KeyBindings.Add((Key=VK_T,Cmd="POLY SELECT MATCHING TEXTURE",bShift=True))
	KeyBindings.Add((Key=VK_Q,Cmd="POLY SELECT REVERSE",bShift=True))
	KeyBindings.Add((Key=VK_X,Cmd="POLY SELECT MEMORY XOR",bShift=True))
	
	KeyBindings.Add((Key=VK_DELETE,Cmd="DELETE"))
	KeyBindings.Add((Key=VK_SPACE,Cmd="CAMERA ALIGN",bCtrl=True))
	KeyBindings.Add((Key=VK_MINUS,Cmd="HOOK CAMSPEED SUB",bCtrl=True))
	KeyBindings.Add((Key=VK_PLUS,Cmd="HOOK CAMSPEED ADD",bCtrl=True))
	
	KeyBindings.Add((Key=VK_0,Cmd="HOOK DRAWMODE LIGHTONLY",bAlt=True))
	KeyBindings.Add((Key=VK_1,Cmd="HOOK DRAWMODE WIREFRAME",bAlt=True))
	KeyBindings.Add((Key=VK_1,Cmd="HOOK OPEN PREFERENCES",bCtrl=True))
	KeyBindings.Add((Key=VK_2,Cmd="HOOK DRAWMODE ZONES",bAlt=True))
	KeyBindings.Add((Key=VK_2,Cmd="HOOK OPEN 2DEDITOR",bCtrl=True))
	KeyBindings.Add((Key=VK_3,Cmd="HOOK DRAWMODE BSPPOLYS",bAlt=True))
	KeyBindings.Add((Key=VK_3,Cmd="HOOK OPEN LIGHTSCALE",bCtrl=True))
	KeyBindings.Add((Key=VK_4,Cmd="HOOK DRAWMODE BSPCUTS",bAlt=True))
	KeyBindings.Add((Key=VK_4,Cmd="HOOK OPEN TEXREPLACE",bCtrl=True))
	KeyBindings.Add((Key=VK_5,Cmd="HOOK DRAWMODE DYNAMICLIGHT",bAlt=True))
	KeyBindings.Add((Key=VK_5,Cmd="HOOK DRAWMODE MAPCLEANUP",bCtrl=True))
	KeyBindings.Add((Key=VK_6,Cmd="HOOK DRAWMODE UNLIT",bAlt=True))
	KeyBindings.Add((Key=VK_7,Cmd="HOOK DRAWMODE OVERHEAD",bAlt=True))
	KeyBindings.Add((Key=VK_8,Cmd="HOOK DRAWMODE XZ",bAlt=True))
	KeyBindings.Add((Key=VK_9,Cmd="HOOK DRAWMODE YZ",bAlt=True))
	KeyBindings.Add((Key=VK_N,Cmd="HOOK DRAWMODE NORMALS",bAlt=True))
}