class TarZone extends ZoneInfo;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Generic\GoopE1.wav" NAME="LavaEx" GROUP="Generic"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Generic\GoopJ1.wav" NAME="LavaEn" GROUP="Generic"
//#exec AUDIO IMPORT FILE="Sounds\Generic\uGoop1.wav" NAME="InGoop" GROUP="Generic"
//	 AmbientSound=InGoop

// When an actor enters this zone.
event ActorEntered( actor Other )
{
	Super.ActorEntered(Other);
	if ( Other.IsA('Pawn') && Pawn(Other).bIsPlayer )
		Pawn(Other).WaterSpeed *= 0.1;
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	Super.ActorLeaving(Other);
	if ( Other.IsA('Pawn') && Pawn(Other).bIsPlayer )
		Pawn(Other).WaterSpeed *= 10;
}

defaultproperties
{
	ZoneTerminalVelocity=+0250.000000
	ZoneFluidFriction=+00004.000000
	bWaterZone=True
	ViewFog=(X=0.3125,Y=0.3125,Z=0.234375)
	ViewFlash=(X=-0.39,Y=-0.39,Z=-0.39)
	EntrySound=UnrealI.LavaEn
	ExitSound=UnrealI.LavaEx
	EFXAmbients=REVERB_PRESET_SMALLWATERROOM
}
