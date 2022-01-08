//=============================================================================
// NavigationPoint.
//=============================================================================
class NavigationPoint extends Actor
	native;

#exec Texture Import File=Textures\S_Pickup.pcx Name=S_Pickup Mips=Off Flags=2

//------------------------------------------------------------------------------
// NavigationPoint variables
var() name ownerTeam;	// Creature clan owning this area (area visible from this point)
var() name ProscribedPaths[4]; // 227: list of names or tags of NavigationPoints which should never be connected from this path
var() name ForcedPaths[4];	// 227: list of names or tags of NavigationPoints which should always be connected from this path
var int upstreamPaths[16];
var int Paths[16]; // index of reachspecs (used by C++ Navigation code)
var int PrunedPaths[16];
var NavigationPoint VisNoReachPaths[16]; // paths that are visible but not directly reachable
var transient int visitedWeight;
var actor RouteCache;
var transient const int bestPathWeight;
var NavigationPoint nextNavigationPoint;
var transient const NavigationPoint nextOrdered;
var transient const NavigationPoint prevOrdered;
var transient const NavigationPoint startPath;
var transient const NavigationPoint previousPath;
var transient int cost; // added cost to visit this pathnode
var() int ExtraCost; // Added extra cost to this path (cost is in UU distance scaling).
var transient private int PathSearchTag;

var() byte PathDescription; // pointer to path description in zoneinfo LocationStrings array
var pointer<FComputedReachability*> EditorData;

var() int ForcedPathSize; // 227: When path is forced, use this as path size.
var() float MaxPathDistance; // 227: Maximum path distance (used in editor while binding paths).

var const Inventory DroppedInvList; // 227: Pointer to dropped inventory near this node.

enum PathBuildingType
{
	PATHING_Normal, // No special actions taken, simply check path size normally.
	PATHING_Proscribe, // Never bind to this pathnode.
	PATHING_Force, // Force to bind to this pathnode.
	PATHING_Special, // Special path, same as forced path but requires AI special flag.
};

// Flags
var transient bool taken; // set when a creature is occupying this spot
var() bool bPlayerOnly;	// only players should use this path
var transient bool bEndPoint; // used by C++ navigation code
var bool bEndPointOnly; // only used as an endpoint in routing network
var bool bSpecialCost;	// if true, navigation code will call SpecialCost function for this navigation point
var() bool bOneWayPath;	// ReachSpecs from this path only in the direction the path is facing (180 degrees).
var bool bAutoBuilt;	// placed during execution of "PATHS BUILD"
var() bool bNoStrafeTo; // Pawn should never use serpentine movement upon entering this path.
var bool bIsSpecialNode; // 227j: This node is special goal and shouldn't consider for visible-no-reach checks or shortcut path checks.

native(519) final function describeSpec(int iSpec, out Actor Start, out Actor End, out int ReachFlags, out int Distance);
event int SpecialCost(Pawn Seeker);

// New U227 functions:

// Reach flags description:
const noexport R_WALK = 1;			// bCanWalk required
const noexport R_FLY = 2;			// bCanFly required 
const noexport R_SWIM = 4;			// bCanSwim required
const noexport R_JUMP = 8;			// bCanJump required
const noexport R_DOOR = 16;			// bCanOpenDoors required
const noexport R_SPECIAL = 32;		// bCanDoSpecial required
const noexport R_PLAYERONLY = 64;	// bIsPlayer required

/* Very fast:
Generate a new ReachSpec, example:
Start.AddReachSpec(GenReachSpec(Start,End,VSize(Start.Location-End.Location),50,70,R_WALK),End); */
native(1712) final function int GenReachSpec( Actor Start, Actor End, optional int Dist, optional int ColR, optional int ColH, optional int RchFlgs );

/* Very fast:
Edit an excisting reachspec */
native(1713) final function bool EditReach( int Idx, optional Actor Start, optional Actor End, optional int Dist, optional int ColR,
		optional int ColH, optional int RchFlgs, optional bool bPruned );

/* Very fast:
Remove an existing reachspec.
WARNING: If you remove for example, reachspec #25, all remaining reachspecs after will go -1; #26 becomes #25, #27 becomes #26 etc. It could break
down entire map navigation for AI! */
native(1714) final function bool RemoveReachSpec( int Idx );

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept( actor Incoming )
{
	// Move the actor here.
	taken = Incoming.SetLocation( Location + vect (0,0,20), Rotation);
	if (taken)
		Incoming.Velocity = vect(0,0,0);

	// Play teleport-in effect.
	PlayTeleportEffect(Incoming, true);
	return taken;
}

function PlayTeleportEffect(actor Incoming, bool bOut)
{
	Level.Game.PlayTeleportEffect(Incoming, bOut, false);
}

// Executed in editor while building paths (this is overrided by Forced/ProscribedPaths list).
event PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( End.CanBindWith(Self) )
		return PATHING_Normal;
	return PATHING_Proscribe;
}
function bool CanBindWith( NavigationPoint Start )
{
	return true;
}

// Proper placement on slopes.
function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	if( HitNormal.Z>0.4 && !bCollideWhenPlacing )
	{
		HitLocation.Z+=CollisionHeight;
		SetLocation(HitLocation);
	}
}

// Manually add a reachspec in UnrealScript.
final function AddReachSpec( int iSpec, NavigationPoint End )
{
	local byte i;
	
	for( i=0; i<ArrayCount(Paths); ++i )
	{
		if( Paths[i]==-1 )
		{
			Paths[i] = iSpec;
			break;
		}
	}
	for( i=0; i<ArrayCount(upstreamPaths); ++i )
	{
		if( End.upstreamPaths[i]==-1 )
		{
			End.upstreamPaths[i] = iSpec;
			break;
		}
	}
}

defaultproperties
{
	upstreamPaths(0)=-1
	upstreamPaths(1)=-1
	upstreamPaths(2)=-1
	upstreamPaths(3)=-1
	upstreamPaths(4)=-1
	upstreamPaths(5)=-1
	upstreamPaths(6)=-1
	upstreamPaths(7)=-1
	upstreamPaths(8)=-1
	upstreamPaths(9)=-1
	upstreamPaths(10)=-1
	upstreamPaths(11)=-1
	upstreamPaths(12)=-1
	upstreamPaths(13)=-1
	upstreamPaths(14)=-1
	upstreamPaths(15)=-1
	Paths(0)=-1
	Paths(1)=-1
	Paths(2)=-1
	Paths(3)=-1
	Paths(4)=-1
	Paths(5)=-1
	Paths(6)=-1
	Paths(7)=-1
	Paths(8)=-1
	Paths(9)=-1
	Paths(10)=-1
	Paths(11)=-1
	Paths(12)=-1
	Paths(13)=-1
	Paths(14)=-1
	Paths(15)=-1
	PrunedPaths(0)=-1
	PrunedPaths(1)=-1
	PrunedPaths(2)=-1
	PrunedPaths(3)=-1
	PrunedPaths(4)=-1
	PrunedPaths(5)=-1
	PrunedPaths(6)=-1
	PrunedPaths(7)=-1
	PrunedPaths(8)=-1
	PrunedPaths(9)=-1
	PrunedPaths(10)=-1
	PrunedPaths(11)=-1
	PrunedPaths(12)=-1
	PrunedPaths(13)=-1
	PrunedPaths(14)=-1
	PrunedPaths(15)=-1
	PathDescription=12
	ForcedPathSize=150
	MaxPathDistance=1000
	bStatic=True
	bHidden=True
	SoundVolume=0
	CollisionRadius=46.000000
	CollisionHeight=50.000000
}
