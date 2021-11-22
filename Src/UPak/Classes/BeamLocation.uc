//=============================================================================
// BeamLocation.
//=============================================================================
class BeamLocation expands Keypoint;

var() actor BeamActor;

var Octagon Beam;

function Trigger( actor Other, pawn EventInstigator )
{
	Beam = Spawn( class'Octagon',,, Location );
	SetTimer( 2.0, false );
}

function Timer()
{
	Spawn( BeamActor.Class,,, Location );
}

defaultproperties
{
}
