//=============================================================================
// DynamicSlimeZoneInfo.
//=============================================================================
class DynamicSlimeZoneInfo expands DynamicZoneInfo;

defaultproperties
{
     DamagePerSec=40
     DamageType="Corroded"
     EntrySound=Sound'UnrealShare.Generic.LavaEn'
     ExitSound=Sound'UnrealShare.Generic.LavaEx'
     EntryActor=Class'UnrealShare.GreenSmokePuff'
     ExitActor=Class'UnrealShare.GreenSmokePuff'
     bWaterZone=True
     bPainZone=True
     bDestructive=True
     ViewFlash=(X=-0.117200,Y=-0.117200,Z=-0.117200)
     ViewFog=(X=0.187500,Y=0.281250,Z=0.093750)
     EFXAmbients=REVERB_PRESET_UNDERSLIME
}
