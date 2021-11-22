//=============================================================================
// CARDebug.
//=============================================================================
class CARDebug expands Info;

var Weapon DebugWeapon;

state Debugging
{
	function BeginState()
	{
		log( "********************************" );
		log( "CAR Debugger "$self$" spawned at: "$level.timeseconds );
	}
	
	function Tick( float DeltaTime )
	{	
		if( DebugWeapon != none )
		{
			log( "********************************" );
			log( "<><><> State   : "$DebugWeapon.GetStateName() );
			log( "<><><> Ammo    : "$DebugWeapon.AmmoType.AmmoAmount );
			log( "<><><> Owner   : "$DebugWeapon.Owner );
			log( "<><><> bAltFire: "$Pawn( DebugWeapon.Owner ).bAltFire );
			log( "<><><> bFire   : "$Pawn( DebugWeapon.Owner ).bFire );
		}
	}
}

defaultproperties
{
}
