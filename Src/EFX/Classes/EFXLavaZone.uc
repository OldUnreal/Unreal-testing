//=============================================================================
// EFXLavaZone - Unreal.
//=============================================================================
class EFXLavaZone extends EFXZoneInfo;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

defaultproperties
{
	DamagePerSec=40
	DamageType=Burned
	bPainZone=True
	bWaterZone=True
	bDestructive=True
	bNoInventory=true
	ViewFog=(X=0.5859375,Y=0.1953125,Z=0.078125)
	EntryActor=UnrealShare.FlameExplosion
	ExitActor=UnrealShare.FlameExplosion
	EntrySound=UnrealShare.LavaEn
	ExitSound=UnrealShare.LavaEx
	ReverbPreset=RP_MoodHell
}
