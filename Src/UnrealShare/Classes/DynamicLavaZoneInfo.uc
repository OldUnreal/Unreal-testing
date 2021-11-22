//=============================================================================
// DynamicLavaZoneInfo.
//=============================================================================
class DynamicLavaZoneInfo expands DynamicZoneInfo;

defaultproperties
{
	DamagePerSec=40
	DamageType="Burned"
	EntrySound=LavaEn
	ExitSound=LavaEn
	EntryActor=Class'FlameExplosion'
	ExitActor=Class'FlameExplosion'
	bWaterZone=True
	bPainZone=True
	bDestructive=True
	bNoInventory=True
	ViewFog=(X=0.585938,Y=0.195313,Z=0.078125)
	EFXAmbients=REVERB_PRESET_MOOD_HELL
}