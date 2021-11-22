// ClientReplicationInfo_Interpolating1 - implementation of interface ClientReplicationInfo_Interpolating - version 1
//
// WARNING: This class may be removed in future versions of the game, it shall not be referenced by any mods.
//
// In case if a newer version of the game needs an additional variable in PlayerPositionInfo,
// such a variable should be added in a similar struct inside a new class - ClientReplicationInfo_Interpolating2
// derived directly from ClientReplicationInfo_Interpolating (this may imply copy-pasting the whole class implementation)
// in order to maintain interoperability with older versions.
//
class ClientReplicationInfo_Interpolating1 expands ClientReplicationInfo_Interpolating
	nousercreate;

var struct PlayerPositionInfo
{
	var float TimeStamp;
	var name StateName;
	var float PhysRate, PhysAlpha;
	var Actor Target;
	var byte Flags;
} PositionInfo;


replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		PositionInfo;
}

event BeginPlay()
{
	PositionInfo.TimeStamp = -1;
}

function SynchronizeFrom(float ClientTimeStamp)
{
	if (ClientTimeStamp < PositionInfo.TimeStamp)
		return;

	PlayerOwner = PlayerPawn(Owner);

	PositionInfo.TimeStamp = ClientTimeStamp;
	PositionInfo.StateName = PlayerOwner.DesiredClientState();

	PositionInfo.PhysRate = PlayerOwner.PhysRate;
	PositionInfo.PhysAlpha = PlayerOwner.PhysAlpha;

	PositionInfo.Target = PlayerOwner.Target;
	PositionInfo.Flags = int(PlayerOwner.bIsReducedCrouch) << 1;
}

simulated function float GetTimeStamp()
{
	return PositionInfo.TimeStamp;
}

simulated function ClientAdjustPosition()
{
	if (PositionInfo.TimeStamp < PlayerOwner.CurrentTimeStamp)
		return;
	PlayerOwner.CurrentTimeStamp = PositionInfo.TimeStamp;

	if (PlayerOwner.GetStateName() != PositionInfo.StateName)
		PlayerOwner.GotoState(PositionInfo.StateName);

	if (PlayerOwner.IsInState('PlayerInterpolate') && PositionInfo.Target != none)
	{
		PlayerOwner.Target = PositionInfo.Target;
		PlayerOwner.PhysRate = PositionInfo.PhysRate;
		PlayerOwner.PhysAlpha = PositionInfo.PhysAlpha;
		if (PlayerOwner.Physics != PHYS_Interpolating)
			PlayerOwner.SetPhysics(PHYS_Interpolating);
		PlayerOwner.bInterpolating = true;

		PlayerOwner.ResetDodgeMove();
		ClientAdjustCrouch();
		PlayerOwner.ClientAdjustMovement();
	}
}

simulated function ClientAdjustCrouch()
{
	PlayerOwner.bIsCrouching = false;
	PlayerOwner.bIsReducedCrouch = bool(PositionInfo.Flags & 0x2);
}
