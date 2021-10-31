//=============================================================================
// TracerStreak.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================

//------------------------------------------------------------------------------
// Description:	Effect for simulating a tracer bullet.
//------------------------------------------------------------------------------
// How to use this class:
//
// + Spawn it.
// + Set the endpoints for where the streak will be drawn from/to in the same tick.
// + The fading process is automatically started on the next tick.
//------------------------------------------------------------------------------
// How this class works:
//
// + Connects the two endpoints with large segments. 
// + Starting with the first segment, it is broken into two parts.
// + Then of those two new segments, the first one is broken into two parts.
// + Then of those two new segments, the first one is faded out. 
//   (Using ScaleGlow/Translucency).
// + Once the first segment is completely faded away, the second is faded out.
// + Then the second (next larger) segment is broken in two and those are 
//   faded out.
// + This continues until all the segments are faded out.
//------------------------------------------------------------------------------

class TracerStreak expands Effects;

//////////////////////
// Member variables //
//////////////////////

// Endpoints of streak.
var() vector Start;
var() vector End;

var() class<TracerSeg> SegmentType;
var TracerSeg CurrentSegment;
var vector ObstructionLocation;
var TracerSeg LastSegment;
var bool bFinished;

replication
{
	reliable if( Role==ROLE_Authority )
		Start, End;
}

////////////////
// Interfaces //
////////////////
//------------------------------------------------------------------------------
// Returns true if the given vectors are aproximately equal.
// Fix MWP: This should probably be added to the engine.
//------------------------------------------------------------------------------
static function bool VectorAproxEqual( vector FirstVector, vector SecondVector )
{
	return ( ( FirstVector.x ~= SecondVector.x ) &&
			( FirstVector.y ~= SecondVector.y ) &&
			( FirstVector.z ~= SecondVector.z ) );
}


//------------------------------------------------------------------------------
// This function must be called on the server in the same tick within which it
// was spawned.  The fading process will begin automatically on the next tick.
//------------------------------------------------------------------------------
function SetEndpoints( vector StartPoint, vector EndPoint )
{
	Start = StartPoint;
	End = EndPoint;
}

//------------------------------------------------------------------------------
simulated function FinishedFading();

///////////
// Logic //
///////////

//------------------------------------------------------------------------------
simulated function Tick( float DeltaTime )
{
	if( Start != End || bFinished )
	{
		GotoState('Fading');
	}
	else
	{
		Destroy();
	}
}

//------------------------------------------------------------------------------
simulated state Fading
{
	simulated function BeginState()
	{
		local vector i;
		local vector StreakDirection;
		local rotator StreakRotation;
		local TracerSeg FirstSegment, Seg;
		local Actor HitActor;
		local vector HitNormal, HitLocation;
		
		local vector X,Y,Z;
		
		StreakDirection = Normal(End - Start);
		StreakRotation = rotator(StreakDirection);
		FirstSegment = None;
		SegmentType = class'TracerSegSm';
		for( i = Start; VectorAproxEqual( StreakDirection, Normal(End - i) ); i += StreakDirection * SegmentType.default.CollisionRadius )
		{
			if( FirstSegment == None )
			{
				FirstSegment = Spawn( SegmentType,,, i, StreakRotation );
				Seg = FirstSegment;
			}
			GetAxes(Rotation,X,Y,Z);
		
			HitActor = Trace(HitLocation, HitNormal, Location + Seg.Default.CollisionRadius * X, Location, true);
//			log( "HITACTOR: "$HitActor );
			if ( (HitActor != None) && (HitActor.bProjTarget || (HitActor == Level)
				|| (HitActor.bBlockActors && HitActor.bBlockPlayers)) 
				&& ((Pawn(HitActor) == None) || (HitActor != Instigator) || 
				!Pawn(HitActor).AdjustHitLocation(HitLocation, Velocity)) )
			{
//				log( "HITWALL" );
				Seg.NextSegment = None;
				LastSegment.Destroy();
				bFinished = True;
			}
			else if( FirstSegment != None )
			{
//				log( "Addding on" );
				Seg.NextSegment = Spawn( class'TracerSegSM',,, i, StreakRotation );
				Seg = Seg.NextSegment;
				LastSegment = Seg;
			}

			Seg.Parent = Self;
		}

		Seg.NextSegment = None;

		CurrentSegment = FirstSegment;

		CurrentSegment.Fade();
	}

	// Notification for when our currently fading segment is finished.
	simulated function FinishedFading()
	{
		CurrentSegment = CurrentSegment.NextSegment;
		if( CurrentSegment != None )
		{
			CurrentSegment.Fade();
		}
		else
		{
			Destroy();
		}
	}
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Sprite
     bAlwaysRelevant=True
}
