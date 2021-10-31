//=============================================================================
// GameTypeTrigger: A trigger that is only enabled for certain game types.
//=============================================================================

class GameTypeTrigger expands Trigger;

var() class<GameInfo> GameType[8];

function PreBeginPlay()
{
	local int i;
	local bool bRelevant;

	Super.PreBeginPlay();

	// Upcoming hardcoded fixes for bad map setup.
	if( string(Outer.Name)~="NaliC2" )
		Return;
	else if( string(Outer.Name)~="Toxic" )
	{
		SetCollision( False );
		Return;
	}
	
	bRelevant = False;
	for( i = 0; i < ArrayCount(GameType); i++ )
	{
		if( GameType[i] != None && ClassIsChildOf( Level.Game.Class, GameType[i] ) )
		{
			bRelevant = True;
			break;
		}
	}

	if( !bRelevant )
	{
		// This trigger is not relevant to this game type
		SetCollision( False );
	}
}

defaultproperties
{
     GameType(0)=Class'UnrealShare.SinglePlayer'
     GameType(1)=Class'UnrealShare.CoopGame'
     GameType(2)=Class'UnrealShare.DeathMatchGame'
}
