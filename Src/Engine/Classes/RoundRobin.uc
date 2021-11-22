//=============================================================================
// RoundRobin: Each time it's triggered, it advances through a list of
// outgoing events.
//=============================================================================
class RoundRobin extends Triggers;

var() name OutEvents[16]; // Events to generate.
var() bool bLoop;         // Whether to loop when get to end.
var int i;                // Internal counter.

//
// When RoundRobin is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	if ( OutEvents[i] != '' )
	{
		TriggerEvent(OutEvents[i],Self,EventInstigator);
		if ( ++i>=ArrayCount(OutEvents) || OutEvents[i]=='' )
		{
			if ( bLoop ) i=0;
			else Disable('Trigger');
		}
	}
}

// Reset the roundrobin.
function Reset()
{
	Enable('Trigger');
	i = 0;
}

defaultproperties
{
}
