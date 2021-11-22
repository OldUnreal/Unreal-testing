//=============================================================================
// SparkGenerator.
//=============================================================================
class SparkGenerator expands Effects;

function Trigger( actor Other, Pawn EventInstigator )
{
	spawn( class'SmallSpark',,, Location, Rotation );
}

defaultproperties
{
}
