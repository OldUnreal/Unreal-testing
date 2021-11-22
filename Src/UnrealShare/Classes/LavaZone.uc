class LavaZone extends ZoneInfo;

#exec AUDIO IMPORT FILE="Sounds\Generic\GoopE1.wav" NAME="LavaEx" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\GoopJ1.wav" NAME="LavaEn" GROUP="Generic"
//#exec AUDIO IMPORT FILE="Sounds\Generic\uLava1.wav" NAME="InLava" GROUP="Generic"
//	AmbientSound=InLava

defaultproperties
{
	DamagePerSec=40
	DamageType=Burned
	bPainZone=True
	bWaterZone=True
	bDestructive=True
	bNoInventory=true
	ViewFog=(X=0.5859375,Y=0.1953125,Z=0.078125)
	EntryActor=FlameExplosion
	ExitActor=FlameExplosion
	EntrySound=LavaEn
	ExitSound=LavaEx
	EFXAmbients=REVERB_PRESET_MOOD_HELL
}
