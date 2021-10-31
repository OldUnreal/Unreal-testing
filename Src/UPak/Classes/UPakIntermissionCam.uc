//=============================================================================
// UPakIntermissionCam.
//=============================================================================
class UPakIntermissionCam expands ScriptedPawn;

var Pathnode GoHere;

function PostBeginPlay()
{
	Visibility = 0;
}


auto state Moving
{
	ignores TakeDamage, Bump, Touch;
	
	function BeginState()
	{
	}
	
	function GetDestination()
	{
		local PathNode P;
		
		foreach allactors( class'Pathnode', P )
		{	
			GoHere = P;
		}
	}
}

defaultproperties
{
     BaseEyeHeight=14.000000
}
