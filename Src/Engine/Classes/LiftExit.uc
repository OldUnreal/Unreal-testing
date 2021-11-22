//=============================================================================
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint
			native;

var() name LiftTag; // Lift Tag with matching LiftCenter.LiftTag and Mover.Tag.
var	Mover MyLift;
var() name LiftTrigger; // Mover trigger Tag with matching Trigger.Tag.
var trigger RecommendedTrigger;
var float LastTriggerTime;

function PostBeginPlay()
{
	if ( LiftTag != '' )
		ForEach AllActors(class'Mover', MyLift, LiftTag )
		break;
	//log(self$" attached to "$MyLift);
	if ( LiftTrigger != '' )
		ForEach AllActors(class'Trigger', RecommendedTrigger, LiftTrigger )
		break;
	Super.PostBeginPlay();
}

/* SpecialHandling is called by the navigation code when the next path has been found.
It gives that path an opportunity to modify the result based on any special considerations
*/

function Actor SpecialHandling(Pawn Other)
{

	if ( (Other.Base == MyLift) && (MyLift != None) )
	{
		if ( (self.Location.Z < Other.Location.Z + Other.CollisionHeight)
				&& Other.LineOfSightTo(self) )
			return self;
		Other.SpecialGoal = None;
		Other.DesiredRotation = rotator(Location - Other.Location);
		MyLift.HandleDoor(Other);

		if ( (Other.SpecialGoal == MyLift) || (Other.SpecialGoal == None) )
			Other.SpecialGoal = MyLift.myMarker;
		return Other.SpecialGoal;
	}
	return self;
}
// Lift exit are forced to be bound with matching LiftCenter.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( LiftCenter(End)!=None && LiftTag!='' && LiftCenter(End).LiftTag==LiftTag )
	{
		ForcedDistance = 500;
		return PATHING_Special;
	}
	return Super.EdPathBuildExec(End,ForcedDistance);
}

defaultproperties
{
	ForcedPathSize=60
	bNoStrafeTo=true
}
