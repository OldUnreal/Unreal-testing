//=============================================================================
// EntryGameInfo.
//
//=============================================================================
class EntryGameInfo extends UnrealGameInfo
	NoUserCreate;

event PreLogin
(
	string Options,
	out string Error
)
{
	local int RealMax;

	RealMax=MaxPlayers;
	MaxPlayers = 0;
	Super.PreLogin(Options, Error);
	MaxPlayers = RealMax;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local int RealMax;
	local PlayerPawn result;

	RealMax=MaxPlayers;
	MaxPlayers = 0;
	result = Super.Login(Portal, Options, Error, SpawnClass);
	MaxPlayers = RealMax;
	return result;
}

defaultproperties
{
	bLoggingGame=False
}
