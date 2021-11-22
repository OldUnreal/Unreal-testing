//=============================================================================
// TracerSeg.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================

//------------------------------------------------------------------------------
// Description:	Used by TracerStreak.
//------------------------------------------------------------------------------
// How to use this class:
//
// + Subclass.
// + Set Mesh to use as segment.  
//   (Align down the x-axis with the origin at the leftmost end of the mesh.)
// + Set the CollisionRadius to represent the length of your segment.
// + Set the subtype (SegmentType) to use, or leave None if you want this 
//   to be the segment that actually gets faded out.
// + Set the FadeTime for those segments whose SegmentType is None (the ones 
//   that will actually be faded out).
//------------------------------------------------------------------------------
// How this class works:
//
// + See TracerStreak
//------------------------------------------------------------------------------

class TracerSeg expands Effects
	abstract;

// Fix ARL: Collapse TracerStreak and TracerSeg into a single class.

//////////////////////
// Member variables //
//////////////////////

var() class<TracerSeg> SegmentType;
var TracerSeg CurrentSegment;		// Next TracerSet in linked list.
var Actor Parent;					// Parent actor in N-ary tree.
var bool bNotifiedParent;


var() Texture FadedTexture;	// Texture to use when we go Translucent.  (It None, then we use the normal texture.)

// Used by our parent to maintain a linked list.
var TracerSeg NextSegment;

var() float FadeTime;		// How long it takes us to go from default.ScaleGlow to 0.0;
var() float FadeInterval;	// How long before triggering the next segment to fade.
							// (if zero, it waits until we are completely faded.)
							// (FadeInterval is clamped at FadeTime.)

var bool bNoMore;

////////////////
// Interfaces //
////////////////

simulated function HitWall( Vector HitNormal, Actor Wall )
{
	Destroy();
}

//------------------------------------------------------------------------------
simulated function Fade()
{
	if( SegmentType != None )
	{
		GotoState('Orchestrating');
	}
	else
	{
		GotoState('Fading');
	}
}

//------------------------------------------------------------------------------
simulated function FinishedFading();

////////////
// States //
////////////
//------------------------------------------------------------------------------
// Returns true if the given vectors are aproximately equal.
// Fix MWP: This should probably be added to the engine.
//------------------------------------------------------------------------------
function bool VectorAproxEqual( vector FirstVector, vector SecondVector )
{
	return ( ( FirstVector.x ~= SecondVector.x ) &&
			( FirstVector.y ~= SecondVector.y ) &&
			( FirstVector.z ~= SecondVector.z ) );
}


//------------------------------------------------------------------------------
simulated state Orchestrating
{
	simulated function BeginState()
	{
		local vector Start, End;
		local vector i;
		local vector StreakDirection;
		local rotator StreakRotation;
		local TracerSeg FirstSegment, Seg;
	
		bHidden = True;

		StreakRotation = Rotation;
		StreakDirection = Normal(vector(StreakRotation));

		Start = Location;
		End = Start + StreakDirection * CollisionRadius;

		FirstSegment = None;
		SegmentType = class'TracerSegSm';
		for( i = Start; VectorAproxEqual( StreakDirection, Normal(End - i) ); i += StreakDirection * SegmentType.default.CollisionRadius )
		{
			if( FirstSegment == None )
			{
				FirstSegment = Spawn( class'TracerSegSm',,, i, StreakRotation );
				Seg = FirstSegment;
			}
			else	
			{
				Seg.NextSegment = Spawn( class'TracerSegSm',,, i, StreakRotation );
				Seg = Seg.NextSegment;
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
			NotifyParent();
			Destroy();
		}
	}
}

//------------------------------------------------------------------------------
simulated state Fading
{
	simulated function BeginState()
	{
		Skin = FadedTexture;
		Style = STY_Translucent;
		LifeSpan = FadeTime;

		if( FadeInterval > 0.0 && FadeInterval < FadeTime ) SetTimer( FadeInterval, False );
	}

	simulated function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		ScaleGlow = default.ScaleGlow * LifeSpan / FadeTime;
	}

	simulated function Destroyed()
	{
		NotifyParent();
		Super.Destroyed();
	}

	simulated function Timer()
	{
		NotifyParent();
	}
}

//////////////////////
// Helper functions //
//////////////////////

//------------------------------------------------------------------------------
simulated function NotifyParent()
{
	if( !bNotifiedParent )
	{
		bNotifiedParent = True;

		if( TracerSeg(Parent) != None )
		{
			TracerSeg(Parent).FinishedFading();
		}
		else if( TracerStreak(Parent) != None )
		{
			TracerStreak(Parent).FinishedFading();
		}
	}
}

defaultproperties
{
     RemoteRole=ROLE_None
     bCollideWorld=True
}
