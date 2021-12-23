//=============================================================================
// LiftCenter.
//=============================================================================
class LiftCenter extends NavigationPoint;

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
	local LiftExit Src;

	if ( MyLift == None )
		return self;
	if ( Other.Base == MyLift )
	{
		if ( RecommendedTrigger && !myLift.SavedTrigger && (Level.TimeSeconds - LastTriggerTime > 5) )
		{
			Other.SpecialGoal = RecommendedTrigger;
			LastTriggerTime = Level.TimeSeconds;
			return RecommendedTrigger;
		}
		return Self;
	}

	Src = LiftExit(Other.LastAnchor);
	if( !Src )
		Src = LiftExit(Other.MoveTarget);
	
	if( Src )
	{
		if( Src.bCanJumpToCenter )
			return Self;
		
		if( Src.DesiredKeyFrame!=255 )
		{
			if( MyLift && MyLift.AtKeyFrame(Src.DesiredKeyFrame) )
				return Self;
		}
		else if ( Src.RecommendedTrigger && (Src.LiftTag == LiftTag) && (Level.TimeSeconds - Src.LastTriggerTime > 5)
				&& !MyLift.SavedTrigger
				&& (Abs(Other.Location.X - Src.Location.X) < Other.CollisionRadius)
				&& (Abs(Other.Location.Y - Src.Location.Y) < Other.CollisionRadius)
				&& (Abs(Other.Location.Z - Src.Location.Z) < Other.CollisionHeight) )
		{
			Src.LastTriggerTime = Level.TimeSeconds;
			Other.SpecialGoal = Src.RecommendedTrigger;
			return Src.RecommendedTrigger;
		}
	}

	if( !Src || Src.DesiredKeyFrame==255 )
	{
		dist2d = VSize2DSq(Location - Other.Location);
		if ( (Location.Z - CollisionHeight - MaxZDiffAdd < Other.Location.Z - Other.CollisionHeight + Other.MaxStepHeight)
				&& (Location.Z - CollisionHeight > Other.Location.Z - Other.CollisionHeight - 1200)
				&& (dist2D < 160000) )
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
	bIsSpecialNode=true
}