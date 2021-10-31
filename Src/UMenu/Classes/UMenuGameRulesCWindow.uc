class UMenuGameRulesCWindow extends UMenuGameRulesBase;

function LoadCurrentValues()
{
	if (FragEdit != None)
		FragEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.FragLimit));

	if (TimeEdit != None)
		TimeEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.TimeLimit));

	if (MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.MaxPlayers));

	if (MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.MaxSpectators));

	WeaponsCheck.bChecked = BotmatchParent.GameClass.Default.bCoopWeaponMode;
	HumansOnlyCheck.bChecked = BotmatchParent.GameClass.Default.bHumansOnly;
}


function FragChanged()
{
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

function TimeChanged()
{
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

function MaxPlayersChanged()
{
	if (int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");

	if (int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	BotmatchParent.GameClass.Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if (int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");

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
