// Unreal Static Mesh Actor - Used by editor 'add mesh here' button.
Class StaticMeshActor extends Actor
	NoUserCreate
	Native;

var StaticLightData StaticLightD;
var() bool bBuildStaticLights; // This static mesh should compute vertex light colors on map rebuild.
var() bool bComputeUnlitColor; // This static mesh should compute ActorGUnlitColor value on map rebuild.

simulated function OnMirrorMode()
{
	DrawScale3D.Y *= -1.f;
	PrePivot.Y *= -1.f;
}

defaultproperties
{
	DrawType=DT_Mesh
	bUseMeshCollision=true
	bShadowCast=true
	bCollideActors=true
	bWorldGeometry=true
	bStatic=true
	bBlockActors=true
	bBlockPlayers=true
	RemoteRole=ROLE_None
	bEdShouldSnap=true
	bDirectional=true
	bRenderMultiEnviroMaps=true
	bBuildStaticLights=true
	bIsStaticMesh=true
	bBlockRigidBodyPhys=true
}