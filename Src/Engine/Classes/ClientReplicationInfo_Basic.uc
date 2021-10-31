class ClientReplicationInfo_Basic expands ClientReplicationInfo
	abstract;

static function class<ClientReplicationInfo> GetImplementationClass(PlayerPawn Player)
{
	if (Player.GetNegotiatedVersion() >= 227 &&
		(Player.GetClientSubVersion() >= 10 || Player.GetNegotiatedVersion() > 227 && Player.GetNegotiatedVersion() < 400))
	{
		return class'ClientReplicationInfo_Basic1';
	}
	return none;
}
