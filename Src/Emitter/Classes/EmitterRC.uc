// Nothing that should be used, just a resource class for particles to use.
Class EmitterRC extends Actor
	Native
	Abstract;

simulated function ZoneChange(Zoneinfo NewZone);

defaultproperties
{
	LifeSpan=1
}