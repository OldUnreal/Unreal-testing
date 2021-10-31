//=============================================================================
// DyingPoint.
//=============================================================================
class DyingPoint expands KillPoint;

function Trigger( actor Other, Pawn EventInstigator )
{
	local Pawn Target;
	foreach allactors( class'Pawn', Target, MatchedTag )
	{
		Target.TakeDamage( Target.Health*1.5, Pawn( Other ), Target.Location, vect( 0, 0, 0 ), 'AutoKilled' );
		if( Target.IsA( 'ParentBlob' ) || Target.IsA( 'Bloblet' ) )
			Target.Destroy();
	}
	
	Destroy();
}

defaultproperties
{
}
