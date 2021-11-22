//=============================================================================
// WarpZoneMarker.
//=============================================================================
class WarpZoneMarker extends NavigationPoint
	nousercreate
	native;

cpptext
{
	AWarpZoneMarker() {}
	UBOOL IsValidOnImport() { return FALSE; }
}

var WarpZoneInfo markedWarpZone;

// AI related
var Actor TriggerActor;		//used to tell AI how to trigger me
var Actor TriggerActor2;

function PostBeginPlay()
{
	local WarpZoneMarker T;
	local LevelInfo L;

	if ( markedWarpZone != none && markedWarpZone.numDestinations > 1 )
		FindTriggerActor();
	Super.PostBeginPlay();
	
	if( markedWarpZone!=None && markedWarpZone.TargetLevelID!='' )
	{
		L = Level.FindLevel(markedWarpZone.TargetLevelID);
		if( L==None || L==Level )
			return;
			
		foreach L.AllActors(class'WarpZoneMarker',T)
			if ( string(T.markedWarpZone.ThisTag)~=markedWarpZone.OtherSideURL )
				AddReachSpec(GenReachSpec(Self, T, 100, 256, 256, R_SPECIAL),T);
	}
}

function FindTriggerActor()
{
	local ZoneTrigger Z;

	if ( markedWarpZone.ZoneTag=='' )
		Return;
	ForEach AllActors(class 'ZoneTrigger',Z,,markedWarpZone.ZoneTag)
	{
		TriggerActor = Z.GetTriggerActor();
		return;
	}
}

/* SpecialHandling is called by the navigation code when the next path has been found.
It gives that path an opportunity to modify the result based on any special considerations
*/

/* FIXME - how to figure out if other side actor is OK and use intelligently for all dests?
*/
function Actor SpecialHandling(Pawn Other)
{
	if (Other.Region.Zone == markedWarpZone)
		markedWarpZone.ActorEntered(Other);
	return self;
}
/*	if ( markedWarpZone.numDestinations <= 1 )
		return self;

	if ( markedWarpZone.OtherSideActor is OK )
		return self;

	if (TriggerActor == None)
	{
		FindTriggerActor();
		if (TriggerActor == None)
			return None;
	}

	return TriggerActor;
}
*/

// WarpZoneMarker is forced to be bound with other sides.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( WarpZoneMarker(End)!=None && string(WarpZoneMarker(End).markedWarpZone.ThisTag)~=markedWarpZone.OtherSideURL && markedWarpZone.TargetLevelID=='' )
	{
		ForcedDistance = 100;
		return PATHING_Special;
	}
	return Super.EdPathBuildExec(End,ForcedDistance);
}

// Kill off any possible remaining markers.
function NotifyPathDefine( bool bPreNotify )
{
	if( bPreNotify && (markedWarpZone==None || markedWarpZone.bDeleteMe) )
		Destroy();
}

defaultproperties
{
	bCollideWhenPlacing=False
	bHiddenEd=true
	CollisionRadius=+00020.000000
	CollisionHeight=+00040.000000
	bNoStrafeTo=true
}