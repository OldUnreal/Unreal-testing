class ClientReplicationInfo_Interpolating expands ClientReplicationInfo
	abstract;

static function class<ClientReplicationInfo> GetImplementationClass(PlayerPawn Player)
{
	if (Player.GetNegotiatedVersion() >= 227 &&
		(Player.GetClientSubVersion() >= 10 || Player.GetNegotiatedVersion() > 227 && Player.GetNegotiatedVersion() < 400))
	{
		return class'ClientReplicationInfo_Interpolating1';
	}
	return none;
}
