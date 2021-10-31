//=============================================================================
// comptablet.
//=============================================================================
class CompTablet expands Pickup;

function bool ValidTouch( actor Other )
{
	local Actor A;

	if ( Other.bIsPawn && Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0) && Level.Game.PickupQuery(Pawn(Other), self) )
	{
		if ( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );
		if (Level.Netmode != NM_Standalone)
		{
			Lifespan = 5.0; //shitfix for InventoryData in 227
		}
		return true;
	}
	return false;
}
defaultproperties
{
     PickupMessage="You got the CompTablet."
     PickupViewMesh=LodMesh'UPak.CompTablet'
     Mesh=LodMesh'UPak.CompTablet'
}
