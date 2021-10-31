//=============================================================================
// DMPageConfig.
//=============================================================================
class DMPageConfig extends ModPageContent;

Static function AddModBasedString( WebQuery Query )
{
	StartTable(Query);
	AddConfigEditbox(Query,"Frag Limit",string(Class'DeathMatchGame'.Default.FragLimit),20,"FL");
	AddConfigEditbox(Query,"Time Limit",string(Class'DeathMatchGame'.Default.TimeLimit),20,"TL");
	AddConfigEditbox(Query,"Initial Bots",string(Class'DeathMatchGame'.Default.InitialBots),20,"IB");
	AddConfigCheckbox(Query,"Multiplayer bots",Class'DeathMatchGame'.Default.bMultiPlayerBots,"MB");
	AddConfigCheckbox(Query,"Change levels",Class'DeathMatchGame'.Default.bChangeLevels,"SL");
	AddConfigCheckbox(Query,"Hardcore mode",Class'DeathMatchGame'.Default.bHardCoreMode,"HC");
	AddConfigCheckbox(Query,"Mega speed",Class'DeathMatchGame'.Default.bMegaSpeed,"MS");
	EndTable(Query);
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string P;

	P = "Set "$string(Class'DeathMatchGame')$" ";
	Query.Connection.ConsoleCommand(P$"FragLimit"@Query.GetValue("FL",string(Class'DeathMatchGame'.Default.FragLimit)));
	Query.Connection.ConsoleCommand(P$"TimeLimit"@Query.GetValue("TL",string(Class'DeathMatchGame'.Default.TimeLimit)));
	Query.Connection.ConsoleCommand(P$"InitialBots"@Query.GetValue("IB",string(Class'DeathMatchGame'.Default.InitialBots)));
	Query.Connection.ConsoleCommand(P$"bMultiPlayerBots"@Query.GetValue("MB","0"));
	Query.Connection.ConsoleCommand(P$"bChangeLevels"@Query.GetValue("SL","0"));
	Query.Connection.ConsoleCommand(P$"bHardCoreMode"@Query.GetValue("HC","0"));
	Query.Connection.ConsoleCommand(P$"bMegaSpeed"@Query.GetValue("MS","0"));
}

defaultproperties
{
	PageName="DeathMatch Game"
}
