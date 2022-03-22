//=============================================================================
// WarpZoneInfo. For making disjoint spaces appear as if they were connected;
// supports both in-level warp zones and cross-level warp zones.
//=============================================================================
class WarpZoneInfo extends ZoneInfo
			native;

//-----------------------------------------------------------------------------
// Information set by the level designer.

var() name       TargetLevelID; // 227j: Sub-Level name to bind with.
var() string     OtherSideURL;	// Matching WarpZoneInfo.ThisTag.
var() name       ThisTag;
var() bool		 bNoTeleFrag;	// Don't allow pawns telefrag each other while warping through.

//-----------------------------------------------------------------------------
// Internal.

var const int              iWarpZone;
var coords                 WarpCoords;
var transient WarpZoneInfo OtherSideActor;
var transient Object       OtherSideLevel;
var() string		       Destinations[8]; // Altering destinations when triggering this zone.
var int					   numDestinations;

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if ( Role==ROLE_Authority )
		OtherSideURL, ThisTag, OtherSideActor;
}

//-----------------------------------------------------------------------------
// Functions.

// Warp coordinate system transformations.
native(314) final function Warp  ( out vector Loc, out vector Vel, out rotator R );
native(315) final function UnWarp( out vector Loc, out vector Vel, out rotator R );

// 227j: Warp/UnWarp with OtherSideActor in a single transformation pass.
native final function WarpBothCoords( out vector Loc, out vector Vel, out vector Accel, out rotator R, optional out vector ViewBob );

function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Generate the local connection.
	Generate();

	// Setup destination list.
	numDestinations = 0;
	While( numDestinations < 8 )
	if (Destinations[numDestinations] != "")
		numDestinations++;
	else
		numDestinations = 8;

	// Generate URL if necessary.
	if ( numDestinations>0 && (OtherSideURL == "") )
		OtherSideURL = Destinations[0];
}

function Trigger( actor Other, pawn EventInstigator )
{
	local int nextPick;
	if (numDestinations == 0)
		return;

	nextPick = 0;
	While( (nextPick < 8) && (Destinations[nextPick] != OtherSideURL )  )
	nextPick++;

	nextPick++;
	if ( (nextPick > 7) || (Destinations[nextPick] == "") )
		nextPick = 0;

	OtherSideURL = Destinations[nextPick];
	ForceGenerate();
}

// Set up this warp zone's destination.
simulated event Generate()
{
	if ( OtherSideLevel != None )
		return;
	ForceGenerate();
}

// Set up this warp zone's destination.
simulated event ForceGenerate()
{
	local LevelInfo L;

	if ( InStr(OtherSideURL,"/") >= 0 )
	{
		// Remote level.
		//log( "Warpzone " $ Self $ " remote" );
		OtherSideLevel = None;
		OtherSideActor = None;
	}
	else if( TargetLevelID!='' )
	{
		L = Level.FindLevel(TargetLevelID);
		if( L!=None )
		{
			OtherSideLevel = L.XLevel;
			foreach L.AllActors( class 'WarpZoneInfo', OtherSideActor )
				if ( string(OtherSideActor.ThisTag)~=OtherSideURL && OtherSideActor!=Self )
					break;
		}
	}
	else
	{
		// Local level.
		OtherSideLevel = XLevel;
		foreach AllActors( class 'WarpZoneInfo', OtherSideActor )
		if ( string(OtherSideActor.ThisTag)~=OtherSideURL && OtherSideActor!=Self )
			break;
		//log( "Warpzone " $ Self $ " local, connected to " $ OtherSideActor );
	}
}

// When an actor enters this warp zone.
simulated function ActorEntered( actor Other )
{
	//if ( Other.Role == ROLE_AutonomousProxy )
	//	return; // don't simulate for client players
	Super.ActorEntered( Other );
	if ( !Other.bJustTeleported )
	{
		Generate();
		if ( OtherSideActor != None )
			SetPendingTouch(Other); // 227j, use PostTouch for Velocity change to work correctly.
	}
}

simulated function PostTouch( actor Other )
{
	local vector L;
	local rotator R;
	local Pawn P;

	if ( OtherSideActor == None )
		return;

	// Do not allow client side send to level to avoid network desync.
	if( Other.Level!=OtherSideActor.Level && Other.Role<ROLE_Authority && !Other.bNetTemporary && !Other.bIsProjectile )
		return;
	
	// This needs to also perform a coordinate system transformation,
	// in case the portals aren't directionally aligned.
	Other.Disable('Touch');
	Other.Disable('UnTouch');

	L = Other.Location;
	if ( Other.bIsPlayerPawn )
		R = PlayerPawn(Other).ViewRotation;
	else
		R = Other.Rotation;

	// 227f: if both warpzones have same coords, dont affect some of the components.
	if ( WarpCoords.XAxis~=OtherSideActor.WarpCoords.XAxis
			&& WarpCoords.YAxis~=OtherSideActor.WarpCoords.YAxis )
	{
		L = L-WarpCoords.Origin+OtherSideActor.WarpCoords.Origin;
		if ( Other.bIsPawn )
		{
			Pawn(Other).bWarping = bNoTelefrag;
			
			if( Other.Level!=OtherSideActor.Level )
			{
				Other.SendToLevel(OtherSideActor.Level,L);
			}
			else if ( Other.SetLocation(L) )
			{
				//tell enemies about teleport
				if ( Role == ROLE_Authority )
				{
					foreach AllActors(class'Pawn',P)
					{
						if (P.Enemy == Other)
							P.LastSeenPos = Other.Location;
					}
				}
				Pawn(Other).MoveTimer = -1.0;
			}
			else
			{
				// set up to keep trying to teleport
				GotoState('DelayedWarp');
			}
		}
		else if( Other.Level!=OtherSideActor.Level )
			Other.SendToLevel(OtherSideActor.Level,L);
		else Other.SetLocation(L);
	}
	else
	{
		if ( Other.bIsPlayerPawn )
			WarpBothCoords( L, Other.Velocity, Other.Acceleration, R, Pawn(Other).WalkBob );
		else WarpBothCoords( L, Other.Velocity, Other.Acceleration, R );
		 
		//UnWarp( L, Other.Velocity, R );
		//OtherSideActor.Warp( L, Other.Velocity, R );

		if ( Other.bIsPawn )
		{
			Pawn(Other).bWarping = bNoTelefrag;
			
			if( Other.Level!=OtherSideActor.Level )
			{
				if( !Other.SendToLevel(OtherSideActor.Level,L,R) )
					GoTo'Failed';
				R.Roll = 0;
				Pawn(Other).ClientSetRotation(R);
			}
			else if( !Other.SetLocation(L) )
			{
				GotoState('DelayedWarp');
				GoTo'Failed';
			}
			else
			{
				//tell enemies about teleport
				if ( Role == ROLE_Authority )
				{
					foreach AllActors(class'Pawn',P)
					{
						if (P.Enemy == Other)
							P.LastSeenPos = Other.Location;
					}
					Pawn(Other).MoveTimer = -1.0;
				}
			}
			R.Roll = 0;
			if( !Other.bIsPlayerPawn || !PlayerPawn(Other).bUpdatePosition )
			{
				Pawn(Other).ViewRotation = R;
				R.Pitch = 0;
				Pawn(Other).SetRotation(R);
			}
		}
		else if( Other.Level!=OtherSideActor.Level )
		{
			Other.SendToLevel(OtherSideActor.Level,L,R);
		}
		else Other.SetLocation(L,R);
	}
Failed:
	Other.Enable('Touch');
	Other.Enable('UnTouch');
	// Change rotation according to portal's rotational change.
}

event ActorLeaving( actor Other )
{
	Super.ActorLeaving(Other);
	If ( Other.bIsPawn )
		Pawn(Other).bWarping = false;
}

State DelayedWarp
{
	function Tick(float DeltaTime)
	{
		local Pawn P;
		local bool bFound;

		foreach AllActors(class'Pawn',P)
			if ( P.bWarping && (P.Region.Zone == Self) )
			{
				bFound = true;
				ActorEntered(P);
			}

		If ( !bFound )
			GotoState('');
	}
}

// Spawn a marker for self.
function NotifyPathDefine( bool bPreNotify )
{
	local WarpZoneMarker myMarker;
	local vector HL,HN;

	if( !bPreNotify )
	{
		// Drop marker on floor.
		if( Trace(HL,HN,Location-vect(0,0,128),Location,false)!=None )
			HL.Z+=40;
		else HL = Location;
		
		FindSpot(HL,false,vect(20,20,40));
		
		foreach AllActors(class'WarpZoneMarker',myMarker)
			if( myMarker.markedWarpZone==Self )
			{
				myMarker.SetLocation(HL);
				return;
			}
		myMarker = Spawn(Class'WarpZoneMarker',,,HL,rot(0,0,0));
		myMarker.markedWarpZone = Self;
	}
}

event DrawEditorSelection( Canvas C )
{
	C.Draw3DLine(MakeColor(64,64,64), WarpCoords.Origin, Location);
	C.Draw3DLine(MakeColor(0,255,0), WarpCoords.Origin, WarpCoords.Origin+WarpCoords.XAxis*32.f);
	C.Draw3DLine(MakeColor(255,0,0), WarpCoords.Origin, WarpCoords.Origin+WarpCoords.YAxis*32.f);
	C.Draw3DLine(MakeColor(0,0,255), WarpCoords.Origin, WarpCoords.Origin+WarpCoords.ZAxis*32.f);
}

simulated function OnMirrorMode()
{
	WarpCoords.Origin.Y *= -1.f;
	WarpCoords.XAxis.Y *= -1.f;
	WarpCoords.YAxis.Y *= -1.f;
	WarpCoords.ZAxis.Y *= -1.f;
}

defaultproperties
{
	bEditorSelectRender=true
}