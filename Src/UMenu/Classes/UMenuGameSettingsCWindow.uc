class UMenuGameSettingsCWindow extends UMenuGameSettingsBase;

function LoadCurrentValues()
{
	local int S;

	if (class<DeathMatchGame>(BotmatchParent.GameClass).default.bMegaSpeed)
		StyleCombo.SetSelectedIndex(2);
	else if (class<DeathMatchGame>(BotmatchParent.GameClass).default.bHardcoreMode)
		StyleCombo.SetSelectedIndex(1);
	else
		StyleCombo.SetSelectedIndex(0);

	S = class<DeathMatchGame>(BotmatchParent.GameClass).default.GameSpeed * 100.0;
	SpeedSlider.SetValue(S, true);
	SpeedSlider.SetText(SpeedText $ " [" $ S $ "%]:");
}

function StyleChanged()
{
	local int GameStyleIndex;

	GameStyleIndex = StyleCombo.GetSelectedIndex();

	class<DeathMatchGame>(BotmatchParent.GameClass).default.bMegaSpeed = GameStyleIndex == 2;
	class<DeathMatchGame>(BotmatchParent.GameClass).default.bHardCoreMode = GameStyleIndex == 1 || GameStyleIndex == 2;
}

function SpeedChanged()
{
	local int S;

	S = SpeedSlider.GetValue();
	SpeedSlider.SetText(SpeedText $ " [" $ S $ "%]:");
	class<DeathMatchGame>(BotmatchParent.GameClass).default.GameSpeed = float(S) / 100.0;
}

defaultproperties
{
}
