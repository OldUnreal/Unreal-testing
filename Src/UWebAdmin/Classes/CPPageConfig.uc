//=============================================================================
// CPPageConfig.
//=============================================================================
class CPPageConfig extends ModPageContent;

Static function AddModBasedString( WebQuery Query )
{
	StartTable(Query);
	AddConfigCheckbox(Query,"No friendly fire",Class'CoopGame'.Default.bNoFriendlyFire,"NF");
	AddConfigCheckbox(Query,"Instant weapon respawn",Class'CoopGame'.Default.bInstantWeaponRespawn,"IW");
	AddConfigCheckbox(Query,"Instant item respawn",Class'CoopGame'.Default.bInstantItemRespawn,"II");
	AddConfigCheckbox(Query,"Custom flare & seed respawn time",Class'CoopGame'.Default.bHighFlareAndSeedRespawn,"CF");
	AddConfigEditbox(Query,"Flare & seed respawn time",string(Class'CoopGame'.Default.FlareAndSeedRespawnTime),20,"FF");
	EndTable(Query);
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string P;

	P = "Set "$string(Class'CoopGame')$" ";
	Query.Connection.ConsoleCommand(P$"bNoFriendlyFire"@Query.GetValue("NF","0"));
	Query.Connection.ConsoleCommand(P$"bInstantWeaponRespawn"@Query.GetValue("IW","0"));
	Query.Connection.ConsoleCommand(P$"bInstantItemRespawn"@Query.GetValue("II","0"));
	Query.Connection.ConsoleCommand(P$"bHighFlareAndSeedRespawn"@Query.GetValue("CF","0"));
	Query.Connection.ConsoleCommand(P$"FlareAndSeedRespawnTime"@Query.GetValue("FF",string(Class'CoopGame'.Default.FlareAndSeedRespawnTime)));
}

defaultproperties
{
	PageName="Cooperative Game"
}
