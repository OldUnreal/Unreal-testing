class UMenuGameRulesCWindow extends UMenuGameRulesBase;

function LoadCurrentValues()
{
	if( Class<DeathMatchGame>(BotmatchParent.GameClass) )
	{
		if (FragEdit)
			FragEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.FragLimit));
		if (TimeEdit)
			TimeEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.TimeLimit));
	}
	if (MaxPlayersEdit)
		MaxPlayersEdit.SetValue(string(BotmatchParent.GameClass.Default.MaxPlayers));
	if (MaxSpectatorsEdit)
		MaxSpectatorsEdit.SetValue(string(BotmatchParent.GameClass.Default.MaxSpectators));

	WeaponsCheck.bChecked = BotmatchParent.GameClass.Default.bCoopWeaponMode;
	HumansOnlyCheck.bChecked = BotmatchParent.GameClass.Default.bHumansOnly;
}


function FragChanged()
{
	if( Class<DeathMatchGame>(BotmatchParent.GameClass) )
		Class<DeathMatchGame>(BotmatchParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

function TimeChanged()
{
	if( Class<DeathMatchGame>(BotmatchParent.GameClass) )
		Class<DeathMatchGame>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

function MaxPlayersChanged()
{
	if (int(MaxPlayersEdit.GetValue()) > 64)
		MaxPlayersEdit.SetValue("64");

	if (int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	BotmatchParent.GameClass.Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if (int(MaxSpectatorsEdit.GetValue()) > 64)
		MaxSpectatorsEdit.SetValue("64");

	if (int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	BotmatchParent.GameClass.Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

function WeaponsChecked()
{
	BotmatchParent.GameClass.Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}

function HumansOnlyChecked()
{
	BotmatchParent.GameClass.Default.bHumansOnly = HumansOnlyCheck.bChecked;
}

defaultproperties
{
}
