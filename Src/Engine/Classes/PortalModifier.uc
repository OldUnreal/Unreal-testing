//=============================================================================
// PortalModifier: Can be used to modify reflection of mirrors or warpzone portals.
//=============================================================================
Class PortalModifier extends Object
	native;

var() bool	bBSPUnlit,			// Make BSP unlit.
			bBSPNoFog,			// Disable volumetric fog on BSP.
			bActorUnlit,		// Make actors unlit.
			bActorNoFog,		// Disable volumetric fog on meshes.
			bHideMeshes,		// Hide all mesh actors.
			bHideSprites,		// Hide all non mesh actors.
			bHideDecals,		// Hide decals and projectors.
			bAllowSubportals,	// Allow to draw mirrors/warpzone.
			bAllowSkybox,		// Allow to draw sky.
			bDrawInvisPolies,	// Draw invisible BSP polygons.
			bDrawSecretGoal,	// Draw bHidden+bIsSecretGoal actors.
			bHideSecretGoal,	// Hide bIsSecretGoal actors.
			bOverrideDistanceFog; // Override distance fog with new settings.

var bool bScriptFilterActors,bScriptBSPTextures,bScriptMeshTextures,bScriptCheckPortals,bScriptCheckBSPSurf,bScriptDrawActor;

var(DistanceFog) bool	bDistanceFogBSP, // if bOverrideDistanceFog, Enable distance fog for BSP.
						bDistanceFogActors, // if bOverrideDistanceFog, Enable distance fog for Actors.
						bDistanceFogClips; // if bOverrideDistanceFog, Distance fog should clip render.

var(DistanceFog) color FogColor;
var(DistanceFog) float DistanceFogStart,DistanceFogEnd;

var() Texture ForcedBSPTexture,	// Force all of BSP to use this same texture.
				ForcedMeshTexture; // Force all mesh skins to be this texture.

event bool AllowDraw( Actor Other ); // if bScriptFilterActors: Allow draw a specific actor.
event GetBSPTexture( out Texture T ); // if bScriptBSPTextures: Get replacement BSP texture.
event GetMeshTexture( Actor Other, out Texture T ); // if bScriptMeshTextures: Get replacement actor mesh skin.
event bool AllowPortal( Texture T ); // if bScriptCheckPortals: Check if were allowed to draw this portal (with this BSP surf texture)
event ModifyDrawBSPSurf( Texture T, out int PolyFlags ); // if bScriptCheckBSPSurf: Modify surface polygon flags.
event PreDrawActor( Actor Other ); // if bScriptDrawActor: Called right before about to draw an actor.
event PostDrawActor( Actor Other ); // if bScriptDrawActor: Called right after an actor was drawn.

defaultproperties
{
	FogColor=(R=255,G=255,B=255,A=255)
	DistanceFogStart=200
	DistanceFogEnd=1000
	bAllowSubportals=true
	bAllowSkybox=true
}