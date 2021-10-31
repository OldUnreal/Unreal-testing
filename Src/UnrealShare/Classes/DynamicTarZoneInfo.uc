//=============================================================================
// DynamicTarZoneInfo.
//=============================================================================
class DynamicTarZoneInfo expands DynamicZoneInfo;

defaultproperties
{
	EntrySound=LavaEn
	ExitSound=LavaEn
	EntryActor=Class'WaterImpact'
	ExitActor=Class'WaterImpact'
	ZoneTerminalVelocity=+0250.000000
	ZoneFluidFriction=+00004.000000
	bWaterZone=True
	ViewFog=(X=0.3125,Y=0.3125,Z=0.234375)
	ViewFlash=(X=-0.39,Y=-0.39,Z=-0.39)
	EFXAmbients=REVERB_PRESET_SMALLWATERROOM
}