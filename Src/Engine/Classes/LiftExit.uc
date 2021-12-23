//=============================================================================
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint;

var() name LiftTag; // Lift Tag with matching LiftCenter.LiftTag and Mover.Tag.
var	Mover MyLift;
var() name LiftTrigger; // Mover trigger Tag with matching Trigger.Tag.
var trigger RecommendedTrigger;
var float LastTriggerTime;

var() byte DesiredKeyFrame; // 227j: Keyframe required mover to be stopped at for this to be usable (255 = use LiftCenter.MaxZDiffAdd).
var() bool bCanJumpToCenter; // 227j: AI can jump off from this Exit to LiftCenter regardless where mover is.
var() bool bCanJumpToExit; // 227j: AI can jump off from LiftCenter to this Exit regardless where mover is.

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
	if ( (Other.Base == MyLift) && MyLift && !bCanJumpToExit )
	{
		if( DesiredKeyFrame!=255 )
		{
			if( MyLift.AtKeyFrame(DesiredKeyFrame) )
				return Self;
		}
		else if ( (Location.Z < Other.Location.Z + Other.CollisionHeight) && Other.LineOfSightTo(self) )
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
	DesiredKeyFrame=255
}
