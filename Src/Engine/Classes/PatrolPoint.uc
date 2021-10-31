//=============================================================================
// PatrolPoint.
//=============================================================================
class PatrolPoint extends NavigationPoint;

#exec Texture Import File=Textures\PathNode.pcx Name=S_Patrol Mips=Off Flags=2

var() name Nextpatrol; // Next point to go to.
var() float PauseTime; // How long to pause here
var	 vector lookdir; // Direction to look while stopped
var() name PatrolAnim; // Animation to play while paused (if used it will ignores PauseTime).
var() sound PatrolSound; // Sound to play while paused.
var() byte numAnims; // Number of times animation should play.
var int	AnimCount;
var PatrolPoint NextPatrolPoint;

function PreBeginPlay()
{
	if (pausetime > 0.0)
		lookdir = 200 * vector(Rotation);

	// find the patrol point with the tag specified by Nextpatrol
	foreach AllActors(class 'PatrolPoint', NextPatrolPoint, Nextpatrol)
		break;

	Super.PreBeginPlay();
}
defaultproperties
{
	bDirectional=True
	SoundVolume=128
	Texture=S_Patrol
	bNoStrafeTo=true
}
