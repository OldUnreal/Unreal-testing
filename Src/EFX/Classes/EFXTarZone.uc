//=============================================================================
// EFXTarZone - Unreal.
//=============================================================================
class EFXTarZone extends EFXZoneInfo;

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
	ReverbPreset=RP_SmallWaterRoom
}
