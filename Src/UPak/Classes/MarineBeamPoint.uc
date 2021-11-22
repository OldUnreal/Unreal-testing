//=============================================================================
// MarineBeamPoint.
//=============================================================================
class MarineBeamPoint expands NavigationPoint;

var int MarineCount;
var nowarn PlayerPawn Target;
var() int Waves;

struct MarineBeamData
{
	var() int WaveNumber;
	var() int NumberOfMarines;
	var() Class MarineType[ 32 ]; // WTF is this? But I can't change this eighter or CrashSite2 map wont open!
};

var() MarineBeamData MarineWaveData[ 12 ];

function PostBeginPlay()
{
}
function SubtractMarine()
{
	MarineCount -= 1;
	CheckMarineStatus();
}
function AddMarine()
{
	MarineCount += 1;
}
function CheckMarineStatus()
{
	if( MarineCount <= 0 )
		BeamMarine();
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
function BeamMarine()
{
	local SpaceMarine SM;
	local Teleporter T;
	local Pawn En;
	
	En = GetPlayerPawn();
	SM = Spawn( class'SpaceMarine',,, FindPointNearPlayer(En).Location );
	SM.bBeamingIn = true;
	Waves--;
	if( Waves <= 0 )
	{
		foreach allactors( class'Teleporter', T )
		{
			if( T.Tag=='End' )
				T.Trigger(En,En);
		}
		Destroy();
	}
}
function PathNode FindPointNearPlayer( Pawn BeamSpot )
{
	local Pathnode PN, LastPN;
	
	foreach allactors( class'PathNode', PN )	
	{
		if( BeamSpot==None )
			Return PN;
		if( LastPN != none )
		{
			if( VSize( PN.Location - BeamSpot.Location ) < VSize( LastPN.Location - BeamSpot.Location ) )
				LastPN = PN;
		}
		else LastPN = PN;
	}
	if( LastPN != none )
		return LastPN;
}

defaultproperties
{
     bStatic=False
}
