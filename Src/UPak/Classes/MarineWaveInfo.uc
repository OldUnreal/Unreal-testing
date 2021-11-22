//=============================================================================
////// MarineWaveInfo.
//=============================================================================
class MarineWaveInfo expands Info;

var( WaveSetup ) int WaveNumber;
var( WaveSetup ) class< Weapon > MarineWeapons[ 16 ];
var( WaveSetup ) class< SpaceMarine > MarineList[ 16 ];
var( WaveSetup ) float BeamDelay;
var( WaveSetup ) bool bTriggerable;
var( WaveSetup ) bool bTriggerDispatcher;

var PathNode BeamNodeArray[ 16 ];

var int PlacedMarineTracker[ 16 ];
var int CurrentMarine;

var SpaceMarine PlacedMarines[ 16 ];
var PathNode SurroundingNodes[ 16 ];
var SpaceMarine DeadMarines[ 16 ];

var int TotalMarines;
var int MarinesLeft;

var MasterWaveInfo Controller;
var bool bFilled;
var nowarn Pawn Target;


function PostBeginPlay()
{
	if( string(Outer.Name)~="Crashsite2" ) // Hack fix for map.
	{
		FindObject(Class'Trigger',"Crashsite2.Trigger36").TriggerType = TT_PawnProximity; // Fell trigger
		FindObject(Class'Trigger',"Crashsite2.Trigger38").TriggerType = TT_PawnProximity; // Elevator trigger
	}
	TotalMarines = CountMarines();

	if( WaveNumber == 1 && !bTriggerable )
	{
		if( BeamDelay >= 1 )
			SetTimer( BeamDelay, false );
		else SetTimer( 2.0, false );
	}
	LogStats();
}


function Trigger( actor Other, Pawn EventInstigator )
{
	if( bTriggerable )
	{
		if( BeamDelay > 0 )
			SetTimer( BeamDelay, false );
		else
		{
			if( !FindMasterWaveInfo() )
				Controller = Spawn( class'MasterWaveInfo' );
			Activate();
		}
	}
}


function Timer()
{
	local MasterWaveInfo WaveInfo;
	
	if( !FindMasterWaveInfo() )
		Controller = Spawn( class'MasterWaveInfo' );
		
	foreach allactors( class'MasterWaveInfo', WaveInfo )
		Controller = WaveInfo;
	Activate();
}


function bool FindMasterWaveInfo()
{
	local MasterWaveInfo MWI;
	
	foreach allactors( class'MasterWaveInfo', MWI )
	{
		if( MWI != none )
		{
			Controller = MWI;
			return true;
		}
	}
	return false;
}

function Activate()
{
	local int incrementer;

	if( !FindMasterWaveInfo() )
		Controller = Spawn( class'MasterWaveInfo' );

	TotalMarines = CountMarines();
	//log( "---------- MARINES IN THIS WAVE: "$self$" are "$TotalMarines );
	
	for( incrementer = 0; incrementer <= TotalMarines; incrementer ++ )
		FindPointsNearPlayer( GetPlayerPawn() );
	
	BeamMarine();
}


function int CountMarines()
{
	local int incrementer;
	
	MarinesLeft = 0;
	
	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( MarineList[ incrementer ] != none )
			MarinesLeft++;
		else return MarinesLeft;
	}
	
	return MarinesLeft;
}
		
		
function int MarinesRemaining()
{
	local int incrementer;
	local int RemainingMarines;
	
	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( MarineList[ incrementer ] != none && PlacedMarineTracker[ incrementer ] != 1 )
			RemainingMarines++;
		else return RemainingMarines;
	}
	
	return RemainingMarines;
}

function SubtractMarine( SpaceMarine DeadMarine )
{
	TotalMarines--;

	if( TotalMarines <= 0 )
	{
		//log( "Less than or = to 0 marines remaining." );
		
		if( BeamDelay > 0.0 )
			Controller.FinishWave( WaveNumber, BeamDelay );
		else Controller.FinishWave( WaveNumber );
		Destroy();
	}
}
				
function BeamMarine()
{
	local int incrementer;
	local SpaceMarine NewMarine;

	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( SetCurrentMarine( GetNextMarine() ) )
		{
			NewMarine = Spawn(  MarineList[ CurrentMarine ], self,, BeamNodeArray[ CurrentMarine ].Location );
			NewMarine.MarineBeamController = self;
			NewMarine.StartWeapon = MarineWeapons[ CurrentMarine ];
			NewMarine.bBeamingIn = true;
			AddPlacedMarine( NewMarine );
			PlacedMarineTracker[ CurrentMarine ] = 1;
		}
	}
	bFilled = true;
}
			

function bool SetCurrentMarine( int NextMarine )
{
	if( NextMarine != 999 )
	{
		CurrentMarine = NextMarine;
		return true;
	}
	else return false;
}

function int GetNextMarine()
{
	local int incrementer;
	
	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( ( MarineList[ incrementer ] != none ) && ( PlacedMarineTracker[ incrementer ] == 0 ) )
			return incrementer;
	}
	
	return 999;
}

function AddPlacedMarine( SpaceMarine NewMarine )
{
	local int incrementer;
	
	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( PlacedMarines[ incrementer ] == none )
		{
			PlacedMarines[ incrementer ] = NewMarine;
			break;
		}
	}
}

function Pawn GetPlayerPawn()
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

function FindPointsNearPlayer( Pawn BeamSpot )
{
	local Pathnode PN;
	local int incrementer;
	local NavigationPoint N;
	
	Target = BeamSpot;
	if( Target==None )
	{
		For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			PN = PathNode(N);
			if( PN != none && PN.Tag=='MarineBeamPoint' )
			{
				AddNodeToList( PN );
				Break;
			}
		}
	}
	else
	{
		foreach radiusactors( class'PathNode', PN, 10550 )
		{
			if( PN != none && PN.Tag == 'MarineBeamPoint' && VSize( PN.Location - GetPlayerPawn().Location ) > 200 )
				AddNodeToList( PN );
		}
		for( incrementer = 0; incrementer <= 15; incrementer++ )
			if( BeamNodeArray[ incrementer ] == none )
				break;
		if( incrementer<4 ) // Not enough spawns.
		{
			For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				PN = PathNode(N);
				if( PN != none && PN.Tag=='MarineBeamPoint' )
					AddNodeToList( PN );
			}
		}
	}
}
function AddNodeToList( PathNode AddNode )
{
	local int incrementer;
	
	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( BeamNodeArray[ incrementer ] == AddNode )
			break;
		if( BeamNodeArray[ incrementer ] == none )
		{
			BeamNodeArray[ incrementer ] = AddNode;
			break;
		}
	}
}

function bool GoodNode( PathNode CheckNode )
{
	local int incrementer;
	
	for( incrementer = 0; incrementer <= 15; incrementer++ )
	{
		if( BeamNodeArray[ incrementer ] == CheckNode )
			return false;
	}
	return true;
}

function FindSurroundingNodes( Pawn TargetPawn )
{
	/*local int incrementer;
	local Pathnode TempPathNode;
	local int InsertCount;

	foreach RadiusActors( class'PathNode', TempPathNode, 20000 )
	{
		if( TempPathNode != none && InsertCount < 16 )
		{
			//log( "Found: "$TempPathNode$" that is "$VSize( TempPathNode.Location - TargetPawn.Location)$" units away from player." );
		}
	}*/
}


function LogStats()
{
	/*local MarineWaveInfo MWI;
	
	foreach allactors( class'MarineWaveInfo', MWI )
	{
	}*/
}

defaultproperties
{
}
