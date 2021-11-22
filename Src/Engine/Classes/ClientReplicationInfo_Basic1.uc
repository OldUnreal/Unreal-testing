// ClientReplicationInfo_Basic1 - implementation of interface ClientReplicationInfo_Basic - version 1
//
// WARNING: This class may be removed in future versions of the game, it shall not be referenced by any mods.
//
// In case if a newer version of the game needs an additional variable in PlayerPositionInfo,
// such a variable should be added in a similar struct inside a new class - ClientReplicationInfo_Basic2
// derived directly from ClientReplicationInfo_Basic (this may imply copy-pasting the whole class implementation)
// in order to maintain interoperability with older versions.
//
class ClientReplicationInfo_Basic1 expands ClientReplicationInfo_Basic
	nousercreate;

var struct PlayerPositionInfo
{
	var float TimeStamp;
	var name StateName;
	var class<CustomPlayerStateInfo> CustomPlayerState;
	var EPhysics Physics;
	var float LocX, LocY, LocZ;
	var float VelX, VelY, VelZ;
	var Actor Base;
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
	local vector Loc;

	if (ClientTimeStamp < PositionInfo.TimeStamp)
		return;

	PlayerOwner = PlayerPawn(Owner);

	PositionInfo.TimeStamp = ClientTimeStamp;
	PositionInfo.StateName = PlayerOwner.DesiredClientState();
	PositionInfo.CustomPlayerState = none;
	if (PlayerOwner.CustomPlayerStateInfo != none && PlayerOwner.IsInState('CustomPlayerState'))
		PositionInfo.CustomPlayerState = PlayerOwner.CustomPlayerStateInfo.Class;
	PositionInfo.Physics = PlayerOwner.Physics;

	Loc = PlayerOwner.Location;
	if (Mover(PlayerOwner.Base) != none)
		Loc = (Loc - PlayerOwner.Base.Location) << PlayerOwner.Base.Rotation;
	PositionInfo.LocX = Loc.X;
	PositionInfo.LocY = Loc.Y;
	PositionInfo.LocZ = Loc.Z;

	PositionInfo.VelX = PlayerOwner.Velocity.X;
	PositionInfo.VelY = PlayerOwner.Velocity.Y;
	PositionInfo.VelZ = PlayerOwner.Velocity.Z;

	PositionInfo.Base = PlayerOwner.Base;
	PositionInfo.Flags = int(PlayerOwner.bIsCrouching) | (int(PlayerOwner.bIsReducedCrouch) << 1);
}

simulated function float GetTimeStamp()
{
	return PositionInfo.TimeStamp;
}

simulated function ClientAdjustPosition()
{
	if (PositionInfo.TimeStamp >= PlayerOwner.CurrentTimeStamp)
		PlayerOwner.DefClientAdjustPosition(
			PositionInfo.TimeStamp,
			PositionInfo.StateName,
			PositionInfo.Physics,
			PositionInfo.LocX,
			PositionInfo.LocY,
			PositionInfo.LocZ,
			PositionInfo.VelX,
			PositionInfo.VelY,
			PositionInfo.VelZ,
			PositionInfo.Base);
}

simulated function ClientAdjustCrouch()
{
	PlayerOwner.bIsCrouching = bool(PositionInfo.Flags & 0x1);
	PlayerOwner.bIsReducedCrouch = bool(PositionInfo.Flags & 0x2);
}

simulated function ClientAdjustCustomPlayerState()
{
	if (!PlayerOwner.IsInCustomPlayerState(PositionInfo.CustomPlayerState))
		PlayerOwner.GotoCustomPlayerState(PositionInfo.CustomPlayerState);
}
