class ClientReplicationInfo expands Info
	abstract;

var class<ClientReplicationInfo> CustomImplementationClass;

var PlayerPawn PlayerOwner;

simulated event PostNetReceive()
{
	PlayerOwner = PlayerPawn(Owner);
	if (PlayerOwner != none && bNetOwner)
	{
		PlayerOwner.ClientReplicationInfo = self;
		ClientAdjustPosition();
	}
}

static function ClientReplicationInfo MakeInstance(PlayerPawn Player)
{
	local class<ClientReplicationInfo> ImplementationClass;

	if (default.CustomImplementationClass != none)
		return Player.Spawn(default.CustomImplementationClass, Player);

	ImplementationClass = GetImplementationClass(Player);
	if (ImplementationClass != none)
		return Player.Spawn(ImplementationClass, Player);

	return none;
}

// Shall return either an implementation class compatible with the player's client or none
static function class<ClientReplicationInfo> GetImplementationClass(PlayerPawn Player);

function SynchronizeFrom(float ClientTimeStamp);
simulated function float GetTimeStamp();
simulated function ClientAdjustPosition();
simulated function ClientAdjustCrouch();
simulated function ClientAdjustCustomPlayerState();

defaultproperties
{
	bNetNotify=True
	NetPriority=8
	NetUpdateFrequency=120
	RemoteRole=ROLE_SimulatedProxy
	bOnlyOwnerRelevant=true
}
