//=============================================================================
// LiftJumpDest. 227j: Tell AI how to lift-jump to this dest.
//=============================================================================
Class LiftJumpDest extends LiftExit;

var() byte SourceKeyNum; // This is the keyframe mover starts from -> DesiredKeyFrame where lift-jumping is possible.
var() float JumpMoveAlpha; // Elevator alpha at which point AI should jump off the mover.
var() float JumpZSpeed; // Hardcoded JumpZ speed for AI when jumping off elevator.
var() float MinXYSpeed; // Hardcoded minimum AI 'groundspeed'.

function Actor SpecialHandling(Pawn Other)
{
	if ( (Other.Base == MyLift) && MyLift )
	{
		if( MyLift.bInterpolating )
		{
			Other.DesiredRotation = rotator(Location - Other.Location);
			if( MyLift.KeyNum==DesiredKeyFrame && MyLift.PrevKeyNum==SourceKeyNum )
			{
				if( MyLift.PhysAlpha>=JumpMoveAlpha && MyLift.PhysAlpha<=(JumpMoveAlpha+0.1f) )
				{
					PerformAIJump(Other);
					return Self;
				}
				else SetTimer(0.05,true);
			}
			Other.SpecialPause = 0.5f;
			return self;
		}
		
		Other.SpecialGoal = None;
		Other.DesiredRotation = rotator(Location - Other.Location);
		MyLift.HandleDoor(Other);

		if ( (Other.SpecialGoal == MyLift) || (Other.SpecialGoal == None) )
			Other.SpecialGoal = MyLift.myMarker;
		return Other.SpecialGoal;
	}
	return self;
}

function Timer()
{
	local Pawn P;
	
	if( MyLift.KeyNum==DesiredKeyFrame && MyLift.PrevKeyNum==SourceKeyNum && MyLift.bInterpolating )
	{
		if( MyLift.PhysAlpha>=JumpMoveAlpha && MyLift.PhysAlpha<=(JumpMoveAlpha+0.1f) )
		{
			// Wake up AI.
			foreach AllActors(class'Pawn',P)
				if( P.MoveTarget==Self && P.LatentFloat>0.f )
					P.StopWaiting();
			SetTimer(0,false);
		}
	}
	else SetTimer(0,false);
}

function PerformAIJump( Pawn Other )
{
	if( Other.bIsPlayerPawn || Other.Health<=0 ) return;
	
	Other.Velocity = Other.SuggestFallVelocity(Other.Location, Location, JumpZSpeed, FMax(Other.GroundSpeed, MinXYSpeed), MyLift.Velocity.Z);
	Other.SetPhysics(PHYS_Falling);
	Other.PlayInAir();
}

defaultproperties
{
	bCanJumpToCenter=true
	DesiredKeyFrame=1
	JumpMoveAlpha=0.7
	JumpZSpeed=300
	MinXYSpeed=400
	bNoDelete=true
	bStatic=false
	RemoteRole=ROLE_None
}