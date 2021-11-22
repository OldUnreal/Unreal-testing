// Used for showing bot translocator path ending point.
Class TransPointEnd extends LiftExit;

function PostBeginPlay();
function Actor SpecialHandling(Pawn Other)
{
	return Self;
}

defaultproperties
{
}
