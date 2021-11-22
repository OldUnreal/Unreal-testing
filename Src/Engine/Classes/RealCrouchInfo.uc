class RealCrouchInfo expands Info
	nousercreate;

var() bool bCanCrouchWhenSwimming;     // Player can crouch when swimming in liquids
var() bool bCanCrouchWhenFlying;       // Player can crouch in the flight mode
var() bool bCanCrouchToCeiling;        // Player can crouch to ceiling by holding the Jump key (when swimming or flying)
var() bool bCanDelayForcedUncrouching; // Force uncrouching (when crouching is normally not allowed) only after releasing the Duck key
var() bool bNoHeadShotWhenCrouching;   // No headshots when the player has reduced CollisionHeight

var PlayerPawn PlayerOwner;
var float MaxEyeHeightModifier;
var float PrePivotZ;
var int SetCrouchCallsCount;

var bool bSupportsRealCrouching,bSupportsCrouchJump;

//var private bool bIsBlocked;
//var private Actor BumpedActor;

replication
{
	unreliable if (Role == ROLE_Authority)
		bSupportsRealCrouching,
		bSupportsCrouchJump,
		bCanCrouchWhenSwimming,
		bCanCrouchWhenFlying,
		bCanCrouchToCeiling,
		bCanDelayForcedUncrouching,
		bNoHeadShotWhenCrouching;
}

// -----------------------------------------------------------------------------
// Public functions

state Inactive
{
	ignores Tick;
}

event PostBeginPlay()
{
	bSupportsRealCrouching = Level.bSupportsRealCrouching;
	bSupportsCrouchJump = Level.bSupportsCrouchJump;
}

simulated event PostNetBeginPlay()
{
	PlayerOwner = PlayerPawn(Owner);
	if( PlayerOwner.Player!=None )
		PlayerOwner.SetRealCrouchInfo(self);
}

simulated event PostNetReceive()
{
	Level.bSupportsRealCrouching = bSupportsRealCrouching;
	Level.bSupportsCrouchJump = bSupportsCrouchJump;
}

simulated event Tick(float DeltaTime)
{
	local bool bUpdate;

	if (PlayerOwner == none || PlayerOwner.bDeleteMe)
	{
		if (Role == ROLE_Authority)
			Destroy();
		return;
	}

	if( Level.NetMode!=NM_Client )
	{
		bSupportsRealCrouching = Level.bSupportsRealCrouching;
		bSupportsCrouchJump = Level.bSupportsCrouchJump;
		if (!bSupportsRealCrouching)
		{
			Disable('Tick');
			return;
		}
	}

	bUpdate = UpdateCrouch();
	bUpdate = UpdateMaxEyeHeightModifier(DeltaTime) || bUpdate;
	bUpdate = UpdatePrePivotZ(DeltaTime) || bUpdate;
	bUpdate = UpdateCarriedDecoration() || bUpdate;
	if( !bUpdate )
		Disable('Tick');
}

simulated function Init()
{
	PlayerOwner = PlayerPawn(Owner);
	if (PlayerOwner != none)
		PrePivotZ = PlayerOwner.PrePivot.Z;
	if( Level.NetMode != NM_Client && NetConnection(PlayerOwner.Player)!=None ) //<- Level.default.bSupportsRealCrouching is never true
		RemoteRole = ROLE_SimulatedProxy;
}

final simulated function Inactivate()
{
	if (Role < ROLE_Authority)
		GotoState('Inactive');
	else
		Destroy();
}

simulated function bool SetCrouch(bool bCrouching)
{
	local float DesiredCollisionHeight;
	local vector Offset;

	if (PlayerOwner.bIsReducedCrouch == bCrouching)
		return true;
	if (SetCrouchCallsCount > 1) // Prevents infinite recursive calls
		return false;

	++SetCrouchCallsCount;

	if (bCrouching)
	{
		// Update CollisionHeight and Location
		DesiredCollisionHeight = ReducedCollisionHeight();
		if (PlayerOwner.CollisionHeight <= DesiredCollisionHeight)
		{
			PlayerOwner.bIsReducedCrouch = bCrouching;
			return SetCrouch_Result(true);
		}

		if (PlayerOwner.Physics == PHYS_Walking)
		{
			Offset.Z = DesiredCollisionHeight - PlayerOwner.CollisionHeight;
			if (!bCanCrouchWhenSwimming && !bCanDelayForcedUncrouching && Level.GetLocZone(PlayerOwner.Location + Offset).Zone.bWaterZone)
				return SetCrouch_Result(false);
			PlayerOwner.SetCollisionSize(PlayerOwner.CollisionRadius, DesiredCollisionHeight);
			PlayerOwner.Move(Offset);
		}
		else
			PlayerOwner.SetCollisionSize(PlayerOwner.CollisionRadius, DesiredCollisionHeight, true);
	}
	else
	{
		// Reset CollisionHeight and Location
		DesiredCollisionHeight = NormalCollisionHeight();
		if (PlayerOwner.CollisionHeight >= DesiredCollisionHeight)
		{
			PlayerOwner.bIsReducedCrouch = bCrouching;
			return SetCrouch_Result(true);
		}
		if (!PlayerCanUncrouch(Offset))
			return SetCrouch_Result(false);

		MovePlayer(Offset);
		SetPlayerCollisionHeight(DesiredCollisionHeight);

		if (!bCanDelayForcedUncrouching)
			PlayerOwner.bDuck = 0; // avoid immediate attempts to crouch again
	}

	PlayerOwner.bIsReducedCrouch = bCrouching;

	if (!PlayerOwner.bUpdatePosition)
	{
		PlayerOwner.EyeHeight -= Offset.Z;
		MaxEyeHeightModifier = FMax(MaxEyeHeightModifier, -Offset.Z);
		MovePrePivotZ(-Offset.Z);
		UpdateCarriedDecoration();
	}

	Enable('Tick');

	return SetCrouch_Result(true);
}

final simulated function bool SetCrouch_Result(bool bResult)
{
	--SetCrouchCallsCount;
	return bResult;
}

simulated function MovePlayer(vector Offset)
{
	local vector DstLocation;
	local bool bOldBlockActors, bOldBlockPlayers, bOldCollideWorld;

	if (!bool(Offset))
		return;
	DstLocation = PlayerOwner.Location + Offset;
	PlayerOwner.Move(Offset);
	if (VSize(PlayerOwner.Location - DstLocation) > 0.5)
	{
		bOldBlockActors = PlayerOwner.bBlockActors;
		bOldBlockPlayers = PlayerOwner.bBlockPlayers;
		bOldCollideWorld = PlayerOwner.bCollideWorld;
		PlayerOwner.SetCollision(PlayerOwner.bCollideActors, false, false);
		PlayerOwner.bCollideWorld = false;

		PlayerOwner.Move(DstLocation - PlayerOwner.Location);

		PlayerOwner.SetCollision(PlayerOwner.bCollideActors, bOldBlockActors, bOldBlockPlayers);
		PlayerOwner.bCollideWorld = bOldCollideWorld;
	}
}

simulated function SetPlayerCollisionHeight(float NewCollisionHeight)
{
	local bool bOldBlockActors, bOldBlockPlayers, bOldCollideWorld;

	PlayerOwner.SetCollisionSize(PlayerOwner.CollisionRadius, NewCollisionHeight, true);

	if (PlayerOwner.CollisionHeight != NewCollisionHeight)
	{
		bOldBlockActors = PlayerOwner.bBlockActors;
		bOldBlockPlayers = PlayerOwner.bBlockPlayers;
		bOldCollideWorld = PlayerOwner.bCollideWorld;
		PlayerOwner.SetCollision(PlayerOwner.bCollideActors, false, false);
		PlayerOwner.bCollideWorld = false;

		PlayerOwner.SetCollisionSize(PlayerOwner.CollisionRadius, NewCollisionHeight, true);

		PlayerOwner.SetCollision(PlayerOwner.bCollideActors, bOldBlockActors, bOldBlockPlayers);
		PlayerOwner.bCollideWorld = bOldCollideWorld;
	}
}

simulated function bool PlayerCanUncrouch(optional out vector Offset)
{
	local vector Shift;

	Shift.Z = NormalCollisionHeight() - PlayerOwner.CollisionHeight;
	Offset = vect(0, 0, 0);

	if (PlayerOwner.CollisionHeight >= NormalCollisionHeight())
		return true;
	if (!PlayerOwner.bCollideActors && !PlayerOwner.bCollideWorld)
		return true;

	if (PlayerOwner.Physics == PHYS_Walking)
	{
		Offset.Z = Shift.Z;
		if( PlayerCanMoveBy(Shift) )
		{
			Offset.Z = Shift.Z;
			return true;
		}
	}
	else
	{
		if( PlayerCanMoveBy(-Shift) )
		{
			Offset.Z = -Shift.Z;
			return true;
		}
		if( PlayerCanMoveBy(Shift) )
		{
			Offset.Z = Shift.Z;
			return true;
		}
	}
	
	// Fallback to find spot.
	Offset = PlayerOwner.Location;
	if( PlayerOwner.FindSpot(Offset,,Construct<vector>(PlayerOwner.CollisionRadius,PlayerOwner.CollisionRadius,NormalCollisionHeight())) )
	{
		Offset-=PlayerOwner.Location;
		return true;
	}
	return false;
}

simulated function ClientAdjustCrouch()
{
	local float DesiredCollisionHeight;

	if (PlayerOwner.bIsReducedCrouch)
	{
		DesiredCollisionHeight = ReducedCollisionHeight();
		if (PlayerOwner.CollisionHeight > DesiredCollisionHeight)
			PlayerOwner.SetCollisionSize(PlayerOwner.CollisionRadius, DesiredCollisionHeight);
	}
	else
	{
		DesiredCollisionHeight = NormalCollisionHeight();
		if (PlayerOwner.CollisionHeight < DesiredCollisionHeight)
			PlayerOwner.SetCollisionSize(PlayerOwner.CollisionRadius, DesiredCollisionHeight);
	}
	PlayerOwner.PrePivot.Z = PrePivotZ;
}

// called from PlayerPawn.Landed
simulated function HandleLanding()
{
	if (!PlayerOwner.bUpdatePosition && PlayerOwner.bIsReducedCrouch && PlayerOwner.IsInState('PlayerWalking'))
		PlayerOwner.PlayDuck();
}

// called from PlayerMove in states PlayerSwimming & CheatFlying
simulated function HandleVerticalMovement(float aUp)
{
	if (bCanCrouchWhenSwimming && PlayerOwner.Physics == PHYS_Swimming ||
		bCanCrouchWhenFlying && (PlayerOwner.Physics == PHYS_Flying || PlayerOwner.IsInState('CheatFlying')))
	{
		PlayerOwner.bPressedJump = aUp > 0 && PlayerIsBlockedByCeiling();
	}
}

// called from PlayerPawn.FeignDeath.Rise
simulated function HandleRising()
{
	PlayerOwner.Enable('AnimEnd');
	PlayerOwner.bRising = true;
	if (PlayerOwner.bDuck == 0 && SetCrouch(false))
	{
		PlayerOwner.BaseEyeHeight = PlayerOwner.default.BaseEyeHeight;
		PlayerOwner.PlayRising();
	}
	else
	{
		PlayerOwner.PlayDuck();
		PlayerOwner.BaseEyeHeight = PlayerOwner.default.BaseEyeHeight;
	}
}

simulated function UpdateAirCrouch()
{
	if (!PlayerOwner.bIsCrouching)
	{
		if (bSupportsCrouchJump && PlayerOwner.bDuck != 0 && SetCrouch(true) && PlayerOwner.IsInState('PlayerWalking'))
		{
			PlayerOwner.bIsCrouching = true;
			if (!PlayerOwner.bUpdatePosition)
				PlayerOwner.PlayDuck();
		}
	}
	else if ((PlayerOwner.bDuck == 0 || !bSupportsCrouchJump && !bCanDelayForcedUncrouching) && SetCrouch(false))
	{
		PlayerOwner.bIsCrouching = false;
		if (!PlayerOwner.bUpdatePosition && PlayerOwner.IsInState('PlayerWalking'))
			PlayerOwner.PlayInAir();
	}
}

simulated function UpdateUnderwaterCrouch()
{
	UpdateCrouch();
}

simulated function bool UpdateCrouch()
{
	if (PlayerOwner.bIsReducedCrouch != PlayerShouldBeCrouching())
		SetCrouch(!PlayerOwner.bIsReducedCrouch);
	return PlayerOwner.bIsReducedCrouch;
}

simulated function bool UpdateMaxEyeHeightModifier(float DeltaTime)
{
	MaxEyeHeightModifier = FMax(0, MaxEyeHeightModifier - (DeltaTime * 30.f));
	return (MaxEyeHeightModifier>0);
}

simulated function MovePrePivotZ(float OffsetZ)
{
	local float ShiftZ;

	PlayerOwner.PrePivot.Z += OffsetZ;

	ShiftZ = NormalCollisionHeight() - ReducedCollisionHeight();
	PrePivotZ = FClamp(
		PrePivotZ + OffsetZ,
		FMin(PrePivotZ, PlayerOwner.NormalPrePivotZ() - ShiftZ),
		FMax(PrePivotZ, PlayerOwner.NormalPrePivotZ() + ShiftZ));
}

simulated function bool UpdatePrePivotZ(float DeltaTime)
{
	local float DesiredPrePivotZ, ShiftZ;

	DesiredPrePivotZ = PlayerOwner.CalcDesiredPrePivotZ();
	ShiftZ = NormalCollisionHeight() - ReducedCollisionHeight();

	ShiftZ *= DeltaTime / 0.2;

	if (PrePivotZ < DesiredPrePivotZ)
		PrePivotZ = FMin(DesiredPrePivotZ, PrePivotZ + ShiftZ);
	else
		PrePivotZ = FMax(DesiredPrePivotZ, PrePivotZ - ShiftZ);
	PlayerOwner.PrePivot.Z = PrePivotZ;
	
	return (PlayerOwner.bIsReducedCrouch || (PrePivotZ!=DesiredPrePivotZ));
}

simulated function bool UpdateCarriedDecoration()
{
	local vector DesiredLocation;

	if (PlayerOwner.CarriedDecoration == none)
		return false;

	DesiredLocation = PlayerOwner.GrabbedDecorationPos(PlayerOwner.CarriedDecoration);

	if (PlayerOwner.CarriedDecoration.Location == DesiredLocation)
		return false;
	if (!PlayerOwner.CarriedDecoration.SetLocation(DesiredLocation) && Level.NetMode != NM_Client)
		PlayerOwner.DropDecoration();
	return true;
}

simulated function bool PlayerShouldBeCrouching()
{
	return
		PlayerOwner.DesiredCrouch() ||
		bCanDelayForcedUncrouching && PlayerOwner.bIsReducedCrouch && PlayerOwner.bDuck != 0;
}

simulated function bool PlayerShouldCrouchToCeiling()
{
	return bCanCrouchToCeiling && PlayerOwner.bPressedJump && PlayerIsBlockedByCeiling();
}

simulated function bool PlayerIsBlockedByCeiling()
{
	if ((!PlayerOwner.bCollideActors && !PlayerOwner.bCollideWorld) || !PlayerOwner.bIsReducedCrouch)
		return false;

	return !PlayerCanMoveBy((NormalCollisionHeight()-PlayerOwner.CollisionHeight) * vect(0, 0, 1));
}

simulated function float NormalCollisionHeight()
{
	return PlayerOwner.NormalCollisionHeight();
}

simulated function float ReducedCollisionHeight()
{
	return NormalCollisionHeight() * CrouchHeightPct();
}

simulated function float CrouchHeightPct()
{
	return FClamp(PlayerOwner.CrouchHeightPct, 0.5, 1.0);
}

simulated function float CalcDesiredEyeHeight()
{
	if (PlayerOwner.bIsReducedCrouch && PlayerOwner.IsInState('PlayerWalking'))
		PlayerOwner.BaseEyeHeight = PlayerOwner.default.BaseEyeHeight;

	return FMin(
		PlayerOwner.BaseEyeHeight * (PlayerOwner.DrawScale / PlayerOwner.default.DrawScale),
		FMax(PlayerOwner.BaseEyeHeight, PlayerOwner.default.BaseEyeHeight) * (PlayerOwner.CollisionHeight / PlayerOwner.default.CollisionHeight));
}

simulated function vector GrabbedDecorationOffset(Decoration Decoration)
{
	return (PlayerOwner.EyeHeight - PlayerOwner.default.BaseEyeHeight) * vect(0, 0, 1);
}

simulated function bool IsHeadShot(vector HitLocation, vector TraceDir)
{
	if (bNoHeadShotWhenCrouching && PlayerOwner.bIsReducedCrouch)
		return false;
	return PlayerOwner.DefIsHeadShot(HitLocation, TraceDir);
}

simulated function bool PlayerCanMoveBy(vector Offset /*, optional out vector ResultingOffset*/)
{
	return (PlayerOwner.PointCheck(PlayerOwner.Location+Offset,,,Construct<vector>(PlayerOwner.CollisionRadius,PlayerOwner.CollisionRadius,NormalCollisionHeight()))==None);
	/*local int i;
	local Actor TmpBumpedActor;
	local vector DstLocation, TmpLocation;

	if (!bool(Offset))
	{
		ResultingOffset = Offset;
		return true;
	}

	SetCollision(false, false, false);
	SetCollisionSize(PlayerOwner.CollisionRadius, PlayerOwner.CollisionHeight);
	bCollideWorld = false;
	Move(PlayerOwner.Location - Location);
	if (PlayerOwner.bBlockActors)
		SetCollision(true, false, false);
	bCollideWorld = PlayerOwner.bCollideWorld;

	bIsBlocked = false;
	BumpedActor = none;

	// Checking if the player would hit non-Brush actors, Brush actors, or the level geometry
	Move(Offset);
	if (bIsBlocked)
	{
		SetCollision(false, false, false);
		bCollideWorld = false;
		ResultingOffset = vect(0, 0, 0); // rough, but fast
		return false;
	}

	DstLocation = PlayerOwner.Location + Offset;

	while (
		VSize(Location - DstLocation) > 0.1 &&
		BumpedActor != none &&
		BumpedActor.bCollideActors &&
		!BumpedActor.bBlockPlayers &&
		i < 16)
	{
		TmpLocation = Location;
		TmpBumpedActor = BumpedActor;
		TmpBumpedActor.SetCollision(false, TmpBumpedActor.bBlockActors, false);
		Move(DstLocation - Location);
		TmpBumpedActor.SetCollision(true, TmpBumpedActor.bBlockActors, false);

		if (bIsBlocked)
		{
			SetCollision(false, false, false);
			bCollideWorld = false;
			ResultingOffset = TmpLocation - PlayerOwner.Location; // rough, but fast
			return false;
		}

		BumpedActor = none;
		++i;
	}

	SetCollision(false, false, false);
	bCollideWorld = false;
	if (VSize(Location - DstLocation) > 0.1)
	{
		ResultingOffset = Location - PlayerOwner.Location;
		return false;
	}
	ResultingOffset = Offset;
	return true;*/
}

// -----------------------------------------------------------------------------
// Internals:

/*simulated event Touch(Actor A)
{
	// see AActor::IsBlockedBy
	if (bIsBlocked || !A.bBlockPlayers || Owner == none)
		return;
	if (PlayerPawn(A) != none || Projectile(A) != none)
	{
		if (Owner.bBlockPlayers)
			bIsBlocked = true;
	}
	else if (Owner.bBlockActors)
		bIsBlocked = true;
}

simulated event Bump(Actor A)
{
	BumpedActor = A;
}*/

event FellOutOfWorld();

defaultproperties
{
	bSupportsRealCrouching=true
	bCanCrouchWhenSwimming=True
	bCanCrouchWhenFlying=True
	bCanCrouchToCeiling=True
	bCanDelayForcedUncrouching=True
	bNoHeadShotWhenCrouching=True
	bSkipActorReplication=true
	NetUpdateFrequency=5
	bNetNotify=True
	//CollisionRadius=0
	//CollisionHeight=0
	RemoteRole=ROLE_None
}