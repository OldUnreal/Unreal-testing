//=============================================================================
// LiftCenter.
//=============================================================================
class LiftCenter extends NavigationPoint
			native;

var() name LiftTag; // Matching Tag with LiftExit.LiftTag and Mover.Tag.
var	 mover MyLift;
var() name LiftTrigger; // Trigger for this elevator by matching Trigger.Tag.
var trigger RecommendedTrigger;
var float LastTriggerTime;
var() float MaxZDiffAdd; // Added threshold for Z difference between pawn and lift (for lifts which are at the end of a ramp or stairs)

function PostBeginPlay()
{
	if ( LiftTag != '' )
		ForEach AllActors(class'Mover', MyLift, LiftTag )
	{
		MyLift.myMarker = self;
		SetBase(MyLift);
		break;
	}
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
	local float dist2d;

	if ( MyLift == None )
		return self;
	if ( Other.base == MyLift )
	{
		if ( (RecommendedTrigger != None)
				&& (myLift.SavedTrigger == None)
				&& (Level.TimeSeconds - LastTriggerTime > 5) )
		{
			Other.SpecialGoal = RecommendedTrigger;
			LastTriggerTime = Level.TimeSeconds;
			return RecommendedTrigger;
		}

		return self;
	}

	if ( (LiftExit(Other.MoveTarget) != None)
			&& (LiftExit(Other.MoveTarget).RecommendedTrigger != None)
			&& (LiftExit(Other.MoveTarget).LiftTag == LiftTag)
			&& (Level.TimeSeconds - LiftExit(Other.MoveTarget).LastTriggerTime > 5)
			&& (MyLift.SavedTrigger == None)
			&& (Abs(Other.Location.X - Other.MoveTarget.Location.X) < Other.CollisionRadius)
			&& (Abs(Other.Location.Y - Other.MoveTarget.Location.Y) < Other.CollisionRadius)
			&& (Abs(Other.Location.Z - Other.MoveTarget.Location.Z) < Other.CollisionHeight) )
	{
		LiftExit(Other.MoveTarget).LastTriggerTime = Level.TimeSeconds;
		Other.SpecialGoal = LiftExit(Other.MoveTarget).RecommendedTrigger;
		return LiftExit(Other.MoveTarget).RecommendedTrigger;
	}

	dist2d = square(Location.X - Other.Location.X) + square(Location.Y - Other.Location.Y);
	if ( (Location.Z - CollisionHeight - MaxZDiffAdd < Other.Location.Z - Other.CollisionHeight + Other.MaxStepHeight)
			&& (Location.Z - CollisionHeight > Other.Location.Z - Other.CollisionHeight - 1200)
			&& ( dist2D < 160000) )
	{
		return self;
	}

	if ( MyLift.BumpType == BT_PlayerBump && !Other.bIsPlayer )
		return None;
	Other.SpecialGoal = None;

	MyLift.HandleDoor(Other);
	MyLift.RecommendedTrigger = None;

	if ( (Other.SpecialGoal == MyLift) || (Other.SpecialGoal == None) )
		Other.SpecialGoal = self;

	return Other.SpecialGoal;
}

// LiftCenter can only be bound with matching LiftExit.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( LiftExit(End)!=None && LiftTag!='' && LiftExit(End).LiftTag==LiftTag && End.CanBindWith(Self) )
	{
		ForcedDistance = 500;
		return PATHING_Special;
	}
	return PATHING_Proscribe;
}

// LiftCenter accepts no path requests.
function bool CanBindWith( NavigationPoint Start )
{
	return false;
}

defaultproperties
{
	bNoDelete=true
	bStatic=false
	ExtraCost=400
	ForcedPathSize=60
	bNoStrafeTo=true
}