//=============================================================================
// RepPageConfig.
//=============================================================================
class RepPageConfig extends ModPageContent;

Static function AddModBasedString( WebQuery Query )
{
	StartTable(Query);
	AddConfigEditbox(Query,"Server name",Class'GameReplicationInfo'.Default.ServerName,250,"SN");
	AddConfigEditbox(Query,"Short name",Class'GameReplicationInfo'.Default.ShortName,50,"SH");
	AddConfigEditbox(Query,"Admin name",Class'GameReplicationInfo'.Default.AdminName,50,"AN");
	AddConfigEditbox(Query,"Admin e-mail",Class'GameReplicationInfo'.Default.AdminEmail,50,"AE");
	AddConfigCheckbox(Query,"Show Message Of The Day",Class'GameReplicationInfo'.Default.ShowMOTD,"SM");
	AddConfigEditbox(Query,"MOTD line 1",Class'GameReplicationInfo'.Default.MOTDLine1,150,"M1");
	AddConfigEditbox(Query,"MOTD line 2",Class'GameReplicationInfo'.Default.MOTDLine2,150,"M2");
	AddConfigEditbox(Query,"MOTD line 3",Class'GameReplicationInfo'.Default.MOTDLine3,150,"M3");
	AddConfigEditbox(Query,"MOTD line 4",Class'GameReplicationInfo'.Default.MOTDLine4,150,"M4");
	EndTable(Query);
}

Static function ProcessReceivedData( WebQuery Query )
{
	local string P;

	P = "Set "$string(Class'GameReplicationInfo')$" ";
	Query.Connection.ConsoleCommand(P$"ShowMOTD"@Query.GetValue("SM","0"));
	Query.Connection.ConsoleCommand(P$"ServerName"@Query.GetValue("SN",Class'GameReplicationInfo'.Default.ServerName));
	Query.Connection.ConsoleCommand(P$"ShortName"@Query.GetValue("SH",Class'GameReplicationInfo'.Default.ShortName));
	Query.Connection.ConsoleCommand(P$"AdminName"@Query.GetValue("AN",Class'GameReplicationInfo'.Default.AdminName));
	Query.Connection.ConsoleCommand(P$"AdminEmail"@Query.GetValue("AE",Class'GameReplicationInfo'.Default.AdminEmail));
	Query.Connection.ConsoleCommand(P$"MOTDLine1"@Query.GetValue("M1",Class'GameReplicationInfo'.Default.MOTDLine1));
	Query.Connection.ConsoleCommand(P$"MOTDLine2"@Query.GetValue("M2",Class'GameReplicationInfo'.Default.MOTDLine2));
	Query.Connection.ConsoleCommand(P$"MOTDLine3"@Query.GetValue("M3",Class'GameReplicationInfo'.Default.MOTDLine3));
	Query.Connection.ConsoleCommand(P$"MOTDLine4"@Query.GetValue("M4",Class'GameReplicationInfo'.Default.MOTDLine4));
}

defaultproperties
{
	bNoExtraInfo=True
}