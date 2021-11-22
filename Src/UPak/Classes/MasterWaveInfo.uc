class MasterWaveInfo expands Info;

var int TotalWaves;
var bool bTriggerDispatcher;

function PostBeginPlay()
{
	local MarineWaveInfo WaveInfo;
	
	foreach allactors( class'MarineWaveInfo', WaveInfo )
	{
		if( WaveInfo.bTriggerDispatcher )
			bTriggerDispatcher = true;
		TotalWaves++;
	}
}
		
function FinishWave( int WaveNumber, optional float BeamDelay )
{
	local MarineWaveInfo WaveInfo;
	local Dispatcher D;
	local Pawn E;
	
	E = GetPlayer();
	if( ( WaveNumber == TotalWaves ) && bTriggerDispatcher )
	{
		foreach allactors( class'Dispatcher', D )
		{
			if( D.Tag == 'End' )
				D.Trigger(E,E);
		}
	}
	foreach allactors( class'MarineWaveInfo', WaveInfo )
	{
		if( WaveInfo.WaveNumber == WaveNumber + 1 )
		{
			if( WaveInfo.BeamDelay > 0.0 && !WaveInfo.bTriggerable )
			{
				//log( "<<<<<<<<< Activating: "$WaveInfo );
				WaveInfo.SetTimer( WaveInfo.BeamDelay, false );
			}
			else if( !WaveInfo.bTriggerable )
			{
				//log( "<<<<<<<<< Activating2: "$WaveInfo );
				WaveInfo.Activate();
			}
			break;
		}
	}
}
		
function Pawn GetPlayer()
{
	local Pawn P,EList[32];
	local byte c;

	For( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( P!=none && P.bIsPlayer && SpaceMarine(P)==None )
		{
			EList[c] = P;
			c++;
			if( c==32 )
				Break;
		}
	}
	Return EList[Rand(c)];
}

defaultproperties
{
}
