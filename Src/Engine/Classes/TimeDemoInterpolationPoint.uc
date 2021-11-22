//=============================================================================
// TimeDemoInterpolationPoint - used to time one cycle of a flyby
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class TimeDemoInterpolationPoint extends InterpolationPoint;

var TimeDemo T;

function InterpolateEnd( actor Other )
{
	if ( T!=None)
		T.StartCycle();
	Super.InterpolateEnd(Other);
}

defaultproperties
{
	bNoDelete=false
}