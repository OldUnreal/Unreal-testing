//=============================================================================
// EFXSlimeZone - Unreal.
//=============================================================================
class EFXSlimeZone extends EFXZoneInfo;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

defaultproperties
{
	DamagePerSec=40
	DamageType=Corroded
	bPainZone=True
	bWaterZone=True
	bDestructive=True
	ViewFog=(X=0.1875,Y=0.28125,Z=0.09375)
	ViewFlash=(X=-0.1172,Y=-0.1172,Z=-0.1172)
	EntryActor=UnrealShare.GreenSmokePuff
	ExitActor=UnrealShare.GreenSmokePuff
	EntrySound=UnrealShare.LavaEn
	ExitSound=UnrealShare.LavaEx
	ReverbPreset=RP_UnderSlime
}
