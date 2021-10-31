class WaterZone extends ZoneInfo;

#exec AUDIO IMPORT FILE="Sounds\Generic\dsplash.wav" NAME="DSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\wtrexit1.wav" NAME="WtrExit1" GROUP="Generic"

//#exec AUDIO IMPORT FILE="Sounds\Generic\uWater1a.wav" NAME="InWater" GROUP="Generic"
//	AmbientSound=InWater

defaultproperties
{
	bWaterZone=True
	ViewFog=(X=0.1289,Y=0.1953,Z=0.17578)
	ViewFlash=(X=-0.078,Y=-0.078,Z=-0.078)
	EntryActor=UnrealShare.WaterImpact
	ExitActor=UnrealShare.WaterImpact
	EntrySound=UnrealShare.DSplash
	ExitSound=UnrealShare.WtrExit1
	EFXAmbients=REVERB_PRESET_UNDERWATER
}
