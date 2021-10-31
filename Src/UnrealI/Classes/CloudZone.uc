class CloudZone extends ZoneInfo;

simulated event ActorEntered(Actor Other)
{
	if (!Other.bCollideActors || !Other.bCollideWorld)
		return;
	if (!Other.bIsPawn)
		Other.Destroy();
	else if (Role == ROLE_Authority && Pawn(Other).Health > 0)
		Pawn(Other).Died(none, 'Fell', Other.Location);
}

defaultproperties
{
}