//=============================================================================
// EFXWaterZone - Unreal.
//=============================================================================
class EFXWaterZone extends EFXZoneInfo;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

defaultproperties
{
	bWaterZone=True
	ViewFog=(X=0.1289,Y=0.1953,Z=0.17578)
	ViewFlash=(X=-0.078,Y=-0.078,Z=-0.078)
	EntryActor=UnrealShare.WaterImpact
	ExitActor=UnrealShare.WaterImpact
	EntrySound=UnrealShare.DSplash
	ExitSound=UnrealShare.WtrExit1
	ReverbPreset=RP_Underwater
}
