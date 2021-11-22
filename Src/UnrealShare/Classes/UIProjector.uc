//==================================================================
// class: UIProjector
// file: UIProjector.uc
// author: Raven
// game: For 227 Unreal 1 patch
// description: projects decal onto BSP surface
//==================================================================
class UIProjector extends UIFX config;

#exec TEXTURE IMPORT NAME=UIProjectorIcon FILE="Textures\projector.pcx" GROUP=Icons LODSET=2 FLAGS=2

enum ESizeType
{
	ST_Normal,                                                // decal will not change size
	ST_Grow,                                                  // decal will grow
	ST_Shrink                                                 // decal will shrink
};

var(UIProjector_Size) ESizeType SizeType;                    // how decal size should be affected by distance
var(UIProjector_Size) bool bDistanceSizing;                  // should decal change it's size with distance
var(UIProjector_Size) float ProjectorScale;                  // base projected texture scale
var(UIProjector_Size) float ProjectorScaleModifier;          // scale modifier (for growing/shrinking while moving up/dn)
var(UIProjector_Size) float MinSize;                         // min decal size (used by bDistanceSizing)
var(UIProjector_Size) float MaxSize;                         // max max size (used by bDistanceSizing)
var(UIProjector_Size) float RandomScaleMin;                  // min decal size (used by bRandomScale)
var(UIProjector_Size) float RandomScaleMax;                  // max max size
var(UIProjector_Size) bool bRandomScale;                     // will make size random

var(UIProjector) ERenderStyle ProjectorRenderStyle;          // projector render style
var(UIProjector) bool bStaticProjector;
/*
   bStaticProjector can make static projector form most of the states (except ContinousUpdate and StaticProjector).
   So if you don't need to update you projector all the time (for instance flashlight decal) please set it to true.
*/
var(UIProjector) float ProjectorRefreshTime;                 // how often projected texture will be refreshed
var(UIProjector) float ProjectionDistance;                   // max Z distance from the bottom
var(UIProjector) texture ProjectorTexture;                   // projected texture
var(UIProjector) vector ProjectionOffset;                    // offset from base location
var(UIProjector) rotator ProjectorRotationModifier;          // additional rotation
var(UIProjector) bool bNoRotation;                           // updates everything except rotation
var(UIProjector) actor TracedActor;                          // acto which rotation/location should projector fallow
var(UIProjector) bool bTraceActor;                           // should track actors location/rotation (if you want to track actors rotation set bStaticProjector to false)
// usses TracedActor
var(UIProjector) int ProjectableSurfaces;                    // count of surfaces on which decalw ill be visible

var(UIProjector_Rotator) bool TraceRotation;                 // will trace rotation
var(UIProjector_Rotator) bool bUpdateYaw;                    // will update yaw
var(UIProjector_Rotator) bool bUpdateRoll;                   // will update roll
var(UIProjector_Rotator) bool bUpdatePitch;                  // will update pitch
var(UIProjector_Rotator) bool bReplaceOldRotation;           // replaces old rotation, with new one
var(UIProjector_Rotator) bool bApplyHitNormal;               // should always be true

var(UIProjector_Flicker) float ActiveTime;                   // how long will remain active
var(UIProjector_Flicker) float InActiveTime;                 // how long will remain inactive
var(UIProjector_Flicker) bool bRandom;                       // should stay active/inactive randomly
var(UIProjector_Flicker) float RandomModifier;               // random modifier
var(UIProjector_Flicker) bool bOn;                           // is on or off - works in states:
/*
                                                                TriggerControl
                                                                  if bon=true, then projector turns on when triggered, and off when untriggered
                                                                  if bon=false, then projector turns off when triggered, and on when untriggered

                                                                TriggerToggle
                                                                  should be on at the beginning

                                                                Flicker
                                                                  should be on at the beginning
*/

var(Advanced) bool bLogWarnings;                             // should log all errors and warnings

var bool bAttached;                                          // not-replicated, client side variable used in state Flicker.

var UIProjectorDecal ProjectorDecal;                         // stores decal (client side)
var globalconfig bool bProjectorEnabled;                     // config variable. Describes if projectors are available


//function SetToEnd(bool bToDo){ bTimeToEnd=bToDo; }
//=============================================================================
// returns sizing type
//=============================================================================
simulated function int GetSizeType()
{
	if (SizeType == ST_Normal) return 0;
	else if (SizeType == ST_Grow) return 1;
	else return 2;
}
//=============================================================================
// checks main variables
//=============================================================================
simulated function BeginPlay()
{
	if (ProjectorRefreshTime <= 0 || ProjectorTexture == none || ProjectorScale <= 0) Destroy();
	if (bTraceActor && TracedActor == none) Destroy();
}
//=============================================================================
// spawn decal
//=============================================================================
simulated function OnStart(optional bool bUseOld)
{
	local vector HitNormal,HitLocation,ProjStart, ProjEnd;
	local rotator tmprot;

	if (Level.NetMode == NM_DedicatedServer) return;

	if (bTraceActor) ProjStart = TracedActor.Location;
	else ProjStart = Location;

	if (bNoRotation)
	{
		ProjEnd=ProjStart - (vect(0,0,1)*ProjectionDistance);
	}
	else
	{
		if (!bTraceActor) ProjEnd=vector(Rotation)*ProjectionDistance;
		else
		{
			if (TracedActor != none) ProjEnd=vector(TracedActor.Rotation)*ProjectionDistance>>TracedActor.Rotation;
		}
	}

	if (bTraceActor) tmprot=TracedActor.Rotation;
	else tmprot=Rotation;

	if (Trace(HitLocation, HitNormal, ProjEnd, ProjStart) == none)
	{
		if (bLogWarnings) log(self$": WARNING - can not trace BSP!",'UIProjector');
		Destroy();
	}
	if (!bUseOld)
	{
		ProjectorDecal=Spawn(class'UIProjectorDecal',,,HitLocation+ProjectionOffset,tmprot+ProjectorRotationModifier);
		ProjectorDecal.RemoteRole = ROLE_None;
	}
	ProjectorDecal.BeginUpdate(self, HitNormal);
	ProjectorDecal.Style=ProjectorRenderStyle;
}
//=============================================================================
// re-creates decal
//=============================================================================
simulated function OnRecall()
{
	if (ProjectorDecal != none) return;
	OnStart();
}
//=============================================================================
// destroys decal
//=============================================================================
simulated function OnEnd()
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (ProjectorDecal == none) return;
		if (ProjectorDecal != none) ProjectorDecal.Destroy();
		ProjectorDecal=none;
	}
}
//=============================================================================
// Updates decal
//=============================================================================
simulated function OnCall()
{
	if (ProjectorDecal != none)
	{
		ProjectorDecal.DecalUpdate(self);
	}
}
//=============================================================================
// Updates once only
//=============================================================================
simulated state() StaticProjector
{
Begin:
	OnRecall();
	OnCall();
}
//=============================================================================
// Keeps updating
//=============================================================================
simulated state() ContinousUpdate
{
Begin:
	OnRecall();
Loop:
	OnCall();
	Sleep(ProjectorRefreshTime);
	GoTo('Loop');
}
//=============================================================================
// Flickers
//=============================================================================
simulated state() Flicker
{
	simulated function Timer()
	{
		if (bAttached)
		{
			bAttached=false;
			if (ProjectorDecal != none) ProjectorDecal.DetachDecal();
			if (bRandom) SetTimer(InActiveTime+(FRand() * RandomModifier), false);
			else SetTimer(InActiveTime, false);
		}
		else
		{
			bAttached=true;
			if (ProjectorDecal != none) ProjectorDecal.DecalUpdate(self);
			if (bRandom) SetTimer(ActiveTime+(FRand() * RandomModifier), false);
			else SetTimer(ActiveTime, false);
		}
	}
Begin:
	if ( Level.NetMode == NM_DedicatedServer ) Stop; // If on dedicated server, go to sleep mode.
	OnStart();
	SetTimer(InActiveTime, false);
Loop:
	if (bAttached)
	{
		OnCall();
	}
	Sleep(ProjectorRefreshTime);
	if (!bStaticProjector) GoTo('Loop');
}
defaultproperties
{
	ProjectorRefreshTime=0.1
	ProjectorScaleModifier=0.0000045
	ProjectorScale=1
	ProjectionDistance=1024
	bHidden=true
	bProjectorEnabled=true
	bDirectional=true

	bStasis=false
	bStatic=false
	RemoteRole=ROLE_SimulatedProxy
	bNoDelete=true

	Texture=Texture'UnrealShare.Icons.UIProjectorIcon'
	SizeType=ST_Grow
	ProjectorRenderStyle=STY_Modulated
	InitialState=ContinousUpdate

	DrawScale=0.5
	Style=STY_Masked
	bOn=true

	MinSize=0.2
	MaxSize=4
	ActiveTime=0.05
	InActiveTime=0.03
	bRandom=true
	RandomModifier=0.6
	ProjectableSurfaces=8

	bApplyHitNormal=true
	bReplaceOldRotation=true
}
