class SlimeZone extends ZoneInfo;

#exec AUDIO IMPORT FILE="Sounds\Generic\GoopE1.wav" NAME="LavaEx" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\GoopJ1.wav" NAME="LavaEn" GROUP="Generic"
//#exec AUDIO IMPORT FILE="Sounds\Generic\uGoop1.wav" NAME="InGoop" GROUP="Generic"
//    AmbientSound=InGoop

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
	EFXAmbients=REVERB_PRESET_UNDERSLIME
}
