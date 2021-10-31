//=============================================================================
// DynamicNitrogenZoneInfo.
//=============================================================================
class DynamicNitrogenZoneInfo expands DynamicZoneInfo;

defaultproperties
{
    EntrySound=Sound'UnrealShare.Generic.DSplash'
    ExitSound=Sound'UnrealShare.Generic.WtrExit1'
    EntryActor=Class'UnrealShare.WaterImpact'
    ExitActor=Class'UnrealShare.WaterImpact'
	DamagePerSec=20
	DamageType=Frozen
	bPainZone=True
	bWaterZone=True
	ViewFog=(X=0.01171875,Y=0.0390625,Z=0.046875)
	EFXAmbients=REVERB_PRESET_DRUGGED
}
