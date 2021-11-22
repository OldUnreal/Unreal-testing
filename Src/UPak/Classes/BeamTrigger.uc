//=============================================================================
// BeamTrigger.
//=============================================================================
class BeamTrigger expands Triggers;

var Octagon Beam;
var() float BeamLifeSpan;

function Trigger( actor Other, pawn EventInstigator )
{
	Beam = Spawn( class'Octagon',,, Location );
	SetTimer( 2.0, false );
}

function Timer()
{
	Spawn( class'PresetMarineCarcass',,, Location );
}

defaultproperties
{
}
