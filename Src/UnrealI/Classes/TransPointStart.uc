// Used for showing bot translocator starting point.
Class TransPointStart extends LiftExit;

var TransPointDest DestActor;

function PostBeginPlay();
function Actor SpecialHandling(Pawn Other)
{
	if ( DestActor!=None )
		DestActor.BotSuggestMovePrepare(Other);
	return Self;
}

defaultproperties
{
}
