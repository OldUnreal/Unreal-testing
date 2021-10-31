//=============================================================================
// EnemyUpdater.
//=============================================================================
class EnemyUpdater expands Info;

var int BotCount;

function PostBeginPlay()
{
	SetTimer( 0.5, true );
}

function Timer()
{
	local bots B;
	
	if( CloakMatch( Level.Game ).CloakedPawn != none )
	{
		foreach allactors( class'Bots', B )
		{
			B.Enemy = CloakMatch( Level.Game ).CloakedPawn;
			B.Target = CloakMatch( Level.Game ).CloakedPawn;
		}
	}
}
	

defaultproperties
{
}
