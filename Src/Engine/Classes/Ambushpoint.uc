//=============================================================================
// Ambushpoint.
//=============================================================================
class AmbushPoint extends NavigationPoint;

var vector lookdir;		/* Direction to look while ambushing
						at start, ambushing creatures will pick either their current location, or the location of
						some ambushpoint belonging to their team */
var byte survivecount; // used when picking ambushpoint

function PreBeginPlay()
{
	lookdir = 2000 * vector(Rotation);

	Super.PreBeginPlay();
}

defaultproperties
{
	bDirectional=True
	SoundVolume=128
}
