//=============================================================================
// AlarmPointHate.
//=============================================================================
class AlarmPointHate expands NavigationPoint;

function Touch( actor Other )
{
	if( Other.IsA( 'Pawn' ) && Pawn( Other ).AttitudeToPlayer == ATTITUDE_Ignore )
	{
		Pawn( Other ).AttitudeToPlayer = ATTITUDE_Hate;
	}
}

defaultproperties
{
     bCollideActors=True
     bCollideWorld=True
}
