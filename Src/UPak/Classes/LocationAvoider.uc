//=============================================================================
// LocationAvoider.
//=============================================================================
class LocationAvoider expands FearSpot;

function BeginPlay()
{
	local Pawn P;

	foreach TouchingActors( class'Pawn', P )
		Touch( P );
}
function Touch( actor Other )
{
	if ( Other.bIsPawn )
		Pawn(Other).FearThisSpot(self);
}

defaultproperties
{
     RemoteRole=ROLE_None
     CollisionRadius=300.000000
}
