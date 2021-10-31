// SinglePlayerOnlyStart.uc
class SinglePlayerOnlyStart extends PlayerStart; 

function PreBeginPlay()
{
	if( !ClassIsChildOf( Level.Game.Class, class'UnrealShare.SinglePlayer' ) )
		bSinglePlayerStart = false;
}

// end of SinglePlayerOnlyStart.uc

defaultproperties
{
}
