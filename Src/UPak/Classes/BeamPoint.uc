//=============================================================================
// BeamPoint.
//=============================================================================
class BeamPoint expands Keypoint;

var Octagon Beam;
var() float BeamLifeSpan;

function Trigger( actor Other, pawn EventInstigator )
{
	Beam = Spawn( class'Octagon',,, Location );
	SetTimer( 0.5, false );
}

function Timer()
{
	Spawn( class'PresetMarineCarcass',,, Location );
}

defaultproperties
{
}
