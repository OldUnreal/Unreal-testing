//=============================================================================
// TDMPageConfig.
//=============================================================================
class TDMPageConfig extends ModPageContent;

Static function AddModBasedString( WebQuery Query )
{
	StartTable(Query);
	AddConfigEditbox(Query,"Friendly fire scale",string(Class'TeamGame'.Default.FriendlyFireScale),20,"FF");
	AddConfigEditbox(Query,"Maximum teams allowed (1-16)",string(Class'TeamGame'.Default.MaxTeams),20,"MT");
	AddConfigEditbox(Query,"Goal team score (0 = unlimited)",string(int(Class'TeamGame'.Default.GoalTeamScore)),20,"GT");
	AddConfigEditbox(Query,"Maximum team size",string(Class'TeamGame'.Default.MaxTeamSize),20,"MS");
	AddConfigCheckbox(Query,"Spawn in team area (map specific)",Class'TeamGame'.Default.bSpawnInTeamArea,"TA");
	AddConfigCheckbox(Query,"No team switching",Class'TeamGame'.Default.bNoTeamChanges,"TC");
	EndTable(Query);
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string P;

	P = "Set "$string(Class'TeamGame')$" ";
	Query.Connection.ConsoleCommand(P$"FragLimit"@Query.GetValue("FF",string(Class'TeamGame'.Default.FragLimit)));
	Query.Connection.ConsoleCommand(P$"MaxTeams"@Query.GetValue("MT",string(Class'TeamGame'.Default.MaxTeams)));
	Query.Connection.ConsoleCommand(P$"GoalTeamScore"@Query.GetValue("GT",string(Class'TeamGame'.Default.GoalTeamScore)));
	Query.Connection.ConsoleCommand(P$"MaxTeamSize"@Query.GetValue("MS",string(Class'TeamGame'.Default.MaxTeamSize)));
	Query.Connection.ConsoleCommand(P$"bSpawnInTeamArea"@Query.GetValue("TA","0"));
	Query.Connection.ConsoleCommand(P$"bNoTeamChanges"@Query.GetValue("TC","0"));
}

defaultproperties
{
	PageName="Team DeathMatch"
}
