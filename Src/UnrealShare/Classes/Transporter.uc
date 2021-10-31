//=============================================================================
// Transporter.
//=============================================================================
class Transporter extends NavigationPoint;

var() Vector Offset;

function Trigger( Actor Other, Pawn EventInstigator )
{
	local PlayerPawn tempPlayer;

	// Move the player instantaneously by the Offset vector

	// Find the players
	foreach AllActors( class 'PlayerPawn', tempPlayer )
	{
		if ( !tempPlayer.SetLocation( tempPlayer.Location + Offset ) )
		{
			// The player could not be moved, probably destination is inside a wall
		}
	}

	Disable( 'Trigger' );
}

defaultproperties
{
}

