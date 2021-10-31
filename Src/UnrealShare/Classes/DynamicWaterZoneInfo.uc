//=============================================================================
// DynamicWaterZoneInfo.
//=============================================================================
class DynamicWaterZoneInfo expands DynamicZoneInfo;

defaultproperties
{
     EntrySound=Sound'UnrealShare.Generic.DSplash'
     ExitSound=Sound'UnrealShare.Generic.WtrExit1'
     EntryActor=Class'UnrealShare.WaterImpact'
     ExitActor=Class'UnrealShare.WaterImpact'
     bWaterZone=True
     ViewFlash=(X=-0.078000,Y=-0.078000,Z=-0.078000)
     ViewFog=(X=0.128900,Y=0.195300,Z=0.175780)
     EFXAmbients=REVERB_PRESET_UNDERWATER
}
