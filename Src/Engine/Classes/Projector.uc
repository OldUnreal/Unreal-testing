//=============================================================================
// Projector
// For more complex decals and mesh decal support.
//=============================================================================
Class Projector extends Actor
	Native
	NoUserCreate;

var const transient plane FrustrumPlanes[6];
var noedsave const array<Actor> DecalActors;
var const transient array<int> DecalNodes;
var const transient BoundingBox Box;
var const transient vector VisBox[8];
var const transient Model SurfModel;
var pointer<FStaticProjector*> StaticMapData;

var() Texture ProjectTexture;
var() byte FOV; // Valid FOV range: 0-180 - FIXME!!!
var() float MaxDistance,ProjectorScale;
var() ERenderStyle ProjectStyle;

// Flags
var() bool bProjectActors; // Should project on mesh actors.
var() bool bProjectBSPBackfaces;
var() bool bProjectMeshBackfaces;
var() bool bProjectBSP; // Should project on world BSP
var() bool bGradualFade; // When Translucent, make it fade out on distance.
var() bool bUseBetterActorAttach; // Use a higher precision for mesh actor to attach on detection (but slower).
var() bool bBuildStaticMap; // Builds a pre-rendered projector model to draw when attaching (only for BSP/static meshes), slow creation but fast render.
var const bool bHasAttached;
var transient const bool bProjecting,bStaticMap,bStaticMapBSP;

native(350) final function AttachPrjDecal();
native(351) final function DeattachPrjDecal();
native(352) final function AttachActor( Actor Other );
native(353) final function DeattachActor( Actor Other );
native(354) final function DeattachAllActors();

simulated function PostBeginPlay()
{
	if( Level.NetMode==NM_DedicatedServer )
	{
		if( !Destroy() )
			SetCollision(false);
	}
	else AttachPrjDecal();
}
simulated function Touch( Actor Other )
{
	if( bProjectActors && !Other.bHidden && Other.DrawType==DT_Mesh && Other.Mesh!=None )
		AttachActor(Other);
}
simulated function UnTouch( Actor Other )
{
	if( bProjectActors )
		DeattachActor(Other);
}

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	if( Level.NetMode!=NM_DedicatedServer )
	{
		DeattachPrjDecal();
		AttachPrjDecal();
	}
}

defaultproperties
{
	bProjectMeshBackfaces=true
	MaxDistance=200
	bCollideActors=true
	bProjTarget=false
	bProjectActors=true
	bProjectBSP=true
	ProjectTexture=Texture'S_Pawn'
	bDirectional=true
	ProjectStyle=STY_Masked
	RemoteRole=ROLE_None
	bHidden=true
	ProjectorScale=1
}