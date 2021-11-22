//=============================================================================
// DyingTrigger.
//=============================================================================
class DyingTrigger expands KillTrigger;

function Triggered( actor Other, pawn EventInstigator )
{
	local Pawn P;
	
	foreach allactors( class'Pawn', P, KillTag )
		P.TakeDamage( P.Health*1.5, EventInstigator, P.Location, vect( 0, 0, 0 ), 'TriggeredDeath' );
}

defaultproperties
{
}
